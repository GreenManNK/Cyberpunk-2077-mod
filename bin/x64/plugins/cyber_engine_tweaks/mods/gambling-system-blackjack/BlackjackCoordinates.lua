BlackjackCoordinates = {
    version = '1.0.0',
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

---Initializes all blackjack table coordinates and offsets
function BlackjackCoordinates.init()
    --Table
    RelativeCoordinateCalulator.registerTable(
        'hooh',
        Vector4.new(-1041.2463, 1339.9403, 5.2775, 1), --actual position of table mesh
        Quaternion.new(0, 0, 0, 1) --actual orientation of table mesh
    )
    
    --Holographic Value Display
    RelativeCoordinateCalulator.registerOffset(
        'top_down_holo_display',
        Vector4.new(0.5133, 0.1807, 0.7975, 0), 
        EulerAngles.new(0, 0, 20):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'standard_holo_display',
        Vector4.new(0.4563, 0.8447, 0.7975, 0), 
        EulerAngles.new(0, 0, 30):ToQuat()
    )
    --Hand Count Display
    RelativeCoordinateCalulator.registerOffset(
        'hand_count_display_base_player',
        Vector4.new(0.0713, 0.8807, 0.8075, 0),
        EulerAngles.new(0, 60, 0):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'hand_count_display_base_dealer',
        Vector4.new(-0.0607, -0.7763, 0.0055, 0),
        EulerAngles.new(0, 60, 0):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'hand_count_display_spacing_players',
        Vector4.new(0.18, 0, 0, 0),
        EulerAngles.new(0, 60, 0):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'hand_count_display_digit2_spacing',
        Vector4.new(-0.04, 0, 0, 0),
        EulerAngles.new(0, 60, 0):ToQuat()
    )
    --Card locations
    RelativeCoordinateCalulator.registerOffset(
        'deck_position',
        Vector4.new(-0.5127, 0.1807, 0.7975, 0),
        EulerAngles.new(0, 180, -90):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'player_first_card_position',
        Vector4.new(0.0573, 0.7707, 0.7975, 0),
        EulerAngles.new(0, 180, -90):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'dealer_first_card_position',
        Vector4.new(-0.0007, 0.2647, 0.7975, 0),
        EulerAngles.new(0, 180, -90):ToQuat()
    )
    --Card spacing offsets
    RelativeCoordinateCalulator.registerOffset(
        'card_spacing_player',
        Vector4.new(-0.04, -0.06, 0.0005, 0),  -- per card in player hand
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'card_spacing_dealer',
        Vector4.new(0.09, 0, 0, 0),  -- per card in dealer hand
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'dealer_second_card_offset',
        Vector4.new(-0.005, 0.004, 0, 0),  -- slight offset for dealer's 2nd card animation
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    --Card orientations
    RelativeCoordinateCalulator.registerOffset(
        'card_orientation_face_up',
        Vector4.new(0, 0, 0, 0),  -- no position, just orientation reference
        EulerAngles.new(0, 0, -90):ToQuat()  -- standardOri: face up
    )
    --Double down card offset
    RelativeCoordinateCalulator.registerOffset(
        'card_double_down_offset',
        Vector4.new(0.04, 0, 0, 0),  -- additional X offset for 3rd card in doubled hand
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    --Chip locations
    RelativeCoordinateCalulator.registerOffset(
        'chip_player_center_position',
        Vector4.new(-0.0007, 0.9127, 0.7975, 0),
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'chip_player_left1_up1',
        Vector4.new(0.02, -0.035, 0, 0),
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'chip_player_left1',
        Vector4.new(0.04, 0, 0, 0),
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    --Space between split hands on board
    RelativeCoordinateCalulator.registerOffset(
        'space_between_hands',
        Vector4.new(0.18, 0, 0, 0),
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    --Dealer positions
    RelativeCoordinateCalulator.registerOffset(
        'dealer_spawn_position',
        Vector4.new(-0.0007, -0.2653, 0.0055, 0),  -- dealer spawns at table position
        EulerAngles.new(0, 0, 0):ToQuat()  -- same orientation as table
    )
    RelativeCoordinateCalulator.registerOffset(
        'dealer_workspot_position',
        Vector4.new(-0.0007, -0.2653, 0.0055, 0),  -- workspot entity at table position
        EulerAngles.new(0, 0, 180):ToQuat()  -- 180 degree rotation for workspot
    )
    --Spot positions
    RelativeCoordinateCalulator.registerOffset(
        'spot_position',
        Vector4.new(0, 1.6066, -0.0001, 0),  -- offset from table to spot position
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'mappin_position',
        Vector4.new(0, 1.6066, 0.9358, 0),  -- offset from table to mappin position
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    --Camera offsets
    RelativeCoordinateCalulator.registerOffset(
        'camera_position_offset',
        Vector4.new(0, 0.4, 0.7, 0),  -- camera position offset relative to spot (not table, so no adjustment needed)
        EulerAngles.new(0, 0, 0):ToQuat()
    )

    -- Load tables from JSON files in addons folder (after hardcoded tables)
    local addonTables = JsonData.ReturnAllFromFolder("addons")
    for _, tableData in ipairs(addonTables) do
        -- Convert position to Vector4
        local position = Vector4.new(tableData.position.x, tableData.position.y, tableData.position.z, 1)
        
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

return BlackjackCoordinates

