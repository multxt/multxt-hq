# Contributing

multxt is open source (MIT). The codebase mirrors ccxt's discipline — learn it once, apply
it everywhere.

## Repo map

- **`smxt/`** — unified stock-broker library. Add a broker here.
- **`multxt/`** — aggregation layer + `mxt` CLI. Add an op or a command here.
- **`multxt-hq/`** (this repo) — handbook + submodule pointers. Docs/architecture changes here.

Work happens **inside the submodule**, committed and pushed to that submodule's repo. Then
the gitlink pointer in `multxt-hq` is bumped. Never bump a pointer to an unpushed commit.

## Adding a connector (smxt broker or multxt venue)

Follow the ccxt model:

1. **One file per venue.** `src/connectors/<venue>.ts`, `class Alpaca extends Broker`.
2. **`describe()`** — return static metadata: `id`, `name`, `countries`, `urls`,
   `requiredCredentials`, `fees`, and the `has` map.
3. **`has` capability map** — declare exactly which unified methods the venue supports.
   `true` | `'emulated'` | omitted. Callers feature-detect; they don't try/catch.
4. **Implement only what you `has`.** The base class stubs every unified method to throw
   `NotSupported` — override the ones the venue actually does.
5. **Normalize.** Map the venue's native symbols/ids to the canonical form in
   `loadInstruments()` / `loadMarkets()`. Return the shared `Ticker`/`Order`/`Position`/
   `Balance` shapes — identical across venues.
6. **Errors.** Throw from the shared two-branch hierarchy: `*Error` (business rejection,
   don't retry) vs `OperationFailed`/`NetworkError` (transient, safe to retry).

## Adding a CLI command (multxt)

1. Library function first, command second — the command is a thin wrapper.
2. Support `--json` (machine output) and a human default.
3. Return deterministic exit codes.
4. Side-effecting commands (place order / move funds) must require explicit confirmation or
   `--yes`. Never fire on a bare invocation.

## Style

- TypeScript is the source of truth (ccxt transpiles to other languages from TS — don't
  hand-maintain parallel implementations).
- Keep diffs small and connector-local. No drive-by refactors of the base class in a
  connector PR.

## Security

- Never commit, log, or transmit credentials. Config files (`multxt.yaml`, `.env`) are
  gitignored — keep them that way.
- Don't add a dependency that phones home or bundles telemetry.
