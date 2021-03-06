// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Sharded.sol";
import "./IShardedToken.sol";
import "./ShardedTokenExtension.sol";


contract ShardedToken is IShardedToken, ShardedBase, Ownable {
    using SafeMath for uint256;

    uint256 public totalSupply;

    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed who, uint256 amount);

    // solium-disable-next-line max-len
    constructor() public ShardedBase(type(ShardedTokenExtension).creationCode) {
    }

    function mint(address to, uint256 amount) public override onlyOwner {
        totalSupply = totalSupply.add(amount);
        IShardedTokenExtension(extensionOf(to)).received(address(0), amount);
        emit Mint(to, amount);
    }

    function burned(address from, uint256 amount) public override onlyExtensionOfUser(from) {
        totalSupply = totalSupply.sub(amount);
        emit Burn(from, amount);
    }

    function installExtension() public override returns(address extension) {
        extension = super.installExtension();
        Ownable(extension).transferOwnership(msg.sender);
    }
}
