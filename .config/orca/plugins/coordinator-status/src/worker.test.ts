// Runs src/worker.ts's activate(orca) over a mock host, with the CLI replaced.
import { assert, mockHost, mountWorker, test } from 'orca/testing'
import * as main from './worker'
import type { Snapshot } from './orca-cli'

const NOW = 10_000_000_000
const snapshot = (taskStatus: string): Snapshot => ({
  terminals: [{ handle: 'term_c', worktreeId: 'ws1', title: 'coordinator' }],
  runs: [{ id: 'run_1', objective: 'Ship it', coordinator: 'term_c', updatedAt: NOW,
    tasks: [{ id: 'a', title: 'Build', status: taskStatus }], gates: [], workers: [] }]
})

test('Orca says done, the run is open: the worker reports waiting, then finished', async () => {
  let current = snapshot('dispatched')
  const focused: string[] = []
  main.external.readSnapshot = async () => current
  main.external.focusTerminal = async (handle) => { focused.push(handle); return true }
  main.external.now = () => NOW

  const host = mockHost({
    capabilities: ['agent:read', 'notifications:show'],
    results: { 'agents.list': { agents: [{ terminalId: 'term_c', title: null, agent: 'claude', state: 'done', stateStartedAt: NOW - 1000 }] } }
  })
  const worker = await mountWorker(main, { host, events: ['agent.status.changed'], commands: ['coordinator-status.focus'] })
  try {

  const first = await worker.request('status.get')
  assert.equal(first.views[0].state, 'waiting-on-workers')
  const bar = host.callsOf('statusBar.update').at(-1) as { text: string; visible: boolean }
  assert.equal(bar.text, '1 worker running')
  assert.equal(bar.visible, true)
  assert.equal(host.callsOf('notifications.show').length, 0)

  current = snapshot('completed')
  const second = await worker.request('status.refresh')
  assert.equal(second.views[0].state, 'done')
  assert.deepEqual(host.callsOf('notifications.show').map(call => (call as { title: string }).title), ['Run finished'])

  await worker.command('coordinator-status.focus')
  assert.deepEqual(focused, ['term_c'])
  assert.deepEqual(await worker.request('status.focus', { terminal: 'term_not_shown' }), { ok: false })

  assert.deepEqual(worker.refusals, [])
  } finally {
    await worker.deactivate()
  }
})

test('answers only a gate it showed, as that Run’s coordinator', async () => {
  const resolved: { gateId: string; coordinator: string; resolution: string }[] = []
  main.external.readSnapshot = async () => ({
    terminals: [{ handle: 'term_c', worktreeId: 'ws1', title: null }],
    runs: [{ id: 'run_1', objective: 'Ship it', coordinator: 'term_c', updatedAt: NOW,
      tasks: [{ id: 'a', title: 'Merge', status: 'blocked' }],
      gates: [{ id: 'gate_1', taskId: 'a', status: 'pending', question: 'Merge?', options: ['Yes', 'No'] }], workers: [] }]
  })
  main.external.resolveGate = async (gate, resolution) => { resolved.push({ gateId: gate.gateId, coordinator: gate.coordinator, resolution }); return { ok: true } }
  main.external.now = () => NOW
  const host = mockHost({ capabilities: ['agent:read', 'notifications:show'], results: { 'agents.list': { agents: [] } } })
  const worker = await mountWorker(main, { host, events: ['agent.status.changed'], commands: ['coordinator-status.focus'] })
  try {
    await worker.request('status.get')
    assert.deepEqual(await worker.request('gate.resolve', { gateId: 'gate_other', resolution: 'Yes' }),
      { ok: false, error: 'That gate is no longer pending. Refresh.' })
    assert.deepEqual((await worker.request('gate.resolve', { gateId: 'gate_1', resolution: '   ' })).ok, false)
    assert.deepEqual(await worker.request('gate.resolve', { gateId: 'gate_1', resolution: ' Yes ' }), { ok: true })
    assert.deepEqual(resolved, [{ gateId: 'gate_1', coordinator: 'term_c', resolution: 'Yes' }])
  } finally {
    await worker.deactivate()
  }
})
