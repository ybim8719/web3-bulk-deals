# List of useful tips for foundry


### Create a new forge project : 

```
forge init <name-of-project>
```


Anvil local endpoint : http://127.0.0.1:7545

Anvil tests private keys list : 

(0)0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
(1)0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
(2)0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a

### Deployment on Anvil :

Basic command (anvil must be active on another terminal)

```
forge create SimpleStorage --rpc-url http://127.0.0.1:7545
```

A prompt will appear to get the private key input:

```
forge create SimpleStorage --rpc-url http://127.0.0.1:7545 --interactive
```

on-command method (bad):

```
forge create SimpleStorage --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

### Deploy a contract by using a script: 

```
forge script script/DeploySimpleStorage.s.sol
```

On Anvil : 

```
forge script script/DeployBulkDeal.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```
Using .env

```
forge script script/DeploySimpleStorage.s.sol --rpc-url $RPC_URL --broadcast --private-key $PRIVATE_KEY
```

### A great way to secure your private key using cast : 

```
cast wallet import <nameOfAccountGoesHere> --interactive
```
You will be asked for your private key and a password to secure it. You will do this only once.

an address will be showned. Save it for next step : 

```
forge script script/DeploySimpleStorage.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --account <nameOfAccountGoesHere> --sender <address-retrieved-on-prevstep>
```
List of accounts created here : 

```
cast wallet list
```

### Use cast to interact with deployed contract : 

Example 1 : 

```
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "store(uint256)" 1337 --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

* `0x5FbDB2315678afecb367f032d93F642f64180aa3` or any other address is the target of our `cast send`, the contract we are interacting with;

* `"store(uint256)"` is the [signature of the function](https://ethereum.stackexchange.com/questions/135205/what-is-a-function-signature-and-function-selector-in-solidity-and-evm-language) we are calling.

* `1337` is the number we pass to the `store` function. As we can see in the function signature, we are expected to provide an `uint256` input. You can obviously provide any number you want, as long as it fits `uint256`.



Reading from contract :

```
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "retrieve()"
```

### Use cast to convert hexadecimal to decimal :

```
cast --to-base 0x0000000000000000000000000000000000000000000000000000000000000539 dec
```

### Install chainlist as a dependency

```
forge install smartcontractkit/chainlink-brownie-contracts@1.2.0 --no-commit
```

version to be found here : https://github.com/smartcontractkit/chainlink-brownie-contracts
current version is 1.2.0 


in toml for imports : 
remappings = ['@chainlink/contracts/=lib/chainlink-brownie-contracts/contracts/']

## tests

```
forge test -vvv
```

forge test --mt <name-of-test-function>
forge coverage --fork-url $SEPOLIA_RPC_URL
forge test --mt <name-of-test-function> --fork-url $SEPOLIA_RPC_URL

deploy using script 

