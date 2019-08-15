local patch = "/upload/"

local json = require("resty.json")

ngx.header.content_type = 'application/json';

local function file_exists(path)
    local file = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
end

--local get_post_args = ngx.req.get_post_args
ngx.req.read_body()
local raw_data = ngx.req.get_body_data()
local data = json.decode(raw_data) 

--ngx.log(ngx.STDERR, json_data[2])
local not_exist = {}
local not_exist_count = 0


for key, val in pairs(data) do

    if not file_exists(patch..val) then
        not_exist_count = not_exist_count + 1
        not_exist[not_exist_count] = val        
    end

end

--ngx.log(ngx.STDERR, 'err count = ', #err)

if not_exist_count > 0 then
    ngx.status = 404
    ngx.say( json.encode(not_exist) )
    return
end

local res = {}
local res_err_count = 0

for key, val in pairs(data) do
    r, err = os.remove(patch..val)
    res[val] = {res=r, error = err}
    if not r then
        res_err_count = res_err_count +1
    end
end

if res_err_count > 0 then
    ngx.status = 404
end

ngx.say( json.encode(res) )
return
