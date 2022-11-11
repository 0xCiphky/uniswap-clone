

library Tick(

    struct Info{
        bool initialized;
        uint128 liquidity;
    }

    function update(
        mapping(int24 => Tick.Info) storage self;
        int24 tick,
        uint128 liquidityDelta
    ) internal
    {
        // we get the mapping of ticks and use the tick param given by the user (position of tick they want)
        // we store all staht into tickInfo
        //we then calculate the new liquidity by getting the old liquidity at that range and adding the users liquidity to that
        // if the liquidityBefore is empty that means there is no pool for that range
        // so we create a new pool
        // we then update the new liquidity 
        Tick.Info storage tickInfo = self[tick];
        uint128 liquidityBefore = tickInfo.liquidity;
        uint128 liquidityAfter = tickInfo.liquidity + liquidityDelta;

        if (liquidityBefore == 0) {
            tickInfo.initialized = true;
        }

        tickInfo.liquidity = liquidityAfter
    }

)