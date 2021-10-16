// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
contract Chohan {
    
    address payable public player1;
    address payable public player2;
    
    uint public betAmount;
    uint public p1Choice; // 0 indicates p1 chose Even, 1 indicates p1 chose Odd
    bool public isGameCreated = false;
    
    address lastWinner;
    address lastLoser;
    
    struct gameLog {
        address winner;
        address loser;
        uint amount;
    }
    
    gameLog[10] public recentLogs;
    
    event gameCreated(address, uint, uint);
    event gameFinished(address, uint, uint);
    // event logUpdated(gameLog[]);
    
    function createGame(uint _p1Choice) external payable {
        require(!isGameCreated, "Game is already created");
        require(msg.sender.balance >= msg.value, "Not enough balance to create a game");
        player1 = payable(msg.sender);
        betAmount = msg.value;
        p1Choice = _p1Choice;
        isGameCreated = true;
        player2 = payable(address(0));
        emit gameCreated(player1, betAmount, p1Choice);
    }
    
    function joinGame() external payable {
        require(isGameCreated, "No game created");
        require(msg.sender.balance >= betAmount, "Not enough balance to join the game");
        player2 = payable(msg.sender);
        isGameCreated = false;
        rollDice();
        updateLogs();
    }
    
    function cancelGame() external {
        require(isGameCreated, "No game created");
        require(msg.sender == player1, "You are not creator of the game");
        isGameCreated = false;
        player1 = payable(address(0));
    }
    
    function rollDice() private {
        uint dice1 = randomDice(betAmount);
        uint midFactor = randomDice(dice1);
        uint dice2 = randomDice(midFactor);
        bool p1Won = p1Choice == (dice1 + dice2) % 2;
        address payable winner;
        winner = p1Won? player1 : player2;
        winner.transfer(betAmount * 9 / 5);
        lastWinner = winner;
        lastLoser = p1Won? player2 : player1;
        emit gameFinished(player2, dice1, dice2);
    }
    
    function updateLogs() private {
        // gameLog[] results = new gameLog[](10);
        for(uint i = 0; i < 9; i++) {
            recentLogs[9 - i] = recentLogs[8 - i];
            // results[9 - i] = recentLogs[8 - i];
        }
        recentLogs[0] = gameLog(lastWinner, lastLoser, betAmount);
        // results[0] = recentLogs[0];
        // emit logUpdated(results);
    }
    
    function randomDice(uint randomFactor) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, randomFactor))) % 6 + 1;
    }
}