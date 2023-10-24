// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

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

interface IStakingContract {

    function tokenSent(uint256) external ;
}

contract STAKINGContract is Ownable, IStakingContract {
    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

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

    event TokenStaked(address indexed _from, uint256 amount, StakingPeriod plan, uint256 timestamp);
    event TokenUnstaked(address indexed _from, uint256 amount, StakingPeriod plan, uint256 timestamp );
    event RewardsTransferred(address indexed _to,uint256 amount,StakingPeriod plan,uint256 timestamp);
    event ProcessedIncoming(uint256 timestamp, uint256 amount);
    event DailyRewards(uint256 timestamp, uint256 amount, uint256 staked);

    uint256 public todayBuys;
    uint256 public snapshotDays = 90;
    struct dailyRewards {
        uint256 timeStamp;
        uint256 rewards;
        uint256 staked;
        }
    dailyRewards[] public rewardsArray;

    uint256 public lastEOD;

    constructor() {
        (address router, address locker) = getRoute();
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        uniswapV2Router = _uniswapV2Router;

        apr[StakingPeriod.ONE_MONTH] = 0; //9%
        apr[StakingPeriod.TWO_MONTH] = 500; //20%
        apr[StakingPeriod.THREE_MONTH] = 1500; //32%
        myToken = IERC20(0x6cacfAb6DF68A0815D15085d1372F3464f35eDE0);
        lastEOD = block.timestamp;

    }
    event Received(address sender, uint256 value);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    // ---------- STAKES ----------

    function setToken(ERC20 _myToken) external onlyOwner {
          myToken = IERC20(_myToken);
    }

    function processEODDay() internal {

        uint256 buys = todayBuys;
        uint256 staked = totalStake;
        rewardsArray.push(dailyRewards(block.timestamp, buys, staked));
        todayBuys = 0 ;
        lastEOD += 1 days;

        if ( rewardsArray.length > snapshotDays)
            rewardsArray.pop();

        emit DailyRewards(block.timestamp, buys, staked);
    }

    function tokenSent(uint256 amount) external {
        if ( lastEOD < block.timestamp) 
            processEODDay();

        uint256 purchasedTokens = swapETHForTokens(address(this).balance);
        todayBuys += purchasedTokens;
        emit ProcessedIncoming(block.timestamp, purchasedTokens);
    }
    event SwapedETHForTokens(uint256 timeStamp ,uint256 eth, uint256 amount) ;
    function swapETHForTokens(uint256 eth) internal returns(uint256){
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(myToken);

        // make the swap
        uint256 swapOutput;
        uint256 beginBalance = myToken.balanceOf(address(this));
                          
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: eth }(
            swapOutput, // accept any amount of Tokens
            path,
            address(this),
            block.timestamp
        );
        uint256 endBalance = myToken.balanceOf(address(this));

        emit SwapedETHForTokens(block.timestamp, eth,swapOutput );
        return endBalance - beginBalance;
    }
    
    function createStake(uint256 _stake, StakingPeriod _stakePeriod) public {
        require(_stake > 0, "stake value should not be zero");
        require(myToken.transferFrom(msg.sender, address(this), _stake), "Token Transfer Failed" );

        uint256 _bonus = _stake * ( apr[_stakePeriod] / 10000);

        if (stakes[msg.sender][_stakePeriod].amount == 0) {
            addStakeholder(msg.sender);
            stakes[msg.sender][_stakePeriod] = stake(_stake, _bonus, _stakePeriod, block.timestamp
            );
        
        } else {
            stake memory tempStake = stakes[msg.sender][_stakePeriod];
            tempStake.amount = tempStake.amount + _stake;
            tempStake.bonus = _bonus;
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

        uint256 stakedPlusBonus = tempStake.amount + tempStake.bonus;
        uint256 _investorReward = getRewards(tempStake.timestamp, block.timestamp , stakedPlusBonus);
        
        tempStake.amount -= _stake;

        stakes[msg.sender][_stakePeriod] = tempStake;
        totalStake = totalStake - _stake - stakes[msg.sender][_stakePeriod].bonus;

        totalRewards += _investorReward;

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
        
        uint256 stakingTimeStamp = _investor.timestamp + getStakingPeriodInNumbers(_investor);
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

        if ( tempStake.amount == 0 ) 
            return 0;

        uint256 stakedPlusBonus = tempStake.amount + tempStake.bonus;

        return (todayBuys / totalStake ) * stakedPlusBonus;
    }

    function getTotalRewardsPerStakerAtEnd(StakingPeriod _stakePeriod) public view returns (uint256) {
        stake memory tempStake = stakes[msg.sender][_stakePeriod];
//        uint256 total_rewards = getInvestorRewards(tempStake.amount, tempStake);

        uint256 stakedPlusBonus = tempStake.amount + tempStake.bonus;
        uint256 stakerRewards = getRewards(tempStake.timestamp, block.timestamp , stakedPlusBonus);


        return stakerRewards;
    }

    function getRewards(uint256 start, uint256 end , uint256  amount) public view returns (uint256) {

        uint256 rewardsAmount;

        uint256 _staked;
        uint256 _rewards;

        for( uint256 x = rewardsArray.length; x < 0 ; x--){
            if (rewardsArray[x].timeStamp > start && rewardsArray[x].timeStamp < end ) {
                _staked += rewardsArray[x].staked ;
                _rewards += rewardsArray[x].rewards;
            }
 
        }

        if ( _staked == 0 ) 
            return 0;
            
        rewardsAmount += amount * (_rewards/ _staked  );

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

    function setApyPercentage(uint256 _percentage, StakingPeriod _stakePeriod) public onlyOwner {
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
    function getRoute() internal view returns ( address, address) { 
          if (block.chainid == 1 || block.chainid == 5) {
            return (0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D,0x71B5759d73262FBb223956913ecF4ecC51057641); //Mainnet
          } else if (block.chainid == 56) {
            return (0x10ED43C718714eb63d5aA57B78B54704E256024E,0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE); // PCS Router

            } else if (block.chainid == 97) {
                return (0xD99D1c33F9fC3444f8101754aBC46c52416550D1,0x5E5b9bE5fd939c578ABE5800a90C566eeEbA44a5); //PinkSale Lock
            } else {
                revert("Not supported");
            }

    }
}