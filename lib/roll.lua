-- rollll/lib/roll

local Roll = {}
Roll.__index = Roll


-- ------------------------------------------------------------------------
-- deps

local musicutil = require("lib/musicutil")
local frequtil = include("lib/frequtil")
if z_tuning == nil then
  z_tuning = include("lib/z_tuning/z_tuning")
end
local timeutil = include("lib/timeutil")
local noteutil = include("lib/noteutil")

local Note = include("lib/note")

include("lib/consts")


-- ------------------------------------------------------------------------
-- constructor

function Roll.new(notes, top_note)
  local p = setmetatable({}, Roll)

  p.top_note = top_note
  p.note_factor = 1

  p.left_t = 0
  p.t_factor = 1 / (BAR_DIV * W_BAR)

  p.freq_scale = "log2_edo12"

  p.tuning = "edo12"
  -- p.tuning = "ji_normal"
  -- p.tuning = "ji_overtone"
  -- p.tuning = "ji_gamut"
  p.root_note = 69
  p.root_freq = 440.0
  p.bend_root = z_tuning.bend_root(p.root_freq, p.root_note)

  p.quant_t = false
  p.quant_f = false
  -- p.quant_t = true
  -- p.quant_f = true

  p.note_cursor = Note.new(0, 0, p)
  p.note_cursor.is_cursor = true

  p.notes = notes

  return p
end


-- ------------------------------------------------------------------------
-- note cursor

function Roll:update_note_cursor(x, y)

  local t = noteutil.screen_to_time(x, self.t_factor, self.left_t)
  if self.quant_t then
    local div = self:time_div_for_screen()
    self.note_cursor.time = timeutil.round(t, div)
  else
    self.note_cursor.time = t
  end

  local hz = noteutil.screen_to_hz(y, self.note_factor, self.top_note, self.freq_scale)
  if self.quant_f then
    self.note_cursor.hz = frequtil.round(hz, self.tuning)
  else
    self.note_cursor.hz = hz
  end
end


-- ------------------------------------------------------------------------
-- notes

function Roll:add_note(hz, time)
  local n = Note.new(hz, time)
  table.insert(self.notes, n)
end

function Roll:add_note_at_cursor()
  self:add_note(self.note_cursor.hz, self.note_cursor.time)
end

function Roll:add_note_at_screen_coord(x, y)
  local hz = noteutil.screen_to_hz(y, self.note_factor, self.top_note, self.freq_scale)
  local time = noteutil.screen_to_time(x, self.t_factor, self.left_t)

  -- print("add: @"..time.." - "..hz.." hz")

  self:add_note(hz, time)
end


-- ------------------------------------------------------------------------
-- tuning

-- set the current tuning
function Roll:set_tuning(t)
  self.tuning = t
  self.bend_root = z_tuning.bend_root(self.root_freq, self.root_note)
end

-- set the root note number, without changing root frequency
-- this effects a transposition
function Roll:set_tuning_root_note(num)
  self.root_note = num
  self.bend_root = z_tuning.bend_root(self.root_freq, self.root_note)
end

-- set the root note, updating the root frequency,
-- preserving the ratio of root note freq to 12tet A440
function Roll:set_tuning_note_adjusting(num)
  local interval = num - self.root_note
  local ratio = z_tuning.interval_ratio('edo12', interval)
  local new_freq = self.root_freq * ratio
   -- FIXME, why are we rounding here? (only to 1/16hz but still)
   -- if its just for display purposes that seems silly
  new_freq = math.floor(new_freq * 16) * 0.0625
  self.root_note = num
  self.root_freq = new_freq
  self.bend_root = z_tuning.bend_root(self.root_freq, self.root_note)
end

-- set the root note, updating the root frequency,
-- such that frequency of new root note does not change
function Roll:set_tuning_note_pivoting(num)
  -- local freq = tunings[self.tuning].note_freq(num, self.root_note, self.root_freq)
  local freq = z_tuning.note_num_to_freq(self.tuning, self.root_note, self.root_freq, num)
  self.root_note = num
  self.root_freq = freq
  self.bend_root = z_tuning.bend_root(self.root_freq, self.root_note)
end

-- set the root frequency, without changing root note
-- this effects a transposition
function Roll:set_tuning_root_frequency(freq)
  self.root_freq = freq
  self.bend_root = z_tuning.bend_root(self.root_freq, self.root_note)
end


-- ------------------------------------------------------------------------
-- screen - guides - time

function Roll:time_div_for_screen()
  local bar_w = noteutil.time_to_screen(1, self.t_factor, 0)
  if bar_w >= 100 then
    return 32
  elseif bar_w >= 50 then
    return 16
  elseif bar_w >= 30 then
    return 8
  elseif bar_w >= 10 then
    return 4
  end
  return 1
end

local function set_guide_color_for_t(t)
  if math.floor(t) == t then -- whole bar
    screen.color(table.unpack(COLOR_LINE))
  elseif timeutil.floor(t, 4) == t then
    screen.color(table.unpack(COLOR_LINE_4))
  elseif timeutil.floor(t, 8) == t then
    screen.color(table.unpack(COLOR_LINE_8))
  elseif timeutil.floor(t, 16) == t then
    screen.color(table.unpack(COLOR_LINE_16))
  elseif timeutil.floor(t, 32) == t then
    screen.color(table.unpack(COLOR_LINE_32))
  end
end

function Roll:redraw_t_guides()
  local W, H = screen.get_size()

  local div = self:time_div_for_screen()
  local t = timeutil.ceil(self.left_t, div)
  local bar_x = noteutil.time_to_screen(t, self.t_factor, self.left_t)
  while bar_x < W do
    set_guide_color_for_t(t)
    screen.move(bar_x, 0)
    screen.line(bar_x, H)
    t = t + 1/div
    bar_x = noteutil.time_to_screen(t, self.t_factor, self.left_t)
  end
end


-- ------------------------------------------------------------------------
-- screen - guides - freq

function Roll:redraw_f_guides()
  local W, H = screen.get_size()

  screen.color(table.unpack(COLOR_LINE))

  local note = musicutil.freq_to_note_num(self.top_note)
  -- local note_hz = musicutil.note_num_to_freq(note)
  local note_hz = z_tuning.note_num_to_freq(self.tuning, self.root_note, self.root_freq, note)
  local note_y = noteutil.hz_to_screen(note_hz, self.note_factor, self.top_note, self.freq_scale)

  -- print(note_hz.." -> "..note_y)

  while note_y < H do
    if note > 127 then
      screen.color(table.unpack(COLOR_LINE_OUT))
    end
    screen.move(0, note_y)
    screen.line(W, note_y)
    note = note + 1
    -- note_hz = musicutil.note_num_to_freq(note)
    note_hz = z_tuning.note_num_to_freq(self.tuning, self.root_note, self.root_freq, note)
    note_y = noteutil.hz_to_screen(note_hz, self.note_factor, self.top_note, self.freq_scale)
  end
end


-- ------------------------------------------------------------------------
-- screen

function Roll:redraw_guides()
  self:redraw_t_guides()
  self:redraw_f_guides()
end

function Roll:redraw_notes()
  for _, note in ipairs(self.notes) do
    note:redraw(roll)
  end
end

function Roll:redraw_note_cursor()
  self.note_cursor:redraw(roll)
end

function Roll:redraw()
  self:redraw_guides()
  self:redraw_notes()
  self:redraw_note_cursor()
end


-- ------------------------------------------------------------------------

return Roll
