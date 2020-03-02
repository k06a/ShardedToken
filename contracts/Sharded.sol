pragma solidity ^0.5.0;


contract ShardedBase {
    mapping(address => address) public extensionByUser;
    mapping(address => address) public userByExtension;

    modifier protected {
        require(userByExtension[msg.sender] != address(0), "ShardedBase: access denied");
        _;
    }

    function installExtension() external {
        require(extensionByUser[msg.sender] == address(0), "ShardedBase: extension was already installed");
        address extension = _createExension(msg.sender);
        extensionByUser[msg.sender] = extension;
        userByExtension[extension] = msg.sender;
    }

    // Override in inherited contract
    function _createExension(address user) internal returns(address);
}


contract ShardedExt {
    ShardedBase public shardedBase = ShardedBase(msg.sender);

    modifier protected {
        require(
            msg.sender == address(shardedBase) ||
            shardedBase.userByExtension(msg.sender) != address(0),
            "ShardedBase: access denied"
        );
        _;
    }
}