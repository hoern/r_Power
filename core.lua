addon, ns = ...
local util = ns.util

local pinfo = {
  class = string.upper(select(2, UnitClass('player'))),
  level = UnitLevel("player")
}

local __, _, _, tocversion = GetBuildInfo()

local defaults = {
	["SHAMAN"]  = {
		colors = { 0, 0, 1 },
		blips = 5,
	},
	["PALADIN"] = {
		colors = { 0.81, 0.04, 0.97 },
		blips = 3,
	},
	["DRUID"] = {
		colors = { 1, 1, 0 },
		blips  = 5,
	},
	["ROGUE"] = {
		colors = { 1, 1, 0 },
		blips = 5,
	},
	["WARLOCK"] = {
		colors = { 0.81, 0.04, 0.97 },
		blips = 3,
	},
	["PRIEST"] = {
		colors = { 0.8, 0.4, 0.8 },
		blips = 3,
	},
}

local backdrop = {
		bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
    edgeFile = [[Interface/Tooltips/UI-Tooltip-Border]],
    tile = true, tileSize = 4, edgeSize = 4,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
}

if rPwrConf == nil then
	rPwrConf = {
		ato = "CENTER",
		x   = 0,
		y   = 0,
		scale = 1,
		enabled = true,
		mycolors = nil,
	}
end

local max_blip, red, green, blue, catStance
local cfg_size = 19

rCPFrame = CreateFrame("Frame", "rCPFrame")
rCPFrame:RegisterEvent("VARIABLES_LOADED")

rCPFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "VARIABLES_LOADED" then
		self:UnregisterEvent("VARIABLES_LOADED")
		self:Init()
	end
end)

function rCPFrame:Init()
	max_blip, red, green, blue = initClass()

	if pinfo.class == "DRUID" or pinfo.class == "ROGUE" then
		makeFrames(max_blip, red, green, blue, false)
		util.updateVisuals(max_blip, util.currCP(), red, green, blue)

		rCPFrame:RegisterEvent("UNIT_COMBO_POINTS")
		rCPFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

		if pinfo.class == "DRUID" then -- turn display off when not in kitty
			druidShowHide()
			rCPFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
		end

		if pinfo.class == "ROGUE" then
			if rPwrConf.dpstack == true then -- envenom counter
				rCPFrame:RegisterEvent("UNIT_AURA")
			end
		end

		rCPFrame:SetScript("OnEvent", function(self, event, unit)

			if pinfo.class == "DRUID" and event == "UPDATE_SHAPESHIFT_FORM" then
				druidShowHide()
			end

			if pinfo.class == "ROGUE" and event == "UNIT_AURA" then
				if rPwrConf.dpstack == true and unit == "target" then
					local count = util.currDP()
					util.updateBorder(5, count, 0, 0, 0, 0, 1, 0)
				end
			end

			util.updateVisuals(max_blip, util.currCP(), red, green, blue)
			
			if pinfo.class == "ROGUE" then
				local count = util.currDP()
				util.updateBorder(5, count, 0, 0, 0, 0, 1, 0)
			end

			if pinfo.class == "DRUID" then
				druidShowHide()
			end
		end)
	end

	if pinfo.class == "PALADIN" then
		max_blip, red, green, blue = initClass()

		makeFrames(max_blip, red, green, blue, false)
		util.updateVisuals(max_blip, util.currHolyPower(), red, green, blue)
		rCPFrame:RegisterEvent("UNIT_POWER")
		rCPFrame:SetScript("OnEvent", function(self, event, unit, power)
			if unit ~= "player" or power ~= "HOLY_POWER" then return end
				util.updateVisuals(max_blip, util.currHolyPower(), red, green, blue)
		end)
	end

	if pinfo.class == "WARLOCK" then
		max_blip, red, green, blue = initClass()

		makeFrames(max_blip, red, green, blue, false)
		util.updateVisuals(max_blip, util.currShards(), red, green, blue)
		rCPFrame:RegisterEvent("UNIT_POWER")
		rCPFrame:RegisterEvent("PLAYER_ALIVE")
		rCPFrame:SetScript("OnEvent", function(self, event, unit, power)
		  if event == "PLAYER_ALIVE" then
		    util.updateVisuals(max_blip, util.currShards(), red, green, blue)
		  end
			if unit ~= "player" or power ~= "SOUL_SHARDS" then return end
			util.updateVisuals(max_blip, util.currShards(), red, green, blue)
		end)
	end

	if pinfo.class == "SHAMAN" then
	  rCPFrame.spec = GetPrimaryTalentTree()
		max_blip, red, green, blue = initClass()

    if rCPFrame.spec == 2 then
      cFunc = util.currMaelstrom
		  rCPFrame:RegisterEvent("UNIT_AURA")
		elseif rCPFrame.spec == 1 then
		  rCPFrame:RegisterEvent("UNIT_AURA")
		  cFunc = util.currLB
		  max_blip = 6
		end

    rCPFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

		makeFrames(6, red, green, blue, true)
		shamanHideShow(rCPFrame.spec)
		util.updateVisuals(max_blip, cFunc(), red, green, blue)
		
		rCPFrame:SetScript("OnEvent", function(self, event, unit)
			if event == "ACTIVE_TALENT_GROUP_CHANGED" then
			  rCPFrame.spec = GetPrimaryTalentTree()
			  if rCPFrame.spec == 2 then
			    rCPFrame:RegisterEvent("UNIT_AURA")
			    cFunc = util.currMaelstrom
			    max_blip = 5
			    shamanHideShow(rCPFrame.spec)
				  util.updateVisuals(max_blip, cFunc(), red, green, blue)
        elseif rCPFrame.spec == 1 then
			    rCPFrame:RegisterEvent("UNIT_AURA")
			    cFunc = util.currLB
			    max_blip = 6
			    shamanHideShow(rCPFrame.spec)
				  util.updateVisuals(max_blip, cFunc(), red, green, blue)			    
			  else
			    rCPFrame:UnregisterEvent("UNIT_AURA")
			    for i = 1, max_blip do
			      _G['powerframe'..i]:Hide()
			    end
			  end
		  else
		    if unit ~= "player" then return end
			  util.updateVisuals(max_blip, cFunc(), red, green, blue)
			end
		end)
	end

	if pinfo.class == "PRIEST" and GetPrimaryTalentTree() == 3 then
		max_blip, red, green, blue = initClass()

		makeFrames(max_blip, red, green, blue, false)
		util.updateVisuals(max_blip, util.currOrbs(), red, green, blue)
		rCPFrame:RegisterEvent("UNIT_AURA")
		rCPFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		rCPFrame:SetScript("OnEvent", function(self, event, unit)
			if event == "UNIT_AURA" then
				if unit ~= "player" then return end
				util.updateVisuals(max_blip, util.currOrbs(), red, green, blue)
			elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
				if GetPrimaryTalentTree() == 3 then
					rCPFrame:RegisterEvent("UNIT_AURA")
					priestShowHide(true)
					util.updateVisuals(max_blip, util.currOrbs(), red, gree, blue)
				else
					rCPFrame:UnregisterEvent("UNIT_AURA")
					priestShowHide(false)
				end
			end
		end)
	end
end

function genFrame(red, green, blue, height, width)
	local f = CreateFrame("Frame")
	f:SetWidth(width)
	f:SetHeight(height)
	f:SetBackdrop(backdrop)
	f:SetBackdropColor(red,green,blue,0.5)
	f:SetBackdropBorderColor(0,0,0,1)
	f:Show()
	return f
end

function makeFrames(num, red, green, blue, stretch)
  local mult = 1
  if stretch then 
    mult = 5 / num
  end
	for i = 1, num do
		_G['powerframe'..i] = genFrame(red, green, blue, cfg_size, cfg_size * mult)
		if i == 1 then
			local gb = _G['powerframe1']
			gb:SetPoint(rPwrConf.ato, UIParent, rPwrConf.ato, rPwrConf.x, rPwrConf.y)
			gb:SetMovable(true)
			gb:EnableMouse(true)
			gb:RegisterForDrag("LeftButton")
			gb:SetScript("OnDragStart", function(self)
				if IsAltKeyDown() and IsShiftKeyDown() then
					self:StartMoving()
				end
			end)
			gb:SetScript("OnDragStop", function(self)
				self:StopMovingOrSizing()
				_,_, rPwrConf.ato, rPwrConf.x, rPwrConf.y = self:GetPoint(1)
			end)
			gb:SetScale(rPwrConf.scale)
		else
			_G['powerframe'..i]:SetPoint("TOPLEFT", _G['powerframe'..i-1], "TOPRIGHT", 1, 0)
			_G['powerframe'..i]:SetScale(rPwrConf.scale)
		end
	end
end

function initClass()
	local red, green, blue
	if rPwrConf.mycolors then
		red, green, blue = unpack(rPwrConf.mycolors)
	else
		red, green, blue = unpack(defaults[pinfo.class]["colors"])
	end
	local blips = defaults[pinfo.class]["blips"]
	return blips, red, green, blue
end

local function kittyStance()
	local sid = 0
	local cat = GetSpellInfo(768)
	for i=1, GetNumShapeshiftForms() do
		local _, name, _, _ = GetShapeshiftFormInfo(i)
		if name == cat then sid = i end
	end
	return sid
end

function druidShowHide()
	if GetShapeshiftForm() ~= kittyStance() and util.currCP() == 0 then
		for i = 1, 5 do
			rCPFrame:UnregisterEvent("UNIT_AURA")
			_G['powerframe'..i]:Hide()
		end
	else
		for i = 1, 5 do
			rCPFrame:RegisterEvent("UNIT_AURA")
			_G['powerframe'..i]:Show()
		end
	end
end

function priestShowHide(show)
	if show then
		for i = 1, 3 do
			_G['powerframe'..i]:Show()
		end
	else
		for i = 1, 3 do
			_G['powerframe'..i]:Hide()
		end
	end
end

function shamanHideShow(spec)
  if spec == 1 then
    for i = 1,6 do
      _G['powerframe'..i]:SetWidth(cfg_size * (5/6))
    end
    _G['powerframe6']:Show()
  else
    for i = 1,5 do
      _G['powerframe'..i]:SetWidth(cfg_size)
    end
    _G['powerframe6']:Hide()
  end
end


function ShowColorPicker(r, g, b, cback)
 ColorPickerFrame:SetColorRGB(r,g,b);
 ColorPickerFrame.previousValues = {r,g,b};
 ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = cback, cback, cback;
 ColorPickerFrame:Hide();
 ColorPickerFrame:Show();
end

function colorCallback(bail)
	local nr, ng, nb
	if bail then
		red, green, blue = unpack(bail)
	else
		red, green, blue = ColorPickerFrame:GetColorRGB();
	end
	util.updateVisuals(max_blip, max_blip, red, green, blue)
	rPwrConf.mycolors = { red, green, blue }
end

SLASH_RP1 = "/rp"
SlashCmdList["RP"] = function(str)
	local switch, message = str:match("^(%S*)%s*(.-)$");
	local cmd = string.lower(switch)
	local msg = string.lower(message)

	if cmd == "scale" then
		msg = tonumber(msg) or 1
		if not(msg <= 5) then msg = 1 end
		for i=1, max_blip do
			rPwrConf.scale = msg
			_G['powerframe'..i]:SetScale(msg)
		end
	elseif cmd == "dpstack" then
		if rPwrConf.dpstack == nil or rPwrConf.dpstack == false then
			rPwrConf.dpstack = true
			rCPFrame:RegisterEvent("UNIT_AURA")
		else
			rPwrConf.dpstack = false
			for i = 1, 5 do
				_G["powerframe"..i]:SetBackdropBorderColor(0,0,0,1) -- black
		end
			rCPFrame:UnregisterEvent("UNIT_AURA")
		end
	elseif cmd == "color" then
		if msg == "set" then
			ShowColorPicker(red, green, blue, colorCallback)
		elseif msg == "reset" then
			red, green, blue = unpack(defaults[pinfo.class]["colors"])
			ShowColorPicker(red, green, blue, colorCallback)
		end
	else
		print("|cFF006699ristretto|r Power")
		print("by Hoern, Nesingwary <hoern@d8c.us>")
		print("Usage:")
		print("/rp scale x||dpstack||color (set||reset)")
		print("dpstack: turn deadly poison stacks on/off")
		print("scale 0-5: grow/shrink blips")
		print("color set: pick a color, any color")
		print("color reset: ugh, that pink is hideous")
	end
end