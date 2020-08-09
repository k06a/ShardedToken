// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/Create2.sol";


contract ShardedBase {
    bytes public extensionBytecode;
    bytes32 public extensionBytecodeHash;

    event ExtensionInstalled(
        address indexed sender,
        address indexed extension
    );

    modifier onlyExtensionOfUser(address user) {
        require(msg.sender == extensionOf(user));
        _;
    }

    constructor(bytes memory extension) public {
        extensionBytecode = extension;
        extensionBytecodeHash = keccak256(extension);
    }

    function installExtension() public virtual returns(address extension) {
        extension = Create2.deploy(0, bytes32(uint256(msg.sender)), extensionBytecode);
        ShardedExt(extension).setExtensionHash(extensionBytecodeHash);
        emit ExtensionInstalled(msg.sender, extension);
    }

    function extensionOf(address account) public view virtual returns(address) {
        return Create2.computeAddress(bytes32(uint256(account)), extensionBytecodeHash);
    }
}


contract ShardedExt {
    address public base = msg.sender;
    bytes32 public thisExtensionHash;

    modifier onlyBase {
        require(msg.sender == base);
        _;
    }

    modifier onlyExtensionOfUser(address user) {
        require(msg.sender == extensionOf(user));
        _;
    }

    modifier onlyBaseOrExtensionOfUser(address user) {
        require(msg.sender == base || msg.sender == extensionOf(user));
        _;
    }

    function extensionOf(address user) public view returns(address) {
        return Create2.computeAddress(bytes32(uint256(user)), thisExtensionHash, base);
    }

    function setExtensionHash(bytes32 hash) public onlyBase {
        require(thisExtensionHash == bytes32(0), "ShardedExt: access denied");
        thisExtensionHash = hash;
    }
}
