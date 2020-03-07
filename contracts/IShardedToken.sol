pragma solidity ^0.5.0;


interface IShardedToken {
    function mint(address to, uint256 amount) external /*onlyOwner*/;
    function burned(address from, uint256 amount) external /*protected*/;
}


interface IShardedTokenExtension {
    function balance() external view returns(uint256);

    function allowance(address to) external view returns(uint256);

    function transfer(address to, uint256 amount) external /*onlyOwner*/;

    function received(address from, uint256 amount) external /*protected*/;

    function approve(address to, uint256 amount) external /*onlyOwner*/;

    function transferFrom(address to, uint256 amount) external;

    function burn(uint256 amount) external /*onlyOwner*/;
}
