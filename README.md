## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

- https://book.getfoundry.sh/

- Request testnet LINK and ETH here: https://faucets.chain.link/
- Find information on LINK Token Contracts and get the latest ETH and LINK faucets here:
- - https://docs.chain.link/docs/link-token-contracts/
- - https://docs.chain.link/vrf/v2-5/getting-started
 

## Usage

### Init (in case of start new development from scratch)

```shell
$ forge init --force
$ forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit
$ forge install transmissions11/solmate@v6
[Cyfrin/foundry-devops](https://github.com/Cyfrin/foundry-devops)
$ forge install Cyfrin/foundry-devops
```

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
instead of cast sig "..." you can check it in https://4byte.sourcify.dev/



### Tests
1. Write deploy scripts
    1. Note, this will not work on zkSync
2. Write Tests
    1. Local chain
    2. Forked testnet
```shell
$ forge test --fork-url $SEPOLIA_RPC_URL
$ forge test --fork-url $SEPOLIA_RPC_URL -vvvv
```    
    3. Forked mainnet

### Test's Types
1. Unit Test
2. Integrations
3. Forked
4. Staging <- run tests on a mainnet or testnet

5. Fuzzing
6. Stateful fuzz
7. Stateless fuzz
8. Format verification

### Make
```shell
$ make all 
$ make test 
$ make clean 
$ make deploy 
$ make fund 
$ make help 
$ make install 
$ make snapshot 
$ make format 
$ make anvil 
``` 

```shell
do not forget to create zou .env file
RAW_PRIVATE_KEY=put your data here, better to use accounts
RPC_URL=http://127.0.0.1:8545
SEPOLIA_RPC_URL=put your data here
MAINNET_RPC_URL=put your data here
ETHERSCAN_API_KEY=put your data here 

without keeping the key in the .env
$ cast wallet import defaultKey --interactive
> need to use Private Key for your account for particular Network. To get the private key need to:
1. go to Metamask 
2. select the Account
3. settings "3 dots"
4. Account Details
5. Private Keys (Unlock to reveal)
6. Use you Metamask Password
7. Select the network .... Account / Private keys ->>> Press Copy Button in the right (next to account)
> `defaultKey` keystore was saved successfully. Address: 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
check it ...
$ cast wallet list
>defaultKey (Local)


$ source .env
$ make help
> make deploy ARGS="--network sepolia"
> contract deployed with address 0x66644f18e926caddf4af392a0334753e3d4af83b
``` 

### connect to chain-link
1. start from https://faucets.chain.link/
2. connect your wallet
3. check the Data & Cross-chain & Compute 
