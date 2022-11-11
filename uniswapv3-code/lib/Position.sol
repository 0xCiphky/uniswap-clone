
// The position library tracks how much liquidity a certain person has at that position

library Position(

    struct Info {
        uint128 liquidity;
    }

    // When updating a position this means the owner is either adding(minting) or taking out(burning) liquidity
    // We call the get function below first to get the owners position which will be the in the self param
    // we can then add/remove liq from that position
    function update(
        Info storage self,
         uint128 liquidityDelta
        ) internal 
        {
        uint128 liquidityBefore = self.liquidity;
        uint128 liquidityAfter = self.liquidity + liquidityDelta;

        self.liquidity = liquidityAfter;
        }

    //To get someones position we use three params encoded together: owner address, lower tick pos and upper tick pos
    function get(
        mapping(bytes32 => Info) storage self,
        address owner,
        int24 lowerTick,
        int24 upperTick,
    )
    //Each position is uniquely identified by three keys: owner address, lower tick index, and upper tick index. 
    //We hash the three to make storing of data cheaper: when hashed, every key will take 32 bytes, 
    //instead of 96 bytes when owner, lowerTick, and upperTick are separate keys.
    internal view returns {
        position = self[keccack256(abi.encodePacked(owner, lowerTick, upperTick))];
    }
)