-- rollll/lib/note

local Note = {}
Note.__index = Note


-- ------------------------------------------------------------------------
-- deps

local frequtil = include("lib/frequtil")
local colorutil = include("lib/colorutil")
local noteutil = include("lib/noteutil")

include("lib/consts")


-- ------------------------------------------------------------------------
-- constructor

function Note.new(hz, time)
  local p = setmetatable({}, Note)

  p.hz = hz
  p.time = time

  p.playing = false

  p.is_cursor = false

  return p
end


-- ------------------------------------------------------------------------
-- screen

function Note:screen_coords(roll)
  local x = noteutil.time_to_screen(self.time, roll.t_factor, roll.left_t)
  local y = noteutil.hz_to_screen(self.hz, roll.note_factor, roll.top_note, roll.freq_scale)

  return x, y
end

function Note:redraw(roll)
  local x, y = self:screen_coords(roll)

  if self.is_cursor then
    local pct_off = frequtil.offness(self.hz)
    local c = colorutil.scale(COLOR_NOTE_CURSOR, COLOR_NOTE_CURSOR_OFF, pct_off)
    screen.color(table.unpack(c))
  elseif self.playing then
    screen.color(table.unpack(COLOR_NOTE_PLAYING))
  else
    screen.color(table.unpack(COLOR_NOTE))
  end
  -- screen.move(util.round(x), util.round(y))
  screen.move(x, y)
  screen.circle_fill(W_NOTE)
end


-- ------------------------------------------------------------------------

return Note
