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

    function airdropERC721(
        Erc721Like nft,
        address[] calldata recivers,
        uint256[] calldata data
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

interface Erc721Like {
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;
    function getApproved(uint256 tokenId) external returns (address);
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
        for (uint i = 0; i < 16; i++) {
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
        for (uint256 i = 0; i < 16; i++) {
            token.transfer(recivers[i], data[i]);
        }
    }

    function airdropERC721(
        Erc721Like nft,
        address[] calldata recivers,
        uint256[] calldata data
    ) external {        
        for (uint256 i = 0; i < 16; i++) {
            nft.transferFrom(dropper, recivers[i], data[i]);
        }
    }
}
