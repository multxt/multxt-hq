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

## The business — OSS → community → monetization

This is the strategy, not an afterthought. multxt is a **developer go-to-market**: win
mindshare with free, genuinely excellent open-source tooling, build a community around the
`-xt` ecosystem, then monetize the layers that are painful to self-host.

**1. Acquire dev mindshare (free, MIT).** ccxt is installed everywhere because it's free
and unavoidable; pmxt is replaying that move in prediction markets. `smxt` claims the
unclaimed "ccxt for stocks" slot, and `multxt` is the agent-native CLI that ties the family
together. The libraries are the top of the funnel — the wider they spread, the bigger the
addressable base. Distribution wins: npm, GitHub, the Claude plugin marketplace, the
`-xt` brand.

**2. Build community.** Contributors per connector (the ccxt model — the community maintains
the long tail of venues), a Discord, good docs on `multxt.dev`, and the ecosystem framing
("the `-xt` family") that makes people want to belong to it. Community = free maintenance,
free distribution, free credibility, and a warm audience for everything paid.

**3. Monetize the hard parts (open-core).** The free core stays free; revenue comes from
what developers and traders will pay to *not* run themselves:
- **Hosted / managed execution & data** — the paid, reliable, low-latency layer (ccxt's own
  model: open core + paid Pro/websocket; pmxt's hosted API is the same move).
- **Pro agent layer** — hosted MCP endpoint, multi-account dashboards, alerting, audit logs,
  the convenient "research → confirm → execute" surface for non-CLI users.
- **Strategy & connector marketplace** — take a cut of paid strategies/plugins built on the
  protocol.
- **Enterprise** — support, SLAs, private connectors, white-label for funds/desks.

**Why this compounds toward the $10M goal:** the funnel is developers (cheap to reach, high
intent), the moat is the ecosystem + community (hard to replicate), and the monetization is
recurring and usage-scaled. It also feeds Plutous — the same connector layer and the same
agent-execution rails are dual-use.

**The wedge competitors can't copy:** non-custodial, bring-your-own-keys, any-venue. A
custodial platform (Liquid's Co-Invest, etc.) can bolt on AI, but it will never route to its
competitors' venues or let users keep their own keys. We start from the open, neutral layer —
the place an ecosystem can actually form.

## What success looks like

- smxt becomes the obvious answer to "is there a ccxt for stocks?"
- `mxt` is the command people reach for to do cross-venue ops without writing glue.
- An agent can, via MCP, research → propose → (human confirms) → execute a trade on the
  user's own account, on any supported venue, with no custody handoff.

## Non-goals

- We are **not** a broker, exchange, or custodian. We never hold funds.
- We are **not** a strategy/alpha product. multxt runs *your* strategies; it doesn't sell them.
- We do **not** hide venue capability behind a lowest-common-denominator API.
