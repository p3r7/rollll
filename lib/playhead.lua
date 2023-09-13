-- rollll/lib/playhead

local Playhead = {}
Playhead.__index = Playhead


-- ------------------------------------------------------------------------
-- deps

local musicutil = require("lib/musicutil")
local noteutil = include("lib/noteutil")

include("lib/consts")


-- ------------------------------------------------------------------------
-- constructor

function Playhead.new(roll)
  local p = setmetatable({}, Playhead)

  p.roll = roll

  p.t = 0.0
  p.active = false

  p.reversed = false

  p.active_notes = {}

  return p
end


-- ------------------------------------------------------------------------
-- main

function Playhead:toggle()
  self.active = (not self.active)
end

function Playhead:note_on(m, note)
  -- print("NOTE_ON: "..note.hz)

  table.insert(self.active_notes, note)
  note.playing = true

  if m ~= nil then
    -- TODO: handle bend
    local n = musicutil.freq_to_note_num(note.hz)
    m:note_on(n, 127, 1)
  end
end

function Playhead:note_off(m, note)
  -- print("NOTE_OFF: "..note.hz)

  for i, n in ipairs(self.active_notes) do
    if note == n then
      table.remove(self.active_notes, i)
    end
  end
  note.playing = false

  if m ~= nil then
    local n = musicutil.freq_to_note_num(note.hz)
    m:note_off(n, 0, 1)
  end
end

function Playhead:tick(d, m)
  if playhead.reversed then
    d = -d
  end

  if self.active then
    self.t = self.t + d
    for i, note in ipairs(self.roll.notes) do
      local delta_t = self.t - note.time
      if note.playing and (((not self.reversed) and delta_t > NOTE_DUR) or (self.reversed and delta_t < NOTE_DUR)) then
        self:note_off(m, note)
      end
      if not note.playing
        and delta_t > 0 and math.abs(delta_t) <= 1/PPQN then
        self:note_on(m, note)
      end
    end

    if self.t <= 0 then
      self.t = 0
      self.reversed = false
      self.active = false
    end
  end
end

function Playhead:set(pos)
  if self.active then
    self.t = pos
    -- TODO: play notes
  end
end


-- ------------------------------------------------------------------------

function Playhead:redraw()
  local W, H = screen.get_size()

  local x = noteutil.time_to_screen(self.t, self.roll.t_factor, self.roll.left_t)
  screen.color(table.unpack(COLOR_PLAYHEAD))

  screen.move(x, 0)
  screen.line(x, H)
end


-- ------------------------------------------------------------------------

return Playhead
