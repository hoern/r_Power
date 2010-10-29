local addon, ns = ...
local util = CreateFrame("Frame")
local cfg = ns.cfg

util.print = function(msg)
  DEFAULT_CHAT_FRAME:AddMessage("-[|cff006699rp|r]- "..msg)
end

util.tmisses = function(tab, el)
  for k, v in pairs(tab) do
    if k == el then
      return false
    end
  end
  return true
end

util.numbuffs = function(buffid, target)
  local info = GetSpellInfo(buffid)
  local _, _, _, count, _, _, _, whodunnit = UnitAura(target, info, nil, "HELPFUL")
  return count or 0
end

util.numdebuffs = function(debuffid, target, selfonly)
  local info = GetSpellInfo(debuffid)
  local _, _, _, count, _, _, _, whodunnit = UnitAura(target, info, nil, "HARMFUL")
  return count or 0
end

util.numpower = function(powertype)
  return UnitPower("player", powertype)
end

util.specInfo = function(class, spec)
  local red, green, blue
  if rpowerCfg and rpowerCfg.mycolors then
    red, green, blue = unpack(rpowerCfg.mycolors)
  else
    red, green, blue = unpack(cfg.classes[class]["colors"])
  end
  local blips = cfg.classes[class][spec]["blips"]
  return red, green, blue, blips
end

util.updateVisuals = function(num, max, red, green, blue)
  for i = 1, max do
    if i <= num then
      _G['powerframe'..i]:SetBackdropColor(red, green, blue, 1)
    else
      _G['powerframe'..i]:SetBackdropColor(red, green, blue, 0.3)
    end
  end
end

util.genFrame = function(red, green, blue, height, width)
  local f = CreateFrame("Frame")
  local s = CreateFrame("Frame", nil, f)

  f:SetWidth(width * (rpowerCfg.ratio or 1))
  f:SetHeight(height)
  f:SetBackdrop(cfg.backdrop)
  f:SetBackdropColor(red,green,blue,0.5)
  f:SetBackdropBorderColor(0,0,0,1)
  
  s:SetWidth(f:GetWidth()*0.9)
  s:SetHeight(floor(height/3))
  s:SetBackdrop(cfg.backdrop)
  s:SetBackdropColor(0,1,0,1)
  s:SetBackdropBorderColor(0,0,0,0.6)

  s:SetPoint("TOP", f, "TOP", 0, 0)

  f.Secondary = s
  f:Show()
  return f
end

util.positionFrames = function(frame,i)
  frame:ClearAllPoints()
  if rpowerCfg and rpowerCfg["tree"..i.spec] then
    local p = rpowerCfg["tree"..i.spec]
    frame:SetPoint(p.ato or "CENTER", UIParent, p.ato or "CENTER", p.x or 0, p.y or 0)
  else
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  end
end

util.makeFrames = function(num, red, green, blue, pinfo)
  if _G['powerframe1'] then return end
  local t = pinfo.spec or "0"
  local r = rpowerCfg["tree"..t] and rpowerCfg["tree"..t].ratio or 1
  for i = 1, num do
    _G['powerframe'..i] = util.genFrame(red, green, blue, cfg.blipsize, cfg.blipsize * r)
    if i == 1 then
      local gb = _G['powerframe1']
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
        local t = pinfo.spec
        local scale = rpowerCfg["tree"..t] and rpowerCfg["tree"..t].scale or 1
        local ratio = rpowerCfg["tree"..t] and rpowerCfg["tree"..t].ratio or 1        
        rpowerCfg['tree'..t] = { }
        _,_, rpowerCfg['tree'..t].ato, rpowerCfg['tree'..t].x, rpowerCfg['tree'..t].y = self:GetPoint(1)
        rpowerCfg['tree'..t].scale = scale
        rpowerCfg['tree'..t].ratio = ratio
      end)
      util.positionFrames(gb, pinfo)
      if rpowerCfg and rpowerCfg["tree"..pinfo.spec] then
        gb:SetScale(rpowerCfg["tree"..pinfo.spec].scale or 1)
      else
        gb:SetScale(1)
      end
    else
      _G['powerframe'..i]:SetPoint("TOPLEFT", _G['powerframe'..i-1], "TOPRIGHT", 1, 0)
      if rpowerCfg and rpowerCfg["tree"..pinfo.spec] then
         _G['powerframe'..i]:SetScale(rpowerCfg["tree"..pinfo.spec].scale or 1)
      else
         _G['powerframe'..i]:SetScale(1)
      end
    end
  end
end

util.updateSecondary = function(num, max, r, g, b)
  for i = 1, max do
    if i <= num then
      _G['powerframe'..i].Secondary:SetWidth(_G['powerframe'..i]:GetWidth()*0.90)
      _G['powerframe'..i].Secondary:SetBackdropColor(r,g,b,1)
      _G['powerframe'..i].Secondary:Show()
    else
      _G['powerframe'..i].Secondary:Hide()
    end
  end
end

util.hideSecondary = function(max)
  util.updateSecondary(0, max, 0, 0, 0)
end

util.hideFrames = function(num)
  for i = 1,num do
    _G['powerframe'..i]:Hide()
  end
end

util.showFrames = function(num)
  for i = 1,num do
    _G['powerframe'..i]:Show()
  end
end

util.kittyStance = function()
  local sid = 0
  local cat = GetSpellInfo(768)
  for i=1, GetNumShapeshiftForms() do
    local _, name, _, _ = GetShapeshiftFormInfo(i)
    if name == cat then sid = i end
  end
  return sid
end

ns.util = util