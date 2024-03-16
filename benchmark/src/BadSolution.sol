// TODO: Re-create this with address to our new optimized code.
interface AirdropLike {
    function airdropETH(
        address[] calldata recivers,
        uint256[] calldata value
    ) external payable;

    function airdropERC20(
        Erc20Like token,
        address[] calldata recivers,
        uint256[] calldata data,
        uint256 totalTokens
    ) external;
}

interface Erc20Like {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function increaseAllowance(address target, uint256 amount) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address target) external returns (uint256);    
}

contract BadSolution is AirdropLike {
    address dropper; 
    constructor(address challenge){
        dropper = challenge;
    }

    function airdropETH(
        address[] calldata recivers,
        uint256[] calldata value
    ) external payable {
        for (uint i = 0; i < recivers.length; i++) {
            address payable a = payable(recivers[i]);
            a.transfer(value[i]);
        }
    }

    function airdropERC20(
        Erc20Like token,
        address[] calldata recivers,
        uint256[] calldata data,
        uint256 _totalTokens
    ) external {
        token.transferFrom(address(dropper), address(this), _totalTokens);
        for (uint256 i = 0; i < recivers.length; i++) {
            token.transfer(recivers[i], data[i]);
        }
    }
}
