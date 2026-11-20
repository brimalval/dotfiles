// Orchestration state is only in Orca's CLI, not the plugin host API, so the worker runs it.
// The approach (bundled CLI next to the worker's own Node, JSON only, every failure = unknown)
// follows matteoeusebi/orca-pulse (MIT).
import { execFile } from 'node:child_process'
import { join } from 'node:path'
import type { RawGate, RawRun, RawTask, RawWorker } from './model'

const COMMAND_TIMEOUT_MS = 5000
const MAX_OUTPUT_BYTES = 8 * 1024 * 1024
/** Newest Runs looked at, and how many are read in full per pass. */
const RUNS_SCANNED = 50
const RUNS_READ = 20

type Json = Record<string, unknown>
const record = (value: unknown): value is Json => typeof value === 'object' && value !== null && !Array.isArray(value)
const text = (value: unknown): string | null => typeof value === 'string' && value.trim() ? value : null
const rows = (value: unknown, key: string): unknown[] => {
  const result = record(value) && record(value.result) ? value.result[key] : null
  return Array.isArray(result) ? result : []
}
const time = (value: unknown): number => typeof value === 'number' ? value : Date.parse(String(value)) || 0

/** The worker runs inside the Orca app bundle; its CLI ships in the same bundle. */
function bundledCli(): string | null {
  const marker = '.app/Contents/'
  const end = process.execPath.indexOf(marker)
  return end < 0 ? null : join(process.execPath.slice(0, end + marker.length), 'Resources', 'bin', 'orca')
}
// Last, whatever `orca` is on PATH (Orca's "Install CLI" puts it there on every platform).
const CANDIDATES = [process.env.ORCA_CLI, bundledCli(), '/Applications/Orca.app/Contents/Resources/bin/orca', 'orca']
  .filter((path): path is string => !!path)

function runJson(command: string, args: string[]): Promise<unknown> {
  return new Promise(resolve => {
    try {
      execFile(command, args, { timeout: COMMAND_TIMEOUT_MS, maxBuffer: MAX_OUTPUT_BYTES, windowsHide: true }, (_error, stdout) => {
        try { resolve(JSON.parse(String(stdout))) } catch { resolve(null) }
      })
    } catch { resolve(null) }
  })
}

let working: string | null = null
/** One CLI call; null when no candidate answers or Orca answers with an error. */
export async function orca(args: string[]): Promise<unknown> {
  for (const command of working ? [working, ...CANDIDATES.filter(item => item !== working)] : CANDIDATES) {
    const answer = await runJson(command, args)
    if (answer === null) continue
    working = command
    return record(answer) && answer.ok === true ? answer : null
  }
  working = null
  return null
}

export type Terminal = { handle: string; worktreeId: string | null; title: string | null; agent?: boolean }

export function parseTerminals(value: unknown): Terminal[] {
  return rows(value, 'terminals').flatMap(item => record(item) && typeof item.handle === 'string'
    ? [{ handle: item.handle, worktreeId: text(item.worktreeId), title: text(item.title), agent: !!text(item.agentIdentity) }] : [])
}

/** The Run a terminal coordinates now (`run-current`), or null for a worker or a plain shell. */
export type Binding = { runId: string; objective: string }
export function parseBinding(value: unknown): Binding | null {
  const result = record(value) && record(value.result) ? value.result : null
  return result && typeof result.runId === 'string' ? { runId: result.runId, objective: text(result.objective) ?? '' } : null
}

type Head = Omit<RawRun, 'tasks' | 'gates' | 'workers'>
/**
 * run-list names whoever created a Run. A coordinator that takes over an old Run (`run-use`, as a
 * revived session does) is only visible through run-current, which is also where Orca sends that
 * Run's messages: bindings win, and a bound Run is marked current.
 */
export function applyBindings(heads: readonly Head[], bindings: ReadonlyMap<string, Binding>): Head[] {
  const byRun = new Map([...bindings].map(([terminal, binding]) => [binding.runId, { terminal, binding }]))
  const result = heads.map(head => {
    const bound = byRun.get(head.id)
    return bound ? { ...head, coordinator: bound.terminal, current: true } : head
  })
  // A Run too old for the run-list window still counts once a coordinator is bound to it.
  for (const [runId, { terminal, binding }] of byRun) {
    if (!heads.some(head => head.id === runId)) result.push({ id: runId, objective: binding.objective, coordinator: terminal, updatedAt: 0, current: true })
  }
  return result
}
export function parseRunHeads(value: unknown): Head[] {
  return rows(value, 'runs').flatMap(item => record(item) && typeof item.id === 'string' && typeof item.coordinator_handle === 'string'
    ? [{ id: item.id, objective: text(item.objective) ?? '', coordinator: item.coordinator_handle,
        updatedAt: Math.max(time(item.created_at), time(item.updated_at)) }] : [])
}
export function parseTasks(value: unknown): RawTask[] {
  return rows(value, 'tasks').flatMap(item => record(item) && typeof item.id === 'string'
    ? [{ id: item.id, title: text(item.title) ?? text(item.task_title) ?? item.id, status: text(item.status) ?? '' }] : [])
}
export function parseGates(value: unknown): RawGate[] {
  return rows(value, 'gates').flatMap(item => record(item) && typeof item.id === 'string'
    ? [{ id: item.id, taskId: text(item.taskId) ?? text(item.task_id) ?? '', status: text(item.status) ?? '',
        question: text(item.question) ?? '', options: parseOptions(item.options) }] : [])
}
/** Orca stores a gate's options as a JSON array, sometimes as its string form. */
export function parseOptions(value: unknown): string[] {
  let list = value
  if (typeof value === 'string') { try { list = JSON.parse(value) } catch { return [] } }
  return Array.isArray(list) ? list.filter((item): item is string => typeof item === 'string' && !!item.trim()).slice(0, 6) : []
}
export function parseWorkers(value: unknown): RawWorker[] {
  return rows(value, 'workers').flatMap(item => {
    if (!record(item) || typeof item.taskId !== 'string') return []
    const projection = record(item.projection) ? item.projection : {}
    const attention = record(projection.attention) && projection.attention.requiresAction === true
    const live = record(projection.liveness) && projection.liveness.verdict === 'live'
    return [{ taskId: item.taskId, terminal: text(item.agentTerminalHandle) ?? text(item.terminal), needsYou: attention, live }]
  })
}

/** Settled Runs already read in full. */
const settled = new Map<string, RawRun>()
const isSettled = (run: RawRun) => run.tasks.length > 0 && run.tasks.every(task => task.status === 'completed' || task.status === 'failed')

/** Orca repo id -> its name in Orca's sidebar. */
export type Repos = Record<string, string>
export function parseRepos(value: unknown): Repos {
  const result: Repos = {}
  for (const item of rows(value, 'repos')) {
    if (record(item) && typeof item.id === 'string') result[item.id] = text(item.displayName) ?? text(item.name) ?? item.id
  }
  return result
}
/** A worktree id is `<repo id>::<path>`: the repo's name, else the folder's. */
export function projectOf(worktreeId: string | null, repos: Repos): string | null {
  if (!worktreeId) return null
  const [repoId, path = ''] = worktreeId.split('::')
  return repos[repoId] ?? (path.split(/[\\/]/).filter(Boolean).pop() || null)
}

export type Snapshot = { terminals: Terminal[]; runs: RawRun[]; repos?: Repos }

/** Bindings change only on run-create or run-use, so each agent terminal is asked at most this often. */
const BINDING_TTL_MS = 30_000
const bindingCache = new Map<string, { binding: Binding | null; at: number }>()
async function readBindings(terminals: readonly Terminal[]): Promise<Map<string, Binding>> {
  const now = Date.now()
  const agents = terminals.filter(terminal => terminal.agent)
  for (const handle of bindingCache.keys()) if (!agents.some(terminal => terminal.handle === handle)) bindingCache.delete(handle)
  await Promise.all(agents.map(async ({ handle }) => {
    const cached = bindingCache.get(handle)
    if (cached && now - cached.at < BINDING_TTL_MS) return
    const answer = await orca(['orchestration', 'run-current', '--from', handle, '--json'])
    // A failed read keeps the last answer rather than dropping the coordinator for a pass.
    if (answer !== null || !cached) bindingCache.set(handle, { binding: parseBinding(answer), at: now })
  }))
  const result = new Map<string, Binding>()
  for (const [handle, { binding }] of bindingCache) if (binding) result.set(handle, binding)
  return result
}

/** Every Run whose coordinator terminal is still open, in full. null when the read failed. */
export async function readSnapshot(): Promise<Snapshot | null> {
  const [terminalsAnswer, runsAnswer, reposAnswer] = await Promise.all([
    orca(['terminal', 'list', '--json']),
    orca(['orchestration', 'run-list', '--limit', String(RUNS_SCANNED), '--json', '--full']),
    orca(['repo', 'list', '--json'])
  ])
  if (terminalsAnswer === null || runsAnswer === null) return null
  const terminals = parseTerminals(terminalsAnswer)
  const open = new Set(terminals.map(terminal => terminal.handle))
  const bindings = await readBindings(terminals)
  const heads = applyBindings(parseRunHeads(runsAnswer), bindings)
    .filter(run => open.has(run.coordinator))
    .sort((a, b) => Number(!!b.current) - Number(!!a.current))
    .slice(0, RUNS_READ)
  const runs = await Promise.all(heads.map(async (head): Promise<RawRun | null> => {
    // Orca never bumps updated_at, so only a Run no coordinator is bound to (nobody adds to it)
    // is served from the cache; the Run being coordinated now is read every pass.
    const cached = head.current ? undefined : settled.get(head.id)
    if (cached) return { ...cached, ...head }
    const [tasks, gates, workers] = await Promise.all([
      orca(['orchestration', 'task-list', '--run', head.id, '--json']),
      orca(['orchestration', 'gate-list', '--run', head.id, '--json']),
      orca(['orchestration', 'worker-list', '--run', head.id, '--limit', '100', '--json', '--full'])
    ])
    // Without its tasks a Run cannot be judged; without gates or workers it still can.
    if (tasks === null) return null
    const run = { ...head, tasks: parseTasks(tasks), gates: parseGates(gates), workers: parseWorkers(workers) }
    if (isSettled(run)) settled.set(run.id, run)
    else settled.delete(run.id)
    return run
  }))
  // Whether a worker's session is open changes after its Run settles, so it is set on every read,
  // cached Runs included.
  const withOpen = runs.filter((run): run is RawRun => run !== null).map(run => ({
    ...run, workers: run.workers.map(worker => ({ ...worker, open: !!worker.terminal && open.has(worker.terminal) }))
  }))
  return { terminals, runs: withOpen, repos: parseRepos(reposAnswer) }
}

export type ResolveResult = { ok: true } | { ok: false; error: string }

/**
 * Answers a pending gate for the person, the way Orca's Orchestra panel does: as the Run's
 * coordinator (`--from`), which closes the gate and unblocks its task. Resolving alone does not
 * wake the coordinator, so a `status` message to the Run's inbox follows; Orca delivers it as a
 * wake, like a worker's report. Works for any agent, since it never relies on the coordinator
 * remembering to resolve gates itself.
 */
export async function resolveGate(gate: { runId: string; gateId: string; taskId: string; coordinator: string; question: string }, resolution: string): Promise<ResolveResult> {
  // Re-read first: never overwrite a decision made since the panel was drawn.
  const current = parseGates(await orca(['orchestration', 'gate-list', '--run', gate.runId, '--json'])).find(item => item.id === gate.gateId)
  if (!current) return { ok: false, error: 'Could not read that gate. Refresh and try again.' }
  if (current.status !== 'pending') return { ok: false, error: 'That gate was already answered.' }
  const resolved = await orca(['orchestration', 'gate-resolve', '--id', gate.gateId, '--resolution', resolution, '--from', gate.coordinator, '--json'])
  if (resolved === null) return { ok: false, error: 'Orca refused to resolve the gate.' }
  settled.delete(gate.runId)
  const body = [
    `The user answered this decision gate from the Coordinators panel. The gate is resolved and its task (${gate.taskId}) is no longer blocked on it.`,
    `Question: ${gate.question}`,
    `Answer: ${resolution}`,
    'Act on the answer now. If the answer says it was already handled, the gate was stale: confirm and move on.'
  ].join('\n')
  const sent = await orca(['orchestration', 'send', '--to', `run:${gate.runId}`, '--from', gate.coordinator, '--type', 'status',
    '--subject', `Gate answered: ${resolution.slice(0, 80)}`, '--body', body, '--task-id', gate.taskId, '--json'])
  // The gate is resolved either way; say so if the coordinator may not have heard.
  return sent === null ? { ok: false, error: 'Gate resolved, but the coordinator could not be messaged. Tell it in chat.' } : { ok: true }
}

/** Shows one terminal tab in Orca. */
export async function focusTerminal(handle: string): Promise<boolean> {
  return (await orca(['terminal', 'switch', '--terminal', handle, '--json'])) !== null
}
