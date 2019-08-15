--local cjson = require "cjson"
--ngx.say("read: ", cjson.encode({os.getenv("JWT_SECRET")}))


--local cjson = require "cjson"

--ngx.header["Content-Type"] = "text/plain"
--ngx.say("TEST success")
--[[ 
local resty_md5 = require "resty.md5"
    local md5 = resty_md5:new()
    if not md5 then
        ngx.say("failed to create md5 object")
        return
    end

    local ok = md5:update("hel")
    if not ok then
        ngx.say("failed to add data")
        return
    end

    ok = md5:update("lo")
    if not ok then
        ngx.say("failed to add data")
        return
    end

    local digest = md5:final()

    local str = require "resty.string"
    ngx.say("md5: ", str.to_hex(digest))
 ]]

 ngx.say("Hello!")