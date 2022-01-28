// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface CEth {
    function mint() external payable; // to deposit to compound
    function redeem(uint redeemTokens) external returns (uint); // to withdraw from compound
    function exchangeRateStored() external view returns (uint); 
    function balanceOf(address owner) external view returns (uint256 balance);
}

interface IERC20{
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

contract TestCompoundEth {
    CEth public cToken;
    IERC20 public ercToken;
    mapping(address => uint) public balances;
    // uint public totalAccountEthBalance;

    constructor(address _cToken/*, address _ercToken*/) 
    {
        cToken = CEth(_cToken);
        // ercToken = IERC20(_ercToken);
    }
    
    function addBalance() public payable {     
        // totalAccountEthBalance += msg.value;
        uint balanceBefore = cToken.balanceOf(address(this));
        cToken.mint{value: msg.value}();
        uint toAddCEth = cToken.balanceOf(address(this)) - balanceBefore;
        balances[msg.sender] += toAddCEth;   
    }

    receive() external payable {}
    
    function withdraw() public  payable
    {
        // uint256 toTransfer = cToken.balanceOf(address(this));
        uint256 toTransfer = balances[msg.sender];
        balances[msg.sender] = balances[msg.sender] - toTransfer;
        cToken.redeem(toTransfer);

        // uint toReturn = address(this).balance - totalAccountEthBalance;
        // payable(msg.sender).transfer(toReturn);
    }
    
    // function getCTokenBalance() external view returns (uint) {
    //     return cToken.balanceOf(address(this));
    // }


    function redeem(uint _cTokenAmount) external {
        require(balances[msg.sender] >= _cTokenAmount);
        balances[msg.sender] -= _cTokenAmount;
        require(cToken.redeem(_cTokenAmount) == 0, "redeem failed");
    }

}


// for Rinkeby , use following contract address for cEth = 0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e
// for other Compound addresses, go to https://compound.finance/docs#getting-started
// my wallet address = 0xC3B9701E27f2f6Eae771C157D09f6999969803B2