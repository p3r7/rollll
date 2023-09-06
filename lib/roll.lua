-- rollll/lib/roll

local Roll = {}
Roll.__index = Roll


-- ------------------------------------------------------------------------
-- deps

local musicutil = require("lib/musicutil")
local timeutil = include("lib/timeutil")
local frequtil = include("lib/frequtil")
local noteutil = include("lib/noteutil")

local Note = include("lib/note")

include("lib/consts")


-- ------------------------------------------------------------------------
-- constructor

function Roll.new(top_note)
  local p = setmetatable({}, Roll)

  p.top_note = top_note
  p.note_factor = 1

  p.left_t = 0
  p.t_factor = 1 / (BAR_DIV * W_BAR)

  p.hz_scalng_mode = M_HZ_SCALING_LIN

  p.quant_t = false
  p.quant_f = false
  -- p.quant_t = true
  -- p.quant_f = true

  p.note_cursor = Note.new(0, 0, p)
  p.note_cursor.is_cursor = true

  p.notes = {}

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

  local hz = noteutil.screen_to_hz(y, self.note_factor, self.top_note)
  if self.quant_f then
    self.note_cursor.hz = frequtil.round(hz)
  else
    self.note_cursor.hz = hz
  end
end


-- ------------------------------------------------------------------------
-- notes

function Roll:add_note(hz, time)
  local n = Note.new(hz, time, self)
  table.insert(self.notes, n)
end

function Roll:add_note_at_cursor()
  self:add_note(self.note_cursor.hz, self.note_cursor.time)
end

function Roll:add_note_at_screen_coord(x, y)
  local hz = noteutil.screen_to_hz(y, self.note_factor, self.top_note)
  local time = noteutil.screen_to_time(x, self.t_factor, self.left_t)

  -- print("add: @"..time.." - "..hz.." hz")

  self:add_note(hz, time)
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
  local note_hz = musicutil.note_num_to_freq(note)
  local note_y = noteutil.hz_to_screen(note_hz, self.note_factor, self.top_note)

  while note_y < H do
    if note > 127 then
      screen.color(table.unpack(COLOR_LINE_OUT))
    end
    screen.move(0, note_y)
    screen.line(W, note_y)
    note = note + 1
    note_hz = musicutil.note_num_to_freq(note)
    note_y = noteutil.hz_to_screen(note_hz, self.note_factor, self.top_note)
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
    note:redraw(self.t_factor, self.left_t,
                self.note_factor, self.top_note)
  end
end

function Roll:redraw_note_cursor()
  self.note_cursor:redraw(self.t_factor, self.left_t,
                          self.note_factor, self.top_note)
end

function Roll:redraw()
  self:redraw_guides()
  self:redraw_notes()
  self:redraw_note_cursor()
end


-- ------------------------------------------------------------------------

return Roll
