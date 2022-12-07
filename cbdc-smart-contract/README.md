
# CBDC

This demo creates a hypothetical [CBDC][1].  

> These scenarios **DO NOT** accurately represent any banking model or monetary policies.  
> The only aim of discussing these scenarios in the context of this this demo, is to showcase capabilities of a underlying blockchain based smart contract.

Following actors are involved in our CBDC setup:

1. Central bank - controls supply of the CBDC
2. Consumers - users for the CBDC

# Digital Wallets

All the users will interact with our CDBC using a [crypto wallet][3].

> It is important to note that the crypto wallet only stores the private key for the user.  
> This key is used to _sign_ the transactions on behalf of the customer.
> The actual asset or coins remain on the network.

## MetaMask

> **DO NOT** use your real life crypto wallet to interact with this demo.  
> 
> This environment will be wiped away regularly.  
> There is NO way we can help you recover assets left on the network.

Metamask can used to [create a test wallet][2] to interact with this demo.

# CBDC Functions

Our CBDC is [ERC20][5] compliant.  All the functions supported by our CBDC are explained below.

## Token in existence `totalSupply`

Get the amount of CBDC in circulation.

## Balance of an account `balanceOf`

Get the total amount of CBDC owned by the account.

## Check line of credit `allowance`

Get the outstanding credit the receiver has with a particular _credit_ provider.  
Allows a supplier to check viability of the purchaser (credit receiver) to pay for the goods/services.

## Pay the receiver `transfer`

Send the specified amount to the receiver

## Approve a line of credit `approve`

Set an approved amount of credit.

## Minting

Only the central bank can mint new coins.

## Pay using credit `transferFrom`

Sends the requested amount of token to the receiver.  
The caller needs to have approved line of credit with the _credit provider_.  
This allows the _credit provider_ to directly pay the supplier of the _service_ for which the _caller_ would have received the credit approval.

# References

- [Understanding ERC20 token based smart contracts][5]

---------
[1]: https://www.investopedia.com/terms/c/central-bank-digital-currency-cbdc.asp
[2]: https://www.youtube.com/watch?v=xeIkeB8iUrM
[3]: https://en.wikipedia.org/wiki/Cryptocurrency_wallet
[4]: https://en.wikipedia.org/wiki/Reserve_requirement#Countries_and_districts_without_reserve_requirements
[5]: https://ethereum.org/en/developers/tutorials/understand-the-erc-20-token-smart-contract/#a-basic-implementation-of-erc-20-tokens
