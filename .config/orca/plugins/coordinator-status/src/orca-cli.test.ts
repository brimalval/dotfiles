// The parsing and binding rules in src/orca-cli.ts, with Orca's real answer shapes.
import { assert, test } from 'orca/testing'
import { applyBindings, parseBinding, parseTerminals, type Binding } from './orca-cli'

test('run-current: a coordinator names its Run; a worker or a shell names none', () => {
  assert.deepEqual(parseBinding({ ok: true, result: { runId: 'run_old', objective: 'Retail PR C' } }), { runId: 'run_old', objective: 'Retail PR C' })
  assert.equal(parseBinding({ ok: true, result: { runId: null } }), null)
  assert.equal(parseBinding(null), null)
})

test('only agent terminals are asked which Run they coordinate', () => {
  const terminals = parseTerminals({ ok: true, result: { terminals: [
    { handle: 'term_agent', worktreeId: 'ws', title: 'x', agentIdentity: 'claude' },
    { handle: 'term_shell', worktreeId: 'ws', title: 'y' }
  ] } })
  assert.deepEqual(terminals.map(terminal => terminal.agent), [true, false])
})

test('a revived coordinator that took over an old Run (run-use) owns it, even past the run-list window', () => {
  const heads = [
    { id: 'run_old', objective: 'Retail PR C', coordinator: 'term_closed', updatedAt: 1 },
    { id: 'run_other', objective: 'Other', coordinator: 'term_x', updatedAt: 2 }
  ]
  const bindings = new Map<string, Binding>([
    ['term_new', { runId: 'run_old', objective: 'Retail PR C' }],
    ['term_y', { runId: 'run_ancient', objective: 'Ancient' }]
  ])
  assert.deepEqual(applyBindings(heads, bindings), [
    { id: 'run_old', objective: 'Retail PR C', coordinator: 'term_new', updatedAt: 1, current: true },
    { id: 'run_other', objective: 'Other', coordinator: 'term_x', updatedAt: 2 },
    { id: 'run_ancient', objective: 'Ancient', coordinator: 'term_y', updatedAt: 0, current: true }
  ])
})
