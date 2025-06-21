-include .env

deploy-sepolia:; forge script script/DeployFundMe.s.sol --rpc-url $(SEPOLIA_RPC_URL) --broadcast --private-key $(DEV_PRIVATE_KEY)