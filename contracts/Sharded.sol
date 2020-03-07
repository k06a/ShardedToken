pragma solidity ^0.5.0;

import "@openzeppelin/contracts/utils/Create2.sol";


// Wait until 0penZeppelin 2.6.0 integrate this:
// https://github.com/OpenZeppelin/openzeppelin-contracts/pull/2088
library Create2Hash {
    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address) {
        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash)
        );
        return address(bytes20(_data << 96));
    }
}


contract ShardedBase {
    bytes public extensionBytecode;
    bytes32 public extensionBytecodeHash;

    event ExtensionInstalled(
        address indexed sender,
        address indexed extension
    );

    modifier onlyExtensionOfUser(address user) {
        require(msg.sender == Create2Hash.computeAddress(bytes32(uint256(user)), extensionBytecodeHash, address(this)));
        _;
    }

    constructor(bytes memory extension) public {
        extensionBytecode = extension;
        extensionBytecodeHash = keccak256(extension);
    }

    function installExtension() public returns(address extension) {
        extension = Create2.deploy(bytes32(uint256(msg.sender)), extensionBytecode);
        ShardedExt(extension).setExtensionHash(extensionBytecodeHash);
        emit ExtensionInstalled(msg.sender, extension);
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
        require(msg.sender == Create2Hash.computeAddress(bytes32(uint256(user)), thisExtensionHash, base));
        _;
    }

    modifier onlyBaseOrExtensionOfUser(address user) {
        require(msg.sender == base || msg.sender == Create2Hash.computeAddress(bytes32(uint256(user)), thisExtensionHash, base));
        _;
    }

    function setExtensionHash(bytes32 hash) public onlyBase {
        require(uint256(thisExtensionHash) == 0, "ShardedExt: access denied");
        thisExtensionHash = hash;
    }
}
