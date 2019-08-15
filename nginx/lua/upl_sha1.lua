local resty_sha1 = require "resty.sha1"
local upload = require "resty.upload"
local cjson = require "cjson"
local str = require "resty.string"

local chunk_size = 4096
local patch = "/upload/"

local function my_get_file_name(header)
    local file_name
    local name

    for i, ele in ipairs(header) do
        
        file_name = string.match(ele, 'filename="(.*)"')
        ngx.say("file_name: ", file_name)

        name = string.match(ele, 'name="(.*)"')
        ngx.say("name: ", name)

        if file_name and file_name ~= "" then
            return patch .. file_name
        end
    end
    return nil
end

local form = upload:new(chunk_size)
local sha1 = resty_sha1:new()
local file

while true do
    local typ, res, err = form:read()

    if not typ then
        ngx.say("failed to read: ", err)
        return
    end

    --ngx.say("read: ", cjson.encode({typ, res}))

    if typ == "header" then
        local file_name = my_get_file_name(res)
        ngx.say("res file: ", file_name)

        if file_name then
            file = io.open(file_name, "w+")
            if not file then
                ngx.say("failed to open file ", file_name)
                return
            end
        end
    elseif typ == "body" then
        if file then
            file:write(res)
            sha1:update(res)
        end
    elseif typ == "part_end" then
        file:close()
        file = nil
        local sha1_sum = sha1:final()
        sha1:reset()
        ngx.say("sha1: ", str.to_hex(sha1_sum))
        --my_save_sha1_sum(sha1_sum)
        
    elseif typ == "eof" then
        break
    else
        -- do nothing
    end
end
