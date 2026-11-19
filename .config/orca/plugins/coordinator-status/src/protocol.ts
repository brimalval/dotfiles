// The panel <-> worker contract, declared once: src/panel.tsx and src/worker.ts both read it.
import type { CoordinatorView } from './model'

export type StatusAnswer = { views: CoordinatorView[]; readAt: number | null }

declare module 'orca' {
  interface PluginRequests {
    /** The last read, reading once if there is none yet. */
    'status.get': { output: StatusAnswer }
    /** Reads now. */
    'status.refresh': { output: StatusAnswer }
    /** Switches to a terminal the panel was shown (a coordinator or a waiting worker). */
    'status.focus': { input: { terminal: string }; output: { ok: boolean } }
    /** Answers a pending gate the panel was shown, then wakes its coordinator with the answer. */
    'gate.resolve': { input: { gateId: string; resolution: string }; output: { ok: boolean; error?: string } }
  }
  interface PluginPanelEvents {
    /** Posted after every read. */
    'status.changed': StatusAnswer
  }
}
