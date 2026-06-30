# Build Scope

The implementation blueprint. [`roadmap.md`](./roadmap.md) is the *what/when*; this is the
*how* — broken into **subagent-sized work packages (WPs)** with explicit dependencies,
parallelization, and acceptance criteria, so each phase can be executed as an orchestrated
multi-agent run.

## How we build (orchestration model)

Each phase is one orchestration pass with the same shape:

```
scope (this doc)  →  fan-out implement (1 agent per WP, parallel where deps allow)
                  →  adversarial verify (build + test + spec-conformance per WP)
                  →  integrate (wire WPs, run the phase acceptance check)
```

Rules for every WP:
- **One WP = one agent = one focused PR-sized change.** No drive-by refactors.
- **Conformance over cleverness.** A connector/command is "done" only when it matches the
  unified contract in [`architecture.md`](./architecture.md) — `has` map honest,
  shapes normalized, errors from the shared hierarchy.
- **Verify before integrate.** A WP isn't done until it builds clean (`tsc`), its tests
  pass, and a second agent confirms it does what it claims (esp. the `has` map matches the
  implemented methods).
- **Secrets never touched.** Creds live in gitignored config; no WP logs/echoes/commits them.

Status legend: ✅ done · 🔨 ready to build · ⛔ blocked by dep · 🔭 needs research first.

---

## Known gaps in the current scaffold (fix first)

- **smxt/Alpaca `has.fetchOHLCV` is `true` but `fetchOHLCV()` is not implemented** — it
  currently falls through to the base `NotSupported` stub. The reference connector must be
  honest. → **WP-2.0** below: implement `fetchOHLCV` (Alpaca `/v2/stocks/{symbol}/bars`) or
  flip the flag. This is the canonical example connectors are copied from, so it ships first.
- No CI yet. → **WP-0.1**.
- No tests anywhere. → covered per-WP.

---

## Phase 0 — Foundation hardening  *(small, do before Phase 1/2)*

| WP | Title | Deps | Deliverable / Acceptance |
|---|---|---|---|
| **0.1** 🔨 | CI workflow | — | `.github/workflows/ci.yml` in `multxt` + `smxt`: `tsc` build + lint + test on push/PR. Green on main. |
| **0.2** 🔨 | Shared lint/format | — | eslint + prettier config per package; `npm run lint` passes. |
| **0.3** 🔨 | Test runner baseline | — | `vitest` wired in both packages; one trivial passing test; `npm test` works. |

Parallel: all three independent.

---

## Phase 1 — multxt CLI walking skeleton

**Goal / DoD:** `mxt` performs real operations against a configured crypto account via
ccxt, with `--json` and deterministic exit codes.

| WP | Title | Deps | Deliverable / Acceptance |
|---|---|---|---|
| **1.1** 🔨 | Config loader | — | `src/config/`: load + validate `multxt.yaml` (per-venue creds keyed by venue id), honoring each connector's `requiredCredentials`. Gitignored. **AC:** missing-cred → typed error; secrets never printed; `mxt config check` lists configured venues without revealing keys. |
| **1.2** 🔨 | Venue adapter (ccxt) | — | `src/connectors/venue.ts` + harden `cex.ts`: wrap a ccxt exchange into the internal `Venue` interface (`fetchTicker`, `fetchPositions`, `setLeverage`, `createMarketOrder`, `has`). **AC:** unit tests with a mocked ccxt instance; `has` reflects ccxt's `has`. |
| **1.3** ⛔(1.1,1.2) | Real `set-leverage` + `price-diff` | 1.1, 1.2 | Replace CLI stubs with real calls. **AC:** `mxt set-leverage <v> <sym> <x> --json` returns the venue response; `mxt price-diff a b sym --json` streams normalized spread; exit codes deterministic. |
| **1.4** ⛔(1.1,1.2) | `positions` + `balances` | 1.1, 1.2 | `mxt positions --json`, `mxt balances --json` across all configured venues. **AC:** aggregated, normalized, sorted; empty state handled. |
| **1.5** 🔨 | Error → exit-code map | — | Map the shared error hierarchy to stable exit codes (auth=printable, network=retryable). **AC:** documented table; `--json` includes `{ok,error,code}`. |
| **1.6** ⛔(1.3,1.4) | **Minimal plugin/MCP (ship the funnel early)** | 1.3, 1.4, 4.1 | `mxt mcp serve` exposing the read-only + confirm-gated commands that already exist (`positions`, `balances`, `price-diff`, `set-leverage`) as MCP tools, packaged as a Claude Code / Codex plugin. **AC:** an agent installs it and reads positions; placing an order requires confirm. This is the **north-star surface** — don't wait for Phase 4 to ship a v0. |

Parallel: 1.1, 1.2, 1.5 run concurrently; 1.3 + 1.4 fan out after; 1.6 last (pulls the guard model 4.1 forward).

**Phase-1 acceptance:** against a paper/sandbox account, all five commands work end-to-end,
`--json` everywhere, no secret ever logged — **and a minimal plugin is installable by an AI
agent.** Getting the plugin into agents' hands early is the whole GTM (see vision: the plugin
is the funnel); Phase 4 then deepens it.

---

## Phase 2 — smxt v0 (one broker, fully unified)

**Goal / DoD:** Alpaca is a complete, tested, published reference connector that every
future broker is copied from.

| WP | Title | Deps | Deliverable / Acceptance |
|---|---|---|---|
| **2.0** 🔨 | Complete Alpaca reference | — | Implement `fetchOHLCV` (Alpaca bars). Audit `has` ↔ impl parity (every `true` is implemented; everything unimplemented is `false`/omitted). **AC:** a "has-conformance" test asserts no method declared `true` throws `NotSupported`. |
| **2.1** ⛔(2.0) | Alpaca unit tests | 2.0 | Tests for every mapper (`parseOrder`, instrument/position/account normalization) + `throwForStatus` (401→Auth, 429→RateLimit, 422→InvalidOrder/InsufficientFunds, 5xx→BrokerNotAvailable). **AC:** mappers covered; error mapping covered. |
| **2.2** 🔭 | Alpaca paper integration test | 2.0 | Opt-in (env-gated) live test against an Alpaca **paper** account: account→order→cancel→positions round-trip. **AC:** documented, skipped without creds, green with them. |
| **2.3** ⛔(2.0,2.1) | Publish `@multxt/smxt` | 2.0, 2.1 | npm publish 0.1.x. **AC:** `npm i @multxt/smxt` then `smxt('alpaca',…)` works from a clean project. |

Parallel: 2.1 + 2.2 after 2.0; 2.3 last.

**Phase-2 acceptance:** `@multxt/smxt` on npm, Alpaca passing has-conformance + unit tests.

---

## Phase 3 — Aggregation across asset classes

**Goal / DoD:** multxt operates crypto **and** stocks (and prediction markets) from one
surface, capability-gated.

| WP | Title | Deps | Deliverable / Acceptance |
|---|---|---|---|
| **3.1** ⛔(P1,P2) | smxt connector in multxt | P1, P2 | `src/connectors/stock.ts` wraps an smxt `Broker` into the internal `Venue`. **AC:** `mxt positions`/`balances` include Alpaca holdings. |
| **3.2** 🔭 | pmxt connector in multxt | P1 | `src/connectors/prediction.ts` over pmxt (note: pmxt is a sidecar server — research the integration). **AC:** `mxt price` works on a Polymarket market. |
| **3.3** ⛔(3.1) | `rebalance` + `transfer` ops | 3.1 | Capability-gated ops (skip venues whose `has` lacks `transfer`). **AC:** dry-run plan; no-fire without `--yes`. |
| **3.4** ⛔(P1) | Strategy runner (L3) | P1 | Spawn strategy plugins, stream `StrategyEvent`s; one reference strategy (e.g. spread monitor). **AC:** plugin protocol documented + reference plugin runs. |

Parallel: 3.1 + 3.2 + 3.4 concurrent; 3.3 after 3.1.

---

## Phase 4 — Agent surface (the wedge)

**Goal / DoD:** an agent drives multxt **non-custodially** against the user's own accounts.

| WP | Title | Deps | Deliverable / Acceptance |
|---|---|---|---|
| **4.1** ⛔(P1) | Confirmation/guard model | P1 | Every side-effecting command requires explicit confirm or `--yes`; read-only commands never gate. **AC:** firing without confirm is impossible; tested. |
| **4.2** ⛔(P3,4.1) | `mxt mcp serve` | P3, 4.1 | Thin MCP wrapper exposing the same command handlers as tools (precedent: `@pmxt/mcp`). **AC:** an MCP client can list venues, read positions, and (with confirm) place an order. |
| **4.3** ⛔(4.2) | Claude plugin packaging | 4.2 | Distributable via Claude plugin marketplace. **AC:** installs + connects in the desktop/CLI client. |
| **4.4** ⛔(4.2) | Reference agent loop | 4.2 | research → propose → (human confirm) → execute, documented end-to-end. |

---

## Phase 5 — Breadth (rolling)

| WP | Title | Deps | Notes |
|---|---|---|---|
| **5.1** 🔭 | smxt: Interactive Brokers | P2 | `@stoqey/ib` → TCP socket to IB Gateway/TWS. Connector abstracts the gateway dependency. |
| **5.2** 🔭 | smxt: Futu / moomoo | P2 | Local OpenD gateway. Strong SEA coverage (HK/US/A/SGX). |
| **5.3** 🔭 | smxt: Tiger | P2 | SEA-relevant alternative. |
| **5.4** | More ops, more strategies | P3 | rolling |
| **5.5** | Docs site on `multxt.dev` | P2 | rolling |

Each broker WP = research access model → implement connector (copy Alpaca) → has-conformance
+ unit tests → integration test behind a gateway.

---

## Dependency graph (top level)

```
Phase 0 ─┬─────────────► Phase 1 ─┐
         └─► Phase 2 ──────────────┼─► Phase 3 ─► Phase 4
                 └► Phase 5 (rolling, after P2)
```

## First ultracode run (recommended)

Run **Phase 0 + Phase 2.0–2.1 together** as the opening pass — small, parallel, no
cross-package deps, and it makes the reference connector honest + tested before anyone
copies it. Then Phase 1 as the second pass. Each pass: fan-out implement → adversarial
verify (build/test/has-conformance) → integrate → phase acceptance check.
