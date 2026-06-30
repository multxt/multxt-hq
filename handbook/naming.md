# Naming — the `-xt` convention

## The pattern

`-xt` = **e**`X`**change **T**rading. The prefix names the asset class:

| Name | Expansion | Domain |
|---|---|---|
| `ccxt` | **C**rypto**C**urrency e**X**change **T**rading | crypto CEX/DEX |
| `pmxt` | **P**rediction **M**arket e**X**change **T**rading | prediction markets |
| `smxt` | **S**tock **M**arket e**X**change **T**rading | stock/broker APIs |
| `multxt` | **MUL**ti e**X**change **T**rading | the layer above all of them |

`multxt` deliberately breaks the 4-letter mold: it isn't *another* asset-class connector,
it's the **aggregation + operations + CLI** layer that composes the connectors. The `mul`
(multi) signals "across all `-xt` libraries."

## Binaries & packages

| Thing | Value |
|---|---|
| CLI binary | `mxt` |
| GitHub org | `github.com/multxt` |
| npm scope | `@multxt/*` (e.g. `@multxt/core`, `@multxt/smxt`, `@multxt/mcp`) |
| Domain | `multxt.dev` |

`mxt` (3 letters) is the daily-driver command — short, like `git`/`gh`. The packages are
scoped under `@multxt` because bare names are squatted on npm.

## Conventions for new connectors

- A connector file is named for its venue id: `alpaca.ts`, `ibkr.ts`, `binance` (via ccxt).
- The venue `id` is lowercase, no spaces (`'alpaca'`, `'ibkr'`, `'futu'`).
- Display `name` is human-readable (`'Alpaca'`, `'Interactive Brokers'`, `'Futu'`).

## Future `-xt` slots (open)

The pattern extends cleanly if the project grows:

- `fxxt` — FX / forex brokers
- `cmxt` — commodities / futures
- `bmxt` — bond / fixed-income

These are *not* committed work — just reserved conceptual space. multxt aggregates whatever
`-xt` libraries exist.
