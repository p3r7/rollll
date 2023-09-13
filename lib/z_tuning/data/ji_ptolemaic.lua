-- "chromaticized" version of ptolemy's intense diatonic (5-limit)
-- (new intervals constructed from major thirds)
local r = {
   1, -- C  
   4 / 3 * 4 / 5, -- Db
   9 / 8, -- D
   3 / 2 * 4 / 5, -- Eb
   5 / 4, -- E
   4 / 3, -- F
   9 / 8 * 5 / 4, -- F#
   3 / 2, -- G
   5 / 4 * 5 / 4, -- G#
   5 / 3, -- A
   9 / 4 * 4 / 5, -- Bb
   15 / 8 -- B
}
return { ratios = r }