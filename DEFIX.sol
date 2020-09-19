
pragma solidity >=0.4.22 <0.7.0;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";


contract DEFIX is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;
    
    event Burn(address indexed burner, uint256 value);

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    uint256 private _multiplier;
    uint256 private _startTime;
    uint256 private _burnTime;
    uint256 private _burnPercent;

    address private communityAddress = 0x74507C4973EcFc9126827Bf54AE3fb52E60499Ea;
    address private stakingAddress   = 0x6df03fF8AB9f31dCD41A6A0Eafc41d81Ac1e7641;
    address private marketingAddress = 0x161D2389FD4be1C2b91369FE9fE939D474EAF8da;
    address private preSaleAddress   = 0xB03096AfCF878fC4B2eE75a552F56a83cb33de2b;
    address private softStakeAddress = 0xFaf6BE82850373583151A19bF22C5a9C4deeFF0F;
    address private teamAddress      = 0xa7Abe1e71D7220154f7dcf5D8860C083D5095c37;
    address private uniswapAddress   = 0xCf12fe3Ca4d98449efbe048d4B29083606e0a516;

    struct vestingSchedule {
        uint256 allocatedAmount;             /* Percentage for vesting rate per duration. */
        uint256 releasedAmount;              /* Percentage for vesting rate per duration. */
        uint256 cliffDuration;               /* Duration of the cliff, with respect to the grant start day, in days. */
        uint256 duration;                    /* Duration of the vesting schedule, with respect to the grant start day, in days. */
        uint256 percentage;                  /* Percentage for vesting rate per duration. */
    }

    mapping (address => vestingSchedule) private _vestingSchedules;

    
    
    constructor () public {
        _name = "Defix Network";
        _symbol = "DEFIX";
        _decimals = 18;
        _multiplier = uint256 (10 ** _decimals);
        _totalSupply = 100000000 * _multiplier;
        _startTime = block.timestamp;
        _burnTime = block.timestamp + 15 * 24 * 3600;
        _burnPercent = 6;

        _balances[communityAddress]   =                        0;
        _balances[stakingAddress]     =                        0;
        _balances[marketingAddress]   =    6000000 * _multiplier;
        _balances[preSaleAddress]     =   50000000 * _multiplier;
        _balances[softStakeAddress]   =                        0;
        _balances[teamAddress]        =                        0;
        _balances[uniswapAddress]     =   10000000 * _multiplier;

        _vestingSchedules[communityAddress] = vestingSchedule(
            4000000 * _multiplier,
            0,
            60,
            60,
            4
        );

        _vestingSchedules[stakingAddress] = vestingSchedule(
            12000000 * _multiplier,
            0,
            60,
            60,
            2
        );

        _vestingSchedules[softStakeAddress] = vestingSchedule(
            8000000 * _multiplier,
            0,
            90,
            120,
            4
        );

        _vestingSchedules[teamAddress] = vestingSchedule(
            10000000 * _multiplier,
            0,
            365,
            0,
            100
        );
        
        emit Transfer(address(0), marketingAddress, 6000000 * _multiplier);
        emit Transfer(address(0), preSaleAddress,  50000000 * _multiplier);
        emit Transfer(address(0), uniswapAddress,  10000000 * _multiplier);
    }

    
    function name() public view returns (string memory) {
        return _name;
    }

    
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    
    function decimals() public view returns (uint256) {
        return _decimals;
    }

    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

`sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        
        

        if (_burnTime < block.timestamp && _totalSupply.sub(amount, "ERC20: transfer amount exceeds totalSupply") >= 25000000 * _multiplier) {
            _totalSupply = _totalSupply.sub(amount * _burnPercent / 100);
            _balances[recipient] = _balances[recipient].add(amount * (100 - _burnPercent) / 100);
            uint256 receivedAmount;
            uint256 burnAmount;
            receivedAmount = amount * (100 - _burnPercent) / 100;
            burnAmount = amount * _burnPercent / 100;
            emit Transfer(sender, recipient, receivedAmount);
            emit Transfer(sender, address(0), burnAmount);
            emit Burn(sender, burnAmount);
        } else {
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
    }

    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

   
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    
    function _validateAddress(address beneficiary) internal view returns (bool) {
        if(beneficiary == communityAddress || beneficiary == stakingAddress || beneficiary == softStakeAddress || beneficiary == teamAddress) {
            return true;
        } else {
            return false;
        }
    }

    
    function _calculateToken(address beneficiary) internal {
        require(beneficiary != address(0), "ERC20: transfer to the zero address");
        require(_validateAddress(beneficiary) == true);

        if(block.timestamp.sub(_startTime) > _vestingSchedules[beneficiary].cliffDuration * 24 * 3600) {
            if(_vestingSchedules[beneficiary].releasedAmount < _vestingSchedules[beneficiary].allocatedAmount) {
                uint256 releaseAmount;
                uint256 times;
                uint256 newReleaseAmount;

                times = block.timestamp.sub(_startTime).sub(_vestingSchedules[beneficiary].cliffDuration * 24 * 3600).div(_vestingSchedules[beneficiary].duration * 24 * 3600);
                releaseAmount = _vestingSchedules[beneficiary].allocatedAmount.mul(times).mul(_vestingSchedules[beneficiary].percentage).div(100);

                require(releaseAmount <= _vestingSchedules[beneficiary].allocatedAmount);

                newReleaseAmount = releaseAmount.sub(_vestingSchedules[beneficiary].releasedAmount);
                _vestingSchedules[beneficiary].releasedAmount = releaseAmount;
                _balances[beneficiary] = _balances[beneficiary].add(newReleaseAmount);
                
                if(newReleaseAmount != 0) {
                    emit Transfer(address(0), beneficiary, newReleaseAmount);
                }
            }
        }
    }

    
    function unlockToken(address beneficiary) public {
        require(beneficiary != address(0), "ERC20: approve from the zero address");
        _calculateToken(beneficiary);
    }
}
