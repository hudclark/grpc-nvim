local api = vim.api
local buffer = require("grpc-nvim.buffer")
local Job = require("plenary.job")
local request = require("grpc-nvim.request")
local buffer_name = "grpc_nvim_results"
local function append_to_buf_cb(buf)
  local function _1_(_241, _242)
    return api.nvim_buf_set_lines(buf, -1, -1, false, {_242})
  end
  return _1_
end
local function execute_request(request0, buf)
  local cb = vim.schedule_wrap(append_to_buf_cb(buf))
  local data_args
  if request0.data then
    data_args = {"-d", table.concat(request0.data, "\n")}
  else
    data_args = {}
  end
  local job = Job:new({command = "grpcurl", args = vim.fn.extend(data_args, request0.args), on_stdout = cb, on_stderr = cb})
  if (-1 == vim.fn.bufwinnr(buf)) then
    vim.cmd(("vert sb" .. buf))
  else
  end
  api.nvim_buf_set_option(buf, "modifiable", true)
  return job:start()
end
local function make_result_header(request0)
  local function _4_(_241)
    return ("// " .. _241)
  end
  local function _5_()
    if request0.data then
      return request0.data
    else
      return {}
    end
  end
  return vim.fn.extend({("// grpcurl " .. table.concat(request0.args, " "))}, vim.tbl_map(_4_, _5_()))
end
local function execute_under_cursor()
  local _6_ = request["request-from-cursor"]()
  if (_6_ == nil) then
    return api.nvim_err_writeln("Failed to create request")
  elseif (nil ~= _6_) then
    local req = _6_
    local buf = buffer["get-or-create-tmp"](buffer_name)
    local header = make_result_header(req)
    api.nvim_buf_set_lines(buf, 0, -1, false, header)
    return execute_request(req, buf)
  else
    return nil
  end
end
return {["execute-under-cursor"] = execute_under_cursor}
