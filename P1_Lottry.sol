//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Lottry{
   address  public manager;
   address payable[] public players;
   address payable public winner;

   constructor(){
    manager = msg.sender;
   }
   function participate() public payable{
    require(msg.value==1 ether,"Need Deposit 1 Ether");
    players.push(payable(msg.sender));
   }
   function getBlance() public view returns(uint){
    require(manager==msg.sender,"Only Manger can get this function");
    return address(this).balance;
   }
   function random() internal view returns(uint){
    return uint(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp, players.length)));
   }
   function pickWinner() public{
    require(manager==msg.sender,"You're Not Manager");
    require(players.length>=3,"Player are less then 3");

    uint r = random();
    uint index = r%players.length;
    winner=players[index];
    winner.transfer(getBlance());
    players = new address payable[](0);
   }

}