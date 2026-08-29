RouletteAnimations = {
    version = '1.0.0',
    roulette_spinning = false,
    ball_spinning = false
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

-- Module state
local initialized = false
local dependencies = {}

-- Roulette spinner variables
local roulette_spinning = false
local roulette_spinning_count = 0
local roulette_spinning_speed = 0
local roulette_angle_count = 0
local roulette_angle = 0
local roulette_speed_adjusted = 0

-- Roulette ball variables
local ball_center = {x=0, y=0, z=0}
local ball_phase = 0
local ball_spinning = false
local ball_spinning_count = 0
local ballX = 0
local ballY = 0
local ball_distance = 0.35 --0.35 = max distance, 0.23 = contact, 0.2 = resting
local ball_speed = 0.2
local ball_bounces = 0
local ball_bounce1 = 0
local bounce_randomness = 30
local ball_angle = 0
local ball_height = 0
local bounce_height = 60
local max_ball_bounces = 4 --how many bounces before the ball is force stopped

-- tableCenterPoint is now managed by TableManager

-- Helper function: MapVar
local function MapVar(var, in_min, in_max, out_min, out_max) --maps a value from one range to another
    return ( (var - in_min) / (in_max - in_min) ) * (out_max - out_min) + out_min
end

-- Helper function: LowerBallDistance
local function LowerBallDistance()
    if ball_distance > 0.2 then --dont flip the < to a > on accident or you'll be debugging why the ball disappears for a few hours             >:(
        ball_distance = ball_distance - ( 0.3*ball_speed^2 - 0.06*ball_speed + 0.0035 ) --math to make the ball fall faster as it gets closer to the center
    elseif ball_distance < 0.2 then
        ball_distance = 0.2 --cap to prevent exponential runaway into spinner wheel and past it
    end
end

-- Helper function: BounceRandomizer
local function BounceRandomizer()
    local ball_bounce_speed_max_range = 0.04
    local ball_bounce_speed_top = 0.015
    local ball_bounce_speed_target = roulette_speed_adjusted

    local ball_bounces_sofar = ball_bounces / max_ball_bounces --percentage of how "aggressivly" to sync ball with wheel. higher values (0.98) shoudl equal more sync
    if ball_bounces_sofar == 1 then ball_bounces_sofar = 0.9999 end --prevent divide by 0 after below conversion
    ball_bounces_sofar = ( -ball_bounces_sofar + 1 ) --invert 0 to 1 to go from 1 to 0
    local ball_bounce_speed_used_range = ball_bounce_speed_max_range * ball_bounces_sofar --changes ball_bounce_speed_max_range to a smaller range, smaller as the ball bounce count increases

    local ball_bounce_adjusted_top_speed = MapVar(ball_bounces, 0, max_ball_bounces, roulette_speed_adjusted, ball_bounce_speed_top)

    local ball_bounce_speed_range_top = ball_bounce_adjusted_top_speed
    local ball_bounce_speed_range_bottom = ball_bounce_adjusted_top_speed - ball_bounce_speed_used_range

    local randomized = ( MapVar(math.random(), 0, 1, ball_bounce_speed_range_bottom, ball_bounce_speed_range_top) / ball_bounces ) --randomize ball speed for after contact

    ball_speed = ball_speed + randomized

    bounce_randomness = ( math.random() * 20 ) + ( 20 - (ball_bounces*2) ) --tick length for bounce sin wave to complete 2pi (1 full wave)
end

-- Helper function: BallBounce
local function BallBounce(max)
    if ( (ball_speed - roulette_spinning_speed) < 1 and (ball_speed - roulette_spinning_speed) > -1 ) then --check if ball speed matches wheel speed
        ball_phase = 2 --end bounces and allow ball to settle
        return
    end
    ball_bounce1 = ball_bounce1 + 1 --tick counter up
    local bounce_height_new = bounce_height + (ball_bounces * 5)
    local bounce_progress = MapVar(ball_bounce1, 0, bounce_randomness, 0, math.pi*2) --convert tick count to a value in the first wave of sin()
    ball_distance = ball_distance + ( math.sin(bounce_progress) / bounce_height_new ) --Add current sin(count) to current distance

    if (ball_distance <= 0.23 and ball_bounce1 >= 10) then --check for collision, >=10 ensures the ball has moved
        if ball_bounces >= max then --check if max number of bounces has been reached
            ball_phase = 2
        else
            --Following code only runs if processing a collision:
            ball_bounces = ball_bounces + 1 --count total bounces
            ball_bounce1 = 0 --reset count for next bounce
            BounceRandomizer()
        end
    end
end

-- Public function: AdvanceSpinner
function RouletteAnimations.AdvanceSpinner()
    if roulette_spinning_count == 0 then
        roulette_spinning_speed = (math.random() * 1) + 3 --wheel spin randomness, math.random() generates random float between 0 and 1, eg. 0.387643
    end

    roulette_spinning_count = roulette_spinning_count + 1 --increase count, linear, used to tell how many times AdvanceSpinner() has been called / how long the spin has elapsed
    roulette_angle_count = roulette_angle_count + roulette_spinning_speed --advance the wheel by the current speed
    roulette_spinning_speed = roulette_spinning_speed - 0.0025 --decrease wheel speed
    
    roulette_speed_adjusted = -(MapVar(roulette_spinning_speed, 0, 360, 0, math.pi*2))

    roulette_angle = math.fmod(roulette_angle_count, 360) --divide by 360 and get remainder, eg. set 725 degrees to 5 degrees
    if roulette_spinning_speed <= 0 then --end spin when count reaches max
        roulette_spinning = false
        RouletteAnimations.roulette_spinning = false
        roulette_spinning_count = 0
        roulette_angle_count = 0
        roulette_speed_adjusted = 0
    end
    dependencies.SetRotateEnt('roulette_spinner', {r=0, p=0, y=roulette_angle})
end

-- Public function: AdvanceRouletteBall
function RouletteAnimations.AdvanceRouletteBall()
    if ball_spinning_count == 0 then
        ball_speed = (math.random() / 10) + 0.3 --math.random() generates random float between 0 and 1, eg. 0.387643 --maybe move into phase 1
        ball_phase = 1
    end

    ball_spinning_count = ball_spinning_count + 1 --increase count, linear

    ballX = ballX + ball_speed --advances the ball by the current speed. increase in ballX = increase over x axis in sin() graph. 6.28/pi*2 = 360 degrees
    ballY = ballY + ball_speed
    local sinX = math.sin(ballX) --convert ballX var through sin() and cos() to get -1 to 1 range
    local cosY = math.cos(ballY)
    local bigX = sinX * ball_distance --multiply sin() and cos() result to spread ball out from center
    local bigY = cosY * ball_distance
    local movedX = bigX + ball_center.x --adjust ball's XY position to CP2077 world coordinates
    local movedY = bigY + ball_center.y

    if ball_phase == 1 then

        if ball_speed > 0 then --slows ball, "friction"
            ball_speed = ball_speed - 0.001
        else
            if ball_speed < 0 then
                ball_speed = ball_speed + 0.001
            end
        end

        if ball_speed < 0.15 then --when the ball has decelerated enough, this sets when the ball falls off the outer wall circle
            LowerBallDistance()
        end

        if (ball_bounces == 0 and ball_distance <= 0.23) then
            ball_bounces = 1 --first bounce, triggers below if statement
            dependencies.GetPlayer():StopSoundEvent("q303_hotel_casino_roulette_ball_start")
            dependencies.GetPlayer():PlaySoundEvent("q303_hotel_casino_roulette__ball_stop")
            BounceRandomizer() --pre-load randomness
        end
        if ball_bounces >= 1 then
            BallBounce(max_ball_bounces) --calculate and process bounce, (max) = bounce number limit
        end

    end

    if ball_phase == 2 then

        roulette_spinning_speed = roulette_spinning_speed - 0.010 --decrease wheel speed, helps speed play up once ball is decided.

        ball_speed = roulette_speed_adjusted --always match ball speed to wheel, keeps them in sync.

        local angle_diff = 0    --find ball's angle relative to the wheel
        if ball_angle >= roulette_angle then
            angle_diff = ball_angle - roulette_angle
        else
            angle_diff = ( ball_angle - roulette_angle ) + 360 --corrects for negative angles
        end

        local mapped_angle = MapVar(angle_diff, 0, 360, 0, 37) --maps 360 value to 1-37 for roulette slots
        local roulette_slot_float = mapped_angle - math.floor(mapped_angle)  --grabs decimal places of mapped_angle

        -- settle ball into roulette wheel slot
        --if not ( roulette_slot_float <= 0.001 or roulette_slot_float >= 0.999 ) then
        --end
        if ( roulette_slot_float < 0.5 ) then
            ball_speed = ball_speed - ( 0.001 * (roulette_slot_float * 10) )
        elseif ( roulette_slot_float > 0.5 )then
            ball_speed = ball_speed + 0.001 * ( -10 * roulette_slot_float + 10 )
        end
        LowerBallDistance()

        if not roulette_spinning then
            ball_phase = 3
            local ball_result = math.floor(mapped_angle)
            if dependencies.UpdateSpinResults then
                dependencies.UpdateSpinResults(tostring(ball_result))
            end
            dependencies.ProcessSpinResult(ball_result+1)
            --DualPrint('result: '..roulette_slots[ball_result+1].label..' '..roulette_slots[ball_result+1].color)
        end

    end

    if ball_phase == 3 then

        ball_speed = 0
        ball_spinning = false
        RouletteAnimations.ball_spinning = false

    end

    -- update ball height to stay on "ground" based on ball_distance
    local tableCenterPoint = TableManager.GetActiveTableCenterPoint()
    if not tableCenterPoint then
        -- Don't spam error if tableCenterPoint is just not set yet (table not initialized)
        -- Only log once per second to avoid spam
        if not RouletteAnimations._lastTableCenterError or (os.time() - RouletteAnimations._lastTableCenterError) >= 1 then
            dependencies.DualPrint('=E ERROR: tableCenterPoint not set in RouletteAnimations, CODE 5001')
            RouletteAnimations._lastTableCenterError = os.time()
        end
        return
    end
    
    if ball_distance <= 0.25 then
        ball_height = 0.41 * ball_distance + tableCenterPoint.z -0.02331358
    else
        ball_height = 0.07 * ball_distance + tableCenterPoint.z +0.06268642
    end

    local entity = Game.FindEntityByID(dependencies.FindEntIdByName('roulette_ball')) --grab entity from entRecords table
    if not entity then
        dependencies.DualPrint('=E ERROR: Could not find roulette_ball entity, CODE 5002')
        return
    end
    
    local newPos = Vector4.new(movedX, movedY, ball_height, 0) --set XYZ of latest position
    Game.GetTeleportationFacility():Teleport(entity, newPos, EulerAngles.new(0, 0, 0)) --update ball to latest position

    ball_angle = math.deg(math.atan2( (newPos.y - ball_center.y), (newPos.x - ball_center.x) )) + 180 --calculate ball's angle relative to center in degrees
            --atan2() is depreciated after lua 5.3, CET currently uses 5.1 (2024-04-18),(2025-04-10)

    if not ball_spinning then
        --reset all ball variables for next spin
        ball_spinning_count = 0
        ballX = 0
        ballY = 0
        ball_distance = 0.35
        ball_bounces = 0
        --ball_falling = false
        ball_speed = 0.2
        ball_bounce1 = 0
        ball_spinning_check = 0
        RouletteAnimations.ball_spinning = false
    end

end

-- Public function: StartSpin
function RouletteAnimations.StartSpin()
    roulette_spinning = true
    ball_spinning = true
    -- Update exposed properties
    RouletteAnimations.roulette_spinning = true
    RouletteAnimations.ball_spinning = true
end

-- Public function: UpdateBallCenter
function RouletteAnimations.UpdateBallCenter(centerPoint)
    -- Store in TableManager for the active table
    local activeTableID = TableManager.GetActiveTable()
    if activeTableID then
        TableManager.SetTableCenterPoint(activeTableID, centerPoint)
    end
    ball_center = {x=centerPoint.x, y=centerPoint.y, z=centerPoint.z+0.08668642}
end

-- Public function: Reset
function RouletteAnimations.Reset()
    ball_speed = 0
    ball_spinning = false
    ball_phase = 0
    roulette_spinning = false
    roulette_spinning_count = 0
    roulette_spinning_speed = 0
    roulette_angle_count = 0
    roulette_angle = 0
    roulette_speed_adjusted = 0
    ball_spinning_count = 0
    ballX = 0
    ballY = 0
    ball_distance = 0.35
    ball_bounces = 0
    ball_bounce1 = 0
    ball_angle = 0
    ball_height = 0
    -- Update exposed properties
    RouletteAnimations.roulette_spinning = false
    RouletteAnimations.ball_spinning = false
end

-- Public function: Initialize
function RouletteAnimations.Initialize(deps)
    dependencies = deps
    initialized = true
    
    -- tableCenterPoint is now managed by TableManager and retrieved via GetActiveTableCenterPoint()
    -- It will be set via UpdateBallCenter() when InitTable() is called
end

-- Expose global flags as getters (used by init.lua)
function RouletteAnimations.IsRouletteSpinning()
    return roulette_spinning
end

function RouletteAnimations.IsBallSpinning()
    return ball_spinning
end

return RouletteAnimations

