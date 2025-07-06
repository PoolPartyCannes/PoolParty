<h1 align="center">
🏊🏊‍♀️🏊‍♂️ Pool Party ️🏊🏊‍♀️🏊‍♂️
</h1>

<h4 align="center">
  <a href="https://sloths-warsaw.vercel.app/">Website</a> |
  <a href="https://devfolio.co/projects/sloth-shaming-bea7">Devfolio</a>
  <p align="center">
    <img src="./assets/walrus.png" alt="Logo" width="300" height="auto">
  </p>
</h4>

🦭 As crypto matures, more and more companies with already existing tokens and holders will merge, both as companies, and probably as tokens too. While it is better for rebranding, this is usually a very capital inefficient process where old liquidity gets stuck and companies will just have to add aditionall liquidity into a new pool. Pool Party is a platform that allows companies to create a deposit phase, and then have the old liquidity bootstrap the new company and ecosystem, while users will get their verifiable fair share of the pie. 🍰

- ⛓️ **Cross Chain**: Thanks to LayerZero we can support multiple different evms, and the new token created will be a OFT token, meaning it will be crosschain out of the box.
- 💎 **Shine bright like a Diamond**: Companies won't want to deploy a plain ERC20 token. Therefore, we allow companies to sideload their custom functions in the contract with the help of ERC2535 Diamond proxies
- 💰 **Dynamic Amounts of Tokens**: No matter how many tokens you're merging, we got you.
- 👕 **TEEs**: All computations are safe and verifiable, thanks to Oasis ROFL. 

![Landing page](assets/ui.png)

## Party Finality Date 📆 

When the party's finality date is reached, all tokens will get sold. After that we will use a formula to decide how much each person is getting. All tokens are sold for eth, either in one clip, or TWAP:ed during a certain duration chosen by the company upon party creation. First, all ETH is grouped together onto the factory contract of the chain where the token will get deposited. In each party contract, the amount of tokens deposited, and the total eth derived from each side.

🤓 Let's get nerdy! The formula we will use for this is:
```
total_eth_chain_x * (user_deposit_chain_x / total_deposit_chain_x)
```

If the user was a holder of more than one token thats being merged, then it would be this formula for each token the user deposited.

## Diagrams
### Full flow, from company party creation to token deployment
![Full flow](assets/diagram.png)

## Bounties 😎

### ⛓️‍💥 LayerZero - Best Omnichain DeFi Primitive
We created this protocol to be cross chain, and support multiple different chains. It is fully powered as an OApp, making use of LayerZero's compose feature.

### 🌴 Oasis Protocol - Build on Oasis Stack
For all the protocol signing, as well as orchestrating the retrieval of solidity data from Walrus to create a diamond cut facet, we're making use of the Oasis ROFL TEE as an API endpoint.

### 🦭 Walrus - Best app using Walrus for storage  
To securily, transparently and verifiably store the custom company solidity logic that they will cut into their diamond facet, we have this stored, read and fetched from Walrus

## Next steps

- From the reactions we've gotten when talking to people here about the project we think it is clear to say that this is a product that is actually usefull. We would really like to be able to at least bring it to a minimum production state after the hackathon with a bit of support, so that we can give this to the world.

## Links

- [Devfolio](https://devfolio.co/projects/sloth-shaming-bea7)
- [Vercel](https://sloths-warsaw.vercel.app/)
- [Github](https://github.com/PoolPartyCannes/PoolParty)

### Deployments
- [Deployment Celo](https://explorer.celo.org/alfajores/address/0x81afFbf9392a1402B44B8b6C45C89F602657b3eF)
- [Deployment Sei](https://seitrace.com/address/0xF519289Ed67326514c6Eb47851f9e605DC8ad640?chain=pacific-1)

## Team

- [Mikael](https://x.com/poisonedfunctor)
- [0xjsi.eth](https://x.com/0xjsieth)