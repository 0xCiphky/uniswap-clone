// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "../lib/Tick.sol";

//Errors
error InvalidTickRange(int24 lowerTick, int24 upperTick);
error NotEnoughLiquidity(uint128 amount);
error InsuffecientInputAmount();



contract UniswapV3Pool {

    event Mint(address sender, address owner, int24 lowerTick, int24 upperTick, uint128 amount, uint128 amount0, uint128 amount1);

    using Tick for mapping(int24 => Tick.Info);
    using Position for mapping(bytes32 => Position.Info);
    using Position for Position.Info;

    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;

    address public immutable token0;
    address public immutable token1;

    struct Slot0 {
        uint160 sqrtPricex96;
        //current tick
        int24 tick;
    } 
    Slot0 public slot0;

    // amount of liquidity: L
    uint128 public liquidity;

    //Ticks info
    mapping(int24 => Tick.Info) public ticks;
    //Positions info
    mapping(bytes32 => Position.Info) public positions;


    constructor(address token0_, address token1_, uint160 sqrtPricex96, int24 tick) {
        token0 = token0_;
        token1 = token1_;

        slot0 = Slot0{sqrtPricex96: sqrtPricex96, tick: tick};
    }

    //upper and lower bounds are used to set the tick range
    //amount is the amount of liquidity we want to provide
    //This amount will be split in to the two tokens we provide
    function mint(
        address owner,
        int24 lowerTick,
        int24 upperTick,
        uint128 amount
    )  external returns (uint256 amount0, uint256 amount1) {
        
        //checks to make sure the tick ranges provided by the user are valid
        if(
            lowerTick >= upperTick ||
            lowerTick < MIN_TICK || 
            upperTick > MAX_TICK
        ) {
            revert InvalidTickRange(lowerTick, upperTick);
        }


        if (amount == 0) {
            revert NotEnoughLiquidity(amount);
        }

        ticks.update(lowerTick, amount);
        ticks.update(upperTick, amount);

        Position.Info storage position = positions.get(
            owner,
            lowerTick,
            upperTick
        );
        position.update(amount);

        //these vals should be calculated through a func but we just hardcode it for now
        amount0 = 0.998976618347425280 ether;
        amount1 = 5000 ether;

        liquidity += uint128(amount);

        // These two variables will hold the balances of the two tokens
        uint256 balance0Before;
        uint256 balance1Before;

        //if the amount that we are of liquidity we are depositing in is greater then 0
        //then we get the balance of the tokens before we add that liquidity
        if(amount0 > 0) {balance0Before = balance0();}
        if(amount1 > 0) {balance1Before = balance1();}

        //This is a callback function where the user adds the liquidity amount0 and amount1 to the pools
        IuniswapV3MintCallBack(msg.sender).uniswapV3MintCallBack(
            amount0,
            amount1
        );

        //We then do a check to see if the callback was successfull and the liquidity was added to the pools
        if(amount0 > 0 && balance0Before + amount0 > balance0()) {
            revert InsuffecientInputAmount();
        }
        if( amount1 > 0 && balance1Before + amount1 > balance1()) {
            revert InsuffecientInputAmount();
        }

        emit Mint(msg.sender, owner, lowerTick, upperTick, amount, amount0, amount1);
    }

    // functions to get the balance of the two tokens
    function balance0() internal returns(uint256 balance) {
        balance = IERC20(token0).balanceOf(address(this));
    }
    function balance1() internal returns(uint256 balance) {
        balance = IERC20(token1).balanceOf(address(this));
    }

}