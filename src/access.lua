local responses = require "kong.tools.responses"
local http = require"socket.http"
local ltn12 = require"ltn12"
local JSON = require "kong.plugins.middleman.json"

local get_headers = ngx.req.get_headers
local set_header =  ngx.req.set_header
local get_uri_args = ngx.req.get_uri_args
local read_body = ngx.req.read_body
local get_body = ngx.req.get_body_data
local ngx_log = ngx.log
local ngx_log_DBG = ngx.DEBUG

local _M = {}

function _M.execute(conf)
    local post_url = conf.url
    local payload = _M.compose_payload()

    local response_body = {}

    local res, code, response_headers, status = http.request
        {
            url = post_url,
            method = "POST",
            headers = _M.compose_headers(payload:len()),
            source = ltn12.source.string(payload),
            sink = ltn12.sink.table(response_body)
        }


    if code > 299 then
        return responses.send(code,table.concat(response_body))
    end

    _M.set_header_payload(response_body,conf.header_lable,conf.payload_key)

    ngx_log(ngx_log_DBG, "[middleman-plugin] after header injection #1,  get_headers:" .. table.concat(get_headers()))
end

function _M.set_header_payload(payload,lable,key)
    local payload_json = JSON:decode(payload[1])
    ngx_log(ngx_log_DBG,"[middleman-plugin] (set_header_payload), payload:" .. table.concat(payload) .. "| lable:" .. lable .. "| key:" .. key .. "| payload[key]:" .. payload_json[key])
    set_header(lable,payload_json[key]);
end

function _M.compose_headers(len)
    return {
        ["Content-Type"] = "application/json",
        ["Content-Length"] = len,
    }
end

function _M.compose_payload()
    local headers = get_headers()
    local uri_args = get_uri_args()
    read_body()
    local body_data = get_body()

    headers["target_uri"] = ngx.var.request_uri
    headers["target_method"] = ngx.var.request_method

    local raw_json_headers    = JSON:encode(headers)
    local raw_json_uri_args    = JSON:encode(uri_args)
    local raw_json_body_data    = JSON:encode(body_data)

    return [[ {"headers":]] .. raw_json_headers .. [[,"uri_args":]] .. raw_json_uri_args.. [[,"body_data":]] .. raw_json_body_data .. [[} ]]
end

return _M
