return {
  no_consumer = true,
  fields = {
    url = {required = true, type = "string"},
    payload_key = {type = "string", default = "token"},
    header_lable = {type = "string", default = "authorization"}
  }
}

