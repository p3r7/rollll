

function tkeys(t)
  local t2 = {}
  for k, _ in pairs(t) do
    table.insert(t2, k)
  end
  return t2
end
