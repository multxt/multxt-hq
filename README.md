<h1 align="center">multxt-hq</h1>

<p align="center"><b>The monorepo hub for the <code>-xt</code> family — universal, CLI-first, agent-native trading tooling.</b></p>

---

`ccxt` unified crypto exchanges. `pmxt` unified prediction markets. **`smxt`** unifies
stock brokers. **`multxt`** sits on top of all three and turns them into one operable
surface — a CLI and a library built for humans *and* agents.

```
   ┌─────────┐   ┌─────────┐   ┌─────────┐
   │  ccxt   │   │  pmxt   │   │  smxt   │     connectors  — "talk to one venue"
   │ crypto  │   │ pred.   │   │ brokers │
   └────┬────┘   └────┬────┘   └────┬────┘
        └────────────┬┴─────────────┘
                ┌────▼────┐
                │ multxt  │                    aggregation — "operate across all venues"
                │  + mxt  │                    ops · strategies · CLI · MCP
                └─────────┘
```

## The family

| Repo | Name | Scope | Status |
|---|---|---|---|
| [`multxt`](https://github.com/multxt/multxt) | **Mul**ti e**X**change **T**rading | Aggregation layer + `mxt` CLI + MCP. Ops, strategies, cross-venue. | scaffold |
| [`smxt`](https://github.com/multxt/smxt) | **S**tock **M**arket e**X**change **T**rading | Unified API over stock/broker APIs (Alpaca, IBKR, Futu, …). | scaffold |
| [ccxt](https://github.com/ccxt/ccxt) ↗ | **C**rypto**C**urrency e**X**change **T**rading | Unified API over crypto CEX/DEX. | external |
| [pmxt](https://pmxt.dev) ↗ | **P**rediction **M**arket e**X**change **T**rading | Unified API over prediction markets. | external |

## Principles

1. **CLI-first.** Every capability is a deterministic command with `--json` and clean
   exit codes — scriptable and pipeable, in the spirit of `frarber`.
2. **Agent-native.** Machine-readable output and an MCP surface make the tools
   first-class for LLM agents: research → suggest → confirm → execute.
3. **Non-custodial.** Your keys, your venues. The tools route to *your* accounts and
   never hold funds.
4. **Unified, not lowest-common-denominator.** Mirror ccxt's `has`-capability model so
   venue-specific power isn't lost behind the abstraction.
5. **Open source.** MIT, contribution-friendly, one connector per file.

## Layout

```
multxt-hq/
├── handbook/          the why + the how (read this first)
│   ├── vision.md        why multxt exists, the wedge
│   ├── architecture.md  the -xt family, the layer model, the unified interface spec
│   ├── roadmap.md       phased plan
│   ├── naming.md        the -xt convention
│   └── contributing.md  how to add a connector / op / command
├── multxt/            (submodule) aggregation layer + mxt CLI
└── smxt/              (submodule) unified stock-broker library
```

## Quickstart

```bash
git clone --recurse-submodules https://github.com/multxt/multxt-hq.git
cd multxt-hq
make bootstrap     # init submodules + install deps
make build         # build every package
```

## License

[MIT](./LICENSE) — © 2026 multxt contributors.
