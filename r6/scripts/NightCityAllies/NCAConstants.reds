module NightCityAllies

public final class NCAConstants {

// =============================================== Features ============================================================

    public static func Dev() -> Bool = false;

// ============================================== Levelling ============================================================

    public static func MinimumLevel() -> Int32 = 5;
    public static func LevelFloorBelowPlayer() -> Int32 = 20;
    public static func BaseXP() -> Float = 400.0;
    public static func LevelGrowth() -> Float = 1.10;
    public static func CombatExpBaseRate() -> Float = 150.0;
    public static func CombatExpContributionRate() -> Float = 100.0;

// =============================================== Pricing =============================================================

    public static func HiringPriceFactor() -> Float = 10.0;

// =============================================== Spawning ============================================================

    public static func SpawnMinDistance() -> Float = 20.0;
    public static func SpawnMaxDistance() -> Float = 40.0;
    public static func SpawnMaxAttempts() -> Int32 = 12;
    public static func DisplaySquadCap() -> Int32 = 4;

// ================================================ Timing =============================================================

    public static func TickDelay() -> Float = 0.75;
    public static func CrowdHandoverTime() -> Float = 1.0;
    public static func CrowdWalkAwayTime() -> Float = 25.0;

// ============================================== Routines =============================================================

    public static func WorkspotHandoverDelay() -> Float = 0.3;
    public static func MinBooking() -> Float = 0.1;
    public static func InterruptGrace() -> Float = 0.5;

// ============================================== Behaviours ===========================================================

    // Catching up to the player after being left behind.
    public static func CatchUpApproachDistance() -> Float = 3.0;
    public static func CatchUpApproachTolerance() -> Float = 1.0;

    // Exploring a location.
    public static func MinInteractionTime() -> Float = 30.0;         // shortest stay at one interaction point
    public static func MaxInteractionTime() -> Float = 120.0;        // longest stay at one interaction point
    public static func SearchRetryTime() -> Float = 10.0;            // wait before looking for a free point again
    public static func WalkToRandomPropTime() -> Float = 1.5;        // how long to walk towards a random prop
    public static func MoveGiveUpTime() -> Float = 30.0;             // how long a walk across the location to an interaction gets before it counts as failed TODO maybe add "isWalking" probe, observe how it behaves
    public static func ExitGiveUpTime() -> Float = 5.0;              // the walk back out is only a step or two, so it fails much sooner
    public static func ArrivalDistance() -> Float = 1.25;            // start animation when this far from the walk target
    public static func ExitArrivalDistance() -> Float = 0.5;         // they have to be properly back out before moving on
    public static func LocationEntryDelay() -> Float = 5.0;          // settle time after walking in, before heading anywhere
    public static func EntryFollowDistance() -> Float = 3.0;         // how close squad members stay to V during the settle time
    public static func EntryFollowTolerance() -> Float = 1.0;
    public static func NavmeshSnapRadius() -> Float = 3.0;           // how far beside an interaction its stand-in point may be and still count as being at the prop
    public static func PathNodeArrivalDistance() -> Float = 1.25;    // the same arrival test, for one node of a connector path
    public static func PathNodeGiveUpTime() -> Float = 15.0;
}
