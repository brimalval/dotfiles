// No build step: Orca strips the types and compiles the JSX when the panel loads.
import {
  atom, Badge, Box, Button, Callout, Collapsible, EmptyState, Heading, IconButton, Input, List, ListItem, plugin, Progress,
  read, RelativeTime, Row, set, Stack, Text, update, type PanelContext
} from 'orca'
import type { StatusAnswer } from './protocol'
import { LABEL, type Attention, type CoordinatorState, type CoordinatorView, type GateRef, type RunSummary, type TaskLine, type TaskState } from './model'

const status = atom<StatusAnswer | null>(null)
/** The answer waiting for a second press: a gate is a real decision (a push, a prod merge). */
const confirming = atom<{ gateId: string; resolution: string } | null>(null)
const sending = atom<string | null>(null)
const errors = atom<Record<string, string>>({})
const drafts = atom<Record<string, string>>({})
/** Which runs' task lists are open, by run id; kept across refreshes and panel runs. */
const expanded = atom<Record<string, boolean>>('expanded', {}, { persist: 'plugin' })
const TASK_ICON: Record<TaskState, 'play' | 'flag' | 'error' | 'more' | 'check'> = {
  working: 'play', blocked: 'flag', failed: 'error', queued: 'more', done: 'check'
}
const TASK_LABEL: Record<TaskState, string> = {
  working: 'Running', blocked: 'Blocked', failed: 'Failed', queued: 'Queued', done: 'Done'
}
const ALREADY = 'Already handled in chat; this gate was stale.'

const TONE: Record<CoordinatorState, 'warning' | 'danger' | 'accent' | 'neutral' | 'success'> = {
  'needs-you': 'warning', stalled: 'danger', working: 'accent', 'waiting-on-workers': 'neutral', done: 'success'
}

const focus = (terminal: string) => { void plugin.request('status.focus', { terminal }) }
const refresh = async () => { set(status, await plugin.request('status.refresh')) }

async function send(gateId: string, resolution: string): Promise<void> {
  set(sending, gateId)
  try {
    const result = await plugin.request('gate.resolve', { gateId, resolution })
    update(errors, (all) => {
      const { [gateId]: _old, ...rest } = all
      return result.ok ? rest : { ...rest, [gateId]: result.error ?? 'Could not answer the gate.' }
    })
    if (result.ok) update(drafts, ({ [gateId]: _old, ...rest }) => rest)
  } finally {
    set(sending, null)
    set(confirming, null)
  }
}

function Gate({ item, gate }: { item: Attention; gate: GateRef }) {
  const pending = read(confirming)
  const busy = read(sending) === gate.gateId
  const error = read(errors)[gate.gateId]
  const draft = read(drafts)[gate.gateId] ?? ''
  const ask = (resolution: string) => set(confirming, { gateId: gate.gateId, resolution })
  return (
    <Box border="warning" padding="sm" radius="sm" direction="column" gap="xs">
      <Row justify="between" gap="sm">
        <Text size="sm" weight="medium">{gate.question || item.text}</Text>
        <IconButton icon="terminal" label="Open coordinator" size="sm" variant="ghost" onPress={() => focus(gate.coordinator)} />
      </Row>
      {pending?.gateId === gate.gateId ? (
        <Callout tone="warning" title={pending.resolution === ALREADY ? 'Mark this gate as already handled?' : `Answer “${pending.resolution}”?`}>
          <Text size="xs" muted>Resolves the gate and wakes the coordinator with your answer.</Text>
          <Row gap="xs">
            <Button size="sm" tone="warning" disabled={busy} onPress={() => send(gate.gateId, pending.resolution)}>{busy ? 'Sending…' : 'Send'}</Button>
            <Button size="sm" variant="ghost" disabled={busy} onPress={() => set(confirming, null)}>Cancel</Button>
          </Row>
        </Callout>
      ) : (
        <Stack gap="xs">
          <Row gap="xs" wrap>
            {gate.options.map(option => <Button key={option} size="sm" variant="outline" onPress={() => ask(option)}>{option}</Button>)}
            <Button size="sm" variant="ghost" tooltip="You already answered this in chat" onPress={() => ask(ALREADY)}>Already handled</Button>
          </Row>
          <Input label="Other answer" labelHidden placeholder="Other answer… (Enter)" value={draft}
            onChange={(value) => update(drafts, (all) => ({ ...all, [gate.gateId]: value }))}
            onSubmit={(value) => { if (value.trim()) ask(value.trim()) }} />
        </Stack>
      )}
      {error ? <Text size="xs" tone="danger">{error}</Text> : null}
    </Box>
  )
}

export function setup(ctx: PanelContext): void {
  ctx.subscriptions.push(plugin.on('status.changed', (payload) => set(status, payload)))
  void plugin.request('status.get').then((answer) => set(status, answer))
}

function taskDescription(task: TaskLine): string {
  if (task.state === 'blocked' && task.gated) return 'Blocked · waiting on your decision'
  if (task.terminal) return `${TASK_LABEL[task.state]} · session open, click to go to it`
  return TASK_LABEL[task.state]
}

function Tasks({ run }: { run: RunSummary }) {
  const open = read(expanded)[run.id] ?? false
  return (
    <Collapsible title={`Tasks (${run.counts.done} of ${run.counts.total} done)`} open={open}
      onChange={(next) => update(expanded, (all) => ({ ...all, [run.id]: next }))}>
      <List label={`Tasks of ${run.title}`}>
        {run.tasks.map(task => (
          <ListItem key={task.id} title={task.title} description={taskDescription(task)} icon={TASK_ICON[task.state]}
            onPress={task.terminal ? () => focus(task.terminal as string) : undefined} />
        ))}
      </List>
    </Collapsible>
  )
}

function RunLine({ run, named }: { run: RunSummary; named: boolean }) {
  const { counts } = run
  const parts = [
    counts.working && `${counts.working} running`, counts.queued && `${counts.queued} queued`,
    counts.blocked && `${counts.blocked} blocked`, counts.failed && `${counts.failed} failed`
  ].filter(Boolean).join(' · ')
  return (
    <Stack gap="xs">
      {named ? <Text size="xs" truncate>{run.title}</Text> : null}
      <Progress label={`${counts.done} of ${counts.total} tasks done`} value={counts.total ? (counts.done / counts.total) * 100 : 0} />
      {parts ? <Text size="xs" muted>{parts}</Text> : null}
      <Tasks run={run} />
    </Stack>
  )
}

function Coordinator({ view }: { view: CoordinatorView }) {
  return (
    <Box border padding="sm" radius="md" direction="column" gap="sm">
      <Row justify="between" gap="sm">
        <Badge tone={TONE[view.state]}>{LABEL[view.state]}</Badge>
        <IconButton icon="terminal" label="Open coordinator" size="sm" variant="ghost" onPress={() => focus(view.handle)} />
      </Row>
      <Text weight="medium">{view.title}</Text>
      <Text size="sm" tone={view.state === 'needs-you' ? 'warning' : view.state === 'stalled' ? 'danger' : undefined} muted={view.state !== 'needs-you' && view.state !== 'stalled'}>
        {view.detail}
      </Text>
      {view.attention.flatMap(item => item.gate ? [<Gate key={item.key} item={item} gate={item.gate} />] : [])}
      {view.attention.some(item => !item.gate) ? (
        <List label="Waiting on you">
          {view.attention.filter(item => !item.gate).map(item => (
            <ListItem key={item.key} title={item.text} icon="agent"
              onPress={item.terminal ? () => focus(item.terminal as string) : undefined} />
          ))}
        </List>
      ) : null}
      {/* With one Run the card title already names it. */}
      {view.runs.map(run => <RunLine key={run.id} run={run} named={view.runs.length > 1} />)}
    </Box>
  )
}

export default function Panel() {
  const answer = read(status)
  return (
    <Stack gap="md">
      <Row justify="between">
        <Heading>Coordinators</Heading>
        <IconButton icon="refresh" label="Refresh" variant="ghost" onPress={refresh} />
      </Row>
      {answer === null ? <Text muted>Reading orchestration runs…</Text>
        : answer.views.length === 0
          ? <EmptyState icon="bot" title="No live runs" description="Coordinators with an open Orca orchestration Run show here." />
          : answer.views.map(view => <Coordinator key={view.handle} view={view} />)}
      {answer?.readAt ? <Text size="xs" muted>Read <RelativeTime at={answer.readAt} /></Text> : null}
    </Stack>
  )
}
