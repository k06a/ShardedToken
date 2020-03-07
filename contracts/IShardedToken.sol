pragma solidity ^0.5.0;


interface IShardedToken {
    function mint(address to, uint256 amount) external;
    function burned(address from, uint256 amount) external;
}


interface IShardedTokenExtension {
    function balance() external view returns(uint256);
    function allowance(address to) external view returns(uint256);

    // Only owner can call
    function transfer(address to, uint256 amount) external;
    function approve(address to, uint256 amount) external;
    function burn(uint256 amount) external;

    // Any user cal call
    function transferFrom(address to, uint256 amount) external;

    // Only IShardedTokenExtension can call
    function received(address from, uint256 amount) external;
}
