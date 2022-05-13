// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Banco {


    constructor() payable {

    }

    function incrementBalance(uint256 _amount) payable public {
        // Agrega saldo al contrato
        require(msg.value == _amount);
    }

    function getBalance() public {
        // Envia saldo a la addresss que ejecuta el contrato
        msg.sender.transfer( address(this).balance );
    }
}