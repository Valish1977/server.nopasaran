local upload = require "resty.upload"
--local cjson = require "cjson"

local chunk_size = 4096
local upload_dir = "/store/upload/"

local file
local file_patch
local file_type

local form = upload:new(chunk_size)


local function my_get_file_name(data)
    local filename = string.match(data, 'filename="(.*)"')
    local name = string.match(data, 'name="(.*)";')
    if name and name ~= "" and filename and filename ~= "" then
        return name
    end
    return nil
end


while true do
    local ctype, res, err = form:read()

    if not ctype then
        ngx.status = 400
        ngx.say("failed to read: ", err)
        return
    end

    if ctype == "header" then
        local header, data = res[1], res[2]

        --ngx.say("header: ", header)
        --ngx.say("data: ", data)

        if header == "Content-Disposition" then
            local file_name = my_get_file_name(data)
            if file_name then
                file_patch = upload_dir .. file_name
                file = io.open(file_patch, "w+")
                if not file then
                    ngx.status = 400
                    ngx.say("failed to open file ", file_patch)
                    return
                end
            end
        end

        if header == "Content-Type" then
            file_type = data
        end

    end 
    
    if ctype == "body" then
        if file then
            file:write(res)
        end
    end

    if ctype == "part_end" then
        if file then
            file:close()
        end
        file = nil
    end

    if ctype == "eof" then
        break
    end
end
