addon, ns = ...
local cfg = CreateFrame("Frame")

cfg.blipsize = 19
cfg.ON = "|cff00ff00on|r"
cfg.OFF = "|cffff0000off|r"

cfg.backdrop = {
    bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
    edgeFile = [[Interface/Tooltips/UI-Tooltip-Border]],
    tile = true, tileSize = 4, edgeSize = 4,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
}

cfg.classes = {
  ["SHAMAN"]  = {
    ["colors"] = { 0, 0, 1 },
    ["0"] = false,
    ["1"] = {
      ["blips"] = 6,
      ["seconds"] = false,
    },
    ["2"] = {
      ["blips"] = 5,
      ["seconds"] = false,
    },
    ["3"] = false,
  },
  ["PALADIN"]  = {
    ["colors"] = { 0, 0, 1 },
    ["0"] = {
      ["blips"] = 3,
      ["seconds"] = false,
    },
    ["1"] = {
      ["blips"] = 3,
      ["seconds"] = false,
    },
    ["2"] = {
      ["seconds"] = false,
      ["blips"] = 3,
    },
    ["3"] = {
      ["seconds"] = false,
      ["blips"] = 3,
    },
  },  
  ["ROGUE"]  = {
    ["colors"] = { 1, 1, 0 },
    ["0"] = {
      ["seconds"] = false,
      ["blips"] = 5,
    },
    ["1"] = {
      ["seconds"] = true,
      ["blips"] = 5,
    },
    ["2"] = {
      ["seconds"] = true,
      ["blips"] = 5,
    },
    ["3"] = {
      ["seconds"] = true,
      ["blips"] = 5,
    },
  },
  ["DRUID"]  = {
    ["colors"] = { 1, 1, 0 },
    ["0"] = false,
    ["1"] = {
      ["seconds"] = false,
      ["blips"] = 5,
    },
    ["2"] = {
      ["seconds"] = false,
      ["blips"] = 5,
    },
    ["3"] = {
      ["seconds"] = false,
      ["blips"] = 5,
    },
  },
  ["MAGE"]  = {
    ["colors"] = { 0, 0, 1 },
    ["0"] = false,
    ["1"] = {
      ["seconds"] = false,
      ["blips"] = 4,
    },
    ["2"] = {
      ["seconds"] = false,
      ["blips"] = 4,
    },
    ["3"] = {
      ["seconds"] = false,
      ["blips"] = 4,
    },
  },
  ["WARLOCK"]  = {
    ["colors"] = { 46/255, 8/255, 84/255 },
    ["0"] = {
      ["seconds"] = false,
      ["blips"] = 3,
    },
    ["1"] = {
      ["seconds"] = false,
      ["blips"] = 3,
    },
    ["2"] = {
      ["seconds"] = false,
      ["blips"] = 3,
    },
    ["3"] = {
      ["seconds"] = false,
      ["blips"] = 3,
    },
  },
  ["PRIEST"]  = {
    ["colors"] = { 0, 0, 1 },
    ["0"] = false,
    ["1"] = false,
    ["2"] = false,
    ["3"] = {
      ["seconds"] = true,
      ["blips"] = 3,
    },
  },  
}

ns.cfg = cfg