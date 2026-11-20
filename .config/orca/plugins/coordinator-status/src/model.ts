// What a coordinator is really doing, worked out from its Orca status and its Runs.
// Orca's own status only sees Claude Code's turn: a coordinator that hands work to workers ends
// its turn and shows "done" while the Run is still going. This module adds the Run back in.
// Pure: no Orca calls, so every rule is tested in model.test.ts.

/** Orca's status of one agent; `unknown` until Orca has reported it. */
export type AgentState = 'working' | 'blocked' | 'waiting' | 'done' | 'unknown'

/** What the coordinator is doing, most urgent first. */
export type CoordinatorState = 'needs-you' | 'stalled' | 'working' | 'waiting-on-workers' | 'done'

export const SEVERITY: Record<CoordinatorState, number> = {
  'needs-you': 4, stalled: 3, working: 2, 'waiting-on-workers': 1, done: 0
}

export type RawTask = { id: string; title: string; status: string }
export type RawGate = { id: string; taskId: string; status: string; question: string; options: string[] }
/** `live`: Orca's liveness verdict (only a live worker can wait on a person).
 *  `open`: its terminal is still open in Orca, whatever the task's state. */
export type RawWorker = { taskId: string; terminal: string | null; needsYou: boolean; live: boolean; open?: boolean }
export type RawRun = {
  id: string
  objective: string
  coordinator: string
  /** Orca never moves a Run's updated_at past its creation, so this is when it was made. */
  updatedAt: number
  /** The coordinator terminal is bound to this Run right now (`run-current`). */
  current?: boolean
  tasks: RawTask[]
  gates: RawGate[]
  workers: RawWorker[]
}

/** What a pending gate needs for the panel to answer it. */
export type GateRef = { runId: string; gateId: string; taskId: string; coordinator: string; question: string; options: string[] }
export type Attention = { key: string; kind: 'gate' | 'worker' | 'coordinator'; text: string; terminal: string | null; gate?: GateRef }
export type Counts = { working: number; queued: number; blocked: number; failed: number; done: number; total: number }
export type TaskState = 'working' | 'blocked' | 'failed' | 'queued' | 'done'
/** One task as the panel lists it; `terminal` is its live worker, when it has one. */
export type TaskLine = { id: string; title: string; state: TaskState; terminal: string | null; gated: boolean }  // terminal: its worker's open session
export type RunSummary = { id: string; title: string; counts: Counts; attention: Attention[]; finished: boolean; tasks: TaskLine[] }

/** What matters now comes first. */
const TASK_ORDER: readonly TaskState[] = ['working', 'blocked', 'failed', 'queued', 'done']
const taskState = (status: string): TaskState => status === 'completed' ? 'done' : status === 'failed' ? 'failed'
  : status === 'blocked' ? 'blocked' : status === 'dispatched' ? 'working' : 'queued'
export type CoordinatorView = {
  handle: string
  title: string
  agent: AgentState
  state: CoordinatorState
  /** One line saying why it is in that state. */
  detail: string
  runs: RunSummary[]
  attention: Attention[]
}

/** A Run whose tasks are all settled stays on show this long, then it is history. */
export const FINISHED_RUN_TTL_MS = 12 * 60 * 60 * 1000
/** After a worker reports, Orca takes a moment to wake the coordinator: open tasks with nothing
 *  running only count as stalled once the coordinator has been idle this long. */
export const STALL_GRACE_MS = 90 * 1000
const MAX_TITLE = 100

const FINAL = new Set(['completed', 'failed'])

/** Objectives are free text, often long or a Markdown heading: one bounded line. */
export function shortTitle(value: string): string {
  const line = (value.split('\n').find(part => part.trim()) ?? '').replace(/^\s*#+\s*/, '').replace(/\s+/g, ' ').trim()
  return line.length > MAX_TITLE ? `${line.slice(0, MAX_TITLE - 1).trimEnd()}…` : line
}

export function summarizeRun(run: RawRun): RunSummary {
  const counts: Counts = { working: 0, queued: 0, blocked: 0, failed: 0, done: 0, total: run.tasks.length }
  for (const task of run.tasks) {
    if (task.status === 'completed') counts.done++
    else if (task.status === 'failed') counts.failed++
    else if (task.status === 'blocked') counts.blocked++
    else if (task.status === 'dispatched') counts.working++
    else counts.queued++
  }
  const titles = new Map(run.tasks.map(task => [task.id, task.title]))
  const attention: Attention[] = [
    ...run.gates.filter(gate => gate.status === 'pending').map((gate): Attention => ({
      key: gate.id, kind: 'gate', text: shortTitle(gate.question) || titles.get(gate.taskId) || gate.id, terminal: run.coordinator,
      gate: { runId: run.id, gateId: gate.id, taskId: gate.taskId, coordinator: run.coordinator, question: gate.question, options: gate.options }
    })),
    // Orca's attention flag also marks dead workers, which is the coordinator's business:
    // only a live worker can be waiting for a person.
    ...run.workers.filter(worker => worker.needsYou && worker.live && worker.terminal).map((worker): Attention => ({
      key: `${run.id}:${worker.taskId}`, kind: 'worker',
      text: `Worker waiting: ${shortTitle(titles.get(worker.taskId) ?? worker.taskId)}`, terminal: worker.terminal
    }))
  ]
  const gated = new Set(run.gates.filter(gate => gate.status === 'pending').map(gate => gate.taskId))
  const lines = run.tasks.map((task): TaskLine => {
    const state = taskState(task.status)
    // The newest dispatch whose session is still open, finished or not, can be opened.
    const worker = run.workers.find(item => item.taskId === task.id && item.terminal && item.open)
    return { id: task.id, title: shortTitle(task.title), state, terminal: worker?.terminal ?? null, gated: gated.has(task.id) }
  })
  return {
    id: run.id, title: shortTitle(run.objective) || run.id, counts, attention,
    tasks: TASK_ORDER.flatMap(state => lines.filter(line => line.state === state)),
    finished: run.tasks.length > 0 && run.tasks.every(task => FINAL.has(task.status))
  }
}

/** Runs worth showing: open ones, the Run a coordinator is bound to right now however old (a
 *  revived coordinator resumes an old Run), and other settled ones from the last 12 hours. */
export function liveRuns(runs: readonly RawRun[], now: number): RawRun[] {
  return runs.filter(run => run.tasks.length > 0 && (run.current ||
    !run.tasks.every(task => FINAL.has(task.status)) || now - run.updatedAt <= FINISHED_RUN_TTL_MS))
}

const plural = (n: number, word: string): string => `${n} ${word}${n === 1 ? '' : 's'}`
const TOOLTIP_MAX = 256
const clip = (value: string, max: number): string => value.length > max ? `${value.slice(0, max - 1).trimEnd()}…` : value

/**
 * The rules, in order:
 * 1. The coordinator itself is asking (permission or a question), or a Run has a pending gate or
 *    a live worker waiting for a person: needs you.
 * 2. Its turn is running: working.
 * 3. Its turn ended but a task is dispatched: waiting on workers (Orca shows "done" here).
 * 4. Its turn ended, nothing is running, yet tasks are still open: stalled, once the grace period
 *    has passed (before that Orca is probably about to wake it).
 * 5. Every task is settled: done.
 */
export function coordinatorView(
  handle: string, runs: readonly RawRun[], agent: AgentState, agentSince: number | null, now: number
): CoordinatorView | null {
  const shown = liveRuns(runs, now).sort((a, b) => Number(!!b.current) - Number(!!a.current) || b.updatedAt - a.updatedAt)
  if (!shown.length) return null
  const summaries = shown.map(summarizeRun)
  const attention = summaries.flatMap(run => run.attention)
  if (agent === 'blocked' || agent === 'waiting') {
    attention.unshift({ key: `${handle}:self`, kind: 'coordinator', text: 'The coordinator is asking you something', terminal: handle })
  }
  const total = summaries.reduce((sum, run) => ({
    working: sum.working + run.counts.working, queued: sum.queued + run.counts.queued,
    blocked: sum.blocked + run.counts.blocked, failed: sum.failed + run.counts.failed,
    done: sum.done + run.counts.done, total: sum.total + run.counts.total
  }), { working: 0, queued: 0, blocked: 0, failed: 0, done: 0, total: 0 })
  const open = total.total - total.done - total.failed

  let state: CoordinatorState
  let detail: string
  if (attention.length) {
    state = 'needs-you'
    // The items themselves are listed under it; the line only counts them.
    detail = `${plural(attention.length, 'thing')} waiting on you`
  } else if (agent === 'working') {
    state = 'working'
    detail = total.working ? `Coordinating · ${plural(total.working, 'worker')} running` : 'Coordinating'
  } else if (total.working) {
    state = 'waiting-on-workers'
    detail = `Waiting on ${plural(total.working, 'worker')}` + (total.queued ? ` · ${total.queued} queued` : '')
  } else if (open) {
    const idleFor = agentSince === null ? Infinity : now - agentSince
    if (idleFor < STALL_GRACE_MS) {
      state = 'waiting-on-workers'
      detail = 'Waking up for the next step'
    } else {
      state = 'stalled'
      detail = `${plural(open, 'task')} open, nothing running`
    }
  } else {
    state = 'done'
    detail = total.failed ? `Finished · ${total.failed} failed` : `Finished · ${plural(total.done, 'task')}`
  }
  const title = summaries[0].title + (summaries.length > 1 ? ` (+${summaries.length - 1} more)` : '')
  return { handle, title, agent, state, detail, runs: summaries, attention }
}

export type StatusBarText = { text: string; tone: 'neutral' | 'accent' | 'success' | 'warning' | 'danger'; tooltip: string; visible: boolean }

/** One status-bar line across every coordinator. */
export function statusBar(views: readonly CoordinatorView[]): StatusBarText {
  if (!views.length) return { text: '', tone: 'neutral', tooltip: '', visible: false }
  const count = (state: CoordinatorState) => views.filter(view => view.state === state).length
  const needs = views.reduce((sum, view) => sum + view.attention.length, 0)
  const stalled = count('stalled')
  const busy = count('working') + count('waiting-on-workers')
  const workers = views.reduce((sum, view) => sum + view.runs.reduce((n, run) => n + run.counts.working, 0), 0)
  const parts: string[] = []
  if (needs) parts.push(`${needs} need${needs === 1 ? 's' : ''} you`)
  if (stalled) parts.push(`${stalled} stalled`)
  if (busy) parts.push(workers ? `${plural(workers, 'worker')} running` : `${busy} coordinating`)
  if (!parts.length) parts.push('all settled')
  const tone = needs ? 'warning' : stalled ? 'danger' : busy ? 'accent' : 'success'
  // Orca refuses a tooltip over 256 characters: one short line per coordinator, cut to fit.
  const lines = views.map(view => `${LABEL[view.state]}: ${clip(view.title, 48)}`)
  return { text: clip(parts.join(' · '), 80), tone, tooltip: clip(lines.join('\n'), TOOLTIP_MAX), visible: true }
}

export const LABEL: Record<CoordinatorState, string> = {
  'needs-you': 'Needs you', stalled: 'Stalled', working: 'Working', 'waiting-on-workers': 'Waiting on workers', done: 'Done'
}

export type Notice = { title: string; body: string }

/**
 * What changed between two reads that a person should hear about: a new thing waiting on them,
 * a coordinator that stalled, and a coordinator whose Runs all finished.
 * Nothing on the first read, so a restart never replays old news.
 */
export function notices(before: readonly CoordinatorView[] | null, after: readonly CoordinatorView[]): Notice[] {
  if (before === null) return []
  const old = new Map(before.map(view => [view.handle, view]))
  const out: Notice[] = []
  for (const view of after) {
    const prev = old.get(view.handle)
    const seen = new Set(prev?.attention.map(item => item.key) ?? [])
    for (const item of view.attention) {
      if (!seen.has(item.key)) out.push({ title: 'Coordinator needs you', body: `${item.text}\n${view.title}` })
    }
    if (view.state === 'stalled' && prev?.state !== 'stalled') {
      out.push({ title: 'Coordinator stalled', body: `${view.detail}\n${view.title}` })
    }
    if (view.state === 'done' && prev && prev.state !== 'done') {
      out.push({ title: 'Run finished', body: `${view.detail}\n${view.title}` })
    }
  }
  return out
}
