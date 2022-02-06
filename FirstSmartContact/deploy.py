from solcx import compile_standard, install_solc
import json
from web3 import Web3
import os
from dotenv import load_dotenv

load_dotenv()

with open("./SimplesStorage.sol", "r") as file:
    simple_storage_file = file.read()

install_solc("0.6.0")

print("Installing...")
compiled_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": simple_storage_file}},
        "settings": {
            "outputSelection": {
                "*": {
                    "*": ["abi", "metadata", "evm.bytecode", "evm.bytecode.sourceMap"]
                }
            }
        },
    },
    solc_version="0.6.0",
)

with open("./compiled_code.json", "w") as file:
    json.dump(compiled_sol, file)

# get bytecode
bytecode = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"][
    "bytecode"
]["object"]

# get abi
abi = json.loads(
    compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["metadata"]
)["output"]["abi"]

# For connecting to ganache
w3 = Web3(Web3.HTTPProvider("HTTP://127.0.0.1:7545"))
chain_id = 1337
my_address = "0xC68D3e011843d7Fa344eedd3319586Ca2b3a2b6F"
private_key = os.getenv('private_key')
print (private_key)

# Create the contract in Python
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)
print(SimpleStorage)
# GET THE LATEST TEST TRANCSACTION
nonce = w3.eth.getTransactionCount(my_address)
print(nonce)
# 1 build transaction
# 2 sign a transaction
# 3 Send a transaction
transaction = SimpleStorage.constructor().buildTransaction(
    {
        "gasPrice": w3.eth.gas_price,
        "chainId": chain_id,
        "from": my_address,
        "nonce": nonce,
    }
)
print(transaction)
signed_txn = w3.eth.account.sign_transaction(transaction, private_key=private_key)
print("Deploying Contract!")
# Send it!
tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
# Wait for the transaction to be mined, and get the transaction receipt
print("Waiting for transaction to finish...")
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
print(f"Done! Contract deployed to {tx_receipt.contractAddress}")

# Working with deployed Contracts
# We need ABI and tx_receipt.contractAddress for calling fucntion
simple_storage = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)
# Two way for using smart contract 
# 1 call -> simulate making the call and getting return value (Not making state change)
# 2 transact -> Making State change (can use for view and function) will makeing state change
# Making call function
print(f"Initial Stored Value {simple_storage.functions.retrieve().call()}")

# Making transaction 
greeting_transaction = simple_storage.functions.store(15).buildTransaction(
    {
        "chainId": chain_id,
        "gasPrice": w3.eth.gas_price,
        "from": my_address,
        "nonce": nonce + 1,
    }
)
signed_greeting_txn = w3.eth.account.sign_transaction(
    greeting_transaction, private_key=private_key
)
tx_greeting_hash = w3.eth.send_raw_transaction(signed_greeting_txn.rawTransaction)
print("Updating stored Value...")
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_greeting_hash)

print(simple_storage.functions.retrieve().call())

# for cli https://docs.nethereum.com/en/latest/ethereum-and-clients/ganache-cli/#:~:text=Ganache%20CLI%20is%20the%20latest,running%20an%20actual%20Ethereum%20node.&text=Accounts%20can%20be%20re%2Dcycled,need%20for%20faucets%20or%20mining).
# For running owh blobkchain node
# https://github.com/ethereum/go-ethereum
# https://infura.io/ or https://www.alchemy.com/ for making eth data
# Foir checking chain id