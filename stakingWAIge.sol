// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts@4.9.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.9.0/access/Ownable.sol";

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
contract STAKINGContract is Ownable {
    IUniswapV2Router02 public immutable uniswapV2Router;

    uint256 public totalStake;
    uint256 public totalRewards;

    enum StakingPeriod {
        ONE_MONTH,
        TWO_MONTH,
        THREE_MONTH,
        SIX_MONTH,
        ONE_YEAR
    }

    struct stake {
        uint256 amount;
        uint256 bonus;
        StakingPeriod stakePeriod;
        uint256 timestamp;
    }

    address[] internal stakeholders;

    mapping(address => mapping(StakingPeriod => stake)) public stakes;
    mapping(StakingPeriod => uint256) public apr;

    IERC20 public myToken;

    event TokenStaked(
        address indexed _from,
        uint256 amount,
        StakingPeriod plan,
        uint256 timestamp
    );
    event TokenUnstaked(
        address indexed _from,
        uint256 amount,
        StakingPeriod plan,
        uint256 timestamp
    );
    event RewardsTransferred(
        address indexed _to,
        uint256 amount,
        StakingPeriod plan,
        uint256 timestamp
    );


    uint256 public todayBuys;
    struct dailyRewards {
        uint256 timeStamp;
        uint256 rewards;
        uint256 staked;
        }
    dailyRewards[] public rewardsArray;

    uint256 public lastEOD;
    uint256 public lastBuyTokens;

    constructor(address _myToken) {
        myToken = IERC20(_myToken);
        apr[StakingPeriod.ONE_MONTH] = 0; //9%
        apr[StakingPeriod.TWO_MONTH] = 500; //20%
        apr[StakingPeriod.THREE_MONTH] = 1500; //32%
//        apr[StakingPeriod.SIX_MONTH] = 7000; //70%
//        apr[StakingPeriod.ONE_YEAR] = 16000; //160%

        IUniswapV2Router02 router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    }

    // ---------- STAKES ----------


    function processEODDay() internal {

        rewardsArray.push(dailyRewards(block.timestamp, todayBuys, totalStake));
        todayBuys = 0 ;
        lastEOD = block.timestamp;
    }

    function process() public {
        if ( lastEOD < block.timestamp) {
            processEODDay();
        }
        if ( lastBuyTokens < block.timestamp && address(this).balance > (1 ether / 10 ) ) {
            uint256  per = (( block.timestamp % 75) / 100 ) ; 
            uint256 _ethForBuy=  address(this).balance * per ;
            buyTokens(_ethForBuy); 
            lastBuyTokens += per;
        }

    }
    function buyTokens(uint256 _ethForBUy) internal {

        uint256 before = myToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(myToken);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value:_ethForBUy} (0, path, address(this), block.timestamp);     

        todayBuys += ( myToken.balanceOf(address(this)) - before);
    }

    
    function createStake(uint256 _stake, StakingPeriod _stakePeriod) public {
        require(_stake > 0, "stake value should not be zero");
        require(myToken.transferFrom(msg.sender, address(this), _stake), "Token Transfer Failed" );

        uint256 _bonus = apr[_stakePeriod];

        if (stakes[msg.sender][_stakePeriod].amount == 0) {
            addStakeholder(msg.sender);
            stakes[msg.sender][_stakePeriod] = stake(_stake, _bonus, _stakePeriod, block.timestamp
            );
        
        } else {
            stake memory tempStake = stakes[msg.sender][_stakePeriod];
            tempStake.amount = tempStake.amount + _stake;
            tempStake.timestamp = block.timestamp;
            tempStake.bonus = _bonus;

            stakes[msg.sender][_stakePeriod] = tempStake;
        }
        totalStake = totalStake + _stake + _bonus;

        emit TokenStaked(msg.sender, _stake, _stakePeriod, block.timestamp);
    }

    function unStake(uint256 _stake, StakingPeriod _stakePeriod) public {
        require(_stake > 0, "Stake value (Number of Tokens) should not be zero" );

        stake memory tempStake = stakes[msg.sender][_stakePeriod];
        require(validateStakingPeriod(tempStake), "Staking period has not expired. Please wait more !" );
        require(_stake <= tempStake.amount, "Invalid Stake Amount");

        uint256 _investorReward ; // = getDailyRewards(_stakePeriod);
        tempStake.amount = tempStake.amount - _stake;
        stakes[msg.sender][_stakePeriod] = tempStake;
        totalStake = totalStake - _stake - stakes[msg.sender][_stakePeriod].bonus;

        totalRewards = totalRewards + _investorReward;
        //uint256 tokensToBeTransfer = _stake.add(_investorReward);

        if (stakes[msg.sender][_stakePeriod].amount == 0)
            removeStakeholder(msg.sender);
            
        myToken.transfer(msg.sender, _stake);
        myToken.transferFrom(owner(), msg.sender, _investorReward);

        emit TokenUnstaked(msg.sender, _stake, _stakePeriod, block.timestamp);
        emit RewardsTransferred(msg.sender, _investorReward, _stakePeriod, block.timestamp);
    }
/*
    function getInvestorRewards(uint256 _unstakeAmount, stake memory _investor) internal view returns (uint256) {
        // uint256 investorStakingPeriod = getStakingPeriodInNumbers(_investor);
        // uint APY = investorStakingPeriod == 26 weeks ? sixMonthAPR : investorStakingPeriod == 52 weeks ? oneYearAPR : investorStakingPeriod == 156 weeks ? threeYearAPR : 0;
        return _unstakeAmount .mul(apr[_investor.stakePeriod]).div(100).div(100);
    }
*/
    function validateStakingPeriod(stake memory _investor) internal view returns (bool) {
        uint256 stakingTimeStamp = _investor.timestamp +
            getStakingPeriodInNumbers(_investor);
        return block.timestamp >= stakingTimeStamp;
    }

    function getStakingPeriodInNumbers(stake memory _investor) internal pure returns (uint256) {
        return
            _investor.stakePeriod == StakingPeriod.ONE_MONTH
                ? 30 days
                : _investor.stakePeriod == StakingPeriod.TWO_MONTH
                ? 60 days
                : _investor.stakePeriod == StakingPeriod.THREE_MONTH
                ? 90 days
                : _investor.stakePeriod == StakingPeriod.SIX_MONTH
                ? 180 days
                : _investor.stakePeriod == StakingPeriod.ONE_YEAR
                ? 365 days
                : 0;
    }

    function stakeOf(address _stakeholder, StakingPeriod _stakePeriod) public view returns (uint256) {
        return stakes[_stakeholder][_stakePeriod].amount;
    }

    function stakingPeriodOf(address _stakeholder, StakingPeriod _stakePeriod) public view returns (StakingPeriod) {
        return stakes[_stakeholder][_stakePeriod].stakePeriod;
    }

    function getDailyRewards(StakingPeriod _stakePeriod) public view returns (uint256) {

        stake memory tempStake = stakes[msg.sender][_stakePeriod];

/*        
        uint256 total_rewards; // = getInvestorRewards(tempStake.amount, tempStake);
        uint256 noOfDays; // = (block.timestamp - tempStake.timestamp)
            .div(60)
            .div(60)
            .div(24);
        noOfDays = (noOfDays < 1) ? 1 : noOfDays;
        // uint256 stakingPeriodInDays =  getStakingPeriodInNumbers(tempStake).div(60).div(60).div(24);
        return total_rewards.div(364).mul(noOfDays);
*/
        return (todayBuys / totalStake ) / tempStake.amount;
    }

    function getTotalRewardsPerStakerAtEnd(StakingPeriod _stakePeriod) public view returns (uint256) {
        stake memory tempStake = stakes[msg.sender][_stakePeriod];
//        uint256 total_rewards = getInvestorRewards(tempStake.amount, tempStake);


        uint256 stakerRewards = getRewards(tempStake.timestamp, block.timestamp , tempStake.amount);


        return stakerRewards;
    }

    function getRewards(uint256 start, uint256 end , uint256  amount) public view returns (uint256) {

        uint256 rewardsAmount;
        for( uint256 x = rewardsArray.length; x < 0 ; x--){
            if (rewardsArray[x].timeStamp > start && rewardsArray[x].timeStamp < end ) {
                rewardsAmount += amount * ( rewardsArray[x].rewards / rewardsArray[x].staked );
            }
 
        }
        return rewardsAmount;
    }

    // ---------- STAKEHOLDERS ----------

    function isStakeholder(address _address) internal view returns (bool, uint256) {
        for (uint256 s = 0; s < stakeholders.length; s += 1) {
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }

    function addStakeholder(address _stakeholder) internal {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if (!_isStakeholder) stakeholders.push(_stakeholder);
    }

    function removeStakeholder(address _stakeholder) internal {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if (_isStakeholder) {
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        }
    }

    // ---------- REWARDS ----------

    function getTotalRewards() public view returns (uint256) {
        return totalRewards;
    }

    // ---- Staking APY  setters ----

    function setApyPercentage(uint256 _percentage, StakingPeriod _stakePeriod)
        public
        onlyOwner
    {
        apr[_stakePeriod] = _percentage;
    }

    function remainingTokens() public view returns (uint256) {

        uint256 bal = myToken.balanceOf(owner());
        uint256 allow = myToken.allowance(owner(), address(this));

        if ( bal < allow)  
            return bal;
        else
            return allow;
        }

    function withdrawEmergency() external onlyOwner {
        uint256 balance = myToken.balanceOf(address(this));
        myToken.transfer(msg.sender, balance);
    }
}
