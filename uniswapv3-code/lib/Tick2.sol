// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

library Tick2{

    //struct that holds info abou the tick range
    // initialized: is there a;ready a pool initialized(created) at that tick range
    // liquidity: how much liquidity is at that tick range
    struct Info{
        bool initialized;
        uint128 liquidity;
    }

    //We take in three variables into this update function
    // The tick mapping from the uniswapV4Pool
    // the tick range and liquidity amountf
    function update
    (
        // This is the whole tick mapping with all tick ranges
        mapping (int24 => Tick2.Info) storage self,
        int24 tick,
        uint128 liquidityDelta
    ) internal {
        // This is the specific tick that the user specified for from params
         Tick2.Info storage tickInfo = self[tick];

         //store the currLiq of that tick in a var
         uint128 liquidityBefore = tickInfo.liquidity;
         uint128 liquidityAfter = liquidityBefore + liquidityDelta;

        // if the tick is not initialized meaning there is no pool there we create a new one
         if(liquidityBefore == 0) {
            tickInfo.initialized = true;
        }
        // finally we update the ticks liquidity to the new liquidity with the users amount
        tickInfo.liquidity = liquidityAfter;
    }
}