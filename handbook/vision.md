# Vision

## The one-liner

**One operable surface for every market — built for agents first.**

`ccxt` made it trivial to *talk to* any crypto exchange. `pmxt` did the same for
prediction markets. But "talk to a venue" is not "operate a book." Traders still glue
together leverage tweaks, margin moves, transfers, rebalances, and price diffs across a
dozen venues with bespoke scripts. And the new operator — an LLM agent — has no
first-class, non-custodial, multi-venue tool to drive any of it.

multxt is that tool.

## The wedge

Three shifts make this the right project at the right time:

1. **The `-xt` pattern won.** ccxt is the de-facto standard for crypto. pmxt extended it
   to prediction markets. The convention — unified API, one connector per venue, a `has`
   capability map — is proven and loved. It has simply never been pushed *up* (into an
   operations/aggregation layer) or *sideways* (into stock brokers). We do both.

2. **Agents need execution rails.** Every "AI trading" product today is either custodial
   (you deposit with them — e.g. Liquid's Co-Invest) or a chatbot with no execution. The
   gap is a **non-custodial, CLI/MCP, bring-your-own-keys** layer an agent can drive
   against the *user's own* accounts. That's structurally something a custodial platform
   can never offer — they won't route to their competitors.

3. **CLI is the agent-native interface.** A clean CLI with `--json` and deterministic exit
   codes is, with a thin wrapper, also an MCP server. Build the CLI well and the agent
   surface comes nearly for free. `frarber` already proved this shape works for real money.

## What we're building

- **smxt** — the missing `-xt` library: a unified API over stock/broker APIs. There is no
  "ccxt for stocks" with global/SEA coverage today. This is greenfield.
- **multxt** — the aggregation + operations + CLI layer that composes ccxt + pmxt + smxt
  into one `mxt` command and one library, agent-native by construction.

## Who it's for

- **Multi-venue traders** who live in scripts and want one toolbelt instead of ten.
- **Agent builders** who need a non-custodial execution tool that works against a user's
  own exchange/broker accounts.
- **The OSS community** around ccxt/pmxt who want the layers above and beside them.

## What success looks like

- smxt becomes the obvious answer to "is there a ccxt for stocks?"
- `mxt` is the command people reach for to do cross-venue ops without writing glue.
- An agent can, via MCP, research → propose → (human confirms) → execute a trade on the
  user's own account, on any supported venue, with no custody handoff.

## Non-goals

- We are **not** a broker, exchange, or custodian. We never hold funds.
- We are **not** a strategy/alpha product. multxt runs *your* strategies; it doesn't sell them.
- We do **not** hide venue capability behind a lowest-common-denominator API.
