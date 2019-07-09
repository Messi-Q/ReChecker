pragma solidity ^0.4.23;

 
 
 
 
 
 

contract CryptoRoulette {

    uint256 private secretNumber;
    uint256 public lastPlayed;
    uint256 public betPrice = 0.001 ether;
    address public ownerAddr;

    struct Game {
        address player;
        uint256 number;
    }
    Game[] public gamesPlayed;

    constructor() public {
        ownerAddr = msg.sender;
        shuffle();
    }

    function shuffle() internal {
         
        secretNumber = 6;
    }

    function play(uint256 number) payable public {
        require(msg.value >= betPrice && number <= 10);

        Game game;
        game.player = msg.sender;
        game.number = number;
        gamesPlayed.push(game);

        msg.sender.transfer(this.balance);
         
         
         
         

         
        lastPlayed = now;
    }

    function kill() public {
        if (msg.sender == ownerAddr && now > lastPlayed + 6 hours) {
            suicide(msg.sender);
        }
    }

    function() public payable { }
}