// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "hardhat/console.sol";

contract AnerShare {
    // Security Token para repartir dividendos
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    // direcciones con el saldo que contienen
    mapping(address => uint256) public balanceOf; 
    // Mapping de las direcciones asociadas que el dueño del contrato permitira que manejen cierta cantidad de tokens
    mapping(address => mapping(address => uint256)) public allownce;

    // La cantidad de dividendos totales
    uint256 dividenPerToken;
    // Almacena los dividendos de cada accionario
    mapping(address => uint256) public dividenBalanceOf;
    mapping(address => uint256) public dividenCreditTo;

    function update(address _address) internal {
        uint256 debit = dividenPerToken - dividenCreditTo[_address];
        dividenBalanceOf[_address] += balanceOf[_address] * debit;
        dividenCreditTo[_address] = dividenPerToken;
    }

    function withdraw() public {
        update(msg.sender);
        uint256 amount = dividenBalanceOf[msg.sender];
        dividenBalanceOf[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function deposit() public payable {
        dividenPerToken += (msg.value / totalSupply) * (uint256(10) ** decimals);
        console.log("dividenPerToken: ", msg.value, totalSupply);
        console.log("dividenPerToken: ", dividenPerToken);
    }

    function get_dividenPerToken() public view returns (uint256) {
        return dividenPerToken;
    }

    constructor() {
        name = "Aner Share";
        symbol = "ANRS";
        decimals = 8;
        totalSupply = 100000000 * (uint256(10) ** decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        update(msg.sender);
        update(_to);
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