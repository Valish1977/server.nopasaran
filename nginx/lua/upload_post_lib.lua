
--ngx.log(ngx.STDERR, 'START')

local resty_post = require "resty.post"
local post = resty_post:new({
  path = "/upload/",
  name = function(name, field)
    --ngx.log(ngx.STDERR, name)
    return field
  end
})
--local m = post:read()
post:read()

ngx.log(ngx.STDERR, name)


--ngx.header["Content-Type"] = "text/plain"
--ngx.say("upload 1success")
--ngx.exit(200)
return