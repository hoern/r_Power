addon, ns = ...

util = CreateFrame("Frame")

util.currDP = function()
	local dp = GetSpellInfo(72330)
	local _, _, _, count, _, _, _, whodunnit = UnitAura("target", dp, nil, "HARMFUL")
	if count == nil then return 0 end
	return count
end

util.currMaelstrom = function ()
	local msw = GetSpellInfo(53817)
	local _, _, _, count, _, _, _, whodunnit = UnitAura("player", msw, nil, "HELPFUL")
	if count == nil then return 0 end
	if whodunnit == "player" then
		return count
	end
end

util.currOrbs = function()
	local orb = GetSpellInfo(77487)
	local _, _, _, count, _, _, _, whodunnit = UnitAura("player", orb, nil, "HELPFUL")
	if count == nil then return 0 end
	return count
end

util.currShards = function()
	return UnitPower("player", SPELL_POWER_SOUL_SHARDS)
end

util.currHolyPower = function()
	return UnitPower("player", SPELL_POWER_HOLY_POWER)
end

util.currCP = function()
	return GetComboPoints("player")
end

util.currLB = function()
	local lb = GetSpellInfo(324)
	local _, _, _, count, _, _, _, whodunnit = UnitAura("player", lb, nil, "HELPFUL")
	if count == nil then return 0 end
	if count < 3 then return 0 end
	return count - 3
end

ns.util = util