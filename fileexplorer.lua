VERSION = "0.1.0"

local micro = import("micro")
local config = import("micro/config")
local os = import("os")
local filepath = import("filepath")
local ioutil = import("ioutil")
local buffer = import("micro/buffer")

function explorer(bp)
    local path = bp.Buf.Path or "."
    local dir = filepath.Dir(path)

    local files, err = ioutil.ReadDir(dir)
    if not files then
        micro.InfoBar():Error("ReadDir failed: " .. (err or "unknown"))
        return
    end

    -- Separate dirs and files
    local dirs, regular = {}, {}
    for i = 1, #files do
        local f = files[i]
        if f:IsDir() then
            table.insert(dirs, f)
        else
            table.insert(regular, f)
        end
    end

    -- Merge dirs and files into one list
    local sorted = {}
    for _, v in ipairs(dirs) do table.insert(sorted, v) end
    for _, v in ipairs(regular) do table.insert(sorted, v) end

    explorer_files = sorted
    explorer_dir = dir

    -- Build list
    local list = "Files in " .. dir .. ":\n"
    for i, f in ipairs(sorted) do
        local label = ""
        if f:IsDir() then
            label = "[dir]  " .. f:Name() .. "/"
        else
            local size = f:Size()
            local kb = string.format("%.1f KB", size / 1024)
            label = string.format("       %-20s (%s)", f:Name(), kb)
        end
        list = list .. string.format("%2d. %s\n", i, label)
    end

    -- Open in new vertical pane
    local buf = buffer.NewBuffer(list, "filelist.txt")
    bp:VSplitIndex(buf, true)
end

  
function init()
    config.MakeCommand("explorer", explorer, config.NoComplete)
    config.MakeCommand("openfile", openfile, config.CompleteFiles)
end
