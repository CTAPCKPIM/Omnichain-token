# __Creating and sending ONFT, using the Foundry__

__Smart contract__ for creating ONFT, and sending it to another chain;
___[Foundry](https://book.getfoundry.sh/)___.
> __Goerli and fantom testnet forks is used__

### Functions of the smart contract:
 + `sendToken();` - the function for sending a token (message); 
 + `receiveToken();` - the function for receiving a token (message);; 

# __Foundry__

### __Install:__
[__On Windows__](https://book.getfoundry.sh/getting-started/installation#on-windows-build-from-source) __|__
[__On Linux and macOS__](https://book.getfoundry.sh/getting-started/installation#on-linux-and-macos)

### __First Steps with Foundry [here](https://book.getfoundry.sh/getting-started/first-steps#first-steps-with-foundry)__

### __Files in a project:__
__About dependencies read [here](https://book.getfoundry.sh/projects/dependencies?highlight=rem#dependencies)__

`remappings.txt` - helps to [remmaping](https://book.getfoundry.sh/projects/dependencies?highlight=rem#remapping-dependencies) dependencies for import in a project.

    $ remappings.txt
    solmate/=/lib/solmate/src/

`.gitmodules` - this pulls the library, stages the [.gitmodules](https://book.getfoundry.sh/projects/dependencies?highlight=.gitmodules#adding-a-dependency) file in git and makes a commit with the message "Installed".

__Configuring with foundry.toml [here](https://book.getfoundry.sh/config/?highlight=foundry.toml#configuring-with-foundrytoml)__

`foundry.toml` - configurations for Forge.

__Continuous Integration [here](https://book.getfoundry.sh/config/continous-integration?highlight=workflows#continuous-integration)__

`.github/workflows` - git action [installed](https://book.getfoundry.sh/config/continous-integration?highlight=workflows#github-actions) automatically Forge.

### __Main commands:__
+ `forge build` - for compile contracts;
+ `forge test` - for testing contracts;
+ `forge coverage` - for see coverage;
+ `froge help` - will show you more commands;

> Forge can produce [__traces__](https://book.getfoundry.sh/forge/traces#understanding-traces) either for failing tests (-vvv) or all tests (-vvvv). 
 `forge test -vvv/vvvv`

#### Command 'test':
If you want to _start_ your tests in the [__fork__](https://book.getfoundry.sh/forge/fork-testing#fork-testing):

    forge test --fork-url <your_rpc_url>
> In this project using the command `forge test`

__Inside: `test/OmnichainNFT.t.sol`__  
```Solidity
string RPC_URL_GOERLI = "https://goerli.infura.io/<your_key>";
string RPC_URL_FTM = "https://fantom-testnet.blastapi.io/<your_key>";
```

#### Command 'coverage':
If you want to see your _coverage_ in tests in the [__fork__](https://book.getfoundry.sh/forge/fork-testing#fork-testing):

    forge coverage --fork-url <your_rpc_url>

#### __How to write tests using [Forge Standart lib](https://book.getfoundry.sh/forge/writing-tests#writing-tests)__

#### __[Сheat codes](https://book.getfoundry.sh/cheatcodes/#cheatcode-types) are used for manipulate the state of the blockchain, as well as test for specific reverts and events.__

#### __Code example:__
```Solidity
function testExample() public {
    address alice = makeAddr("alice"); // Creating the address 0x4Fa...Tt
    address bob = makeAddr("bob"); // Creating the address 0xR6a...Hf

    hoax(alice, ETH); // analog '.connect(alice)' in ethers
    IERC20(address).approve(bob, amountTransfer);

    vm.stopPrank(); // Stops an active prank started by 'hoax(alice);'

    hoax(bob, ETH); // analog '.connect(bob)' in ethers
    IERC20(address).transferFrom(alice, bob, amountTransfer);
}
```