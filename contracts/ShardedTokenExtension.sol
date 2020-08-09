// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Sharded.sol";
import "./IShardedToken.sol";


contract ShardedTokenExtension is IShardedTokenExtension, ShardedExt, Ownable {
    using SafeMath for uint256;

    uint256 private _balance;
    mapping(address => uint256) private _allowance;

    function balance() external view override returns(uint256) {
        return _balance;
    }

    function allowance(address to) external view override returns(uint256) {
        return _allowance[to];
    }

    function transfer(address to, uint256 amount) external override onlyOwner {
        _transfer(to, amount);
    }

    function received(address from, uint256 amount) external override onlyBaseOrExtensionOfUser(from) {
        _balance = _balance.add(amount);
    }

    function approve(address to, uint256 amount) external override onlyOwner {
        require(_allowance[to] == 0 || amount == 0);
        _allowance[to] = amount;
    }

    function transferFrom(address to, uint256 amount) external override {
        _allowance[msg.sender] = _allowance[msg.sender].sub(amount);
        _transfer(to, amount);
    }

    function burn(uint256 amount) external override onlyOwner {
        _balance = _balance.sub(amount, "ShardedTokenExtension: Not enough balance");
        IShardedToken(address(base)).burned(owner(), amount);
    }

    //

    function _transfer(address to, uint256 amount) internal {
        _balance = _balance.sub(amount, "ShardedTokenExtension: Not enough balance");
        IShardedTokenExtension(extensionOf(to)).received(owner(), amount);
    }
}
