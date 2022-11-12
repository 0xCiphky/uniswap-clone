//Library that will hold info about the customers positions and have functions to update/get positions

library Position {
    
    struct Info{
        uint128 liquidity;
    }


    function get(
        // we get the positions mapping that holds all the positions for this liq pool
        // We get this from the storage
        mapping(bytes31 => Position.Info) storage self;
        address owner,
        int24 lowerTick,
        int24 upperTick,
    ) internal view returns(Position.Info storage position) {
        position = self[keccack256(abi.encodePacked(owner, upperTick, lowerTick))];
    }

    // we update the liquidity held by that user in the position
    // we first use the get function to get the users position then update it
    function update(
        Info storage self,
        uint128 liquidityDelta
    ) internal {
        uint128 liquidityBefore = self.liquidity;
        uint128 liquidityAfter = liquidityBefore + liquidityDelta;

        self.liquidity = liquidityAfter;
    }

}