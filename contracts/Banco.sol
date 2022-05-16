// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Banco {
    address owner;

    modifier onlyOwner() {
        // Modificador no se le pasan parametros ,se agregan a las demas funciones como middleware para
        // validar/modificar variables
        require(msg.sender == owner);
        _;
    }

    constructor() payable {
        owner = msg.sender;
    }

    function newOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function getOwner() public view returns(address) {
        return owner;
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function incrementBalance(uint256 _amount) public payable  {
        // Agrega saldo al contrato
        require(msg.value == _amount);
    }

    function withdrawBalance() public onlyOwner {
        // Envia saldo a la addresss que ejecuta el contrato
        payable(msg.sender).transfer( address(this).balance );
    }
}