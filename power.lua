addon, ns = ...
local util = ns.util
local cfg = ns.cfg
local pinfo = {
  class = string.upper(select(2, UnitClass('player'))),
  level = UnitLevel("player")
}
if util.tmisses(cfg.classes, pinfo.class) then return end -- bail if we aren't counting anything
if not rpowerCfg then rpowerCfg = { } end
local red, green, blue, maxblip

local updatePinfo = function()
  pinfo.level = UnitLevel("player")
  pinfo.spec = tostring(GetPrimaryTalentTree() or 0)
end

local updatePowerDisplay = function(u,p,i,e)
  local c = 0

  if i.class == "DRUID" then
    if u ~= "player" then return end
    c = GetComboPoints("player", "target")

  elseif i.class == "ROGUE" then
    if u ~= "target" and u ~= "player" then return end
    c = GetComboPoints("player", "target")
    local stacks = util.numdebuffs(72330, "target")
    util.updateSecondary(stacks, 5,0,0.7,0)

  elseif i.class == "WARLOCK" then
    if u ~= "player" and (p ~= "SOUL_SHARDS" or p ~= "OVERRIDE") then return end
    c = util.numpower(SPELL_POWER_SOUL_SHARDS)
  
  elseif i.class == "PRIEST" then
    if u ~= "player" then return end
    c = util.numbuffs(77487, "player")
  
  elseif i.class == "PALADIN" then
    if u ~= "player" and (p ~= "HOLY_POWER" or p ~= "OVERRIDE") then return end
    c = util.numpower(SPELL_POWER_HOLY_POWER)
  
  elseif i.class == "MAGE" then
    if u ~= "player" then return end
    c = util.numdebuffs(36032, "player")
  
  elseif i.class == "SHAMAN" then
    if i.spec == "1" then -- elemental
      if u ~= "player" then return end
      c = util.numbuffs(324, "player")
      if c <= 3 then c = 0 else c = c - 3 end
    elseif i.spec == "2" then -- enhancement
      c = util.numbuffs(53817, "player")
      p = util.numdebuffs(77661, "target")
      util.updateSecondary(p,5,1,0,0)
    end
  end
  util.updateVisuals(c, maxblip, red, green, blue)  
end

local classAddDel = function(i)
  if cfg.classes[i.class][i.spec] == false then
    util.hideFrames(maxblip)
    return
  else
    util.showFrames(maxblip)
  end
  local s = rpowerCfg["tree"..i.spec] and rpowerCfg["tree"..i.spec].scale or 1
  local r = rpowerCfg["tree"..i.spec] and rpowerCfg["tree"..i.spec].ratio or 1
  maxblip = cfg.classes[i.class][i.spec].blips

  if i.class == "SHAMAN" then
    if i.spec == "1" then
      if not _G['powerframe6'] then
        _G['powerframe6'] = util.genFrame(red, green, blue, cfg.blipsize, cfg.blipsize)
        _G['powerframe6'].Secondary:Hide()
        _G['powerframe6']:SetPoint("TOPLEFT", _G['powerframe5'], "TOPRIGHT", 1, 0)
        local s = rpowerCfg["tree"..i.spec] and rpowerCfg["tree"..i.spec].scale or 1
        local r = rpowerCfg["tree"..i.spec] and rpowerCfg["tree"..i.ratio].scale or 1
        _G['powerframe6']:SetScale(s)
        _G['powerframe6']:SetWidth(cfg.blipsize * r)        
      else
        _G['powerframe6']:Show()
      end
    elseif i.spec == "2" then
      if _G['powerframe6'] then
        _G['powerframe6']:Hide()
      end
    end

  elseif i.class == "DRUID" then
    if GetShapeshiftForm() ~= util.kittyStance() and GetComboPoints("player") == 0 then
      util.hideFrames(5)
    else util.showFrames(5) end

  elseif i.class == "PRIEST" then
    if i.spec ~= "3" then util.hideFrames(3)
    else util.showFrames(3) end
  end

  for idx = 1, maxblip do
    gb = _G['powerframe'..idx]
    gb:SetScale(s)
    gb:SetWidth(gb:GetHeight()*r)
  end
  util.positionFrames(_G['powerframe1'], i)
end

local classInit = function()
  updatePinfo()
  if cfg.classes[pinfo.class][pinfo.spec] == false then return false end
  red, green, blue, maxblip = util.specInfo(pinfo.class, pinfo.spec)
  util.makeFrames(maxblip, red, green, blue, pinfo)
  util.showFrames(maxblip)
  updatePowerDisplay("player", "OVERRIDE", pinfo)
  util.hideSecondary(maxblip)
  return true
end

local classEvents = function(class, spec)
  pwrF:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
  if rpowerCfg and rpowerCfg.oochide then
    pwrF:RegisterEvent("PLAYER_REGEN_ENABLED")
    pwrF:RegisterEvent("PLAYER_REGEN_DISABLED")
  end
  if class == "DRUID" then
    pwrF:RegisterEvent("UNIT_POWER")
    pwrF:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    pwrF:RegisterEvent("PLAYER_TARGET_CHANGED")
  elseif class == "ROGUE" then
    pwrF:RegisterEvent("UNIT_POWER")
    pwrF:RegisterEvent("UNIT_AURA")
    pwrF:RegisterEvent("PLAYER_TARGET_CHANGED")
  elseif class == "WARLOCK" then
    pwrF:RegisterEvent("UNIT_POWER")
  elseif class == "PRIEST" then
    pwrF:RegisterEvent("UNIT_AURA")
  elseif class == "PALADIN" then
    pwrF:RegisterEvent("UNIT_POWER")
  elseif class == "MAGE" then
    pwrF:RegisterEvent("UNIT_AURA")
  elseif class == "SHAMAN" then
    pwrF:RegisterEvent("UNIT_AURA")
    pwrF:RegisterEvent("PLAYER_TARGET_CHANGED")
  end

  pwrF:SetScript("OnEvent", function(self, event, u, p)
    if event == "ACTIVE_TALENT_GROUP_CHANGED" then updatePinfo(); classAddDel(pinfo);
    elseif event == "PLAYER_REGEN_ENABLED" then util.hideFrames(maxblip)
    elseif event == "PLAYER_REGEN_DISABLED" then util.showFrames(maxblip)
    elseif event == "UNIT_POWER" then updatePowerDisplay(u, p, pinfo, event)
    elseif event == "PLAYER_TARGET_CHANGED" then updatePowerDisplay(u, nil, pinfo, event)
    elseif event == "UNIT_AURA" then updatePowerDisplay(u, nil, pinfo, event)
    elseif event == "UPDATE_SHAPESHIFT_FORM" then classAddDel(pinfo)
    end
  end)

end

pwrF = CreateFrame("Frame", "RistrettoPowerFrame")
pwrF:RegisterEvent("PLAYER_ALIVE")
pwrF:RegisterEvent("VARIABLES_LOADED")
pwrF:SetScript("OnEvent", function(self, event)
  if event == "PLAYER_ALIVE" or event == "VARIABLES_LOADED" then
    if classInit() then 
      classEvents(pinfo.class, pinfo.spec) 
    else 
      pwrF:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
      pwrF:SetScript("OnEvent", function(self, event)
        if classInit() then
          classEvents(pinfo.class, pinfo.spec)
        end
      end)
    end
  end
end)

ShowColorPicker = function(r, g, b, cback)
 ColorPickerFrame:SetColorRGB(r,g,b);
 ColorPickerFrame.previousValues = {r,g,b};
 ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = cback, cback, cback;
 ColorPickerFrame:Hide();
 ColorPickerFrame:Show();
end

colorCallback = function(bail)
  local nr, ng, nb
  if bail then
    red, green, blue = unpack(bail)
  else
    red, green, blue = ColorPickerFrame:GetColorRGB();
  end
  util.updateVisuals(maxblip, maxblip, red, green, blue)
  rpowerCfg.mycolors = { red, green, blue }
end

SLASH_RP1 = "/rp"
SlashCmdList["RP"] = function(str)
  local switch, message = str:match("^(%S*)%s*(.-)$");
  local cmd = string.lower(switch)
  local msg = string.lower(message)

  if cmd == "oochide" then
    rpowerCfg.oochide = not rpowerCfg.oochide
    if rpowerCfg.oochide then
      pwrF:RegisterEvent("PLAYER_REGEN_DISABLED")
      pwrF:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
      pwrF:UnregisterEvent("PLAYER_REGEN_DISABLED")
      pwrF:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end      
    local x = rpowerCfg.oochide and cfg.ON or cfg.OFF
    util.print("Hiding out of combat is now "..x)
  elseif cmd == "scale" then
    local t = pinfo.spec
    local s = tonumber(msg)
    if s < 0.1 or s > 10 then s = 1 end
    if not rpowerCfg["tree"..t] then rpowerCfg["tree"..t] = { } end
    rpowerCfg["tree"..t].scale = s
    for i = 1, maxblip do
      _G['powerframe'..i]:SetScale(s)
    end
    util.print("Scaled frames to "..s.." times of normal")
  elseif cmd == "ratio" then
    local t = pinfo.spec
    local s = tonumber(msg)
    if s < 0.1 or s > 10 then s = 1 end
    if not rpowerCfg["tree"..t] then rpowerCfg["tree"..t] = { } end
    rpowerCfg["tree"..t].ratio = s
    for i = 1, maxblip do
      local gb = _G['powerframe'..i]
      gb:SetWidth(gb:GetHeight()*s)
    end
    util.print("Ratio now "..s..":1 width:height")
  elseif cmd == "info" then
    StaticPopupDialogs["RP_ABOUT"] = {
      text = format([[|cff006699ristretto|r Power
      by Hoern <Alasin>, Nesingwary US Alliance
      Stats: Scale: |cff006699%s|r, Ratio: |cff006699%s|r, Spec: |cff006699%s|r
      |cffff0000[esc] to close|r]], 
      rpowerCfg["tree"..pinfo.spec] and rpowerCfg["tree"..pinfo.spec].scale or 1,
      rpowerCfg["tree"..pinfo.spec] and rpowerCfg["tree"..pinfo.spec].ratio or 1,
      pinfo.spec),
      timeout = 0,
      whileDead = true,
      hideOnEscape = true,
    }
    StaticPopup_Show ("RP_ABOUT")
  elseif cmd == "color" or cmd == "colors" then
    if msg == "reset" then
      red, green, blue = unpack(cfg.classes[pinfo.class]["colors"])
      ShowColorPicker(red, green, blue, colorCallback)
    else
      ShowColorPicker(red, green, blue, colorCallback)
    end
  else
    util.print("/rp info - info")
    util.print("/rp stats - print some states")
    util.print("/rp scale n - make blips n size of original (0.x works)")
    util.print("/rp ratio n - midfy width:height ratio to n:1 (0.x works)")
    util.print("/rp color - change the blip color")
    util.print("/rp color reset - reset blip color to default")    
  end
end