pragma solidity ^0.8.14;

import "../lib/Position2.sol";
import "../lib/Tick2.sol";
import "../Interfaces/IERC20.sol";

//Custom errors
error UNISWAPV4POOL_INVALIDPARAMS(int24, int24);
error UNISWAPV4POOL_INVALIDAMOUNT(uint256);
error InsuffecientInputAmount();



contract UniswapV3Pool{

    event Mint(address, address, int24, int24, uint256, uint256, uint256);
    

    //lets initalize the libraries to use later
    using Position2 for mapping(bytes32 => Position2.Info);
    using Position2 for Position2.Info;
    using Tick2 for mapping(int24 => Tick2.Info);

    //Pool tokens 
    address public immutable token0;
    address public immutable token1;

    //Tick ranges
    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;

    uint128 public liquidity; 

    struct Slot0 {
        //current sqrt(p)
        uint160 sqrtPricex96;
        //current tick
        int24 tick;
    }
    Slot0 public slot0;

    // This mapping will be tick-range to tick info
    mapping(int24 => Tick2.Info) public ticks;
    //this mapping will be a unique ID(owner) to their position info
    mapping(bytes32 => Position2.Info) public positions;

    constructor(
        address token0_,
        address token1_,
        uint160 sqrtPricex96,
        int24 tick
    ) {
        token0 = token0_;
        token1 = token1_;
        slot0 = Slot0({sqrtPricex96: sqrtPricex96, tick: tick});
    }

    //Mint function

    // To mint we need the user to provide his address, 
    //the tick ranges and the amount of liquidity he would like to provide to the pool

    //If the function is successful it will return the two token amounts that was deposited in the liquidity
    function mint(
        address owner,
        int24 lowerTick,
        int24 upperTick,
        uint128 amount
    ) external returns(uint256 amount0, uint256 amount1)
    {
        //lets do some checks to make sure the ticks provided are in range and the amount is valid(>0)

        if (lowerTick >= upperTick || upperTick > MAX_TICK || lowerTick < MIN_TICK)
            {
                revert UNISWAPV4POOL_INVALIDPARAMS(lowerTick, upperTick);
            }

        if (amount == 0) revert UNISWAPV4POOL_INVALIDAMOUNT(amount0);

        //now we can start the Minting process

        //lets update the ticks mapping
        // update function is from the ticks library
        // this will update the ticks liquidity adding the user liquidity 
        ticks.update(lowerTick,amount);
        ticks.update(upperTick, amount);

        //lets update the position mapping
        //we encode the owner address, lowerTick and upperTick and use that to fetch the position
        Position2.Info storage position =  positions.get(owner, lowerTick, upperTick);

        // position: is the position of the cuurent user, we retrieved using the get function
        // we now update it by adding the amount(users liqu) to the positions liquidity
        position.update(amount);


        //we are done updating our mapping now we have a callBack function where the user will send the liq amount to the pool

        //we usually calculate how much of each token the user has to deposit but we will just hardcode it for now
        amount0 = 0.998976618347425280 ether;
        amount1 = 5000 ether;

        //we update the liquidity to the amount being added
        liquidity += uint128(amount);

        //lets do some checks to make sure the user sent the funds
        uint256 balance0Before;
        uint256 balance1Before;

        if(amount0 > 0 ) {balance0Before = balance0();}
        if(amount1 > 0 ) {balance1Before = balance1();}

        //this is a callback func to the user which calls for him to send the funds
        //IUniswapV3MintCallBack(msg.sender).UniswapV4MintCallBack(
        //    amount0,
        //    amount1
        //);

        if( amount0 > 0 && balance0Before + amount0 > balance0()) {revert InsuffecientInputAmount();}
        if( amount1 > 0 && balance1Before + amount1 > balance1()) {revert InsuffecientInputAmount();}

        emit Mint(msg.sender, owner, lowerTick, upperTick, amount, amount0, amount1);

    }


    function balance0() internal returns(uint256 balance) {
        balance = IERC20(token0).balanceOf(address(this));
    }
    function balance1() internal returns(uint256 balance) {
        balance = IERC20(token1).balanceOf(address(this));
    }
}