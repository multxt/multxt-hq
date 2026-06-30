# CLAUDE.md — multxt-hq

Guidance for Claude Code when working in this repo.

## What this is

`multxt-hq` is the **master monorepo** for the `-xt` family of open-source trading tools.
It is a thin orchestration shell: a handbook + submodules. The real code lives in the
submodules. Each submodule is an independently publishable npm package with its own git
repo under `github.com/multxt`.

```
multxt-hq/         this repo — handbook + submodule pointers (no app code of its own)
├── multxt/        submodule → github.com/multxt/multxt   (aggregation + mxt CLI)
└── smxt/          submodule → github.com/multxt/smxt     (stock-broker unified lib)
```

External members of the family — **ccxt** (crypto) and **pmxt** (prediction markets) —
are *dependencies*, not submodules. We consume them; we don't vendor them.

## The agent team (`.claude/agents/`)

A dedicated dev crew lives here, modeled on plutous-io's team but lean for an OSS CLI library. These files are canonical; cheunhong's HQ symlinks them in (`hq/.claude/agents/multxt/`) so they're invokable from his operating center too.

| Agent | Model | Role |
|---|---|---|
| **Lex** | opus | Lead / architect / orchestrator — owns the `-xt` contract, WP decomposition, PR-gate. **Entry point.** |
| **Ash** | sonnet | smxt connector engineer — base Broker, per-broker connectors, `has` maps |
| **Cole** | sonnet | multxt CLI + aggregation — Venue adapter, ops, CLI, MCP, guard model |
| **Ren** | sonnet | QA + has-conformance — vitest/CI, the adversarial-verify gate |
| **Vale** | sonnet | Docs + DevRel — handbook, connector/CLI docs, npm publish, multxt.dev |
| **Jax** | opus | Adversarial reviewer — secrets hygiene, the `--yes` guard model, license/dep audit |

Loop: Lex decomposes → Ash/Cole implement → Ren verifies → Lex integrates → Jax security-gates → Vale docs + publishes. Names carry a `(multxt)` tag in their frontmatter so they group cleanly when symlinked into a larger agent set.

## Read first

1. [`handbook/vision.md`](./handbook/vision.md) — why this exists, the wedge, who it's for.
2. [`handbook/architecture.md`](./handbook/architecture.md) — the layer model and the
   **unified interface spec** every `-xt` connector implements. This is the contract.
3. [`handbook/naming.md`](./handbook/naming.md) — the `-xt` convention and how to name things.

## Design rules (non-negotiable)

- **CLI-first.** New capability ⇒ a deterministic command first, library function second.
  Every command supports `--json` and returns a clean exit code. No interactive-only features.
- **Agent-native.** Output is machine-parseable. Side-effecting commands (anything that
  places an order or moves funds) require explicit confirmation or a `--yes` flag — never
  fire on a bare invocation.
- **Non-custodial.** We never hold keys server-side or take custody of funds. Credentials
  live in a local config file (gitignored), à la `frarber.yaml`.
- **One connector per file.** Mirror ccxt: `src/connectors/<venue>.ts`, each a subclass of
  the shared base class, with a `has` capability map and `describe()` metadata.
- **Unified, not lossy.** Prefer ccxt's `has`/capability model over hiding venue features.

## Working in submodules

- `make bootstrap` initializes submodules and installs deps.
- Edit code **inside the submodule**, commit + push there, then bump the pointer here.
- Do not commit submodule gitlink bumps without the underlying submodule commit being pushed.

## Security

- Never `cat`, echo, log, commit, or transmit any credentials/config file (e.g.
  `multxt.yaml`, `.env`). They are gitignored — keep it that way.
- Commands that place real orders or move funds are hard to reverse. Confirm intent before
  running them.

## Build / test

```bash
make bootstrap   # submodule init + npm install across packages
make build       # tsc build every package
make test        # run package test suites
make lint        # lint all packages
```
