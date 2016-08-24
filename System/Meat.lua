local animalsName, animalsTable = ...
local _ = nil

animalsTable.animalsAurasToIgnore = {
    "Arcane Protection",
    "Water Bubble",
}
function animalsTable.animalsAuraBlacklist(object)
    local auraToCheck = nil
    for i = 1, #animalsTable.animalsAurasToIgnore do
        auraToCheck = animalsTable.animalsAurasToIgnore[i]
        if animalsTable.Aura(object, auraToCheck) then return false end
    end
    return true
end

animalsTable.humansAurasToIgnore = {
}
function animalsTable.humansAuraBlacklist(object)
    local auraToCheck = nil
    for i = 1, #animalsTable.humansAurasToIgnore do
        auraToCheck = animalsTable.humansAurasToIgnore[i]
        if animalsTable.Aura(object, auraToCheck) then return false end
    end
    return true
end

function animalsTable.logToFile(message)
    if animalsDataPerChar.log then
        local file = ReadFile(animalsTable.logFile)
        -- local debugStack = string.gsub(debugstack(2, 100, 100), '%[string "local function GetScriptName %(%) return "gst..."%]', "line")
        -- debugStack = string.gsub(debugStack, "\n", ", ")
        WriteFile(animalsTable.logFile, file..",\n{\n\t"..message.."\n\t\"time\":"..GetTime()..",\n\t\"Line Number\": "..debugStack.."\n}")
    end
end

function GS.humanNotDuplicate(unitPassed)
    for i = 1, GS.AllyTargetsSize do
        unit = GS.AllyTargets[i].Player
        if unit == unitPassed then return false end
    end
    return true
end

-- ripped from CommanderSirow of the wowace forums
function GS.TTDF(unit) -- keep updated: see if this can be optimized
    -- Setup trigger (once)
    if not nMaxSamples then
        -- User variables
        nMaxSamples = 15             -- Max number of samples
        nScanThrottle = 0.5             -- Time between samples
    end

    -- Training Dummy alternate between 4 and 200 for cooldowns
    if tContains(GS.Dummies, UnitName(unit)) then
        if not GSR.DummyTTDMode or GSR.DummyTTDMode == 1 then
            if (not GS.TTD[unit] or GS.TTD[unit] == 200) then GS.TTD[unit] = 4 return else GS.TTD[unit] = 200 return end
        elseif GSR.DummyTTDMode == 2 then
            GS.TTD[unit] = 4
            return
        else
            GS.TTD[unit] = 200
            return
        end
    end

    -- if health = 0 then set time to death to negative
    if GS.Health(unit) == 0 then GS.TTD[unit] = -1 return end

    -- Query current time (throttle updating over time)
    local nTime = GetTime()
    if not GS.TTDM[unit] or nTime - GS.TTDM[unit].nLastScan >= nScanThrottle then
        -- Current data
        local data = GS.Health(unit)

        if not GS.TTDM[unit] then GS.TTDM[unit] = {start = nTime, index = 1, maxvalue = GS.Health(unit, max)/2, values = {}, nLastScan = nTime, estimate = nil} end

        -- Remember current time
        GS.TTDM[unit].nLastScan = nTime

        if GS.TTDM[unit].index > nMaxSamples then GS.TTDM[unit].index = 1 end
        -- Save new data (Use relative values to prevent "overflow")
        GS.TTDM[unit].values[GS.TTDM[unit].index] = {dmg = data - GS.TTDM[unit].maxvalue, time = nTime - GS.TTDM[unit].start}

        if #GS.TTDM[unit].values >= 2 then
            -- Estimation variables
            local SS_xy, SS_xx, x_M, y_M = 0, 0, 0, 0

            -- Calc pre-solution values
            for i = 1, #GS.TTDM[unit].values do
                z = GS.TTDM[unit].values[i]
                -- Calc mean value
                x_M = x_M + z.time / #GS.TTDM[unit].values
                y_M = y_M + z.dmg / #GS.TTDM[unit].values

                -- Calc sum of squares
                SS_xx = SS_xx + z.time * z.time
                SS_xy = SS_xy + z.time * z.dmg
            end
            -- for i = 1, #GS.TTDM[unit].values do
            --     -- Calc mean value
            --     x_M = x_M + GS.TTDM[unit].values[i].time / #GS.TTDM[unit].values
            --     y_M = y_M + GS.TTDM[unit].values[i].dmg / #GS.TTDM[unit].values

            --     -- Calc sum of squares
            --     SS_xx = SS_xx + GS.TTDM[unit].values[i].time * GS.TTDM[unit].values[i].time
            --     SS_xy = SS_xy + GS.TTDM[unit].values[i].time * GS.TTDM[unit].values[i].dmg
            -- end

            -- Few last addition to mean value / sum of squares
            SS_xx = SS_xx - #GS.TTDM[unit].values * x_M * x_M
            SS_xy = SS_xy - #GS.TTDM[unit].values * x_M * y_M

            -- Results
            local a_0, a_1, x = 0, 0, 0

            -- Calc a_0, a_1 of linear interpolation (data_y = a_1 * data_x + a_0)
            a_1 = SS_xy / SS_xx
            a_0 = y_M - a_1 * x_M

            -- Find zero-point (Switch back to absolute values)
            a_0 = a_0 + GS.TTDM[unit].maxvalue
            x = - (a_0 / a_1)

            -- Valid/Usable solution
            if a_1 and a_1 < 1 and a_0 and a_0 > 0 and x and x > 0 then
                GS.TTDM[unit].estimate = x + GS.TTDM[unit].start
                -- Fallback
            else
                GS.TTDM[unit].estimate = nil
            end

            -- Not enough data
        else
            GS.TTDM[unit].estimate = nil
        end
        GS.TTDM[unit].index = GS.TTDM[unit].index + 1 -- enable
    end

    if not GS.TTDM[unit].estimate then
        GS.TTD[unit] = math.huge
    elseif nTime > GS.TTDM[unit].estimate then
        GS.TTD[unit] = -1
    else
        GS.TTD[unit] = GS.TTDM[unit].estimate-nTime
    end
end
-- ripped from CommanderSirow of the wowace forums