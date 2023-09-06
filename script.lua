-- rollll.
-- @eigen


local inspect = require("lib/inspect")
local lattice = require("lattice")

musicutil = require("lib/musicutil")
timeutil = include("lib/timeutil")
frequtil = include("lib/frequtil")
noteutil = include("lib/noteutil")
kbdutil = include("lib/kbdutil")

local Roll = include("lib/roll")
local Playhead = include("lib/playhead")

include("lib/consts")


-- ------------------------------------------------------------------------
-- state

local s_lattice

roll = nil
playhead = nil

fullscreen = false

mouse_x = 0
mouse_y = 0

snap_note = false


-- ------------------------------------------------------------------------
-- midi

m = nil


-- ------------------------------------------------------------------------
-- script lifecycle

local clock_redraw

function init()
  roll = Roll.new(30)
  playhead = Playhead.new(roll)

  m = midi:connect_output()

  s_lattice = lattice:new{
    ppqn = PPQN
  }

  clock_redraw = clock.run(function()
      while true do
        clock.sleep(1/FPS)
        redraw()
      end
  end)

  local sprocket = s_lattice:new_sprocket{
    action = function(step)
      -- local step_bars = (step / PPQN) / 4
      -- print(step_bars)
      -- playhead:set(step_bars)
      playhead:tick(1/PPQN, m)
    end,
    division = 1/PPQN,
    enabled = true
  }
end


-- ------------------------------------------------------------------------
-- ux - keyboard

screen.key = function(char, modifiers, is_repeat, state)
  -- print(inspect(char))

  if char == nil then
    return
  end

  if type(char) == "string" then
    if char == "t" and #modifiers == 0 and state >= 1 then
      roll.quant_t = not roll.quant_t
    end
    if char == "f" and #modifiers == 0 and state >= 1 then
      roll.quant_f = not roll.quant_f
    end
    if char == "r" and #modifiers == 0 and state >= 1 then
      playhead.reversed = not playhead.reversed
    end

    if char == " " and state >= 1 then

      if #modifiers == 0 then
        playhead:toggle()
        if playhead.active then
          s_lattice:start()
        else
          s_lattice:stop()
        end
      end

      if kbdutil.isCtrl(modifiers) then
        playhead.t = 0
      end

    end
  end

  if char.name ~= nil then
    if char.name == "F11" and state >= 1 then
      fullscreen = not fullscreen
       screen.set_fullscreen(fullscreen)
    end

    local has_roll_moved = false
    if char.name == "up" and state >= 1 then
      if #modifiers == 0 or kbdutil.isCtrl(modifiers) then
        local step = kbdutil.isCtrl(modifiers) and 6 or 0.5
        roll.top_note = util.clamp(roll.top_note - step, 0, 127)
        has_roll_moved = true
      elseif kbdutil.isAlt(modifiers) then
        roll.note_factor = util.clamp(roll.note_factor + 0.1, 0.5, 10)
        has_roll_moved = true
      end
    end
    if char.name == "down" and state >= 1 then
      if #modifiers == 0 or kbdutil.isCtrl(modifiers) then
        local step = kbdutil.isCtrl(modifiers) and 6 or 0.5
        roll.top_note = util.clamp(roll.top_note + step, 0, 127)
        has_roll_moved = true
      elseif kbdutil.isAlt(modifiers) then
        roll.note_factor = util.clamp(roll.note_factor - 0.1, 0.5, 10)
        has_roll_moved = true
      end
    end

    if char.name == "left" and state >= 1 then
      if #modifiers == 0 or kbdutil.isCtrl(modifiers) then
        local step = kbdutil.isCtrl(modifiers) and 0.5 or 0.1
        roll.left_t = util.clamp(roll.left_t - step, T_MIN, T_MAX)
        has_roll_moved = true
      elseif kbdutil.isAlt(modifiers) then
        roll.t_factor = util.clamp(roll.t_factor + 0.1/(BAR_DIV * W_BAR), 0.5/(BAR_DIV * W_BAR), 10/(BAR_DIV * W_BAR))
        has_roll_moved = true
      end
    end
    if char.name == "right" and state >= 1 then
      if #modifiers == 0 or kbdutil.isCtrl(modifiers) then
        local step = kbdutil.isCtrl(modifiers) and 0.5 or 0.1
        roll.left_t = util.clamp(roll.left_t + step, T_MIN, T_MAX)
        has_roll_moved = true
      elseif kbdutil.isAlt(modifiers) then
        roll.t_factor = util.clamp(roll.t_factor - 0.1/(BAR_DIV * W_BAR), 0.5/(BAR_DIV * W_BAR), 10/(BAR_DIV * W_BAR))
        has_roll_moved = true
      end
    end
    if has_roll_moved then
      roll:update_note_cursor(mouse_x, mouse_y)
    end
  end
end


-- ------------------------------------------------------------------------
-- ux - mouse

screen.mouse = function(x, y)
  mouse_x, mouse_y = x, y
  roll:update_note_cursor(mouse_x, mouse_y)
end

screen.click = function(x, y, state, button)
  if button == 1 and state >= 1 then
    roll:add_note_at_cursor()
  end
end

-- tfw no scroll: ;_;


-- ------------------------------------------------------------------------
-- screen

-- function redraw_cursor()
--   screen.color(table.unpack(COLOR_TMP_NOTE))
--   screen.move(mouse_x, mouse_y)
--   screen.circle_fill(W_NOTE)
-- end

function redraw_hud_bubble(x, y, w)
  screen.color(table.unpack(COLOR_HUD_BUBBLE))
  screen.move(x, y)
  screen.circle_fill(HUD_BUBBLE_H/2)
  screen.move(x + w, y)
  screen.circle_fill(HUD_BUBBLE_H/2)
  screen.move(x, y - HUD_BUBBLE_H/2 + 1)
  screen.rect_fill(w, HUD_BUBBLE_H - 1)
end

function redraw_hud()
  local W, H = screen.get_size()

  -- cursor t
  redraw_hud_bubble(10, H - 7, HUD_BUBBLE_T_W)
  if roll.quant_t then
    screen.color(table.unpack(COLOR_HUD_QUANT))
  else
    screen.color(table.unpack(COLOR_HUD))
  end
  screen.move(15, H - 10)
  screen.text(timeutil.format(roll.note_cursor.time))

  -- cursor f
  redraw_hud_bubble(W - HUD_BUBBLE_G_W - 10, H - 7, HUD_BUBBLE_G_W)
  if roll.quant_f then
    screen.color(table.unpack(COLOR_HUD_QUANT))
  else
    screen.color(table.unpack(COLOR_HUD))
  end
  screen.move(W - 30, H - 10)
  screen.text_right(frequtil.format_hz(roll.note_cursor.hz))
  screen.move(W - 10, H - 10)
  screen.text_right(frequtil.format_note(roll.note_cursor.hz))
end

function redraw()
  screen.clear()

  roll:redraw()
  -- redraw_cursor()
  playhead:redraw()
  redraw_hud()

  screen.refresh()
end
