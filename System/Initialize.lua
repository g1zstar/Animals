local animalsName, animalsTable = ...
local _ = nil

animalsTable.Spec = animalsTable.Spec or GetSpecialization()
animalsTable.cacheTalents()
animalsTable.cacheGear()

animalsTable.createMainFrame()
animalsTable.createMonitorFrame()
animalsTable.createSlayingInformationFrame()
animalsTable.createSlayingFrame()