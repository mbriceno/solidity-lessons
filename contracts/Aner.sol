// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Aner {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    // direcciones con el saldo que contienen
    mapping(address => uint256) public balanceOf; 
    // Mapping de las direcciones asociadas que el dueño del contrato permitira que manejen cierta cantidad de tokens
    mapping(address => mapping(address => uint256)) public allownce;

    constructor() {
        name = "Aner";
        symbol = "ANR";
        decimals = 8;
        totalSupply = 100000000 * (uint256(10) ** decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        // Asigna los tokens que puede manejar una direccion
        allownce[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // Tranfiere balance de una direccion aprobada por el dueño del contrato a otra direccion
        require(balanceOf[_from] >= _value);
        require(allownce[_from][msg.sender] >= _value);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allownce[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}