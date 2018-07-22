FROM kong:0.13.1-alpine
COPY . /usr/local/share/lua/5.1/kong/plugins/middleman/
WORKDIR /usr/local/share/lua/5.1/kong/plugins/middleman
RUN mv -f nginx_kong.lua /usr/local/share/lua/5.1/kong/templates/
RUN cp src/* . &&\
luarocks make *.rockspec
ENV KONG_CUSTOM_PLUGINS = "middleman"