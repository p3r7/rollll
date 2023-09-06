-- rollll/lib/noteutil
--
-- kinda like an ext to musicutil

local noteutil = {}


-- ------------------------------------------------------------------------
-- deps

local musicutil = require("lib/musicutil")
local frequtil = include("lib/frequtil")


-- ------------------------------------------------------------------------
-- screen x <-> time

function noteutil.screen_to_time(x, t_factor, t_offset)
  if t_factor == nil then t_factor = 1 end
  if t_offset == nil then t_offset = 0 end

  return x * t_factor + t_offset
end

function noteutil.time_to_screen(t, t_factor, t_offset)
  if t_factor == nil then t_factor = 1 end
  if t_offset == nil then t_offset = 0 end

  return (t - t_offset) / t_factor
end


-- ------------------------------------------------------------------------
-- screen y <-> hz

function noteutil.screen_to_hz(y, note_factor, note_offset)
  if note_factor == nil then note_factor = 1 end
  if note_offset == nil then note_offset = 0 end
  -- return y * hz_factor + hz_offset
  -- return util.linexp(0, W_NOTE * 128, HZ_MIN, HZ_MAX, y) * hz_factor + hz_offset
  return frequtil.fromlin(((y / W_ROLL_NOTE) / note_factor + note_offset))
end

function noteutil.hz_to_screen(hz, note_factor, note_offset)
  if note_factor == nil then note_factor = 1 end
  if note_offset == nil then note_offset = 0 end

  -- return (hz - hz_offset) / hz_factor
  -- return util.explin(HZ_MIN, HZ_MAX, 0, W_NOTE * 128, hz - hz_offset) / hz_factor
  return (frequtil.tolin(hz) - note_offset) * W_ROLL_NOTE * note_factor
end


-- ------------------------------------------------------------------------

return noteutil
