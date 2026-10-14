export type SpinnerStyle = 'shimmer' | 'prism' | 'scanner' | 'tide' | 'pulse' | 'orbit'
export type Git = { branch: string; dirty: number; ahead: number; behind: number }
// Where the checkout is: its root, the project it belongs to, and the
// worktree's name when it is a linked worktree.
export type Repo = { top: string; project: string; worktree?: string }
export type TurnStat = { durationMs: number; tools: number; added: number; removed: number }
export type Tick = { n: number; now: number; startedAt: number }

declare module 'claude-code' {
  interface PluginState {
    'rose-pine': {
      mode: string
      model: string
      git: Git | null
      repo: Repo | null
      tick: Tick
      spinner: SpinnerStyle
      turns: TurnStat[]
    }
  }
}
