import { expect, mock, test } from 'claude-code/testing'

import { formatDuration, hasModePill, meter, parseGit, prettyModel, stripMode } from '../hooks/register'

test('parses git status headers', async () => {
  expect(parseGit('## main...origin/main [ahead 2, behind 1]\n M a.ts\n?? b.ts\n')).toEqual({
    branch: 'main',
    dirty: 2,
    ahead: 2,
    behind: 1,
  })
  expect(parseGit('## No commits yet on trunk\n')).toEqual({ branch: 'trunk', dirty: 0, ahead: 0, behind: 0 })
  expect(parseGit('fatal: not a repo')).toBe(null)
})

test('formats durations and meters', async () => {
  expect(formatDuration(3_400)).toBe('3s')
  expect(formatDuration(64_000)).toBe('1m 4s')
  expect(meter(50, 10)).toEqual({ filled: '▰▰▰▰▰', empty: '▱▱▱▱▱' })
})

test('turn summary draws duration, tools and line counts', async ($, on) => {
  mock.clock(on)
  on('turn.start', ($, e) => ({ turnId: e.turnId }))
  on('tool.call', () => ({ result: {} }) as never)
  on('turn.complete', ($, e) => ({ text: e.answer }))
  await $.turn.start({ turnId: 't1', text: 'hi' })
  await $.tool.call({ tool: 'Edit', file_path: '/tmp/a', old_string: 'a\nb', new_string: 'a\nb\nc' })
  await $.turn.complete({ turnId: 't1', answer: 'ok', text: 'ok', durationMs: 42_000, isAborted: false, reason: 'end_turn' } as never)

  const ui = await $.ui.mount({
    plugin: 'rose-pine',
    surface: 'terminal',
    component: 'TurnDuration',
    props: { word: 'Baked', durationMs: 42_100 },
  })
  const drawn = await ui.find({ text: /42s/ })
  expect(drawn?.text).toContain('❀ 42s · 1 tool · +3/−2')
  await ui.unmount()
})

test('session modes become pills and spinner keeps the word', async $ => {
  const modes = await $.ui.mount({
    plugin: 'rose-pine',
    surface: 'terminal',
    component: 'SessionMode',
    props: { modes: ['focus'] },
  })
  expect((await modes.find({ type: 'Text', text: / focus / }))?.props.backgroundColor).toBe('#393552')
  await modes.unmount()

  const spin = await $.ui.mount({
    plugin: 'rose-pine',
    surface: 'terminal',
    component: 'Spinner',
    props: { word: 'Working', message: null, suffix: '…', mode: 'thinking' },
  })
  expect((await spin.drawn()) !== undefined).toBe(true)
  await spin.unmount()
})

test('strips the permission-mode indicator from footer text', async () => {
  expect(stripMode('⏵⏵ auto mode on (shift+tab to cycle) · ? for shortcuts')).toBe('? for shortcuts')
  expect(stripMode('⏸ plan mode on (shift+tab to cycle)')).toBe('')
  expect(stripMode('⏵⏵ accept edits on (shift+tab to cycle)')).toBe('')
  expect(stripMode('esc to interrupt')).toBe('esc to interrupt')
})

test('spots the mode pill and prettifies model ids', async () => {
  expect(hasModePill('(shift+tab to cycle)')).toBe(true)
  expect(hasModePill('? for shortcuts')).toBe(false)
  expect(prettyModel('claude-opus-5-5')).toBe('Opus 5.5')
  expect(prettyModel('claude-fable-5-1[1m]')).toBe('Fable 5.1')
  expect(prettyModel('gpt-x')).toBe('gpt-x')
})
