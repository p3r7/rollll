local Tuning = include('lib/z_tuning/tuning')
local JI = require 'lib/core/intonation'

local names = {}
local tunings = {}

--- standard 12tet
tunings['edo12'] = Tuning.new {
   note_freq = function(midi, root_note, root_freq)
      local deg = midi - root_note
      return root_freq * (2 ^ ((midi - root_note) / 12))
   end,

   interval_ratio = function(interval)
      return 2 ^ (interval / 12)
   end
}
table.insert(names, 'edo12')

tunings['ji_normal'] = Tuning.new {
   ratios = JI.normal()
}
table.insert(names, 'ji_normal')

tunings['ji_overtone'] = Tuning.new {
   ratios = JI.overtone()
}
table.insert(names, 'ji_overtone')

tunings['ji_undertone'] = Tuning.new {
   ratios = JI.undertone()
}
table.insert(names, 'ji_undertone')

-- 43-tone
tunings['ji_partch'] = Tuning.new {
   ratios = JI.partch()
}
table.insert(names, 'ji_partch')

-- 168-tone!
tunings['ji_gamut'] = Tuning.new {
   ratios = JI.gamut()
}
table.insert(names, 'ji_gamut')


return names, tunings
