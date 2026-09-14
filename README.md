<h1>H20: An ERC20 Written in Huff</h1>

[![CI](https://github.com/tom2o17/H20/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/tom2o17/H20/actions/workflows/test.yml)

<h3>Motivation and Background</h3>

This repository is a learning resource for developers who want to understand how a token works at the level of raw EVM opcodes. `src/H20.huff` is a minimal ERC20 written in [Huff](https://huff.sh), a low-level language that gives you direct control over the stack, memory and storage with almost nothing between you and the bytecode.

Every line of the contract carries a comment showing the stack after that instruction executes, so the file can be read top to bottom as a walkthrough of what the EVM is doing. The storage layout and the memory conventions are documented at the top of the contract. Read that header first.

Note: this token deliberately emits no events. There is not a single `LOG` opcode in the contract, so `Transfer` and `Approval` are never emitted. That keeps the code focused on the core mechanics, but it means the token is not ERC20-compliant for off-chain indexers and should not be deployed as a real token.

<h3>A Brief History of Huff</h3>

Huff was created in 2019 by Zac Williamson at Aztec Protocol. He needed an elliptic curve library (Weierstrudel) that was faster than anything Solidity could produce, and wrote Huff as a thin macro layer over EVM assembly to get there. The original compiler was written in TypeScript.

In 2022 the language was revived by a community that formed the `huff-language` GitHub organisation. A new TypeScript compiler, `huffc`, was written first, followed the same year by `huff-rs`, a rewrite in Rust that became the standard compiler and added Foundry integration through `foundry-huff`. Most Huff code in the wild, including this repository originally, was built with `huff-rs`.

`huff-rs` was archived in October 2024. The organisation's official successor, `huff2`, is a ground-up rewrite that has not yet shipped a release and is still missing features such as `#include`. In the meantime a maintained fork of `huff-rs` called [huff-neo](https://github.com/cakevm/huff-neo) fixes a number of codegen bugs, keeps its dependencies current and ships binaries. This repository uses huff-neo, whose compiler binary is named `hnc`, together with its Foundry harness `foundry-huff-neo`.

<h3>What Is Implemented</h3>

| Function | Notes |
|---|---|
| `owner()` | Set to the deployer in the constructor |
| `mint(uint256)` | Owner only, mints to the caller |
| `balanceOf(address)` | |
| `totalSupply()` | |
| `transfer(address,uint256)` | |
| `approve(address,uint256)` | |
| `allowance(address,address)` | |
| `transferFrom(address,address,uint256)` | Checks both balance and allowance |
| `name()` | Returns the constant `"Token"` |
| `setName(string)` | Writes storage that `name()` never reads, kept as an exercise |
| `decimals()` | Stub: the handler exists but returns no data |

Storage is laid out by hand. Slot `0x00` is the balances mapping base, `0x01` the owner, `0x02` total supply, `0x03` the allowances mapping base. Mapping slots are derived exactly the way Solidity derives them, so the contract can be inspected with standard tooling.

<h2>Prerequisites</h2>

Three tools are needed. Everything else is pulled in by pnpm.

1. **Foundry** (`forge`). Install with [foundryup](https://getfoundry.sh).
2. **pnpm** 12 or later. The exact version is pinned in `package.json` under `packageManager`, so with Corepack or a recent pnpm it will select itself.
3. **The Huff compiler** `hnc` from huff-neo, which must be on your `PATH`. Either use the installer:

```
curl -L https://raw.githubusercontent.com/cakevm/huff-neo/main/hnc-up/install | bash
hnc-up
```

or download a release binary from the [huff-neo releases page](https://github.com/cakevm/huff-neo/releases) and place it on your `PATH`. Confirm with:

```
hnc --version
```

<h2>Installing Dependencies</h2>

All Solidity dependencies (`forge-std` and `foundry-huff-neo`) are managed by pnpm and pinned to exact upstream commits in `package.json`. There are no git submodules. Install them with:

```
pnpm install
```

The Foundry remappings in `foundry.toml` point at `node_modules`, so `forge` picks the packages up directly.

<h2>Building</h2>

```
pnpm build
```

This runs `forge build` and compiles the Solidity test harness. The Huff contract itself is compiled on demand when the tests run.

<h2>Running Tests</h2>

```
pnpm test
```

This runs `forge test`. The test suite in `test/h20.t.sol` compiles `src/H20.huff` with `hnc`, deploys it into the Foundry EVM and exercises every function, including the failure paths for insufficient balance and allowance. Add `-vvvv` for full traces:

```
forge test -vvvv
```

Two settings in `foundry.toml` are worth knowing about. `ffi = true` is required because the harness shells out to `hnc`; be aware that this allows any test to run commands on your machine. `evm_version = "osaka"` matches the EVM version huff-neo compiles for by default, and the contract uses `PUSH0`, so the test EVM must be Shanghai or later.

<h2>Continuous Integration</h2>

`.github/workflows/test.yml` runs on every push to `main` and every pull request. It installs pnpm, Foundry and a pinned version of `hnc`, then runs `pnpm install`, `pnpm build` and `pnpm test`.

<h2>Repository Layout</h2>

```
src/H20.huff              the token, with a stack comment on every line
test/h20.t.sol            Foundry tests, deploy through foundry-huff-neo
foundry.toml              solc version, EVM version, remappings into node_modules
package.json              pinned Solidity dependencies and the build/test scripts
.github/workflows/        CI
```
