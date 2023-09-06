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

function Note.new(hz, time, parent)
  local p = setmetatable({}, Note)

  p.hz = hz
  p.time = time

  p.parent = parent

  p.playing = false

  p.is_cursor = false

  return p
end


-- ------------------------------------------------------------------------
-- screen

function Note:screen_coords()
  local x = noteutil.time_to_screen(self.time, self.parent.t_factor, self.parent.left_t)
  local y = noteutil.hz_to_screen(self.hz, self.parent.note_factor, self.parent.top_note)

  return x, y
end

function Note:redraw()
  local x, y = self:screen_coords()

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
