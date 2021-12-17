--[[ Burning Timer ]]--

-- Known Issues:
-- Timers will become incorrect if the server is lagging (No way to correct that bug since the lag is only server sided, not client sided)
-- Tree Stumps show incorrect burning timers (Displays as 45s but is actually 10s)
-- Timers will be incorrect if the object is already burning before being loaded (In this case, objects will be marked via brackets)

-- For testing:
-- AoE-Burning Spell:
--	pos = ThePlayer:GetPosition() for k,v in pairs(TheSim:FindEntities(pos.x,0,pos.z,64)) do if v.components and v.components.burnable then v.components.burnable:Ignite() end end

local _G = GLOBAL
local TUNING = _G.TUNING

_G.mod_burningTimer = {}
_G.mod_burningTimer.enabled = GetModConfigData("enabledByDefault")
_G.mod_burningTimer.burntimeList = { -- To avoid crashes, certain burntimers have to be hardcoded
	blueprint = TUNING.SMALL_BURNTIME,
}
_G.mod_burningTimer.burntimeRNG = {
--	blueprint = nil,
}
_G.mod_burningTimer.campfireMaxFuel = {}
_G.mod_burningTimer.campfireFuelRate = {}
_G.mod_burningTimer.campfireRainRate = {}
_G.mod_burningTimer.campfireFireLevels = {}

_G.mod_burningTimer.lanternLightTime = {}
_G.mod_burningTimer.lanternIntensityMin = {}
_G.mod_burningTimer.lanternIntensityDiff = {}

_G.mod_burningTimer.campfireReveal = GetModConfigData("showCampfireTimer") == "hidden" and 0.0 or nil
_G.mod_burningTimer.lanternReveal = GetModConfigData("showLanternTimer") == "hidden" and 0.0 or nil
_G.mod_burningTimer.starReveal = GetModConfigData("showStarTimer") == "hidden" and 0.0 or nil
_G.mod_burningTimer.revealDuration = GetModConfigData("showHiddenDuration")

_G.mod_burningTimer.burntimeTextSize = 30
_G.mod_burningTimer.campfireTextSize = 30
_G.mod_burningTimer.lanternTextSize = 30
_G.mod_burningTimer.starTextSize = 30

_G.mod_burningTimer.fetchingTimer = false
_G.mod_burningTimer.debug = false

_G.mod_burningTimer.validFueltypes = {}
for k, v in pairs(_G.FUELTYPE) do
	if v ~= _G.FUELTYPE.USAGE then -- Not a real fuel, according to Klei's code
		table.insert(_G.mod_burningTimer.validFueltypes, v.."_fueled")
	end
end

local burntimeList         = _G.mod_burningTimer.burntimeList
local burntimeRNG          = _G.mod_burningTimer.burntimeRNG
local campfireMaxFuel      = _G.mod_burningTimer.campfireMaxFuel
local campfireFuelRate     = _G.mod_burningTimer.campfireFuelRate
local campfireRainRate     = _G.mod_burningTimer.campfireRainRate
local campfireFireLevels   = _G.mod_burningTimer.campfireFireLevels
local lanternLightTime     = _G.mod_burningTimer.lanternLightTime
local lanternIntensityMin  = _G.mod_burningTimer.lanternIntensityMin
local lanternIntensityDiff = _G.mod_burningTimer.lanternIntensityDiff

-- Credit for testing this in their own mod goes to Ryuu
AddGlobalClassPostConstruct("entityscript","EntityScript", function(self)
	local oldRegisterComponentActions = self.RegisterComponentActions
	local oldUnregisterComponentActions = self.UnregisterComponentActions

	self.RegisterComponentActions = function(self, name)
		if not _G.mod_burningTimer.fetchingTimer then
			return oldRegisterComponentActions(self, name)
		end
	end
	self.UnregisterComponentActions = function(self, name)
		if not _G.mod_burningTimer.fetchingTimer then
			return oldUnregisterComponentActions(self, name)
		end
	end
end) 

-- The way how to fetch burning timers is based on the 'Item Info' mod made by 'Ryuu', thanks to Ryuu
local function fetchBurntime(prefab)
	if burntimeList[prefab] then return false end

	local inst
	local IsMasterSim = _G.TheWorld.ismastersim
	_G.TheWorld.ismastersim = true -- Your ingame data has just been corrupted
	_G.mod_burningTimer.fetchingTimer = true -- Fetching Burning Timers has been enabled
	local math_random_orig = math.random -- Your RNG is going to be corrupted

	math.random = function(a,b) return a and b and a or a and 1 or 0.0 end -- Set random to lowest value possible
	inst = _G.SpawnPrefab(prefab)
	if inst and inst.components.burnable and inst.components.burnable.burntime then
		burntimeList[prefab] = inst.components.burnable.burntime
	else
		burntimeList[prefab] = false
	end
	inst:Remove()

	if burntimeList[prefab] then -- boats do technically burn forever
		math.random = function(a,b) return a and b and b or a and a or 1.0 end -- Set random to highest value possible
		inst = _G.SpawnPrefab(prefab)
		if inst and inst.components.burnable and inst.components.burnable.burntime then
			burntimeRNG[prefab] = inst.components.burnable.burntime - burntimeList[prefab]
		end
		if burntimeRNG[prefab] == 0.0 then
			burntimeRNG[prefab] = nil
		end
		inst:Remove()
	end

	math.random = math_random_orig -- Your RNG is fine again
	_G.mod_burningTimer.fetchingTimer = false -- Fetching Burning Timers has been disabled
	_G.TheWorld.ismastersim = IsMasterSim -- Your ingame data is fine again

	if _G.mod_burningTimer.debug then
		print("Fetched Burning Stats from",prefab,"- Burntime:",burntimeList[prefab],"Burntime RNG:",burntimeRNG[prefab])
	end
	return true
end

local function fetchCampfireStats(prefab)
	if campfireMaxFuel[prefab] then return false end

	local inst
	local IsMasterSim = _G.TheWorld.ismastersim
	_G.TheWorld.ismastersim = true -- Your ingame data has just been corrupted
	_G.mod_burningTimer.fetchingTimer = true -- Fetching Burning Timers has been enabled

	local IsRaining = _G.TheWorld.state.israining -- Your rain is going to be corrupted
	local PrecipitationRate = _G.TheWorld.state.precipitationrate

	_G.TheWorld.state.israining = false -- Rain suddenly stopped.
	inst = _G.SpawnPrefab(prefab)
	if inst and inst.components.fueled and inst.components.fueled.rate then
		campfireMaxFuel[prefab]    = inst.components.fueled.maxfuel
		campfireFuelRate[prefab]   = inst.components.fueled.rate
		campfireFireLevels[prefab] = 
			inst.components.burnable
			and inst.components.burnable.fxchildren[1]
			and inst.components.burnable.fxchildren[1].components
			and inst.components.burnable.fxchildren[1].components.firefx
			and inst.components.burnable.fxchildren[1].components.firefx.levels
			or {}
	else
		campfireMaxFuel[prefab] = false
	end
	inst:Remove()

	if campfireMaxFuel[prefab] then
		local toSave
		_G.TheWorld.state.israining = true -- Let there be rain!
		_G.TheWorld.state.precipitationrate = 0.0 -- But then again, there's no rain rn
		inst = _G.SpawnPrefab(prefab)
		toSave = inst.components.fueled.rate
		inst:Remove()
		_G.TheWorld.state.precipitationrate = 1.0 -- Suddenly rain appeared
		inst = _G.SpawnPrefab(prefab)
		campfireRainRate[prefab] = inst.components.fueled.rate - toSave
		inst:Remove()
	end

	_G.TheWorld.state.israining = IsRaining -- Your rain is fine again
	_G.TheWorld.state.precipitationrate = PrecipitationRate -- Your precipitation rate is fine again
	_G.mod_burningTimer.fetchingTimer = false -- Fetching Burning Timers has been disabled
	_G.TheWorld.ismastersim = IsMasterSim -- Your ingame data is fine again

	if _G.mod_burningTimer.debug then
		print("Fetched Campfire Stats from",prefab,"- Max Fuel:",campfireMaxFuel[prefab],"Fuel Rate:",campfireFuelRate[prefab],"Rain Rate:",campfireRainRate[prefab],"Fire Levels:",campfireFireLevels[prefab])
	end
	return true
end

-- I know there's only one lantern ingame which has constant stats
-- ... but there might also be other lanterns nearby, or new lanterns, or lanterns with different stats
-- That's why we anyway fetch the lantern stats
local function fetchLanternStats(prefab)
	if lanternLightTime[prefab] then return false end

	local inst
	local IsMasterSim = _G.TheWorld.ismastersim
	_G.TheWorld.ismastersim = true -- Your ingame data has just been corrupted
	_G.mod_burningTimer.fetchingTimer = true -- Fetching Burning Timers has been enabled

	inst = _G.SpawnPrefab(prefab)
	if inst and inst.components.fueled and (inst.components.fueled.updatefn or inst.components.fueled.ontakefuelfn) then
		local updatefn = inst.components.fueled.updatefn or inst.components.fueled.ontakefuelfn
		lanternLightTime[prefab] = inst.components.fueled.maxfuel
		if inst.components.machine and inst.components.machine.turnonfn then
			inst.components.machine.turnonfn(inst)
		elseif inst.components.equippable and inst.components.equippable.onequipfn then
			inst.components.equippable.onequipfn(inst, _G.ThePlayer, true)
		end
		local _light = inst._light
		if _light then
			inst.components.fueled.currentfuel = inst.components.fueled.maxfuel
			updatefn(inst)
			local maxLight = _light.Light:GetRadius()
			inst.components.fueled.currentfuel = 0.0
			updatefn(inst)
			lanternIntensityMin[prefab] = _light.Light:GetRadius()
			lanternIntensityDiff[prefab] = maxLight - lanternIntensityMin[prefab]
			if lanternIntensityDiff[prefab] == 0.0 then
				lanternLightTime[prefab] = false
			end
		else
			lanternLightTime[prefab] = false
		end
	else
		lanternLightTime[prefab] = false
	end
	inst:Remove()

	_G.mod_burningTimer.fetchingTimer = false -- Fetching Burning Timers has been disabled
	_G.TheWorld.ismastersim = IsMasterSim -- Your ingame data is fine again

	if _G.mod_burningTimer.debug then
		print("Fetched Lantern Stats from",prefab,"- Light Time:",lanternLightTime[prefab],"Intensity Min:",lanternIntensityMin[prefab],"Intensity Diff:",lanternIntensityDiff[prefab])
	end
	return true
end

local function getBurntime(prefab)
	if not prefab then return 0.0, nil end
	if burntimeList[prefab] == nil then fetchBurntime(prefab) end
	if not burntimeList[prefab] then return 0.0, nil end
	return burntimeList[prefab], burntimeRNG[prefab]
end

local function getCampfireStats(prefab)
	if not prefab then return false, 0.0, 0.0, {} end
	if campfireMaxFuel[prefab] == nil then fetchCampfireStats(prefab) end
	if not campfireMaxFuel[prefab] then return false, 0.0, 0.0, {} end
	return campfireMaxFuel[prefab], campfireFuelRate[prefab], campfireRainRate[prefab], campfireFireLevels[prefab]
end

local function getLanternStats(prefab)
	if not prefab then return false, 0.0, 0.0 end
	if lanternLightTime[prefab] == nil then fetchLanternStats(prefab) end
	if not lanternLightTime[prefab] then return false, 0.0, 0.0 end
	return lanternLightTime[prefab], lanternIntensityMin[prefab], lanternIntensityDiff[prefab]
end

_G.mod_burningTimer.getBurntime = getBurntime
_G.mod_burningTimer.getCampfireStats = getCampfireStats
_G.mod_burningTimer.getLanternStats = getLanternStats

local function InGame() return _G.ThePlayer and _G.ThePlayer.HUD and not _G.ThePlayer.HUD:HasInputFocus() end
if GetModConfigData("hideButton") and GetModConfigData("hideButton") > 0 then
	_G.TheInput:AddKeyDownHandler(GetModConfigData("hideButton"),function()
		if InGame() and _G.TheWorld and _G.mod_burningTimer then
			_G.mod_burningTimer.enabled = not _G.mod_burningTimer.enabled
			if _G.ThePlayer and _G.ThePlayer.components and _G.ThePlayer.components.talker then
				_G.ThePlayer.components.talker:Say("Burning Timer: "..(_G.mod_burningTimer.enabled and "Enabled" or "Disabled"))
			end
		end
	end)
end

-- Burning Timer --
if GetModConfigData("showBurningTimer") then
	AddPrefabPostInit("fire", function(inst)
		inst:DoTaskInTime(0.01, function()
			inst:AddComponent("burningtimer")
		end)
		return
	end)
end

-- Campfire Timer --
local function campfireTimer(inst)
	inst:DoTaskInTime(0.1, function()
		inst:AddComponent("campfiretimer")
	end)
	return
end
if GetModConfigData("showCampfireTimer") then
	AddPrefabPostInit("campfirefire",     function(inst) return campfireTimer(inst) end)
	AddPrefabPostInit("coldfirefire",     function(inst) return campfireTimer(inst) end)
	AddPrefabPostInit("nightlight_flame", function(inst) return campfireTimer(inst) end)
	--AddPrefabPostInit("pigtorch_flame", function(inst) return campfireTimer(inst) end) -- It works for pig torches but their light range does not depend on their available fuel so this mod will show obviously invalid numbers
	AddPrefabPostInit("obsidianfirefire", function(inst) return campfireTimer(inst) end) -- From Tropical Experience mod
end

-- Lantern Timer --
local function lanternTimer(inst)
	inst:DoTaskInTime(0.01, function()
		inst:AddComponent("lanterntimer")
	end)
	return
end
if GetModConfigData("showLanternTimer") then
	AddPrefabPostInit("lanternlight",     function(inst) return lanternTimer(inst) end)
end

-- Star Timer --
local function starTimer(inst)
	inst:DoTaskInTime(0.01, function()
		inst:AddComponent("startimer")
	end)
	return
end
if GetModConfigData("showStarTimer") then
	AddPrefabPostInit("stafflight",       function(inst) return starTimer(inst) end)
	AddPrefabPostInit("staffcoldlight",   function(inst) return starTimer(inst) end)
end

if GetModConfigData("showCampfireTimer") == "hidden" or GetModConfigData("showLanternTimer") == "hidden" or GetModConfigData("showStarTimer") == "hidden" then
	AddPlayerPostInit(function(inst)
		inst:DoTaskInTime(1, function()
			if inst ~= _G.ThePlayer then return end
			inst:AddComponent("bt_revealer")
		end)
	end)
end