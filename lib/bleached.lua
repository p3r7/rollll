-- lib/control/bleached.
-- @eigen

local bleached = {}


-- ------------------------------------------------------------------------
-- sysex

local MAX_VERSION = {2, 0, 0}

local function is_supported_version(v, max, index)
  if index == nil then index = 1 end

  if index > #max then
    return true
  end

  if v[index] > max[index] then
    return false
  end

  if v[index] < max[index] then
    return true
  end

  return is_supported_version(v, max, index+1)
end

local function version_string(v)
  return v[1] .. "." .. v[2] .. "." .. v[3]
end

-- 0x1F - "1nFo"
bleached.request_sysex_config_dump = function(midi_out)
  local data = {0xf0, 0x7d, 0x00, 0x00, 0x1f, 0xf7}
  if seamstress ~= nil then
    midi_out:send(data)
  else
    midi.send(midi_out.device, data)
  end
end

-- 0x0F - "c0nFig"
bleached.is_sysex_config_dump = function(sysex_payload)
  return (sysex_payload[2] == 0x7d and sysex_payload[3] == 0x00 and sysex_payload[4] == 0x00
          and sysex_payload[5] == 0x0f)
end

bleached.parse_sysex_config_dump = function(sysex_payload)
  local device_id = sysex_payload[6]
  local version = {sysex_payload[7], sysex_payload[8], sysex_payload[9]}

  if not is_supported_version(version, MAX_VERSION) then
    print("Unsupported bleached version (" .. version_string(version) .. " > " .. version_string(MAX_VERSION)  .. ") !")
    return nil
  end

  local nb_sensors = sysex_payload[10]
  local ch = sysex_payload[11]

  local cc_list = {}
  for i=0,nb_sensors-1 do
    table.insert(cc_list, sysex_payload[12+i])
  end

  return {
    version = version,
    ch = ch,
    cc = cc_list,
  }
end


-- ------------------------------------------------------------------------
-- init

local dev_bleached = nil
local midi_bleached = nil
local conf_bleached = nil

function bleached.find_dev_norns()
  for _,dev in pairs(midi.devices) do
    if dev.name~=nil and dev.name == "bleached" then
      print("detected bleached")
      return dev
    end
  end
end

function bleached.find_dev_seamstress()
  for _, dev in pairs(midi.inputs) do
    -- print(dev.name)
    if dev.name~=nil and util.string_starts(dev.name, "bleached:") then
      print("detected bleached")
      return dev
    end
  end
end

function bleached.find_dev()
  if seamstress ~= nil then
    return bleached.find_dev_seamstress()
  else -- norns
    return bleached.find_dev_norns()
  end
end

function bleached.connect_dev(dev)
  if seamstress ~= nil then
    if dev ~= nil then
      dev_bleached = dev
      midi_bleached = {i = midi.connect_input(dev.port),
                       o = midi.connect_output(dev.port)}
    end
  else -- norns
    if dev ~= nil then
      dev_bleached = dev
      local m = midi.connect(dev.port)
      midi_bleached = {i = m,
                       o = m}
    end
  end
end

function bleached.init(cc_cb_fn, dev)
  if dev == nil then
    dev = bleached.find_dev()
  end

  bleached.connect_dev(dev)

  if midi_bleached == nil then
    return
  end

  local is_sysex_dump_on = false
  local sysex_payload = {}

  midi_bleached.i.event = function(data)
    local d = midi.to_msg(data)

    if is_sysex_dump_on then
      tab.print(data)
      for _, b in pairs(data) do
        table.insert(sysex_payload, b)
        if b == 0xf7 then
          is_sysex_dump_on = false
          if bleached.is_sysex_config_dump(sysex_payload) then
            conf_bleached = bleached.parse_sysex_config_dump(sysex_payload)
            print("done retrieving bleached config")
            tab.print(sysex_payload)
          end
        end
      end
    elseif d.type == 'sysex' then
      is_sysex_dump_on = true
      sysex_payload = {}
      for _, b in pairs(d.raw) do
        table.insert(sysex_payload, b)
      end
    elseif d.type == 'cc' and conf_bleached ~= nil then
      if cc_cb_fn ~= nil then
        cc_cb_fn(d)
      end
    end
  end

  -- ask config dump via sysex
  bleached.request_sysex_config_dump(midi_bleached.o)

end


-- ------------------------------------------------------------------------
-- conf accessors (stateful)

local function mustHaveConf()
  if conf_bleached == nil then
    error("Attempted to access the bleached configuration but it didn't get retrieved.")
  end
end

bleached.cc_to_row = function(cc)
  local pot = bleached.cc_to_pot(cc)

  if pot > 4 then
    return 1
  end
  return 2
end

bleached.cc_to_row_pot = function(cc)
  local pot = bleached.cc_to_pot(cc)

  if pot > 4 then
    return pot - 4
  end
  return pot
end

bleached.cc_to_pot = function(cc)
  mustHaveConf()
  local t = tab.invert(conf_bleached.cc)
  return t[cc]
end



-- ------------------------------------------------------------------------

return bleached
