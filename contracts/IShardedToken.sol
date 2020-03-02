pragma solidity ^0.5.0;


contract IShardedToken {
    function mint(address to, uint256 amount) public /*onlyOwner*/;
    function burn(address from, uint256 amount) public /*protected*/;

    function _createExension(address user) internal returns(address);
}


contract IShardedTokenExtension {
    function balance() public view returns(uint256);

    function transfer(address to, uint256 amount) public /*onlyOwner*/;

    function receive(address from, uint256 amount) public /*protected*/;

    function allowance(address to) public view returns(uint256);

    function approve(address to, uint256 amount) public /*onlyOwner*/;

    function transferFrom(address to, uint256 amount) public;

    //

    function burn(uint256 amount) public /*onlyOwner*/;
}
