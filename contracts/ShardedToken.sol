pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./Sharded.sol";
import "./IShardedToken.sol";


contract ShardedToken is IShardedToken, ShardedBase, Ownable {
    using SafeMath for uint256;

    uint256 public totalSupply;

    function mint(address to, uint256 amount) public {
        require(msg.sender == owner(), "Access denied");
        totalSupply = totalSupply.add(amount);
        ShardedTokenExtension(to).received(address(0), amount);
    }

    function burned(address /*from*/, uint256 amount) public protected {
        totalSupply = totalSupply.sub(amount);
    }

    function _createExension(address user) internal returns(address) {
        ShardedTokenExtension ext = new ShardedTokenExtension();
        ext.transferOwnership(user);
        return address(ext);
    }
}


contract ShardedTokenExtension is IShardedTokenExtension, ShardedExt, Ownable {
    using SafeMath for uint256;

    uint256 private _balance;
    mapping(address => uint256) private _allowance;

    function balance() public view returns(uint256) {
        return _balance;
    }

    function transfer(address to, uint256 amount) public onlyOwner {
        _balance = _balance.sub(amount, "Not enough balance");
        ShardedTokenExtension(to).received(address(this), amount);
    }

    function received(address /*from*/, uint256 amount) public protected {
        _balance = _balance.add(amount);
    }

    //

    function allowance(address to) public view returns(uint256) {
        return _allowance[to];
    }

    function approve(address to, uint256 amount) public onlyOwner {
        require(_allowance[to] == 0 || amount == 0);
        _allowance[to] = amount;
    }

    function transferFrom(address to, uint256 amount) public {
        _allowance[msg.sender] = _allowance[msg.sender].sub(amount);
        transfer(to, amount);
    }

    //

    function burn(uint256 amount) public onlyOwner {
        ShardedToken(address(shardedBase)).burned(owner(), amount);
    }
}
