-- rollll/lib/frequtil
--
-- kinda like an ext to musicutil

local frequtil = {}


-- ------------------------------------------------------------------------
-- deps

local musicutil = require("lib/musicutil")

include("lib/consts")


-- ------------------------------------------------------------------------
-- print

function frequtil.format_hz(hz)
  return string.format("%.2f", hz).." hz"
end

function frequtil.format_note(hz)
  local note = musicutil.freq_to_note_num(frequtil.round(hz))
  return musicutil.note_num_to_name(note, true)
end


-- ------------------------------------------------------------------------
-- math

function frequtil.floor(hz)
  local note = musicutil.freq_to_note_num(hz)
  return musicutil.note_num_to_freq(note)
end

function frequtil.ceil(hz)
  local note = musicutil.freq_to_note_num(hz)
  if hz == musicutil.note_num_to_freq(note) then
    return hz
  end
  return musicutil.note_num_to_freq(util.clamp(note+1, 0, 127))
end

function frequtil.round(hz)
  local floored = frequtil.floor(hz, div)
  local ceiled = frequtil.ceil(hz, div)

  local diff_f = math.abs(hz - floored)
  local diff_c = math.abs(hz - ceiled)

  if diff_f < diff_c then
    return floored
  else
    return ceiled
  end
end

-- function frequtil.offness_prev(hz)
--   local prv = frequtil.floor(hz)
--   local nxt = frequtil.ceil(hz)
--   if hz == prv then
--     return 0
--   end

--   math.abs(hz - prv)

-- end

-- function frequtil.offness_next(hz)
--   local nxt = frequtil.ceil(hz)
--   if hz == nxt then
--     return 0
--   end

-- end

function frequtil.offness(hz)
  local prv = frequtil.floor(hz)
  local nxt = frequtil.ceil(hz)

  if hz == prv or hz == nxt then
    return 0
  end

  local prv_d = math.abs(hz - prv)
  local nxt_d = math.abs(nxt - hz)

  if prv_d < nxt_d then
    return prv_d / (nxt - prv)
  else
    return nxt_d / (nxt - prv)
  end
end


-- ------------------------------------------------------------------------
-- ploting scale - 12edo

-- x2 -> +1 octave
-- x2^(1/12) -> +1 note

local LOG_SCALE = 2^(1/12)

-- like a continuous version of `musicutil.freq_to_note_num`
-- only works well on the range HZ_MIN-HZ_MAX (mapped to 0-127)
function frequtil.tolin(hz)
  local min_log = math.log(HZ_MIN, LOG_SCALE)
  local max_log = math.log(HZ_MAX, LOG_SCALE)
  local freq_log = math.log(hz, LOG_SCALE)
  local v = (freq_log - min_log) / (max_log - min_log) * 127
  return v
end

-- like a continuous version of `musicutil.note_num_to_freq`
-- only works well on the input range 0-127
function frequtil.fromlin(v)
  local min_log = math.log(HZ_MIN, LOG_SCALE)
  local max_log = math.log(HZ_MAX, LOG_SCALE)
  local freq_log = min_log + (max_log - min_log) * v / 127
  local hz = LOG_SCALE^(freq_log)
  return hz
end


-- ------------------------------------------------------------------------

return frequtil
