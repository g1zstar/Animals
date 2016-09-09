local animalsName, animalsTable = ...
local _ = nil

function animalsTable.animalsAuraBlacklist(object)
    local auraToCheck = nil
    for i = 1, #animalsTable.animalsAurasToIgnore do
        auraToCheck = animalsTable.animalsAurasToIgnore[i]
        if animalsTable.aura(object, auraToCheck) then return false end
    end
    return true
end

function animalsTable.humansAuraBlacklist(object)
    local auraToCheck = nil
    for i = 1, #animalsTable.humansAurasToIgnore do
        auraToCheck = animalsTable.humansAurasToIgnore[i]
        if animalsTable.aura(object, auraToCheck) then return false end
    end
    return true
end

function animalsTable.logToFile(message)
    if animalsDataPerChar.log then
        local file = ReadFile(animalsTable.logFile)
        local debugStack = string.gsub(debugstack(2, 100, 100), 'Interface\\AddOns\\Animals\\.-(%w+)%.lua', "file: %1, line")
        debugStack = string.gsub(debugStack, "\n", ", ")
        WriteFile(animalsTable.logFile, file..",\n{\n\t"..message.."\n\t\"time\":"..GetTime()..",\n\t\"Line Number\": "..debugStack.."\n}")
    end
end

function animalsTable.humanNotDuplicate(unitPassed)
    for i = 1, animalsTable.humansSize do
        unit = animalsTable.targetHumans[i].Player
        if unit == unitPassed then return false end
    end
    return true
end

-- ripped from CommanderSirow of the wowace forums
function animalsTable.TTDF(unit) -- keep updated: see if this can be optimized
    -- Setup trigger (once)
    if not nMaxSamples then
        -- User variables
        nMaxSamples = 15             -- Max number of samples
        nScanThrottle = 0.5             -- Time between samples
    end

    -- Training Dummy alternate between 4 and 200 for cooldowns
    if tContains(animalsTable.dummiesID, animalsTable.getUnitID(unit)) then
        if not animalsDataPerChar.dummyTTDMode or animalsDataPerChar.dummyTTDMode == 1 then
            if (not animalsTable.TTD[unit] or animalsTable.TTD[unit] == 200) then animalsTable.TTD[unit] = 4 return else animalsTable.TTD[unit] = 200 return end
        elseif animalsDataPerChar.dummyTTDMode == 2 then
            animalsTable.TTD[unit] = 4
            return
        else
            animalsTable.TTD[unit] = 200
            return
        end
    end

    if not ObjectExists(unit) or not UnitExists(unit) or animalsTable.health(unit) == 0 then animalsTable.TTD[unit] = -1 return end

    -- Query current time (throttle updating over time)
    local nTime = GetTime()
    if not animalsTable.TTDM[unit] or nTime - animalsTable.TTDM[unit].nLastScan >= nScanThrottle then
        -- Current data
        local data = animalsTable.health(unit)

        if not animalsTable.TTDM[unit] then animalsTable.TTDM[unit] = {start = nTime, index = 1, maxvalue = animalsTable.health(unit, max)/2, values = {}, nLastScan = nTime, estimate = nil} end

        -- Remember current time
        animalsTable.TTDM[unit].nLastScan = nTime

        if animalsTable.TTDM[unit].index > nMaxSamples then animalsTable.TTDM[unit].index = 1 end
        -- Save new data (Use relative values to prevent "overflow")
        animalsTable.TTDM[unit].values[animalsTable.TTDM[unit].index] = {dmg = data - animalsTable.TTDM[unit].maxvalue, time = nTime - animalsTable.TTDM[unit].start}

        if #animalsTable.TTDM[unit].values >= 2 then
            -- Estimation variables
            local SS_xy, SS_xx, x_M, y_M = 0, 0, 0, 0

            -- Calc pre-solution values
            for i = 1, #animalsTable.TTDM[unit].values do
                z = animalsTable.TTDM[unit].values[i]
                -- Calc mean value
                x_M = x_M + z.time / #animalsTable.TTDM[unit].values
                y_M = y_M + z.dmg / #animalsTable.TTDM[unit].values

                -- Calc sum of squares
                SS_xx = SS_xx + z.time * z.time
                SS_xy = SS_xy + z.time * z.dmg
            end
            -- for i = 1, #animalsTable.TTDM[unit].values do
            --     -- Calc mean value
            --     x_M = x_M + animalsTable.TTDM[unit].values[i].time / #animalsTable.TTDM[unit].values
            --     y_M = y_M + animalsTable.TTDM[unit].values[i].dmg / #animalsTable.TTDM[unit].values

            --     -- Calc sum of squares
            --     SS_xx = SS_xx + animalsTable.TTDM[unit].values[i].time * animalsTable.TTDM[unit].values[i].time
            --     SS_xy = SS_xy + animalsTable.TTDM[unit].values[i].time * animalsTable.TTDM[unit].values[i].dmg
            -- end

            -- Few last addition to mean value / sum of squares
            SS_xx = SS_xx - #animalsTable.TTDM[unit].values * x_M * x_M
            SS_xy = SS_xy - #animalsTable.TTDM[unit].values * x_M * y_M

            -- Results
            local a_0, a_1, x = 0, 0, 0

            -- Calc a_0, a_1 of linear interpolation (data_y = a_1 * data_x + a_0)
            a_1 = SS_xy / SS_xx
            a_0 = y_M - a_1 * x_M

            -- Find zero-point (Switch back to absolute values)
            a_0 = a_0 + animalsTable.TTDM[unit].maxvalue
            x = - (a_0 / a_1)

            -- Valid/Usable solution
            if a_1 and a_1 < 1 and a_0 and a_0 > 0 and x and x > 0 then
                animalsTable.TTDM[unit].estimate = x + animalsTable.TTDM[unit].start
                -- Fallback
            else
                animalsTable.TTDM[unit].estimate = nil
            end

            -- Not enough data
        else
            animalsTable.TTDM[unit].estimate = nil
        end
        animalsTable.TTDM[unit].index = animalsTable.TTDM[unit].index + 1 -- enable
    end

    if not animalsTable.TTDM[unit].estimate then
        animalsTable.TTD[unit] = math.huge
    elseif nTime > animalsTable.TTDM[unit].estimate then
        animalsTable.TTD[unit] = -1
    else
        animalsTable.TTD[unit] = animalsTable.TTDM[unit].estimate-nTime
    end
end
-- ripped from CommanderSirow of the wowace forums

animalsTable.interruptTable = {

}

function animalsTable.interruptFunction(target)
    if not target then target = "target" end
    if not ObjectExists(target) or not UnitExists(target) or not UnitCastingInfo(target) and not UnitChannelInfo(target) then return end

    if UnitCastingInfo(target) and not select(9, UnitCastingInfo(target)) then
        if not animalsTable.interruptTable[animalsTable.getUnitID(target)] then animalsTable.interruptTable[animalsTable.getUnitID(target)] = {} end
        if not animalsTable.interruptTable[animalsTable.getUnitID(target)][select(10, UnitCastingInfo(target))] then animalsTable.interruptTable[animalsTable.getUnitID(target)][select(10, UnitCastingInfo(target))] = {name = UnitCastingInfo(target), type = "cast"} end
    elseif UnitChannelInfo(target) and not select(8, UnitChannelInfo(target)) then
        if not animalsTable.interruptTable[animalsTable.getUnitID(target)] then animalsTable.interruptTable[animalsTable.getUnitID(target)] = {} end
        -- if not animalsTable.interruptTable[animalsTable.getUnitID(target)][select(10, UnitCastingInfo(target))] then animalsTable.interruptTable[animalsTable.getUnitID(target)][select(10, UnitChannelInfo(target))] = {name = UnitChannelInfo(target), type = "channel"} end
    end
end