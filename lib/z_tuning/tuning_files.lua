local scala = include('lib/z_tuning/tuning_scala')
local tuning = include('lib/z_tuning/tuning')

local TuningFiles = {}

-- local user_data_path = _path.data .. 'z_tuning/tunings'
-- local factory_data_path = _path.code .. 'z_tuning/lib/data'
local user_data_path = seamstress.state.data .. 'tunings'
local factory_data_path = seamstress.state.path .. '/lib/z_tuning/data'

print("user_data_path: "..user_data_path)
print("factory_data_path: "..factory_data_path)

TuningFiles.bootstrap = function()
  print('bootstrapping tunings...')
  local dir = io.open(user_data_path)
  if not dir then
    print('creating tuning data directory...')
    os.execute("mkdir -p " .. user_data_path)
    print('copying tuning data...')
    os.execute("cp " .. factory_data_path .. "/*.* " .. user_data_path)
  else
    dir.close()
  end
end

function splitlines(s)
  if s:sub(-1) ~= "\n" then
    s = s .. "\n"
  end
  return s:gmatch("(.-)\n")
end

-- needs to use a callback :/
TuningFiles.load_files = function(callback)
  local names = {}
  local tunings = {}
  local handle_scanned_files = function(list)
    print('----------------------------------')
    print('handling scanned tuning files:')
    print(list)
    print('----------------------------------')

    for file in splitlines(list) do
      print('handling tuning file: ' .. file)
      -- local file = string.match(path, ".+/(.*)$")
      -- print(file)
      if file then
        local name, ext = string.match(file, "(.*)%.(.*)")
        local is_tuning_file = false
        if ext == 'scl' then
          is_tuning_file = true
          print('loading tuning file (.scl): ' .. file)
          local r = scala.load_file(factory_data_path .. '/' .. file)
          tunings[name] = tuning.new({
              ratios = r
          })
        elseif ext == 'lua' then
          is_tuning_file = true
          print('loading tuning file (.lua): ' .. file)
          local path = factory_data_path .. '/' .. file
          local data = dofile(path)
          if data then
            tunings[name] = tuning.new(data)
          else
            print("tuning_files: couldn't load file at path: "..path )
          end
        else
          print('WARNING: tuning module encountered unrecognized file: ' .. file)
        end
        if is_tuning_file  then
          table.insert(names, name)
          print('added: ' .. name) -- : '..tunings[name])
        end
      end
    end
    tab.print(tunings)
    return names, tunings
  end
  local scan_cmd = 'ls ' .. factory_data_path
  print('scanning: ')
  print(scan_cmd)
  -- norns.system_cmd(scan_cmd, handle_scanned_files)
  ---- local res = os.execute(scan_cmd)
  --- UUUUUGH
  local stdout = io.popen(scan_cmd, 'r')
  local res = stdout:read('*a')
  return handle_scanned_files(res)
end

return TuningFiles
