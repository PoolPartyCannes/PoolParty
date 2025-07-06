<h1 align="center">
🏊🏊‍♀️🏊‍♂️ Pool Party ️🏊🏊‍♀️🏊‍♂️
</h1>

<h4 align="center">
  <a href="https://poolparty-53ma9ewcr-zenis-projects.vercel.app/">Website</a>
  <p align="center">
    <img src="./assets/walrus.png" alt="Logo" width="300" height="auto">
  </p>
</h4>

🦭 As crypto matures, more and more companies with already existing tokens and holders will merge, both as companies, and probably as tokens too. While it is better for rebranding, this is usually a very capital inefficient process where old liquidity gets stuck and companies will just have to add aditional liquidity into a new pool. Pool Party is a platform that allows companies to create a deposit phase, and then have the old liquidity bootstrap the new company and ecosystem, while users will get their verifiable fair share of the pie. 🍰

- ⛓️ **Multi EVM**: Thanks to Flow we can support multiple different evms allowing us to scale to mainstream audiences and seamlessly connect to digital ecosystems. 
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

### ⛓️‍💥 Flow - Best Platform for Widespread Adoption
We created this protocol hoping to reach the masses, and support multiple different EVMs. Building on flow lets us put killer apps in the hands of consumers.

### 🌴 Oasis Protocol - Build on Oasis Stack
For all the protocol signing, as well as orchestrating the retrieval of solidity data from Walrus to create a diamond cut facet, we're making use of the Oasis ROFL TEE as an API endpoint.

### 🦭 Walrus - Best app using Walrus for storage  
To securily, transparently and verifiably store the custom company solidity logic that they will cut into their diamond facet, we have this stored, read and fetched from Walrus

## Next steps

- From the reactions we've gotten when talking to people here about the project we think it is clear to say that this is a product that is actually usefull. We would really like to be able to at least bring it to a minimum production state after the hackathon with a bit of support, so that we can give this to the world.

## Links

- [Vercel](https://poolparty-53ma9ewcr-zenis-projects.vercel.app/)
- [Github](https://github.com/PoolPartyCannes/PoolParty)

### Deployments
- [Implementation (Flow)](https://www.flowscan.io/evm/account/0xe0a3a7d5E6d51e94EaEFc6662A20559C43a112d3)
- [Token Implementation (Flow)](https://www.flowscan.io/evm/account/0x386efeB7F57B10d1D44D12Dc3B8BbB42D8bd7f26)
- [Factory (Flow)](https://www.flowscan.io/evm/account/0x2e1a345a30a5250989CB4825043863f4001bd3aa)

## Team

- [PF](https://x.com/poisonedfunctor)
- [0xjsi.eth](https://x.com/0xjsieth)