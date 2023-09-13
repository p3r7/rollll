
local musicutil = require("lib/musicutil")


-- ------------------------------------------------------------------------
-- general

FPS = 60
-- FPS = 1

-- ------------------------------------------------------------------------
-- boundaries

HZ_MIN = musicutil.note_num_to_freq(0)
HZ_MAX = musicutil.note_num_to_freq(127)

T_MIN = 0
T_MAX = 4000


-- ------------------------------------------------------------------------
-- time

PPQN = 96

-- REVIEW: have this adaptative to current zoom level
BAR_DIV = 4

COLOR_PLAYHEAD = {255, 0, 0}

NOTE_DUR = 1/32


-- ------------------------------------------------------------------------
-- screen - notes

COLOR_NOTE_CURSOR = {147, 112, 219}
COLOR_NOTE_CURSOR_OFF = {255, 0, 0}
COLOR_NOTE = {219, 147, 112}
COLOR_NOTE_PLAYING = {220, 220, 220}

W_NOTE = 4
W_ROLL_NOTE = 10


-- ------------------------------------------------------------------------
-- screen - roll

W_NOTE_SPACING = 10

W_BAR = 30

COLOR_LINE = {155, 155, 155}
COLOR_LINE_4 = {57, 57, 57}
COLOR_LINE_8 = {27, 27, 27}
COLOR_LINE_16 = {17, 17, 17}
COLOR_LINE_32 = {13, 13, 13}

COLOR_LINE_OUT = {17, 17, 17}


M_HZ_SCALING_LIN = 1
M_HZ_SCALING_EXP = 2


-- ------------------------------------------------------------------------
-- screen - hud

-- COLOR_HUD = {143, 188, 143}
COLOR_HUD = {255, 255, 0}
COLOR_HUD_QUANT = {255, 20, 0}

COLOR_HUD_BUBBLE = {43, 54, 24}
HUD_BUBBLE_H = 10

HUD_BUBBLE_T_W = 30
HUD_BUBBLE_G_W = 70
