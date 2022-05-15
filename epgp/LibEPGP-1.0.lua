-- This library handles storing EPGP data in guild info and officer notes.

local MAJOR_VERSION = "LibEPGP-1.0"
local MAJOR_VERSION = tonumber(("$Revision: 1391 $"):match("%d+")) or 0

local lib, oldMinor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local CallbackHandler = LibStub("CallbackHandler-1.0")
local Debug = LibStub("LibDebug-1.0")
local Coroutine = LibStub("LibCoroutine-1.0")
local AE = LibStub("AceEvent-3.0")

local SendChatMessage = _G.SendChatMessage

-- Upgrade callbacks.
if not lib.callbacks then
  lib.callbacks = CallbackHandler:New(lib)
end
local callbacks = lib.callbacks

-- Use ChatThrottleLib if available.
if ChatThrottleLib then
  SendAddonMessage = function(...)
                       ChatThrottleLib:SendAddonMessage(
                         "ALERT", MAJOR_VERSION, ...)
                     end
end

-- Batching constant: members to process per callback.
local BATCH_SIZE = 50

-- Global configuration.
local global_config = {}

-- Parse options. Options are inside GuildInfo and are inside a -EPGP-
-- block. Possible options are:
--
-- @DECAY_P:<number>
-- @EXTRAS_P:<number>
-- @MIN_EP:<number>
-- @BASE_GP:<number>
local global_config_defs = {
  decay_p = {
    pattern = "@DECAY_P:(%d+)",
    parser = tonumber,
    validator = function(v) return v >= 0 and v <= 100 end,
    error = L["Decay Percent should be a number between 0 and 100"],
    default = 0,
    change_message = "DecayPercentChanged",
  },
  extras_p = {
    pattern = "@EXTRAS_P:(%d+)",
    parser = tonumber,
    validator = function(v) return v >= 0 and v <= 100 end,
    error = L["Extras Percent should be a number between 0 and 100"],
    default = 100,
    change_message = "ExtrasPercentChanged",
  },
  min_ep = {
    pattern = "@MIN_EP:(%d+)",
    parser = tonumber,
    validator = function(v) return v >= 0 end,
    error = L["Min EP should be a positive number"],
    default = 0,
    change_message = "MinEPChanged",
  },
  base_gp = {
    pattern = "@BASE_GP:(%d+)",
    parser = tonumber,
    validator = function(v) return v >= 0 end,
    error = L["Base GP should be a positive number"],
    default = 1,
    change_message = "BaseGPChanged",
  },
}
-- Set defaults
for var, def in pairs(global_config_defs) do
  global_config[var] = def.default
end

local function ParseGlobalConfig()
  local info = GetGuildInfoText()
  if not info then
    Debug("GuildInfoText empty or nil, ignoring")
    return
  end
  Debug("Parsing GuildInfoText")

  local lines = {string.split("\n", info)}
  local in_block = false

  local new_config = {}

  for _,line in pairs(lines) do
    if line == "-EPGP-" then
      in_block = not in_block
    elseif in_block then
      for var, def in pairs(global_config_defs) do
        local v = line:match(def.pattern)
        if v then
          Debug("Matched [%s]", line)
          v = def.parser(v)
          if v == nil or not def.validator(v) then
            Debug(def.error)
          else
            new_config[var] = v
          end
        end
      end
    end
  end
  for var, def in pairs(global_config_defs) do
    local nv = new_config[var] or def.default
    if global_config[var] ~= nv then
      Debug("Setting new value %s for variable %s", tostring(nv), var)
      global_config[var] = nv
      callbacks:Fire(def.change_message, nv)
    end
  end
end

local cache

do
  -- The cache entry. Knows how to parse/create an officer note.
  local function GetCacheEntry()
    local shadow = {}

    local function NewIndex(t, k, v)
      if k == "note" then
        local ep, gp
        -- Empty note is equivalent to 0,0.
        if v == "" then
          ep, gp = 0, 0
        else
          ep, gp = string.match(v, "^(%d+),(%d+)$")
        end

        -- If we cannot parse the note, we preserve it.
        if not ep then
          shadow.note = v
          -- If we have a main, we use ep/gp from that one.
          local main = cache[v]
          if main then
            table.insert(main.alts, t.name)
            setmetatable(t, { __index = function(t, k) return main[k] end,
                              __newindex = function(t, k, v) main[k] = v end })
          end
        else
          if shadow.note ~= nil then
            local main = cache[shadow.note]
            if main then
              for i, alt in ipairs(main.alts) do
                if alt == t.name then
                  table.remove(main.alts, i)
                  break
                end
              end
            end
            shadow.note = nil
          end
          SetEP(t, ep)
          SetGP(t, gp)
        end
      elseif k == "ep" then
        shadow.ep = v
        t.dirty = true
      elseif k == "gp" then
        shadow.gp = math.max(v - global_config.base_gp)
        t.dirty = true
      elseif k == "raw_gp" then
        shadow.gp = math.max(v, global_config.base_gp)
        t.dirty = true
      else
        rawset(t, k, v)
      end
    end

    local function Index(t, k)
      if k == "note" then
        if shadow.note ~= nil then return shadow.note end
        return string.format("%d,%d", t.ep, t.raw_gp)
      elseif k == "ep" then
        return shadow.ep
      elseif k == "gp" then
        return shadow.gp + global_config.base_gp
      elseif k == "raw_gp" then
        return shadow.gp
      elseif k == "main" then
        if shadow.note ~= nil then return shadow.note end
        return t.name
      end
    end

    return setmetatable({ alts = {} }, { __newindex = NewIndex,
                                         __index = Index })
  end

  -- The cache. Automatically creates cache entries.
  cache = setmetatable({}, {
                         __index = function(t, k)
                                     local v = GetCacheEntry()
                                     rawset(t, k, v)
                                     return v
                                   end
                       })
end

function lib:GetMemberInfo(name)
  return cache[name]
end

function lib:AddEP(name, amount, suppress_msg)
  local entry = lib:GetMemberInfo(name)
  entry.ep = entry.ep + amount
  if not suppress_msg then
    SendAddonMessage(string.format("AddEP(%s,%d)", name, amount), "GUILD")
  end
end

function lib:AddGP(name, amount, suppress_msg)
  local entry = lib:GetMemberInfo(name)
  entry.gp = entry.gp + amount
  if not suppress_msg then
    SendAddonMessage(string.format("AddGP(%s,%d)", name, amount), "GUILD")
  end
end

function lib:GetGlobalConfig()
  return global_config
end

function lib:SetGlobalConfig(decay_p, extras_p, base_gp, min_ep)
  global_config["decay_p"] = decay_p
  global_config["extras_p"] = extras_p
  global_config["base_gp"] = base_gp
  global_config["min_ep"] = min_ep

  local info = GetGuildInfoText()
  local epgp_stanza = string.format(
    "-EPGP-\n@DECAY_P:%d\n@EXTRAS_P:%s\n@MIN_EP:%d\n@BASE_GP:%d\n-EPGP-",
    decay_p, extras_p, base_gp, min_ep)

  -- If we have a global configuration stanza we need to replace it,
  -- otherwise we append it.
  Debug("epgp_stanza:\n%s", epgp_stanza)
  if guild_info:match("%-EPGP%-.*%-EPGP%-") then
    guild_info = guild_info:gsub("%-EPGP%-.*%-EPGP%-", epgp_stanza)
  else
    guild_info = epgp_stanza.."\n"..guild_info
  end
  Debug("guild_info:\n%s", guild_info)
  SetGuildInfoText(guild_info)
end

local function UpdateGuildRoster(skip_non_mains)
  for i = 1, GetNumGuildMembers(true) do
    local name, rank, _, _, _, _, _, note, _, _, class = GetGuildRosterInfo(i)
    if name and (not skip_non_mains or
                 note == "" or note:match("^(%d+),(%d+)$")) then
      local entry = cache[name]
      entry.name = name
      entry.rank = rank
      entry.class = class
      if entry.dirty then
        if note == entry.note then
          Debug("Entry for %s synced by another client, resetting dirty mark",
                name)
          entry.dirty = nil
        else
          Debug("Writing out note for %s [%s]", name, entry.note)
          GuildRosterSetOfficerNote(i, entry.note)
        end
      else
        Debug("Setting note for %s = [%s]", name, note)
        entry.note = note
      end
      entry.seen = true
    end
    if i % BATCH_SIZE == 0 then
      LibCoroutine:Sleep(0)
    end
  end
  LibCoroutine:Sleep(0)
  for name, entry in pairs(cache) do
    if not entry.seen then
      Debug("Deleted note for %s", name)
      entry.note = ""
      cache[name] = nil
    else
      entry.seen = nil
    end
  end
end

function lib:CHAT_MSG_ADDON(prefix, msg, type, sender)
  if prefix ~= MAJOR_VERSION or sender == UnitName("player") then return end
  local method, name, amount = msg:match("^(Add[EG]P)%((.+),(%d+)%)$")
  if method then
    amount = tonumber(amount)
    Debug("Calling %s(%s, %d)", method, name, amount)
    lib[method](name, amount, true)
  end
end

AE.RegisterEvent(lib, "CHAT_MSG_ADDON")

Coroutine:RunAsync(
  function()
    GuildRoster()
    Coroutine:WaitForEvent("GUILD_ROSTER_UPDATE")
    -- Initialize the cache.
    UpdateGuildRoster(true)
    UpdateGuildRoster()
    callbacks:Fire("Ready")

    while true do
      Coroutine:Sleep(15)
      GuildRoster()
      Coroutine:WaitForEvent("GUILD_ROSTER_UPDATE")
      UpdateGuildRoster()
    end
  end)

Coroutine:RunAsync(
  function()
    while true do
      Coroutine:WaitForEvent("GUILD_ROSTER_UPDATE")
      ParseGlobalConfig()
    end
  end)
