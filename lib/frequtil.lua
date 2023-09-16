-- rollll/lib/frequtil
--
-- kinda like an ext to musicutil

local frequtil = {}


-- ------------------------------------------------------------------------
-- deps

local musicutil = require("lib/musicutil")
if z_tuning == nil then
  z_tuning = include("lib/z_tuning/z_tuning")
end


-- ------------------------------------------------------------------------
-- consts

frequtil.HZ_MIN = musicutil.note_num_to_freq(0)
frequtil.HZ_MAX = musicutil.note_num_to_freq(127)


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

function frequtil.floor(hz, tuning)
  if tuning == nil then tuning = "edo12" end
  local note = musicutil.freq_to_note_num(hz)
  return musicutil.note_num_to_freq(note)
end

function frequtil.ceil(hz, tuning)
  local note = musicutil.freq_to_note_num(hz)
  if hz == musicutil.note_num_to_freq(note) then
    return hz
  end
  return musicutil.note_num_to_freq(util.clamp(note+1, 0, 127))
end

function frequtil.round(hz, tuning)
  if tuning == nil then tuning = "edo12" end
  local floored = frequtil.floor(hz, tuning)
  local ceiled = frequtil.ceil(hz, tuning)

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

function frequtil.offness(hz, tuning)
  local prv = frequtil.floor(hz, tuning)
  local nxt = frequtil.ceil(hz, tuning)

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
function frequtil.tolin(hz, mode)
  if mode == nil then mode = "log2_edo12" end

  if mode == "lin" then
    return hz
  end

  local log_scale = 1
  if mode == "log2_edo12" then
    log_scale = 2^(1/12)
  elseif mode == "log2" then
      log_scale = 2
  end

  local min_log = math.log(frequtil.HZ_MIN, log_scale)
  local max_log = math.log(frequtil.HZ_MAX, log_scale)
  local freq_log = math.log(hz, log_scale)
  local v = (freq_log - min_log) / (max_log - min_log) * 127
  return v
end

-- like a continuous version of `musicutil.note_num_to_freq`
-- only works well on the input range 0-127
function frequtil.fromlin(v, mode)
  if mode == nil then mode = "log2_edo12" end

  if mode == "lin" then
    return v
  end

  local log_scale = 1
  if mode == "log2_edo12" then
    log_scale = 2^(1/12)
  elseif mode == "log2" then
      log_scale = 2
  end

  local min_log = math.log(frequtil.HZ_MIN, log_scale)
  local max_log = math.log(frequtil.HZ_MAX, log_scale)
  local freq_log = min_log + (max_log - min_log) * v / 127
  local hz = log_scale^(freq_log)
  return hz
end


-- ------------------------------------------------------------------------

return frequtil
