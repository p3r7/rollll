-- rollll/lib/timeutil

local timeutil = {}


-- ------------------------------------------------------------------------
-- print

function timeutil.format(t)
  -- NB: bar notation

  local bar = math.floor(t)
  local rest = t - bar

  local fourth = math.floor(rest / (1/4))
  -- rest = rest - fourth

  local height = math.floor(rest / (1/8))

  return bar .. "." .. fourth .. "." .. height
end


-- ------------------------------------------------------------------------
-- time math

function timeutil.floor(t, div)
  if div == nil then
    return math.floor(t)
  end

  local whole_part = math.floor(t)
  local decimal_part = t - whole_part
  local floored = decimal_part - (decimal_part % (1/div))
  return whole_part + floored
end

function timeutil.ceil(t, div)
  if div == nil then
    return math.ceil(t)
  end

  local whole_part = math.floor(t)
  local decimal_part = t - whole_part

  local ceiled = 0
  for i=0,1,1/div do
    local upper_bound = 1 - i
    if decimal_part >= upper_bound then
      ceiled = upper_bound
      break
    end
  end

  return whole_part + ceiled
end

function timeutil.round(t, div)
  if div == nil then
    return util.round(t)
  end

  local floored = timeutil.floor(t, div)
  local ceiled = timeutil.ceil(t, div)

  local diff_f = math.abs(t - floored)
  local diff_c = math.abs(t - ceiled)

  if diff_f < diff_c then
    return floored
  else
    return ceiled
  end
end



-- ------------------------------------------------------------------------

return timeutil
