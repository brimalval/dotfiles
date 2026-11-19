import { assert, test } from 'orca/testing'
import { coordinatorView, notices, statusBar, STALL_GRACE_MS, FINISHED_RUN_TTL_MS, type RawRun } from './model'

const NOW = 10_000_000_000
const run = (over: Partial<RawRun> = {}): RawRun => ({
  id: 'run_1', objective: '# Ship voice count\nmore text', coordinator: 'term_c', updatedAt: NOW - 1000,
  tasks: [], gates: [], workers: [], ...over
})
const task = (id: string, status: string) => ({ id, title: `Task ${id}`, status })

test('turn ended but a worker is running: waiting on workers, not done', () => {
  const view = coordinatorView('term_c', [run({ tasks: [task('a', 'completed'), task('b', 'dispatched')] })], 'done', NOW - 5000, NOW)
  assert.equal(view?.state, 'waiting-on-workers')
  assert.equal(view?.detail, 'Waiting on 1 worker')
  assert.equal(view?.title, 'Ship voice count')
})

test('a pending gate needs you, even while the coordinator works', () => {
  const view = coordinatorView('term_c', [run({
    tasks: [task('a', 'blocked')], gates: [{ id: 'gate_1', taskId: 'a', status: 'pending', question: 'Push to main?', options: [] }]
  })], 'working', NOW, NOW)
  assert.equal(view?.state, 'needs-you')
  assert.equal(view?.detail, '1 thing waiting on you')
  assert.equal(view?.attention[0].text, 'Push to main?')
})

test('the coordinator asking for permission needs you', () => {
  const view = coordinatorView('term_c', [run({ tasks: [task('a', 'dispatched')] })], 'blocked', NOW, NOW)
  assert.equal(view?.state, 'needs-you')
  assert.equal(view?.attention[0].kind, 'coordinator')
})

test('only a live worker can be waiting on a person', () => {
  const tasks = [task('a', 'dispatched')]
  const dead = coordinatorView('term_c', [run({ tasks, workers: [{ taskId: 'a', terminal: 'term_w', needsYou: true, live: false }] })], 'done', NOW, NOW)
  assert.equal(dead?.state, 'waiting-on-workers')
  const live = coordinatorView('term_c', [run({ tasks, workers: [{ taskId: 'a', terminal: 'term_w', needsYou: true, live: true }] })], 'done', NOW, NOW)
  assert.equal(live?.state, 'needs-you')
  assert.equal(live?.attention[0].terminal, 'term_w')
})

test('open tasks with nothing running: stalled only after the grace period', () => {
  const runs = [run({ tasks: [task('a', 'completed'), task('b', 'ready')] })]
  assert.equal(coordinatorView('term_c', runs, 'done', NOW - 10_000, NOW)?.state, 'waiting-on-workers')
  assert.equal(coordinatorView('term_c', runs, 'done', NOW - STALL_GRACE_MS - 1, NOW)?.state, 'stalled')
  assert.equal(coordinatorView('term_c', runs, 'working', NOW - STALL_GRACE_MS - 1, NOW)?.state, 'working')
})

test('every task settled: done, with failures named', () => {
  const view = coordinatorView('term_c', [run({ tasks: [task('a', 'completed'), task('b', 'failed')] })], 'done', NOW, NOW)
  assert.equal(view?.state, 'done')
  assert.equal(view?.detail, 'Finished · 1 failed')
})

test('settled runs older than 12 hours drop out; open ones never do', () => {
  const old = NOW - FINISHED_RUN_TTL_MS - 1
  assert.equal(coordinatorView('term_c', [run({ updatedAt: old, tasks: [task('a', 'completed')] })], 'done', NOW, NOW), null)
  assert.equal(coordinatorView('term_c', [run({ updatedAt: old, tasks: [task('a', 'dispatched')] })], 'done', NOW, NOW)?.state, 'waiting-on-workers')
})

test('status bar: needs-you wins the tone, counts read across coordinators', () => {
  const waiting = coordinatorView('term_a', [run({ coordinator: 'term_a', tasks: [task('a', 'dispatched'), task('b', 'dispatched')] })], 'done', NOW, NOW)!
  const gated = coordinatorView('term_b', [run({ id: 'run_2', coordinator: 'term_b', tasks: [task('c', 'blocked')],
    gates: [{ id: 'gate_1', taskId: 'c', status: 'pending', question: 'Merge?', options: [] }] })], 'done', NOW, NOW)!
  const bar = statusBar([gated, waiting])
  assert.equal(bar.text, '1 needs you · 2 workers running')
  assert.equal(bar.tone, 'warning')
  assert.equal(statusBar([]).visible, false)
  const many = Array.from({ length: 12 }, (_, i) => coordinatorView(`term_${i}`, [run({ id: `run_${i}`, coordinator: `term_${i}`,
    objective: 'A very long objective that goes on and on about voice counts and OTA releases', tasks: [task('a', 'dispatched')] })], 'done', NOW, NOW)!)
  assert.ok(statusBar(many).tooltip.length <= 256)
})

test('notices: nothing on the first read, then new gates, stalls and finished runs', () => {
  const working = coordinatorView('term_c', [run({ tasks: [task('a', 'dispatched')] })], 'done', NOW, NOW)!
  assert.deepEqual(notices(null, [working]), [])
  const gated = coordinatorView('term_c', [run({ tasks: [task('a', 'blocked')],
    gates: [{ id: 'gate_1', taskId: 'a', status: 'pending', question: 'Merge?', options: [] }] })], 'done', NOW, NOW)!
  assert.deepEqual(notices([working], [gated]).map(n => n.title), ['Coordinator needs you'])
  assert.deepEqual(notices([gated], [gated]), [])
  const done = coordinatorView('term_c', [run({ tasks: [task('a', 'completed')] })], 'done', NOW, NOW)!
  assert.deepEqual(notices([gated], [done]).map(n => n.title), ['Run finished'])
  assert.deepEqual(notices([done], [done]), [])
})

test('tasks: what matters now first, open worker sessions linked, gated tasks marked', () => {
  const view = coordinatorView('term_c', [run({
    tasks: [task('a', 'completed'), task('b', 'dispatched'), task('c', 'blocked'), task('d', 'ready'), task('e', 'dispatched')],
    gates: [{ id: 'gate_1', taskId: 'c', status: 'pending', question: 'Go?', options: [] }],
    workers: [
      { taskId: 'b', terminal: 'term_b', needsYou: false, live: true, open: true },
      { taskId: 'e', terminal: 'term_e', needsYou: false, live: false, open: false },
      // Finished, but its session was kept open: still linked.
      { taskId: 'a', terminal: 'term_a', needsYou: false, live: false, open: true }
    ]
  })], 'done', NOW, NOW)!
  assert.deepEqual(view.runs[0].tasks.map(t => [t.id, t.state, t.terminal, t.gated]), [
    ['b', 'working', 'term_b', false], ['e', 'working', null, false], ['c', 'blocked', null, true],
    ['d', 'queued', null, false], ['a', 'done', 'term_a', false]
  ])
})
