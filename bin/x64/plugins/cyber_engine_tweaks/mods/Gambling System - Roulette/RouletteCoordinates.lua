RouletteCoordinates = {
    version = '1.0.0',
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

local JsonData = require('JsonData.lua')

---Initializes all roulette table coordinates and offsets
function RouletteCoordinates.init()
    -- Register roulette-specific offsets
    -- IMPORTANT: spinner_center_point is an offset in the table's local coordinate space
    -- It will be rotated by table orientation, then added to table position
    -- All other offsets are relative to spinner_center_point (rotated, then added to spinner center)
    
    -- Spinner center point - offset from table position to spinner center in table's local space
    -- This offset IS rotated by table orientation because it's in the table's local coordinate system
    -- The offset was measured from hooh table: world-space difference was {-0.96375, -0.11231, 0.98131358}
    -- Hooh orientation is approximately 180° around Z, so local-space offset is approximately the inverse
    -- After testing, the correct local-space offset is: {0.96375, 0.11231, 0.98131358}
    -- This ensures: table_pos + (table_orientation * local_offset) = correct spinner position
    -- IMPORTANT: Z offset correction (-0.063) applied here to prevent entity hovering for all tables.
    -- hoohbar table gets +0.063 added to its position to cancel this correction (it's the "off" baseline table).
    RelativeCoordinateCalulator.registerOffset(
        'spinner_center_point',
        Vector4.new(0.96375, 0.11231, 0.98131358 - 0.063, 0),  -- Local-space offset with Z correction (will be rotated by table orientation)
        Quaternion.new(0, 0, 0, 1)
    )
    
    -- All other offsets are relative to SPINNER CENTER POINT (not table position)
    -- These offsets are rotated by table orientation, then added to spinner center position
    -- Use the ORIGINAL offsets from the old system (they were relative to SpinnerCenterPoint)
    
    -- Player pile position (chip stack location)
    -- OLD: Relative to SpinnerCenterPoint: {-0.3892143661, -0.5538890579, +0.09668642}
    RelativeCoordinateCalulator.registerOffset(
        'player_pile_position',
        Vector4.new(-0.3892143661, -0.5538890579, 0.09668642, 0),  -- Original offset, relative to spinner
        Quaternion.new(0, 0, 0, 1)
    )
    
    -- Player playing position (where player stands/sits)
    -- OLD: Relative to SpinnerCenterPoint: {-0.80787625665175, -1.085349415275, -0.93531358}
    RelativeCoordinateCalulator.registerOffset(
        'player_playing_position',
        Vector4.new(-0.80787625665175, -1.085349415275, -0.93531358, 0),  -- Original offset, relative to spinner
        Quaternion.new(0, 0, 0, 1)
    )
    
    -- Player exit position (where player teleports when leaving table)
    -- OLD: Calculated via RotatePoint from SpinnerCenterPoint: {-0.86706985804199, -1.3005326803182, -0.93531358}
    RelativeCoordinateCalulator.registerOffset(
        'player_exit_position',
        Vector4.new(-0.86706985804199, -1.3005326803182, -0.93531358, 0),  -- Original offset, relative to spinner
        Quaternion.new(0, 0, 0, 1)
    )
    
    -- Holographic display position (holo display location)
    -- OLD: Relative to SpinnerCenterPoint: {0.17977070965503, -0.55898646070364, +0.23668642}
    -- CORRECTED: Spinner Z=6.213, Expected holographic Z=6.307, so offset should be 0.094
    -- Calculation: 6.307 - 6.213 = 0.094
    RelativeCoordinateCalulator.registerOffset(
        'holographic_display_position',
        Vector4.new(0.17977070965503, -0.55898646070364, 0.094, 0),  -- Corrected offset, relative to spinner
        Quaternion.new(0, 0, 0, 1)
    )
    
    -- Table board origin (betting board origin)
    -- OLD: Relative to SpinnerCenterPoint: {-2.182648465571, -0.44227742051612, +0.09668642}
    RelativeCoordinateCalulator.registerOffset(
        'table_board_origin',
        Vector4.new(-2.182648465571, -0.44227742051612, 0.09668642, 0),  -- Original offset, relative to spinner
        Quaternion.new(0, 0, 0, 1)
    )
    
    -- Spot position (interaction spot location)
    -- OLD: Relative to SpinnerCenterPoint: {-0.6828427083, -0.7238078523, +0.09368642}
    RelativeCoordinateCalulator.registerOffset(
        'spot_position',
        Vector4.new(-0.6828427083, -0.7238078523, 0.09368642, 0),  -- Original offset, relative to spinner
        Quaternion.new(0, 0, 0, 1)
    )
    
    -- Mappin position (world mappin location) - same as spot position
    RelativeCoordinateCalulator.registerOffset(
        'mappin_position',
        Vector4.new(-0.6828427083, -0.7238078523, 0.09368642, 0),  -- Original offset, relative to spinner
        Quaternion.new(0, 0, 0, 1)
    )
    
    -- Camera position offset (camera offset relative to spot)
    RelativeCoordinateCalulator.registerOffset(
        'camera_position_offset',
        Vector4.new(0, 0.4, 0.7, 0),
        Quaternion.new(0, 0, 0, 1)
    )
    
    -- Register main tables
    -- IMPORTANT Z-OFFSET CORRECTION:
    -- The -0.063 Z offset correction is applied in the spinner_center_point offset (affects all tables).
    -- hoohbar table is the "off" one, so we add +0.063 to its position to cancel the correction.
    -- All other tables automatically get the correction through the spinner_center_point offset.
    
    -- hoohbar table
    -- EXCEPTION: This table is the "off" baseline table, so we add +0.063 to its Z position
    -- to cancel the -0.063 correction that's built into spinner_center_point offset.
    -- Table position is the actual table mesh position in world coordinates
    -- OLD SpinnerCenterPoint: {x=-1045.09375, y=1345.21069, z=6.21331358}
    -- NEW table position should be where the table mesh actually is
    -- Based on migration, using the table position (not spinner center)
    local hoohbarPosition = Vector4.new(-1044.130, 1345.323, 5.232 + 0.063, 1)
    local hoohbarOrientation = Quaternion.new(0.0, 0.0, -1.0, 0.002)
    RelativeCoordinateCalulator.registerTable('hoohbar', hoohbarPosition, hoohbarOrientation)
    
    -- tygerclawscasino table
    -- CORRECTED: Table position (not spinner center)
    -- Z offset correction is automatically applied via spinner_center_point offset
    local tygerclawsPosition = Vector4.new(-64.694, -281.893, -2.494, 1)
    -- CORRECTED: Orientation as Quaternion (i, j, k, r)
    local tygerclawsOrientation = Quaternion.new(0.0, 0.0, 0.997, -0.080)
    RelativeCoordinateCalulator.registerTable('tygerclawscasino', tygerclawsPosition, tygerclawsOrientation)
    
    -- Register optional tables (with dependency checks)
    -- gunrunnersclub table (obsolete mod - coordinates kept as comment for potential future updates)
    -- local gunrunnersPosition = Vector4.new(-2228.825, -2550.422, 81.209, 1)
    -- local gunrunnersOrientation = EulerAngles.new(0, 0, -43.068):ToQuat()
    -- RelativeCoordinateCalulator.registerTable('gunrunnersclub', gunrunnersPosition, gunrunnersOrientation)
    
    -- Note: northoakcasino is commented out in original code, so not registering it here
    -- If needed in the future, uncomment and add similar dependency check

    -- Load tables from JSON files in addons folder (after hardcoded tables)
    -- IMPORTANT: All JSON-loaded tables automatically get the Z offset correction (-0.063)
    -- applied via the spinner_center_point offset. hoohbar is the exception and has +0.063
    -- added to its position to cancel the correction.
    local addonTables = JsonData.ReturnAllFromFolder("addons")
    for _, tableData in ipairs(addonTables) do
        -- Convert position to Vector4 (Z offset correction is automatically applied via spinner_center_point offset)
        local position = Vector4.new(
            tableData.position.x,
            tableData.position.y,
            tableData.position.z,
            1
        )
        
        -- Create Quaternion directly from i, j, k, r components
        local quaternion = Quaternion.new(
            tableData.orientation.i or 0,
            tableData.orientation.j or 0,
            tableData.orientation.k or 0,
            tableData.orientation.r or 1
        )
        
        -- Register the table
        RelativeCoordinateCalulator.registerTable(
            tableData.id,
            position,
            quaternion
        )
    end
end

return RouletteCoordinates

