// `orca plugin test .` runs this in Node with the same runtime and checks Orca uses.
import { assert, mockHost, mount, test } from 'orca/testing'
import * as panel from './panel'
import { coordinatorView } from './model'

const NOW = 10_000_000_000
const view = coordinatorView('term_c', [{
  id: 'run_1', objective: 'Ship voice count', coordinator: 'term_c', updatedAt: NOW,
  tasks: [{ id: 'a', title: 'Merge', status: 'blocked' }],
  gates: [{ id: 'gate_1', taskId: 'a', status: 'pending', question: 'Merge #72?', options: ['Merge', 'Hold'] }], workers: []
}], 'done', NOW, NOW)!

test('shows each coordinator and answers a gate only after a second press', async () => {
  const answers: { gateId: string; resolution: string }[] = []
  const focused: string[] = []
  const host = mockHost({
    requests: {
      'status.get': () => ({ views: [view], readAt: NOW }),
      'status.focus': ({ terminal }) => { focused.push(terminal); return { ok: true } },
      'gate.resolve': (input) => { answers.push(input); return { ok: true } }
    }
  })
  const shown = await mount(panel, { host })
  assert.ok(shown.find({ text: 'Needs you' }))
  assert.ok(shown.find({ text: 'Ship voice count' }))
  assert.ok(shown.find({ text: 'Merge #72?' }))

  // First press only asks.
  await shown.press({ text: 'Merge' })
  assert.deepEqual(answers, [])
  assert.ok(shown.find({ type: 'Callout' }))
  await shown.press({ text: 'Cancel' })
  assert.equal(shown.find({ type: 'Callout' }), null)

  // A typed answer goes through the same confirm.
  await shown.type({ label: 'Other answer' }, 'Merge after CI', { submit: true })
  await shown.press({ text: 'Send' })
  assert.deepEqual(answers, [{ gateId: 'gate_1', resolution: 'Merge after CI' }])

  // The task list starts folded and opens on demand.
  assert.equal(shown.find({ type: 'ListItem' }), null)
  await shown.toggle({ type: 'Collapsible' })
  assert.ok(shown.find({ type: 'ListItem' }))

  await shown.post('status.changed', { views: [], readAt: NOW })
  assert.ok(shown.find({ type: 'EmptyState' }))
  assert.deepEqual(shown.errors, [])
  assert.deepEqual(shown.refusals, [])
  await shown.unmount()
})
