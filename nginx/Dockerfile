FROM ubuntu:latest

RUN DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    #apt dist-upgrade -y && \
    apt install -y nginx-extras lua5.1 luarocks git-core ca-certificates gettext-base curl && \
    rm -rf /var/cache/apt && rm -rf /var/lib/apt

RUN luarocks install lua-cjson \
&& luarocks install lua-resty-string \
&& luarocks install lua-resty-jwt \
&& luarocks install lua-resty-upload


CMD ["nginx", "-g", "daemon off;"]

