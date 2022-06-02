// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Loteria {
    address internal owner;
    uint256 internal num;
    uint256 public numGanador;
    uint256 public precio;
    bool public juego;
    address public ganador;
    uint256 public inversionInicial;

    constructor(uint256 _numGanador, uint256 _precio) payable {
        owner = msg.sender;
        num = 0;
        numGanador = _numGanador;
        precio = _precio;
        juego = true;
        inversionInicial = msg.value;
    }

    function comprobarAcierto(uint256 _num) private view returns(bool) {
        if (_num == numGanador) {
            return true;
        } else {
            return false;
        }
    }

    function numeroRandom() private view returns(uint256) {
        // Genera un numero aleatorio del 0 al 9
        // now es el tiempo de minado del bloque
        // keccak256 algoritmo para crear un hash
        // abi.encode junta los parametros que se le pasan

        return uint256( keccak256( abi.encode(block.timestamp, msg.sender, num) ) ) % 3;
    }

    function participar() external payable returns(bool resultado, uint256 numero) {
        require(juego == true);
        require(msg.value == precio);
        uint256 numUsuario = numeroRandom();
        bool acierto = comprobarAcierto(numUsuario);

        if (acierto) {
            juego = false;
            payable(msg.sender).transfer(inversionInicial + (num * (precio/2)));
            ganador = msg.sender;
            resultado = true;
            numero = numUsuario;
        } else {
            num++;
            resultado = false;
            numero = numUsuario;
        }
    }

    function verPremio() public view returns(uint256){
        return inversionInicial + (num * (precio/2));
    }

    function retirarFondosContrato() external returns(uint256) {
        require(msg.sender == owner);
        require(juego == false);
        payable(msg.sender).transfer(address(this).balance);
        return address(this).balance;
    }

}