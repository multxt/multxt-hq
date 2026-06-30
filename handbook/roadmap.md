# Roadmap

Phased plan. Each phase ships something usable; we don't build the whole pyramid before
the first command works.

## Phase 0 — Foundation *(in progress)*

- [x] `multxt-hq` master repo + handbook + submodule wiring.
- [x] `multxt` scaffold: connectors/ops/strategies/cli/types.
- [x] `smxt` scaffold: base `Broker` class, unified interface, error hierarchy, first stub.
- [ ] CI (build + lint + test) across packages.

## Phase 1 — multxt CLI walking skeleton

Goal: `mxt` does something real against a live crypto account via ccxt.

- [ ] Config loader (`multxt.yaml`, gitignored) with per-venue `requiredCredentials`.
- [ ] `Venue` adapter wrapping a ccxt exchange into the internal interface.
- [ ] Real `mxt set-leverage <venue> <symbol> <x> --json`.
- [ ] Real `mxt price-diff <a> <b> <symbol> --json` (streaming spread).
- [ ] `mxt positions` / `mxt balances` across configured venues.
- [ ] Deterministic exit codes + `--json` everywhere.

## Phase 2 — smxt v0 (the missing library)

Goal: one stock broker fully unified end-to-end.

- [ ] `base/Broker` + `errors` + `types` finalized.
- [ ] **Alpaca** connector (reference): `fetchInstruments`, `fetchTicker`, `fetchOHLCV`,
      `fetchAccount`, `fetchBalance`, `fetchPositions`, `createOrder`, `cancelOrder`,
      `fetchOrders`, `fetchOpenOrders`, `fetchMyTrades`.
- [ ] `has` capability map + `describe()` per connector.
- [ ] Publish `@multxt/smxt` to npm.

## Phase 3 — Aggregation across asset classes

Goal: multxt operates crypto + stocks from one surface.

- [ ] smxt connector inside multxt (stocks alongside ccxt crypto).
- [ ] pmxt connector inside multxt (prediction markets).
- [ ] `mxt rebalance` / `mxt transfer` ops, capability-gated.
- [ ] Strategy plugin runner (L3) with a reference strategy.

## Phase 4 — Agent surface

Goal: an agent drives multxt non-custodially against the user's own accounts.

- [ ] `mxt mcp serve` (or `@multxt/mcp`) — same handlers exposed as MCP tools.
- [ ] Confirmation/guard model for side-effecting tools (no fire without `--yes`/confirm).
- [ ] Claude plugin / marketplace distribution.
- [ ] Reference agent loop: research → propose → confirm → execute.

## Phase 5 — Breadth

- [ ] More smxt brokers: IBKR (`@stoqey/ib` + gateway), Futu (OpenD), Tiger.
- [ ] More ops, more strategies.
- [ ] Docs site on `multxt.dev`.

## Guiding sequence

> CLI before MCP. One venue before many. Crypto (ccxt exists) before stocks (smxt to build)
> before aggregation. Ship each layer usable.
