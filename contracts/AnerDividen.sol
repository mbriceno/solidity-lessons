// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.6.0/contracts/utils/math/SafeMath.sol"; 

contract AnerDividend{
 
    using SafeMath for uint256;

    string public name = "Aner Dividend Token";
    string public symbol = "ANRDIV";
    uint8 public decimals = 0;  
    uint256 public totalSupply_ = 1000000;
    uint256 public totalDividendPoints = 0;
    uint256 public unclaimedDividends = 0;
    uint256 internal pointMultiplier = 1000000000000000000;
    address owner;

    
    struct Account{
        uint256 balance;
        uint256 lastDividendPoints;
     }

    mapping(address => Account) public balanceOf;
    
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );


    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier updateDividend(address investor) {
        uint256 owing = dividendsOwing(investor);
        if(owing > 0) {
            unclaimedDividends = unclaimedDividends.sub(owing);
            balanceOf[investor].balance = balanceOf[investor].balance.add(owing);
            balanceOf[investor].lastDividendPoints = totalDividendPoints;
        }
        _;
    }

    constructor () {
        // Initially assign all tokens to the contract's creator.
        balanceOf[msg.sender].balance = totalSupply_;
        owner = msg.sender;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }

    
    /**
     new dividend = totalDividendPoints - investor's lastDividnedPoint
     ( balance * new dividend ) / points multiplier
    
    **/
    function dividendsOwing(address investor) private view returns(uint256) {
        uint256 newDividendPoints = totalDividendPoints.sub(balanceOf[investor].lastDividendPoints);
        console.log("Dividens:", newDividendPoints);
        uint256 owning = (balanceOf[investor].balance.mul(newDividendPoints)).div(pointMultiplier);
        console.log("Balance:", balanceOf[investor].balance);
        console.log("Owning:", owning);
        return owning;
    }

    /**
    
    totalDividendPoints += (amount * pointMultiplier ) / totalSupply_
    **/
    function disburse(uint256 amount) public onlyOwner {
        totalDividendPoints = totalDividendPoints.add((amount.mul(pointMultiplier)).div(totalSupply_));
        totalSupply_ = totalSupply_.add(amount);
        unclaimedDividends =  unclaimedDividends.add(amount);
    }

   function transfer(address _to, uint256 _value) public updateDividend(msg.sender) updateDividend(_to) returns (bool) {
        require(msg.sender != _to);
        require(_to != address(0));
        require(_value <= balanceOf[msg.sender].balance);
        balanceOf[msg.sender].balance = (balanceOf[msg.sender].balance).sub(_value);
        balanceOf[_to].balance = (balanceOf[_to].balance).add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    mapping (address => mapping (address => Account)) internal allowed;

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        updateDividend(_from)
        updateDividend(_to)
        returns (bool)
    {
        require(_to != _from);
        require(_to != address(0));
        require(_value <= balanceOf[_from].balance);
        require(_value <= (allowed[_from][msg.sender]).balance);

        balanceOf[_from].balance = (balanceOf[_from].balance).sub(_value);
        balanceOf[_to].balance = (balanceOf[_to].balance).add(_value);
        (allowed[_from][msg.sender]).balance = (allowed[_from][msg.sender]).balance.sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        (allowed[msg.sender][_spender]).balance = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

  
    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256)
    {
        return (allowed[_owner][_spender]).balance;
    }

 
    function increaseApproval(
        address _spender,
        uint _addedValue
    )
        public
        returns (bool)
    {
        (allowed[msg.sender][_spender]).balance = (
            (allowed[msg.sender][_spender]).balance.add(_addedValue));
        emit Approval(msg.sender, _spender, (allowed[msg.sender][_spender]).balance);
        return true;
    }

  
    function decreaseApproval(
        address _spender,
        uint _subtractedValue
    )
        public
        returns (bool)
    {
        uint oldValue = (allowed[msg.sender][_spender]).balance;
        if (_subtractedValue > oldValue) {
            (allowed[msg.sender][_spender]).balance = 0;
        } else {
            (allowed[msg.sender][_spender]).balance = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, (allowed[msg.sender][_spender]).balance);
        return true;
    }


}