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
        micro.InfoBar:Error("ReadDir failed: " .. (err or "unknown"))
        return
    end

    local fileCount = #files
    if fileCount == 0 then
        micro.InfoBar:Message("Directory is empty.")
        return
    end

    local list = "Files in " .. dir .. ":\n"
	for i = 1, fileCount do
	    local f = files[i]
	    if f then
	        list = list .. i .. ". " .. f:Name() .. (f:IsDir() and "/" or "") .. "\n"
	    end
	end
    list = list .. "\nType :openfile <n> to open one.\n"

	local newBuf = buffer.NewBuffer(list, "fileexplorer.list")
    bp:VSplitIndex(newBuf, true)

    explorer_files = files
    explorer_dir = dir
end

function openfile(bp, args)
    local index = tonumber(args[1])
    if not index or not explorer_files or not explorer_files[index] then
        micro.InfoBar:Error("Invalid file index")
        return
    end

    local selected = explorer_files[index]
    local fullpath = filepath.Join(explorer_dir, selected.Name)
    bp:HSplitIndex(micro.OpenBuffer(fullpath), true)
end

function init()
    config.MakeCommand("explorer", explorer, config.NoComplete)
    config.MakeCommand("openfile", openfile, config.CompleteFiles)
end
