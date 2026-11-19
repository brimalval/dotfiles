// The plugin's worker. Orca keeps it running while the plugin is enabled (it owns a status bar
// item), so it polls on its own: every POLL_MS, and soon after any agent changes status.
import type { OrcaWorkerApi } from 'orca/worker'
import type {} from './protocol'
import {
  coordinatorView, notices, SEVERITY, statusBar,
  type AgentState, type CoordinatorView, type StatusBarText
} from './model'
import { focusTerminal, readSnapshot, resolveGate } from './orca-cli'

const POLL_MS = 10_000
/** An agent status change usually means a Run moved: read again shortly after it. */
const EVENT_DEBOUNCE_MS = 1_500
const STATUS_ITEM = 'coordinators'
const AGENT_STATES = new Set(['working', 'blocked', 'waiting', 'done'])

/** Replaceable in tests, so a test never runs the real CLI. */
export const external = { readSnapshot, focusTerminal, resolveGate, now: () => Date.now() }

let timer: ReturnType<typeof setInterval> | null = null
let debounce: ReturnType<typeof setTimeout> | null = null

type Agent = { state: AgentState; since: number | null }

export default function activate(orca: OrcaWorkerApi): void {
  /** Orca's own status per terminal handle, from agents.list and agent.status.changed. */
  const agents = new Map<string, Agent>()
  let views: CoordinatorView[] | null = null
  let readAt: number | null = null
  let shownBar = ''
  let reading: Promise<void> | null = null

  const remember = (terminal: string | null | undefined, state: string, since: number | null) => {
    if (terminal && AGENT_STATES.has(state)) agents.set(terminal, { state: state as AgentState, since })
  }

  orca.events.on('agent.status.changed', (event) => {
    remember(event.terminalId, event.mainAgent?.state ?? event.state, event.mainAgent?.stateStartedAt ?? event.receivedAt)
    if (debounce) clearTimeout(debounce)
    debounce = setTimeout(() => { debounce = null; void refresh() }, EVENT_DEBOUNCE_MS)
  })

  /** Asks Orca for the agents in each coordinator's workspace: truth even before any event. */
  const readAgents = async (workspaceIds: readonly string[]) => {
    await Promise.all(workspaceIds.map(async (workspaceId) => {
      try {
        const answer = await orca.host.call('agents.list', { workspaceId })
        for (const agent of answer.agents) remember(agent.terminalId, agent.state, agent.stateStartedAt)
      } catch { /* an unknown workspace id: events still fill it in */ }
    }))
  }

  const updateBar = async (bar: StatusBarText) => {
    const key = JSON.stringify(bar)
    if (key === shownBar) return
    shownBar = key
    try { await orca.host.call('statusBar.update', { id: STATUS_ITEM, ...bar }) } catch { shownBar = '' }
  }

  const read = async () => {
    const snapshot = await external.readSnapshot()
    if (!snapshot) return // keep what we had; a failed read proves nothing
    const now = external.now()
    const coordinators = [...new Set(snapshot.runs.map(run => run.coordinator))]
    const workspaceIds = [...new Set(snapshot.terminals
      .filter(terminal => coordinators.includes(terminal.handle) && terminal.worktreeId)
      .map(terminal => terminal.worktreeId as string))]
    await readAgents(workspaceIds)
    const next = coordinators
      .map(handle => {
        const agent = agents.get(handle) ?? { state: 'unknown' as const, since: null }
        return coordinatorView(handle, snapshot.runs.filter(run => run.coordinator === handle), agent.state, agent.since, now)
      })
      .filter((view): view is CoordinatorView => view !== null)
      .sort((a, b) => SEVERITY[b.state] - SEVERITY[a.state])
    for (const notice of notices(views, next)) {
      try { await orca.host.call('notifications.show', notice) } catch { /* notifications off: the bar still shows it */ }
    }
    views = next
    readAt = now
    await updateBar(statusBar(next))
    orca.panels.post('status.changed', { views: next, readAt })
  }

  const refresh = (): Promise<void> => {
    if (!reading) reading = read().catch(error => orca.log(`read failed: ${String(error)}`)).finally(() => { reading = null })
    return reading
  }

  /** The terminals the panel was shown, the only ones it may ask to focus. */
  const offered = () => new Set((views ?? []).flatMap(view => [
    view.handle,
    ...view.attention.flatMap(item => item.terminal ? [item.terminal] : []),
    ...view.runs.flatMap(run => run.tasks.flatMap(task => task.terminal ? [task.terminal] : []))
  ]))

  orca.panels.handle('status.get', async () => {
    if (views === null) await refresh()
    return { views: views ?? [], readAt }
  })
  orca.panels.handle('status.refresh', async () => {
    await refresh()
    return { views: views ?? [], readAt }
  })
  orca.panels.handle('status.focus', async ({ terminal }) => {
    if (!offered().has(terminal)) return { ok: false }
    return { ok: await external.focusTerminal(terminal) }
  })

  orca.panels.handle('gate.resolve', async ({ gateId, resolution }) => {
    const answer = resolution.trim()
    if (!answer || answer.length > 500) return { ok: false, error: 'Write an answer of up to 500 characters.' }
    // Only a gate the panel was shown, so a request cannot reach any other Run.
    const gate = (views ?? []).flatMap(view => view.attention).find(item => item.gate?.gateId === gateId)?.gate
    if (!gate) return { ok: false, error: 'That gate is no longer pending. Refresh.' }
    const result = await external.resolveGate(gate, answer)
    await refresh()
    return result
  })

  // Pressing the status bar item: go to whatever needs a person most.
  orca.commands.register('coordinator-status.focus', async () => {
    await refresh()
    const top = (views ?? [])[0]
    if (!top) return 'No coordinator with a live Run.'
    const target = top.attention[0]?.terminal ?? top.handle
    return (await external.focusTerminal(target)) ? undefined : 'Could not switch to that terminal.'
  })

  timer = setInterval(() => { void refresh() }, POLL_MS)
  void refresh()
}

export function deactivate(): void {
  if (timer) clearInterval(timer)
  if (debounce) clearTimeout(debounce)
  timer = debounce = null
}
