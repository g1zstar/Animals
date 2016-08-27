local AC, ACD = LibStub("AceConfig-3.0"), LibStub("AceConfigDialog-3.0")

local animalsName, animalsTable = ...
local _ = nil

function animalsGlobal.animalsToggle(command)
    command = command:lower()

    if command == "aoe" then animalsTable.toggleAoE()       return true end
    if command == "cds" then animalsTable.toggleCDs()       return true end
    if command == "d"   then animalsTable.runDebug()        return true end
    if command == "i"   then animalsTable.toggleInterrupt() return true end
    if command == "o"   then ACD:Open("Animals_Settings")   return true end
    if command == "t"   then animalsTable.toggleRun()       return true end

end

function animalsTable.runDebug()
    for k,v in pairs(animalsTable) do
        animalsGlobal[k] = v
    end
end

function animalsTable.toggleRun()
    animalsTable.allowSlaying = not animalsTable.allowSlaying
    animalsTable.monitorAnimationToggle(animalsTable.allowSlaying and "on" or "off")
    print("GStar Rotations: "..(animalsTable.allowSlaying and "On" or "Off"))
end

function animalsTable.toggleAoE()
    animalsTable.aoe = not animalsTable.aoe
    print("GStar Rotations: AoE now "..(animalsTable.aoe and "on" or "off")..".")
end

function animalsTable.toggleCDs()
    animalsTable.cds = not animalsTable.cds
    print("GStar Rotations: CDs now "..(animalsTable.cds and "on" or "off")..".")
end

function animalsTable.toggleInterrupt()
    animalsDataPerChar.interrupt = not animalsDataPerChar.interrupt
    print("GStar Rotations: Interrupt now "..(animalsDataPerChar.interrupt and "on" or "off")..".")
end

function animalsTable.createMonitorFrame()
    if not animalsMonitorParentFrame then
        CreateFrame("Frame", "animalsMonitorParentFrame", UIParent)
        animalsMonitorParentFrame:SetFrameStrata("MEDIUM")
        animalsMonitorParentFrame:SetWidth("64")
        animalsMonitorParentFrame:SetHeight("64")

        if animalsDataPerChar.monitorX and animalsDataPerChar.monitorY then
            animalsMonitorParentFrame:ClearAllPoints()
            animalsMonitorParentFrame:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", animalsDataPerChar.monitorX, animalsDataPerChar.monitorY)
        else
            animalsMonitorParentFrame:ClearAllPoints()
            animalsMonitorParentFrame:SetPoint("CENTER")
        end

        animalsMonitorParentFrame:CreateTexture("animalsMonitorTexture")
        animalsMonitorTexture:SetTexture("Interface\\Addons\\Animals\\Textures\\animalsMonitor.tga")
        animalsMonitorTexture:SetAllPoints(animalsMonitorParentFrame)

        animalsMonitorParentFrame:CreateTexture("animalsAoEOnTexture")
        animalsMonitorParentFrame:CreateTexture("animalsAoEOffTexture")
        animalsAoEOnTexture:SetTexture("Interface\\Addons\\Animals\\Textures\\eyes.tga")
        animalsAoEOffTexture:SetTexture("Interface\\Addons\\Animals\\Textures\\no.tga")

        animalsAoEOnTexture:SetPoint("RIGHT", -10, 3)
        animalsAoEOnTexture:SetSize(20, 20)
        animalsAoEOffTexture:SetPoint("RIGHT", -10, 3)
        animalsAoEOffTexture:SetSize(20, 20)

        animalsMonitorParentFrame:CreateTexture("animalsCDsOnTexture")
        animalsMonitorParentFrame:CreateTexture("animalsCDsOffTexture")
        animalsCDsOnTexture:SetTexture("Interface\\Addons\\Animals\\Textures\\eyes.tga")
        animalsCDsOffTexture:SetTexture("Interface\\Addons\\Animals\\Textures\\no.tga")

        animalsCDsOnTexture:SetPoint("BOTTOMRIGHT", -10, 4)
        animalsCDsOnTexture:SetSize(20, 20)
        animalsCDsOffTexture:SetPoint("BOTTOMRIGHT", -10, 4)
        animalsCDsOffTexture:SetSize(20, 20)

        animalsMonitorParentFrame:SetMovable(1)
        animalsMonitorParentFrame:EnableMouse(true)
        animalsMonitorParentFrame:RegisterForDrag("LeftButton")
    end
    animalsMonitorParentFrame:SetScript("OnMouseDown", function() if animalsAoEOffTexture:IsMouseOver() then animalsTable.toggleAoE() elseif animalsCDsOffTexture:IsMouseOver() then animalsTable.toggleCDs() end end)
    animalsMonitorParentFrame:SetScript("OnDragStart", animalsMonitorParentFrame.StartMoving)
    animalsMonitorParentFrame:SetScript("OnDragStop", function(self) animalsDataPerChar.monitorX, animalsDataPerChar.monitorY = self:GetRect(); animalsMonitorParentFrame:StopMovingOrSizing() end)
    animalsAoEOnTexture:Hide()
    animalsCDsOnTexture:Hide()
    animalsTable.monitorAnimationToggle("off")
end

function animalsTable.monitorAnimation(self, elapsed)
    if animalsTable.aoe then
        if not animalsAoEOnTexture:IsVisible() or animalsAoEOffTexture:IsVisible() then
            animalsAoEOnTexture:Show()
            animalsAoEOffTexture:Hide()
        end
        AnimateTexCoords(animalsAoEOnTexture, 512, 256, 64, 64, 29, elapsed, 0.029)
    elseif animalsAoEOnTexture:IsVisible() or not animalsAoEOffTexture:IsVisible() then
        animalsAoEOffTexture:Show()
        animalsAoEOnTexture:Hide()
    end
    if animalsTable.cds then
        if not animalsCDsOnTexture:IsVisible() or animalsCDsOffTexture:IsVisible() then
            animalsCDsOnTexture:Show()
            animalsCDsOffTexture:Hide()
        end
        AnimateTexCoords(animalsCDsOnTexture, 512, 256, 64, 64, 29, elapsed, 0.029)
    elseif animalsCDsOnTexture:IsVisible() or not animalsCDsOffTexture:IsVisible() then
        animalsCDsOnTexture:Hide()
        animalsCDsOffTexture:Show()
    end
end

function animalsTable.monitorAnimationToggle(argument)
    if argument == "off" then
        animalsMonitorParentFrame:SetScript("OnUpdate", nil)
        animalsMonitorParentFrame:Hide()
    end
    if argument == "on" then
        animalsMonitorParentFrame:SetScript("OnUpdate", animalsTable.monitorAnimation)
        animalsMonitorParentFrame:Show()
    end
end