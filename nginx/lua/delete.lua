local patch = "/store/upload/"

--local json = require("resty.json")

local cjson = require "cjson"

ngx.header.content_type = 'application/json';

local function file_exists(path)
    local file = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
end

--local get_post_args = ngx.req.get_post_args
ngx.req.read_body()
local raw_data = ngx.req.get_body_data()
local data = cjson.decode(raw_data) 

local res = {}
local res_err_count = 0

for key, val in pairs(data) do
    r, err = os.remove(patch..val)
    res[val] = {res=r and r or false, error = err and err or ''}
    if not r then
        res_err_count = res_err_count +1
    end
end

if res_err_count > 0 then
    ngx.status = 404
end

ngx.say( cjson.encode(res) )
return
