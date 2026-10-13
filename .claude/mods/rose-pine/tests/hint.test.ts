import { expect, mock, test } from 'claude-code/testing'

test('the lualine replaces the footer', async ($, on) => {
  mock.env(on, { HOME: '/Users/me' })
  on('agent.list', () => ({ value: [] }) as never)
  on('session.model', () => ({ value: 'claude-opus-5-5' }) as never)
  on('session.cwd', () => ({ value: '/Users/me/dots' }) as never)
  on('session.usage', () => ({ value: { startedAt: 0, context: { window: 200000, percent: 31 }, rateLimits: [] } }) as never)
  const ui = await $.ui.mount({
    plugin: 'rose-pine',
    surface: 'terminal',
    component: 'PromptHint',
    props: { isDraft: false, isWorking: false, hint: '← for agents' },
  })
  expect((await ui.find({ type: 'Text', text: / ASK / }))).toBeDefined()
  expect((await ui.find({ type: 'Text', text: /~\/dots/ }))).toBeDefined()
  expect((await ui.find({ type: 'Text', text: /for agents/ }))).toBeUndefined()
  await ui.unmount()
})
