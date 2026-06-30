# Architecture

## The layer model

```
┌──────────────────────────────────────────────────────────────────┐
│  L4  Surfaces        mxt CLI   ·   library API   ·   mxt mcp serve │
├──────────────────────────────────────────────────────────────────┤
│  L3  Strategy        plugin protocol (JSON-lines over stdio)       │
├──────────────────────────────────────────────────────────────────┤
│  L2  Ops             leverage · margin · transfers · rebalance ·   │
│                      price-diff · positions — unified across venues │
├──────────────────────────────────────────────────────────────────┤
│  L1  Connectors      ccxt (crypto) · pmxt (prediction) · smxt      │
│                      (brokers) — each a unified venue API          │
└──────────────────────────────────────────────────────────────────┘
        L1 = the -xt libraries.   L2–L4 = multxt.
```

- **L1 Connectors** are the `-xt` libraries. multxt adapts each into a common internal
  `Venue` shape so L2 ops don't care whether a position lives on Binance, Polymarket, or
  Alpaca.
- **L2 Ops** are venue-agnostic operations. "Set leverage", "move margin to the thinnest
  account", "diff the price of X across two venues" — each works against any connector that
  declares the capability.
- **L3 Strategy** is a plugin boundary: strategies are external executables speaking
  JSON-lines over stdio, so they can be written in any language and sandboxed.
- **L4 Surfaces** are the CLI, the importable library, and the MCP server (a thin wrapper
  over the same command handlers).

## The unified-interface contract (the `-xt` standard)

Every `-xt` connector — ccxt, pmxt, and the one we own, **smxt** — follows the same shape,
proven by ccxt:

### Base class + per-venue subclass

```
abstract class Exchange/Broker {
  id: string
  name: string
  has: Record<Capability, boolean | 'emulated'>   // capability map
  describe(): VenueMetadata                         // static metadata: urls, fees, limits
  markets: Record<symbol, Market>                   // normalized markets, loaded lazily
  async loadMarkets(reload?): Promise<Markets>
}
class Alpaca extends Broker { /* implements the methods it `has` */ }
```

- **`has` capability map** — declares which unified methods a venue supports
  (`{ fetchOHLCV: true, createOrder: true, setLeverage: false, ... }`). Callers check
  `venue.has.setLeverage` instead of try/catching. This is how we stay "unified, not lossy."
- **`describe()` metadata** — id, name, urls, rate limits, fee schedule, supported
  timeframes, precision/limits. Static, declarative.
- **Symbol & market normalization** — a canonical symbol format and a normalized `Market`
  object per instrument, so `BTC/USDT`, `AAPL`, or a Polymarket token all resolve the same way.
- **Error hierarchy** — a shared error tree (`NetworkError`, `ExchangeError`,
  `AuthenticationError`, `InsufficientFunds`, `OrderNotFound`, `RateLimitExceeded`, …) so
  callers handle failures uniformly across venues.

### Core unified methods

Public (no auth):

| Method | Returns |
|---|---|
| `loadMarkets()` | normalized instrument universe |
| `fetchTicker(symbol)` / `fetchQuote(symbol)` | bid/ask/last |
| `fetchOHLCV(symbol, timeframe)` | candles |
| `fetchOrderBook(symbol)` | L2 book |

Private (auth):

| Method | Returns |
|---|---|
| `fetchBalance()` / `fetchAccount()` | cash + buying power |
| `fetchPositions(symbols?)` | open positions |
| `createOrder(symbol, type, side, amount, price?)` | order result |
| `cancelOrder(id, symbol?)` | — |
| `fetchOrder(id)` / `fetchOrders` / `fetchOpenOrders` | order state |
| `fetchMyTrades(symbol?)` | fills |

Derivatives/leverage extensions (where `has` declares them):
`setLeverage`, `setMarginMode`, `setPositionMode`, `fetchFundingRate`, `transfer`.

## smxt — applying the contract to stock brokers

smxt is ccxt's design re-targeted at brokers. The minimum viable `Broker` interface:

- **Auth:** API key/secret or OAuth, per broker. Some brokers (IBKR, Futu) require a local
  **gateway process** (TWS/IB Gateway, Futu OpenD) rather than pure REST — the connector
  abstracts that, but documents the dependency.
- **Market data:** `fetchQuote`, `fetchOHLCV`, `fetchOrderBook` (where available).
- **Account:** `fetchBalance` (cash, buying power, margin), `fetchPositions`.
- **Trading:** `createOrder` (market/limit/stop), `cancelOrder`, `fetchOrders`,
  `fetchOpenOrders`, `fetchMyTrades`.
- **Capabilities via `has`:** fractional shares, extended hours, short selling, options,
  multi-currency — all declared, not assumed.

### Candidate connectors (priority order)

| Broker | Access model | Coverage | Notes |
|---|---|---|---|
| **Alpaca** | REST + websocket | US equities/options/crypto | Cleanest API; the reference connector. |
| **Interactive Brokers** | TCP socket → IB Gateway/TWS | Global, everything | Needs local gateway; `@stoqey/ib` is the TS client. |
| **Futu (moomoo)** | local **OpenD** gateway + SDK | HK · US · A-shares · SGX | Strong SEA coverage. Gateway process required. |
| **Tiger** | REST/SDK | US · HK · SG · A-shares | SEA-relevant alternative to Futu. |

Reference prior art for "unify the brokers": Indian-market projects (`unified-broker`,
OpenAlgo) exist but are region-locked. No global/SEA-first ccxt-equivalent exists — that's
the smxt opening.

## multxt — the aggregation layer

multxt imports the connectors and exposes:

- **`Venue` adapter** — wraps a ccxt exchange / pmxt market / smxt broker into one internal
  interface so L2 ops are connector-agnostic.
- **Ops** (L2) — `set-leverage`, `margin-mode`, `transfer`, `rebalance`, `price-diff`,
  `positions`, `balances`. Each guards on the underlying `has` map.
- **Strategy runner** (L3) — spawns strategy plugins, streams `StrategyEvent`s.
- **CLI / library / MCP** (L4) — `mxt <command> --json`, the importable API, and
  `mxt mcp serve` exposing the same handlers as MCP tools.

### Packaging (precedent: pmxt)

pmxt already splits its surfaces into separate npm packages — `pmxtjs` (SDK),
`@pmxt/cli`, `@pmxt/mcp` — alongside a self-host `pmxt-core`. multxt follows the same
shape: the library is the core, the `mxt` CLI is the primary surface, and `mxt mcp serve`
(or a `@multxt/mcp` package) exposes the same command handlers as MCP tools. Build the CLI
handlers cleanly and the MCP surface is a thin wrapper over them.

### Config

Credentials live in a local, gitignored `multxt.yaml` (à la `frarber.yaml`): per-venue
keys, never committed, never logged. Loaded once at startup. `requiredCredentials` is
per-venue and flexible — HMAC `apiKey`/`secret` for most crypto, OAuth `token`/
`oauthRefreshToken` + `accountId` for brokers.

## Repo boundaries

| Concern | Lives in |
|---|---|
| Crypto venue API | ccxt (external dep) |
| Prediction-market venue API | pmxt (external dep) |
| Stock-broker venue API | **smxt** (we own) |
| Ops, strategy, CLI, MCP | **multxt** (we own) |
| Handbook, submodule orchestration | **multxt-hq** (this repo) |
