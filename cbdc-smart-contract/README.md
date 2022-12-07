
# CBDC

This demo creates a hypothetical [CBDC][1].  

> These scenarios **DO NOT** accurately represent any banking model or monetary policies.  
> The only aim of discussing these scenarios in the context of this this demo, is to showcase capabilities of a underlying blockchain based smart contract.

There are three types of actors or stakeholders for our CBDC:

1. Central bank - owner of the smart contract.  Mints coins, and lends money to _Commercial_ banks
2. Commercial bank - that borrows from _Central_ Bank, allows other commercial banks or _consumers_ to deposit or borrow money.
3. Consumer - customers that borrow or deposit money into a _commercial_ bank

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

# Scenarios

## Minting

Only the central bank can mint new coins.  This is like creating money in the economy.

## Lending

Banks can lend money to other banks or consumers.  

## Deposits

Banks can accept deposits from other banks or consumers.

## Position

Traditional view has been that commercial banks should hold set amount of _cash_ in their _vault_.  Meaning that the total amount of money loaned to their customers should be a fraction of the total deposits into the bank.  This allows the bank to honour withdrawal requests from their customers.  

It is important to note that [Central banks like][4] Reserve Bank of Australia and Bank of Canda that have a no reserve policy.

# References

- [Understanding ERC20 token based smart contracts][5]

---------
[1]: https://www.investopedia.com/terms/c/central-bank-digital-currency-cbdc.asp
[2]: https://www.youtube.com/watch?v=xeIkeB8iUrM
[3]: https://en.wikipedia.org/wiki/Cryptocurrency_wallet
[4]: https://en.wikipedia.org/wiki/Reserve_requirement#Countries_and_districts_without_reserve_requirements
[5]: https://ethereum.org/en/developers/tutorials/understand-the-erc-20-token-smart-contract/#a-basic-implementation-of-erc-20-tokens
