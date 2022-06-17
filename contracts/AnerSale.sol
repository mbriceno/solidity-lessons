// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface Aner {
    function decimals() external view returns(uint8);
    function balanceOf(address _address) external view returns(uint256);
    function transfer(address _to, uint256 _value) external returns (bool success);
}

contract AnerSale {
    address owner;
    uint256 price;
    Aner anerContract;
    uint256 tokensSold;

    event Sold(address buyer, uint256 amount);

    constructor(uint256 _price, address _addressContract) {
        owner = msg.sender;
        price = _price;
        anerContract = Aner(_addressContract);
    }

    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function buy(uint256 _numTokens) public payable {
        // Valida que la direccion del usuario que compra tenga saldo para comprar la cantida de tokens que pide
        require(msg.value == mul(price, _numTokens));
        // Lleva el numero de tokens a escala de decimales
        uint256 scaledAmount = mul(_numTokens, uint256(10) ** anerContract.decimals());
        // Valida que haya balance en el contrato de venta para cubrir los tokens que se están comprando
        require( anerContract.balanceOf( address(this) ) >= scaledAmount);
        tokensSold += _numTokens;
        require( anerContract.transfer(msg.sender, scaledAmount) );
        emit Sold(msg.sender, _numTokens);
    }

    function endSold() public {
        require(msg.sender == owner);
        // Transfiere balance del contrato de venta al dueño del contrato
        require( anerContract.transfer( owner, anerContract.balanceOf( address(this) ) ) );
        payable(msg.sender).transfer(address(this).balance);
    }
}