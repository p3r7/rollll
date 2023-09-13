
local z_tuning = {}


-- ------------------------------------------------------------------------
-- deps

local tu = include('lib/z_tuning/tuning_util')
local tuning = include('lib/z_tuning/tuning')
local tunings_builtin_names, tunings_builtin = include('lib/z_tuning/tunings_builtin')
local tuning_files = include('lib/z_tuning/tuning_files')


-- ------------------------------------------------------------------------
-- consts

z_tuning.names = {}
z_tuning.tunings = {}
local tuning_keys = {}
local tuning_keys_rev = {}
local num_tunings = 0


-- ------------------------------------------------------------------------

local build_tuning_keys_reversed = function()
   table.sort(tuning_keys)
   tuning_keys_rev = {}
   for i, v in ipairs(tuning_keys) do
      tuning_keys_rev[v] = i
   end
end

local setup_tunings = function()
   z_tuning.tunings = {}
   tuning_keys = {}
   tuning_keys_rev = {}

   -- add built-in tunings
   for k, v in pairs(tunings_builtin) do
      z_tuning.tunings[k] = v
      table.insert(tuning_keys, k)
   end
   for _, n in ipairs(tunings_builtin_names) do
     table.insert(z_tuning.names, n)
   end

   -- add tunings from disk
   local tf_names, tf = tuning_files.load_files()
   for k, v in pairs(tf) do
      z_tuning.tunings[k] = v
      table.insert(tuning_keys, k)
   end
   for _, n in ipairs(tf_names) do
     table.insert(z_tuning.names, n)
   end

   num_tunings = #tuning_keys
   build_tuning_keys_reversed()

   print("tuning_keys_rev:")
   tab.print(tuning_keys_rev)
end

setup_tunings()


-- ------------------------------------------------------------------------
-- lookup

function z_tuning.note_num_to_freq(t, root_note, root_freq, num)
  local freq = z_tuning.tunings[t].note_freq(num, root_note, root_freq)
  --print(''..num..' -> '..freq)
  return freq
end

function z_tuning.bend_root(root_freq, root_note)
   return tu.ratio_st(root_freq / tu.midi_hz(root_note))
end

-- return the frequency ratio for a given number of scale degrees from the root.
-- (argument is `floor`d to an integer)
function z_tuning.interval_ratio(t, interval)
   return z_tuning.tunings[t].interval_ratio(interval)
end

-- return the amount of deviation from 12tet in semitones, for a given note
function z_tuning.get_bend_semitones (t, root_note, bend_root, num)
   local bt = z_tuning.tunings[t].bend_table
   local n = #bt
   print("bend n = "..n)
   local idx = ((num - root_note) % n) + 1
   print("bend idx = "..idx)
   return bt[idx] + bend_root
end


-- ------------------------------------------------------------------------

return z_tuning
