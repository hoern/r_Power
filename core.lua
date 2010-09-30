local pinfo = {
  class = string.upper(select(2, UnitClass('player'))),
}

local reg_bd = {
		bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
    edgeFile = [[Interface/Tooltips/UI-Tooltip-Border]],
    tile = true, tileSize = 4, edgeSize = 4,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
}

local bold_bd = {
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
		enabled = true
	}
end

rCPFrame = CreateFrame("Frame", "rCPFrame")
rCPFrame:RegisterEvent("VARIABLES_LOADED")

rCPFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "VARIABLES_LOADED" then
		self:UnregisterEvent("VARIABLES_LOADED")
		self:Init()
	end
end)

function rCPFrame:Init()
	if pinfo.class == "DRUID" or pinfo.class == "ROGUE" then
		local max_blip = 5
		local red = 1
		local green = 1
		local blue = 0

		makeFrames(max_blip, red, green, blue)
		updateVisuals(max_blip, currCP(), red, green, blue)

		rCPFrame:RegisterEvent("UNIT_COMBO_POINTS")
		rCPFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

		if pinfo.class == "DRUID" then -- turn display off when not in kitty
			for i=1, GetNumShapeshiftForms() do
				local _, name, _, _ = GetShapeshiftFormInfo(i)
				if name == "Cat Form" then stanceID = i end
			end
			druidShowHide(stanceID)
			rCPFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
		end

		if pinfo.class == "ROGUE" then
			if rPwrConf.dpstack == true then -- envenom counter
				rCPFrame:RegisterEvent("UNIT_AURA")
			end
		end

		rCPFrame:SetScript("OnEvent", function(self, event, unit)

			if pinfo.class == "DRUID" and event == "UPDATE_SHAPESHIFT_FORM" then
				druidShowHide(stanceID)
				return true
			end

			if pinfo.class == "ROGUE" and event == "UNIT_AURA" then
				if rPwrConf.dpstack == true and unit == "target" then
					count = currDP()
					for i = 1, 5 do
						if i <= count then
							_G["powerframe"..i]:SetBackdrop(bold_bd)
							_G["powerframe"..i]:SetBackdropBorderColor(0,1,0,1) -- green
						else
							_G["powerframe"..i]:SetBackdrop(reg_bd)
							_G["powerframe"..i]:SetBackdropBorderColor(0,0,0,1) -- black
						end
					end
				end
			end

			updateVisuals(max_blip, currCP(), red, green, blue)
			druidShowHide(stanceID)

		end)
	end

	if pinfo.class == "PALADIN" then
		local max_blip = 3
		local red = 0.81
		local green = 0.04
		local blue = 0.97
		makeFrames(3, red, green, blue)
		updateVisuals(max_blip, currHolyPower(), red, green, blue)
		rCPFrame:RegisterEvent("UNIT_POWER")
		rCPFrame:SetScript("OnEvent", function(self, event, unit, power)
			if unit ~= "player" or power ~= "HOLY_POWER" then return end
				updateVisuals(max_blip, currHolyPower(), red, green, blue)
		end)
	end

	if pinfo.class == "WARLOCK" then
		local max_blip = 3
		local red = 0.81
		local green = 0.04
		local blue = 0.97
		makeFrames(3, red, green, blue)
		updateVisuals(max_blip, currShards(), red, green, blue)
		rCPFrame:RegisterEvent("UNIT_POWER")
		rCPFrame:SetScript("OnEvent", function(self, event, unit, power)
			if unit ~= "player" or power ~= "SOUL_SHARDS" then return end
			local shards = currShards()
			updateVisuals(max_blip, shards, red, green, blue)
		end)
	end

	if pinfo.class == "SHAMAN" then
		local max_blip = 5
		local red = 0
		local green = 0
		local blue = 1
		makeFrames(5, red, green, blue)
		updateVisuals(max_blip, currMaelstrom(), red, green, blue)
		rCPFrame:RegisterEvent("UNIT_AURA")
		rCPFrame:SetScript("OnEvent", function(self, event, unit, power)
			if unit ~= "player" then return end
			updateVisuals(max_blip, currMaelstrom(), red, green, blue)
		end)
	end
end

function druidShowHide(id)
	if pinfo.class == "DRUID" and GetShapeshiftForm() ~= id and currCP() == 0 then
		for i = 1, 5 do
			_G['powerframe'..i]:Hide()
		end
	else
		for i = 1, 5 do
			_G['powerframe'..i]:Show()
		end
	end
end

function genFrame(red, green, blue, size)
	local f = CreateFrame("Frame")
	f:SetWidth(size)
	f:SetHeight(size)
	f:SetBackdrop(reg_bd)
	f:SetBackdropColor(red,green,blue,0.5)
	f:SetBackdropBorderColor(0,0,0,1)
	f:Show()
	return f
end

function makeFrames(num, red, green, blue)
	for i = 1, num do
		_G['powerframe'..i] = genFrame( red, green, blue, 19 )
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
			_G['powerframe'..i]:SetPoint("TOPLEFT", _G['powerframe'..i-1], "TOPRIGHT", 4, 0)
			_G['powerframe'..i]:SetScale(rPwrConf.scale)
		end
	end
end

function currDP()
	local dp = GetSpellInfo(72330)
	local _, _, _, count, _, _, _, whodunnit = UnitAura("target", dp, nil, "HARMFUL")
	if count == nil then return 0 end
	return count
end

function currMaelstrom()
	local msw = GetSpellInfo(53817)
	local _, _, _, count, _, _, _, whodunnit = UnitAura("player", msw, nil, "HELPFUL")
	if count == nil then return 0 end
	if whodunnit == "player" then
		return count
	end
end

function currShards()
	return UnitPower("player", SPELL_POWER_SOUL_SHARDS)
end

function currHolyPower()
	return UnitPower("player", SPELL_POWER_HOLY_POWER)
end

function currCP()
	return GetComboPoints("player")
end

function updateVisuals(max, curr, red, green, blue)
	for i = 1, max do
		if i <= curr then
			_G['powerframe'..i]:SetBackdropColor(red, green, blue,1)
		else
			_G['powerframe'..i]:SetBackdropColor(red, green, blue,0.1)
		end
	end
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
	end
end