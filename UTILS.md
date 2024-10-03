new forge project : forge init <name>

anvil endpoint : http://127.0.0.1:7545
anvil tests private keys: 
(0) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
(1) 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
(2) 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a

several ways to deploy in anvil : 

forge create SimpleStorage --rpc-url http://127.0.0.1:7545
forge create SimpleStorage --rpc-url http://127.0.0.1:7545 --interactive
forge create SimpleStorage --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

deploy from script 
forge script script/DeploySimpleStorage.s.sol

deploy to anvil from script 
forge script script/DeployBulkDeal.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80


forge script script/DeploySimpleStorage.s.sol --rpc-url $RPC_URL --broadcast --private-key $PRIVATE_KEY

secure private key 

cast wallet import nameOfAccountGoesHere --interactive

cast wallet list

