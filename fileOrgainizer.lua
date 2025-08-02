local file_types = {
    Images = {".jpg", ".jpeg", ".png", ".gif", ".bmp", ".pixil", ".psd", ".jng"},
    Documents = {".txt", ".pdf", ".docx", ".xlsx", ".pptx", ".md", ".doc"},
    Audio = {".mp3", ".wav", ".flac", ".ogg", ".aac", ".aif", ".aiff", ".m4a"},
    Videos = {".mp4", ".mkv", ".avi", ".mov"},
    Archives = {".zip", ".tar", ".rar", ".7z"},
    Java = {".java", ".jar", ".class"},
    Python = {".py", ".whl", ".egg", ".pyc", ".pyd"},
    Lua = {".lua"},
    CSS = {".css", ".scss"},
    TypeScript = {".ts"},
    Rust = {".rs"},
    C = {".c", ".h"},
    ["C++"] = {".cpp", ".hpp", ".C", ".cc", ".cxx"},
    Cython = {".pyx"},
    HTML = {".html", ".htm", ".html5", ".xhtml"},
    JavaScript = {".js", ".mjs", ".jsm", ".jsx"},
    Executables = {".exe", ".bat", ".bin", ".sh", ".url", ".lnk"},
    Installers = {".msi", ".apk", ".msp", ".mst"},
    ["3D Models"] = {".blend", ".fbx", ".obj", ".mtl", ".stl", ".3mf", ".ply", ".gltf", ".glb"},
    Other = {}
}

local function get_extension(filename)
    return filename:match("^.+(%..+)$"):lower()
end

local function table_contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

local function list_files(directory)
    local files = {}
    local pfile
    if package.config:sub(1,1) == "\\" then
        pfile = io.popen('dir "'..directory..'" /b /a-d')
    else
        pfile = io.popen('ls -p "'..directory..'" | grep -v /')
    end
    for filename in pfile:lines() do
        table.insert(files, filename)
    end
    pfile:close()
    return files
end

local function create_directory(directory)
    if package.config:sub(1,1) == "\\" then
        os.execute('mkdir "'..directory..'"')
    else
        os.execute('mkdir -p "'..directory..'"')
    end
end

local function move_file(src, dst)
    if package.config:sub(1,1) == "\\" then
        os.execute('move /Y "'..src..'" "'..dst..'"')
    else
        os.execute('mv -f "'..src..'" "'..dst..'"')
    end
end

local function organize_files(directory)
    local files_by_type = {}
    
    for category, _ in pairs(file_types) do
        files_by_type[category] = {}
    end
    
    local script_filename = arg[0]:match("[^/\\]+$")
    
    local files = list_files(directory)
    for _, file in ipairs(files) do
        if file ~= script_filename then
            local file_ext = get_extension(file)
            local categorized = false

            for category, extensions in pairs(file_types) do
                if table_contains(extensions, file_ext) then
                    table.insert(files_by_type[category], file)
                    categorized = true
                    break
                end
            end

            if not categorized then
                table.insert(files_by_type["Other"], file)
            end
        end
    end
    
    for category, files in pairs(files_by_type) do
        local category_folder = directory .. "/" .. category
        create_directory(category_folder)

        for _, file in ipairs(files) do
            local src = directory .. "/" .. file
            local dst = category_folder .. "/" .. file
            move_file(src, dst)
            print("Moving " .. file .. " to " .. category_folder)
        end
    end
end

local function main()
    while true do
        print("Enter the directory to organize (leave blank to use the current script's directory, type 'exit' to quit):")
        local directory = io.read()

        if directory:lower() == "exit" then
            print("Exiting the program.")
            break
        end

        if directory == "" then
            directory = "."
        end
        
        local success = os.execute('cd "'..directory..'"')
        if success then
            print("Organizing files in: " .. directory)
            organize_files(directory)
            print("Files have been organized.")
        else
            print("Invalid directory. Please try again.")
        end
        print("") -- Newline
    end
end

main()
