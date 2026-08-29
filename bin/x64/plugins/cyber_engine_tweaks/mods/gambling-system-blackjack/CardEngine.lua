--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================
CardEngine = {
    version = '1.0.3',
    cards = {},
    inMotionCardsList = {},
    inFlippingMotionCardsList = {},
    deckShufflingAnimationActive = false,
    deckShuffleAnimationAge = 0,
    -- Performance optimization caches
    entityCache = {}
}

local Cron = require('External/Cron.lua')

local cardPath = "boe6\\gambling_props\\boe6_playing_card.ent"
local DECK_CARD_COUNT = 40
local DEFAULT_DECK_APPEARANCE = '7h'

--functions
--=========
---Processes 1 step of each current card in the CardEngine.inFlippingMotionCardsList table
local function cardsInFlippingMotionProcessStep()
    for k,v in pairs(CardEngine.inFlippingMotionCardsList) do
        if CardEngine.inFlippingMotionCardsList[v.id] == nil then
            break
        end

        local flipAngle = 20 --angle to move each step. Basically card flip speed.
        local totalFlipDegrees = 180
        local liftDistance = 0.01 --amount of height to add to the card during each step
        if v.direction == 'left' then --inverts angle to swap direction
            totalFlipDegrees = totalFlipDegrees * -1
            flipAngle = flipAngle * -1
        end

        local steps = totalFlipDegrees / flipAngle --how many iterations of cardsInFlippingMotionProcessStep() to flip 180 degrees
        if v.lifetime >= steps then --after steps (degrees x steps = 180) mark card as done flipping. ('delete')
            CardEngine.inFlippingMotionCardsList[v.id] = nil
            -- Clear from cache when animation completes
            CardEngine.entityCache[v.id] = nil
            break
        end

        -- Cache entity lookup to avoid repeated Game.FindEntityByID calls
        local entity = CardEngine.entityCache[v.id]
        if not entity then
            entity = Game.FindEntityByID(CardEngine.cards[v.id].entID)
            if entity then
                CardEngine.entityCache[v.id] = entity
            else
                -- Entity not found, skip this animation
                CardEngine.inFlippingMotionCardsList[v.id] = nil
                break
            end
        end

        -- Pre-calculate quaternion and vectors once per animation step
        local entQuat = v.curEuler:ToQuat()
        local entityVector4 = entity:GetWorldPosition() --XYZ world position
        local forwardVector = entQuat:GetForward()  --Vector4
        local upVector = entQuat:GetUp()            --Vector4
        local rightVector = entQuat:GetRight()      --Vector4 forward, rotates card on long axis
        local outQuat
        local angleRadians = (math.pi / 180) * flipAngle --convert degrees to radians

        if v.flipAngle == 'horizontal' then
            local rotatedVector = forwardVector.RotateAxis(forwardVector, rightVector, angleRadians)  --[ These 2 functions
            outQuat = entQuat.BuildFromDirectionVector(rotatedVector, upVector)                       --[ Are black magic
        elseif v.flipAngle == 'facewise' then
            if v.halfFlip then
                flipAngle = flipAngle / 2 --half rotation, 90 degrees only.
                angleRadians = (math.pi / 180) * flipAngle
            end
            local rotatedVector = forwardVector.RotateAxis(forwardVector, upVector, angleRadians)
            outQuat = entQuat.BuildFromDirectionVector(rotatedVector, upVector)
        elseif v.flipAngle == 'vertical' then --still doesn't work. smh
            local rotatedUp = upVector.RotateAxis(upVector, forwardVector, angleRadians)
            outQuat = entQuat.BuildFromDirectionVector(forwardVector, rotatedUp)
        else
            DualPrint('CE | Unknown flipAngle: '..tostring(v.flipAngle))
        end

        --add height during first half of flip, subtract during second. no action when in the middle. (the 0.5 does this)
        if v.flipAngle == 'horizontal' then
            if v.lifetime < (steps / 2)-0.5 then
                v.curHeight = v.curHeight + liftDistance
            elseif v.lifetime > (steps / 2)-0.5 then
                v.curHeight = v.curHeight - liftDistance
            end
        elseif v.flipAngle == 'vertical' then
            if v.lifetime < (steps / 2)-0.5 then
                v.curHeight = v.curHeight + liftDistance * 2
            elseif v.lifetime > (steps / 2)-0.5 then
                v.curHeight = v.curHeight - liftDistance * 2
            end
        end
        entityVector4.z = v.curHeight

        local outEuler = outQuat:ToEulerAngles()
        v.curEuler = outEuler

        Game.GetTeleportationFacility():Teleport(entity, entityVector4, outEuler)

        v.lifetime = v.lifetime + 1
    end
end
---Processes 1 step of each current card in the CardEngine.inMotionCardsList table
local function cardsInMotionProcessStep(dt)
    if not next(CardEngine.inMotionCardsList) then
        return
    end
    
    for i, card in pairs(CardEngine.inMotionCardsList) do
        local stepSize = 1.0
        local moveDistance = stepSize * dt * 1
        local rotateDistance = stepSize * dt * 1

        local cardObj = CardEngine.cards[card.id]
        local entID = cardObj.entID
        
        -- Cache entity lookup to avoid repeated Game.FindEntityByID calls
        local entity = CardEngine.entityCache[card.id]
        if not entity then
            entity = Game.FindEntityByID(entID)
            if entity then
                CardEngine.entityCache[card.id] = entity
            end
        end
        
        local doContinue = true
        if entity == nil then
            --DualPrint('CE | Card missing! id: '..tostring(card.id)..' overAge: '..tostring(card.overAge))
            if card.overAge >= 3 then
                CardEngine.inMotionCardsList[i] = nil
                CardEngine.entityCache[card.id] = nil -- Clear from cache
            end
            card.overAge = card.overAge + 1
            doContinue = false
        end

        if doContinue then
            --instatiate output euler
            local euler = EulerAngles.new(card.TargetOriRPY.r, card.TargetOriRPY.p, card.TargetOriRPY.y)

            local currentOrientationRPY = entity:GetWorldOrientation():ToEulerAngles()
            local curOri = {r=currentOrientationRPY.roll,p=currentOrientationRPY.pitch,y=currentOrientationRPY.yaw}
            local tarOri = {r=card.TargetOriRPY.r,p=card.TargetOriRPY.p,y=card.TargetOriRPY.y}
            euler = EulerAngles.new(curOri.r,curOri.p,curOri.y)

            local entityVector4 = entity:GetWorldPosition()
            local TargetVector4 = card.targetPos
            local vectorXYZ = {x=TargetVector4.x-entityVector4.x,y=TargetVector4.y-entityVector4.y,z=TargetVector4.z-entityVector4.z}
            local magnitude = math.sqrt(vectorXYZ.x^2 + vectorXYZ.y^2 + vectorXYZ.z^2)
            if magnitude <= moveDistance then
                Game.GetTeleportationFacility():Teleport(entity, TargetVector4, euler)
                if card.flipEnd then
                    Cron.After(0.5, CardEngine.FlipCard(card.id, card.flipAngle, card.flipDirection, false))
                end
                CardEngine.inMotionCardsList[i] = nil
                CardEngine.entityCache[card.id] = nil -- Clear from cache when animation completes
                break
            end
            local directionXYZ = {x=vectorXYZ.x/magnitude,y=vectorXYZ.y/magnitude,z=vectorXYZ.z/magnitude}
            local newXYZ = {
                x=entityVector4.x+directionXYZ.x*moveDistance,
                y=entityVector4.y+directionXYZ.y*moveDistance,
                z=entityVector4.z+directionXYZ.z*moveDistance}
            local outPositionVector4 = Vector4.new(newXYZ.x,newXYZ.y,newXYZ.z,1)

            Game.GetTeleportationFacility():Teleport(entity, outPositionVector4, euler)
        end
    end
end
---If deck shuffling, process 1 step
local function shuffleDeckAnim()
    if not CardEngine.deckShufflingAnimationActive then
        return
    end
    CardEngine.deckShuffleAnimationAge = CardEngine.deckShuffleAnimationAge + 1
    if CardEngine.deckShuffleAnimationAge > 20 then
        CardEngine.deckShuffleAnimationAge = 0
        CardEngine.deckShufflingAnimationActive = false
        return
    end
    if CardEngine.deckShuffleAnimationAge % 4 == 0 then
        local bottomCardentID = CardEngine.cards['deckCard_'..tostring(0)].entID
        local bottomCard = Game.FindEntityByID(bottomCardentID)
        bottomCard:PlaySoundEvent("q115_sc_02d_card_grab")
    end

    --local cardOrder = {14,5,36,22,28,13,39,9,3,12,35,2,34,19,23,30,20,37,17,7} 4 aces all split hand
    local cardOrder = {14,5,36,22,28,13,39,9,3,12,35,2,34,19,23,30,20,37,17,7}
    local direction = 'left'
    if math.random(1,2) == 1 then --randomly set rotation direction, clockwise or counterclockwise.
        direction = 'right'
    end
    CardEngine.FlipCard('deckCard_'..tostring(cardOrder[CardEngine.deckShuffleAnimationAge]), 'facewise', direction, false)
end

--Methods
--=========
---Runs on init
function CardEngine.init() --runs on game launch
    Cron.Every(0.05, cardsInFlippingMotionProcessStep)
    Cron.Every(0.05, shuffleDeckAnim)
end

--- Runs every frame
---@param dt any delta time
function CardEngine.update(dt)
    cardsInMotionProcessStep(dt)
end

---Create card entity and lua object
---@param id any id of card
---@param faceType string card face, k4, 8s, Ah, etc
---@param positionVector4 any Vector4 spawn position of card
---@param orientationRPY any orientation as {r=,p=,y=}
---@return any id card id output
function CardEngine.CreateCard(id, faceType, positionVector4, orientationRPY)
    local cardSpec = StaticEntitySpec.new()
    cardSpec.templatePath = cardPath
    cardSpec.appearanceName = faceType
    cardSpec.position = positionVector4
    cardSpec.orientation = EulerAngles.ToQuat(EulerAngles.new(orientationRPY.r,orientationRPY.p,orientationRPY.y))
    cardSpec.tags = {"cardEngine",id}

    --local entitySystem = Game.GetStaticEntitySystem()
    local entityID = Game.GetStaticEntitySystem():SpawnEntity(cardSpec)
    CardEngine.cards[id] = { id = id, entID = entityID }
    return id
end

---Delete card
---@param id any id of card to delete
function CardEngine.DeleteCard(id)
    --DualPrint('card deleting: '..tostring(id))
    --DualPrint('entity deleting: '..tostring(CardEngine.cards[id].id))
    Game.GetStaticEntitySystem():DespawnEntity(CardEngine.cards[id].entID)
    -- Clear from cache when card is deleted
    CardEngine.entityCache[id] = nil
end

---Move card to position with animation 'style'
---@param id any id of card to move
---@param positionVector4 any Vector4 target position of card
---@param orientationRPY any orientation target as {r=,p=,y=}
---@param movementStyle string animation style
---@param flipEnd boolean flip card at end true/false
---@param flipAngle? string Optional 'horizontal', 'facewise', or 'vertical'
---@param flipDirection? string Optional 'left' or 'right'
function CardEngine.MoveCard(id, positionVector4, orientationRPY, movementStyle, flipEnd, flipAngle, flipDirection)
    --DualPrint('CE | Move sent for id: '..tostring(id))
    if flipAngle == nil then
        flipAngle = 'horizontal'
    end
    if flipDirection == nil then
        flipDirection = 'left'
    end
    local entity = Game.FindEntityByID(CardEngine.cards[id].entID)
    if movementStyle == 'snap' then
        local euler = EulerAngles.new(orientationRPY.r, orientationRPY.p, orientationRPY.y)
        Game.GetTeleportationFacility():Teleport(entity, positionVector4, euler)
    elseif movementStyle == 'smooth' then
        CardEngine.inMotionCardsList[id] = {id = id, targetPos = positionVector4, TargetOriRPY = orientationRPY, movementStyle = movementStyle, flipEnd = flipEnd, flipAngle = flipAngle, flipDirection = flipDirection, overAge = 0}
    end
    if entity ~= nil then
        entity:PlaySoundEvent("q115_sc_02d_card_pick_up")
    end
end

---Flip card 180 to other face/side
---@param id any id of card to flip
---@param flipAngle string type of rotation. horizontal, facewise, etc.
---@param direction string direction of flip, left or right
function CardEngine.FlipCard(id, flipAngle, direction, halfFlip)
    --DualPrint('CE | Flip sent for id: '..tostring(id))
    local entity = Game.FindEntityByID(CardEngine.cards[id].entID)
    if entity == nil then
        DualPrint('card '..tostring(id)..' does not exist. error #0238')
        return
    end
    entity:PlaySoundEvent("q115_sc_02d_card_put_down")
    local entityVector4 = entity:GetWorldPosition()
    local curEuler = entity:GetWorldOrientation():ToEulerAngles()
    CardEngine.inFlippingMotionCardsList[id] = {id = id, flipAngle = flipAngle, direction = direction, lifetime = 0, curEuler = curEuler, curHeight = entityVector4.z, halfFlip = halfFlip}
end

---Spawns card entities to look like a deck
---@param positionVector4 Vector4 spawn position
---@param orientationQuaternion Quaternion orientation quaternion
function CardEngine.BuildVisualDeck(positionVector4, orientationQuaternion)
    local deckEuler = orientationQuaternion:ToEulerAngles()
    local orientationRPY = { r = deckEuler.roll, p = deckEuler.pitch, y = deckEuler.yaw }
    for i = 0, (DECK_CARD_COUNT-1) do
        local newZ = positionVector4.z + (0.0005 * i)
        local newPositionVector4 = Vector4.new(positionVector4.x, positionVector4.y, newZ, 1)
        CardEngine.CreateCard('deckCard_'..tostring(i), DEFAULT_DECK_APPEARANCE, newPositionVector4, orientationRPY)
    end
end

---Removes all deck card entities
function CardEngine.RemoveVisualDeck()
    for i = 0, 39 do
        CardEngine.DeleteCard('deckCard_'..tostring(i))
    end
end

---Flips deckShuffling var to true, causing the deck 'shuffle' animation
function CardEngine.TriggerDeckShuffle()
    CardEngine.deckShufflingAnimationActive = true
end

---DualPrint a list of all cards currently spawned
function CardEngine.PrintAllCards(excludeDeck) --shout out to deepseek for this function I never call 👍
    local cardList = {}
    for id in pairs(CardEngine.cards) do
        if not (excludeDeck and k:match('^deckCard_')) then
            table.insert(cardList, id)
        end
    end
    DualPrint("Cards: "..table.concat(cardList, ", "))
end

--- Sets card highlight color
---@param cardID string card to highlight
---@param colorIndex number color index 
--- 0 = none, 1 = green, 2 = red, 3 = blue, 4 = orange, 5 = yellow, 6 = light blue
function CardEngine.setHighlightColor(cardID, colorIndex)
    local entityID = CardEngine.cards[cardID].entID
    local entity = Game.FindEntityByID(entityID)
    local newRenderHighlight = entRenderHighlightEvent.new()
    newRenderHighlight.opacity = 1.0
    newRenderHighlight.seeThroughWalls = true
    newRenderHighlight.outlineIndex = colorIndex
    entity:QueueEventForEntityID(entityID, newRenderHighlight)
end

--- Clears entity cache to prevent memory leaks
--- Call this periodically or when cards are no longer needed
function CardEngine.clearEntityCache()
    CardEngine.entityCache = {}
end

return CardEngine