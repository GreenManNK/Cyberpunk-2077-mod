module NightlyNow.Utils

// -----------------------------------------------------------------------------
// Probability - NightlyNow Core
// -----------------------------------------------------------------------------
// Performs a percent based probability check against input value
public func PassProbabilityCheck(valueToCheckAgainst: Int32) -> Bool {
    return RandRange(1, 101) <= valueToCheckAgainst;
}

// Flip a coin
public func FlipCoin() -> Bool = RandRange(0, 2) > 0;

