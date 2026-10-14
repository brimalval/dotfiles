import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register, RenderChildren, Timer } from 'claude-code'

import type { Git, Repo, SpinnerStyle, Tick, TurnStat } from '../types'

// Rosé Pine Moon
const P = {
  base: '#232136',
  surface: '#2a273f',
  overlay: '#393552',
  muted: '#6e6a86',
  subtle: '#908caa',
  text: '#e0def4',
  love: '#eb6f92',
  gold: '#f6c177',
  rose: '#ea9a97',
  pine: '#3e8fb0',
  foam: '#9ccfd8',
  iris: '#c4a7e7',
  hlMed: '#44415a',
  hlHigh: '#56526e',
} as const

const ACCENTS = [P.love, P.gold, P.rose, P.pine, P.foam, P.iris]

const MODES: Record<string, { label: string; color: string }> = {
  default: { label: 'ASK', color: P.rose },
  acceptEdits: { label: 'EDITS', color: P.iris },
  plan: { label: 'PLAN', color: P.pine },
  auto: { label: 'AUTO', color: P.foam },
  bypassPermissions: { label: 'YOLO', color: P.love },
  dontAsk: { label: 'STRICT', color: P.gold },
}

const SPIN_COLOR: Record<string, string> = {
  thinking: P.iris,
  responding: P.rose,
  'tool-use': P.foam,
  'tool-input': P.pine,
  requesting: P.gold,
}

const STYLES: SpinnerStyle[] = ['shimmer', 'prism', 'scanner', 'tide', 'pulse', 'orbit']
const TICK_MS = 90
const STORE_SPINNER = 'spinner'

const mode = atom({ plugin: 'rose-pine', key: 'mode' } as const, 'default')
const model = atom({ plugin: 'rose-pine', key: 'model' } as const, '')
const git = atom({ plugin: 'rose-pine', key: 'git' } as const, null)
const repo = atom({ plugin: 'rose-pine', key: 'repo' } as const, null)
const tick = atom({ plugin: 'rose-pine', key: 'tick' } as const, { n: 0, now: 0, startedAt: 0 })
const spinner = atom({ plugin: 'rose-pine', key: 'spinner' } as const, 'shimmer')
const turns = atom({ plugin: 'rose-pine', key: 'turns' } as const, [])

const lines = (s: unknown) => (typeof s === 'string' && s.length > 0 ? s.split('\n').length : 0)

// The engine's own permission-mode indicator (`⏵⏵ auto mode on (shift+tab to cycle)`);
// the band's mode block replaces it.
const MODE_RE = /(?:⏵⏵|⏸|⏵)?\s*(?:auto mode|auto-accept edits|accept edits|plan mode|bypass permissions|don'?t ask)(?: mode)?\s+on\b(?:\s*\([^)]*\))?/gi

export const stripMode = (hint: string) =>
  hint
    .replace(MODE_RE, '')
    .replace(/(?:\s*·\s*){2,}/g, ' · ')
    .replace(/^\s*·\s*|\s*·\s*$/g, '')
    .trim()

// What the engine draws ahead of the footer in each non-default mode; it sits
// outside PromptHint, so the line leaves it room instead of hiding it.
const PILLS: Record<string, string> = {
  acceptEdits: '⏵⏵ accept edits on',
  plan: '⏸ plan mode on',
  auto: '⏵⏵ auto mode on',
  bypassPermissions: '⏵⏵ bypass permissions on',
  dontAsk: "⏵⏵ don't ask on",
}

const CYCLE_RE = /\s*\(shift\+tab to cycle\)/gi

export const hasModePill = (hint: string) => /\(shift\+tab to cycle\)/i.test(hint) || stripMode(hint) !== hint.trim()

// `claude-opus-5-5` → `Opus 5.5`
export const prettyModel = (id: string) => {
  const m = /^claude-([a-z]+)-(\d+)-(\d+)/.exec(id)
  return m ? `${m[1]![0]!.toUpperCase()}${m[1]!.slice(1)} ${m[2]}.${m[3]}` : id
}

export const formatDuration = (ms: number) => {
  const s = Math.max(0, Math.round(ms / 1000))
  if (s < 60) return `${s}s`
  const m = Math.floor(s / 60)
  if (m < 60) return `${m}m ${s % 60}s`
  return `${Math.floor(m / 60)}h ${m % 60}m`
}

export const parseGit = (out: string): Git | null => {
  const [head, ...rest] = out.split('\n')
  if (head === undefined || !head.startsWith('## ')) return null
  const info = head.slice(3)
  const branch = (info.split('...')[0] ?? '').replace(/^No commits yet on /, '').split(' ')[0] ?? ''
  const ahead = Number(/ahead (\d+)/.exec(info)?.[1] ?? 0)
  const behind = Number(/behind (\d+)/.exec(info)?.[1] ?? 0)
  return { branch, dirty: rest.filter(l => l.trim() !== '').length, ahead, behind }
}

export const meter = (percent: number, cells: number) => {
  const filled = Math.round((Math.min(100, Math.max(0, percent)) / 100) * cells)
  return { filled: '▰'.repeat(filled), empty: '▱'.repeat(cells - filled) }
}

const base = (p: string) => p.replace(/\/+$/, '').split('/').pop() ?? p
const parent = (p: string) => p.replace(/\/+$/, '').replace(/\/[^/]*$/, '')

// `git rev-parse --show-toplevel --git-dir --git-common-dir`, absolute paths.
// A linked worktree's git dir differs from the common dir, which is always the
// main checkout's `.git` (or a bare `name.git`), wherever the worktree lives.
export const parseRepo = (out: string): Repo | null => {
  const [top, gitDir, common] = out.trim().split('\n')
  if (!top || !gitDir || !common) return null
  if (gitDir === common) return { top, project: base(top) }
  const project = base(common) === '.git' ? base(parent(common)) : base(common).replace(/\.git$/, '')
  return { top, project, worktree: base(top) }
}

const width = (s: string) => [...s].length

// The location block's text from widest to narrowest: inside a repo it reads
// `project[ ⎇ worktree]/sub/dirs`, elsewhere the `~`-relative path.
export const pathCandidates = (cwd: string, home: string | undefined, r: Repo | null) => {
  let head: string
  let segs: string[]
  const inRepo = r !== null && (cwd === r.top || cwd.startsWith(`${r.top}/`))
  if (inRepo) {
    head = r.worktree ? `${r.project} ⎇ ${r.worktree}` : r.project
    segs = cwd.slice(r.top.length).split('/').filter(Boolean)
  } else if (home && (cwd === home || cwd.startsWith(`${home}/`))) {
    head = '~'
    segs = cwd.slice(home.length).split('/').filter(Boolean)
  } else {
    head = '/'
    segs = cwd.split('/').filter(Boolean)
  }
  const join = (parts: string[]) =>
    parts.length === 0 ? head : head === '/' ? `/${parts.join('/')}` : `${head}/${parts.join('/')}`
  const n = segs.length
  const out = [join(segs)]
  if (n > 2) out.push(join(['…', ...segs.slice(-2)]))
  if (n > 1) out.push(join(['…', segs[n - 1]!]))
  if (inRepo && n > 0) out.push(head)
  if (n > 0) out.push(segs[n - 1]!)
  return [...new Set(out)]
}

// The widest candidate that fits `budget` columns once padded, or null.
export const fitPath = (candidates: string[], budget: number) =>
  candidates.find(c => width(c) + 2 <= budget) ?? null

const refreshGit = async ($: EngineInterface) => {
  try {
    const cwd = await $.session.cwd()
    const [st, rp] = await Promise.all([
      $.process.run(['git', 'status', '--porcelain=v1', '--branch'], { cwd, timeoutMs: 3000 }),
      $.process.run(
        ['git', 'rev-parse', '--path-format=absolute', '--show-toplevel', '--git-dir', '--git-common-dir'],
        { cwd, timeoutMs: 3000 },
      ),
    ])
    const next = st.exitCode === 0 ? parseGit(st.stdout) : null
    const where = rp.exitCode === 0 ? parseRepo(rp.stdout) : null
    await update($, git, () => next)
    await update($, repo, () => where)
  } catch {
    await update($, git, () => null)
    await update($, repo, () => null)
  }
}

const refreshModel = async ($: EngineInterface) => {
  try {
    const name = await $.session.model()
    await update($, model, () => name)
  } catch {}
}

const captureMode = async ($: EngineInterface, value: string | undefined) => {
  if (value) await update($, mode, () => value)
}

export const register: Register = on => {
  let timer: Timer | undefined
  let gitTimer: Timer | undefined
  let live = { tools: 0, added: 0, removed: 0 }
  let seen = { hint: '', modes: [] as readonly string[] }

  const stopTicking = () => {
    timer?.cancel()
    timer = undefined
  }

  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'rosepine',
      description: 'Rosé Pine mod: `spinner [style]` cycles or picks the spinner style',
      argumentHint: `spinner [${STYLES.join('|')}] | debug`,
    })
    const saved = await $.store.get(STORE_SPINNER)
    if (typeof saved === 'string' && (STYLES as string[]).includes(saved)) {
      await update($, spinner, () => saved as SpinnerStyle)
    }
    const { permissions } = (await $.settings.read()) as { permissions?: { defaultMode?: string } }
    await captureMode($, permissions?.defaultMode)
    void refreshGit($)
    void refreshModel($)
    gitTimer?.cancel()
    gitTimer = $.clock.every(15_000, () => void refreshGit($))

    return next(e)
  })

  on('command.run', { command: 'rosepine' }, async ($, e) => {
    const [sub, pick] = e.args.trim().split(/\s+/)
    if (sub === 'debug') {
      return { text: `PromptHint: ${JSON.stringify(seen.hint)}\nSessionMode: ${JSON.stringify(seen.modes)}` }
    }
    if (sub !== 'spinner') {
      return { text: `Usage: /rosepine spinner [${STYLES.join('|')}]` }
    }
    const current = await read($, spinner)
    const chosen =
      pick && (STYLES as string[]).includes(pick)
        ? (pick as SpinnerStyle)
        : STYLES[(STYLES.indexOf(current) + 1) % STYLES.length]!
    await update($, spinner, () => chosen)
    await $.store.set(STORE_SPINNER, chosen)

    return { text: `Spinner: ${chosen}` }
  })

  // Permission mode rides on the classic hook inputs.
  on('classic.UserPromptSubmit', async ($, e, next) => {
    await captureMode($, e.permission_mode)
    return next(e)
  })
  on('classic.PostToolUse', async ($, e, next) => {
    if (!e.agent_id) await captureMode($, e.permission_mode)
    return next(e)
  })
  on('classic.Stop', async ($, e, next) => {
    await captureMode($, e.permission_mode)
    return next(e)
  })
  on('classic.PostModelSwitch', async ($, e, next) => {
    const r = await next(e)
    void refreshModel($)
    return r
  })

  on('turn.start', async ($, e, next) => {
    {
      live = { tools: 0, added: 0, removed: 0 }
      const now = await $.clock.now()
      await update($, tick, () => ({ n: 0, now, startedAt: now }))
      stopTicking()
      timer = $.clock.every(TICK_MS, () => {
        void $.clock.now().then(t => update($, tick, (prev: Tick) => ({ ...prev, n: prev.n + 1, now: t })))
      })
    }
    return next(e)
  })

  on('tool.call', async ($, e, next) => {
    const result = await next(e)
    live.tools += 1
    if (result.result !== undefined && !result.isError) {
      if (e.tool === 'Edit') {
        live.removed += lines(e.old_string)
        live.added += lines(e.new_string)
      } else if (e.tool === 'Write') {
        live.added += lines(e.content)
      }
    }
    return result
  })

  on('turn.complete', async ($, e, next) => {
    if (e.agentId === undefined) {
      stopTicking()
      const stat: TurnStat = { durationMs: e.durationMs, ...live }
      await update($, turns, (list: TurnStat[]) => [...list, stat].slice(-300))
      void refreshGit($)
      void refreshModel($)
    }
    return next(e)
  })

  on('turn.abort', async ($, e, next) => {
    stopTicking()
    return next(e)
  })

  // 2. The spinner, in a style picked with /rosepine spinner.
  on('ui.render', { component: 'Spinner' }, async ($, e, next) => {
    if (e.surface !== 'terminal') return next(e)
    const { Text } = $.ui.resolve(e)
    const style = await read($, spinner)
    const t = await read($, tick)
    const n = t.n
    const accent = SPIN_COLOR[e.props.mode] ?? P.iris
    const word = e.props.message ?? e.props.word
    const elapsed = t.startedAt > 0 ? formatDuration(t.now - t.startedAt) : ''

    let glyph: RenderChildren = null
    let label: RenderChildren = <Text color={accent}>{word}</Text>

    if (style === 'shimmer') {
      const braille = '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
      glyph = <Text color={accent}>{braille[n % braille.length]}</Text>
      const head = n % (word.length + 6)
      label = [...word].map((ch, i) => {
        const d = Math.abs(i - head)
        return <Text color={d === 0 ? P.text : d === 1 ? P.subtle : accent}>{ch}</Text>
      })
    } else if (style === 'prism') {
      glyph = <Text color={ACCENTS[n % ACCENTS.length]}>◆</Text>
      label = [...word].map((ch, i) => (
        <Text color={ACCENTS[(Math.floor(n / 2) + i) % ACCENTS.length]}>{ch}</Text>
      ))
    } else if (style === 'scanner') {
      const width = 8
      const span = (width - 1) * 2
      const pos = n % span < width ? n % span : span - (n % span)
      glyph = [...Array(width)].map((_, i) => {
        const d = Math.abs(i - pos)
        const color = d === 0 ? P.love : d === 1 ? P.rose : d === 2 ? P.muted : P.hlMed
        return <Text color={color}>▪</Text>
      })
    } else if (style === 'tide') {
      const wave = '▁▂▃▄▅▆▇█▇▆▅▄▃▂'
      glyph = [...Array(8)].map((_, i) => {
        const level = wave[(n + i) % wave.length]!
        return <Text color={wave.indexOf(level) >= 4 ? P.foam : P.pine}>{level}</Text>
      })
    } else if (style === 'pulse') {
      const ramp = [P.hlMed, P.hlHigh, P.muted, P.subtle, accent, accent, P.subtle, P.muted, P.hlHigh]
      glyph = <Text color={ramp[n % ramp.length]}>●</Text>
      label = <Text color={ramp[(n + 2) % ramp.length]}>{word}</Text>
    } else {
      const orbit = '◜◝◞◟'
      glyph = <Text color={ACCENTS[Math.floor(n / 4) % ACCENTS.length]}>{orbit[n % orbit.length]}</Text>
    }

    return (
      <Text>
        {glyph} {label}
        <Text color={P.muted}>{e.props.suffix}</Text>
        {elapsed && <Text color={P.muted}>{`  ${elapsed}`}</Text>}
      </Text>
    )
  })

  // 3. Turn summaries.
  on('ui.render', { component: 'TurnDuration' }, async ($, e, next) => {
    const { Text } = $.ui.resolve(e)
    const list = await read($, turns)
    let best: TurnStat | undefined
    for (const s of list) {
      const d = Math.abs(s.durationMs - e.props.durationMs)
      if (d < 1500 && (!best || d < Math.abs(best.durationMs - e.props.durationMs))) best = s
    }

    return (
      <Text>
        <Text color={P.rose}>❀ </Text>
        <Text color={P.subtle}>{formatDuration(e.props.durationMs)}</Text>
        {best && best.tools > 0 && (
          <Text color={P.muted}>{` · ${best.tools} tool${best.tools === 1 ? '' : 's'}`}</Text>
        )}
        {best && (best.added > 0 || best.removed > 0) && (
          <Text>
            <Text color={P.muted}> · </Text>
            <Text color={P.foam}>{`+${best.added}`}</Text>
            <Text color={P.muted}>/</Text>
            <Text color={P.love}>{`−${best.removed}`}</Text>
          </Text>
        )}
      </Text>
    )
  })

  // 4. Session mode labels as pills.
  on('ui.render', { component: 'SessionMode' }, async ($, e, next) => {
    seen = { ...seen, modes: e.props.modes }
    const modes = e.props.modes.filter(label => stripMode(label) !== '')
    if (modes.length === 0) return next({ ...e, props: { ...e.props, modes } })
    const { Box, Text } = $.ui.resolve(e)
    return (
      <Box flexDirection="row" gap={1}>
        {modes.map((label, i) => (
          <Text backgroundColor={P.overlay} color={ACCENTS[(i + 5) % ACCENTS.length]}>
            {` ${label} `}
          </Text>
        ))}
      </Box>
    )
  })

  // 1. The lualine: the whole footer under the prompt, flat blocks like nvim's.
  // The engine's footer (mode pill, hints, pills) is replaced, not added to.
  on('ui.render', { component: 'PromptHint' }, async ($, e, next) => {
    seen = { ...seen, hint: e.props.hint }
    if (e.surface !== 'terminal') return next(e)
    const { Box, Text } = $.ui.resolve(e)

    const m = MODES[await read($, mode)] ?? { label: (await read($, mode)).toUpperCase(), color: P.subtle }
    const g = await read($, git)
    const r = await read($, repo)
    const name = prettyModel((await read($, model)) || (await $.session.model()))
    const usage = await $.session.usage()
    const cwd = await $.session.cwd()
    const home = await $.env.get('HOME')
    const pct = usage.context.percent
    const pill = PILLS[await read($, mode)]
    // The row's 2-column indent, the pill and the ` · ` after it, and one
    // column of slack so the line never wraps.
    const reserved = pill ? [...pill].length + 3 : 0
    const cols = Math.max(20, (e.viewport?.columns ?? 100) - 3 - reserved)
    const hint = stripMode(e.props.hint.replace(CYCLE_RE, '').replace(/\s*·?\s*←\s*for agents/i, ''))
    let agents = 0
    try {
      agents = (await $.agent.list()).filter(a => a.status === 'running' || a.status === 'pending').length
    } catch {}
    const ctxColor = pct === undefined ? P.muted : pct >= 80 ? P.love : pct >= 50 ? P.gold : P.foam
    const bar = meter(pct ?? 0, cols >= 90 ? 10 : 5)
    const cost = usage.cost?.usd
    const costText = cost === undefined ? '' : ` $${cost.toFixed(2)} `
    const agentsText = agents > 0 ? `← ${agents} agent${agents === 1 ? '' : 's'} ` : ''
    const stats = g
      ? `${g.dirty > 0 ? ` ●${g.dirty}` : ''}${g.ahead > 0 ? ` ↑${g.ahead}` : ''}${g.behind > 0 ? ` ↓${g.behind}` : ''}`
      : ''

    // Width budget: everything but the path is measured, the path gets what is
    // left. Give up the cost first, then the model, then path detail, then the
    // branch's dirty/ahead/behind counts.
    const candidates = pathCandidates(cwd, home, r)
    const steps = [
      { showCost: true, showModel: true, showStats: true, fullOnly: true },
      { showCost: false, showModel: true, showStats: true, fullOnly: true },
      { showCost: false, showModel: false, showStats: true, fullOnly: false },
      { showCost: false, showModel: false, showStats: false, fullOnly: false },
    ]
    let fit = steps[steps.length - 1]!
    let dir: string | null = null
    for (const step of steps) {
      const used =
        (pill ? 0 : width(m.label) + 2) +
        (g ? 4 + width(g.branch) + (step.showStats ? width(stats) : 0) : 0) +
        width(agentsText) +
        (step.showModel ? width(name) + 1 : 0) +
        (7 + bar.filled.length + bar.empty.length) +
        (step.showCost ? width(costText) : 0) +
        1
      const pick = fitPath(step.fullOnly ? candidates.slice(0, 1) : candidates, cols - used)
      fit = step
      dir = pick
      if (pick !== null) break
    }

    return (
      <Box flexDirection="row" height={1} width={cols} overflow="hidden">
        {!pill && (
          <Text backgroundColor={m.color} color={P.base} bold>
            {` ${m.label} `}
          </Text>
        )}
        {dir !== null && (
          <Text backgroundColor={P.overlay} color={P.text}>
            {` ${dir} `}
          </Text>
        )}
        {g && (
          <Text backgroundColor={P.surface}>
            <Text color={P.iris}>{`  ${g.branch}`}</Text>
            {fit.showStats && g.dirty > 0 && <Text color={P.gold}>{` ●${g.dirty}`}</Text>}
            {fit.showStats && g.ahead > 0 && <Text color={P.foam}>{` ↑${g.ahead}`}</Text>}
            {fit.showStats && g.behind > 0 && <Text color={P.love}>{` ↓${g.behind}`}</Text>}
            <Text> </Text>
          </Text>
        )}
        <Box flexGrow={1} height={1} justifyContent="center">
          {(e.props.isWorking || e.props.isDraft) && hint !== '' && (
            <Text color={P.muted} wrap="truncate">{hint}</Text>
          )}
        </Box>
        {agentsText !== '' && <Text color={P.foam}>{agentsText}</Text>}
        {fit.showModel && <Text color={P.subtle}>{`${name} `}</Text>}
        <Text backgroundColor={P.surface}>
          <Text color={ctxColor}>{` ${bar.filled}`}</Text>
          <Text color={P.hlHigh}>{bar.empty}</Text>
          <Text color={P.subtle}>{pct === undefined ? '  --% ' : ` ${String(pct).padStart(3)}% `}</Text>
        </Text>
        {fit.showCost && costText !== '' && (
          <Text backgroundColor={P.overlay} color={P.gold}>{costText}</Text>
        )}
        <Text backgroundColor={m.color}> </Text>
      </Box>
    )
  })
}
