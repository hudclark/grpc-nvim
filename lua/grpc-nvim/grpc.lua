local api = vim.api
local buffer = require("grpc-nvim.buffer")
local Job = require("plenary.job")
local request = require("grpc-nvim.request")
local buffer_name = "grpc_nvim_results"
local spinner_frames = {"\226\160\139", "\226\160\153", "\226\160\185", "\226\160\184", "\226\160\188", "\226\160\180", "\226\160\166", "\226\160\167", "\226\160\135", "\226\160\143"}
local namespace = api.nvim_create_namespace("grpc-nvim")
local function append_to_buf_cb(buf)
  local function _1_(_241, _242)
    return api.nvim_buf_set_lines(buf, -1, -1, false, {_242})
  end
  return _1_
end
local function draw_spinner(buf, text, id)
  local function _2_()
    if id then
      return {id = id}
    else
      return {}
    end
  end
  return api.nvim_buf_set_extmark(buf, namespace, 0, 0, vim.tbl_extend("force", {virt_text_pos = "eol", hl_mode = "combine", virt_text = {text}}, _2_()))
end
local function start_spinner(buf)
  local extmark = draw_spinner(buf, {spinner_frames[1], "Comment"})
  local timer = vim.loop.new_timer()
  local frame = 1
  local function _3_()
    if (frame < #spinner_frames) then
      frame = (frame + 1)
    else
      frame = 1
    end
    draw_spinner(buf, {spinner_frames[frame], "Comment"}, extmark)
    return vim.cmd("redraw")
  end
  timer:start(0, 150, vim.schedule_wrap(_3_))
  return {extmark = extmark, timer = timer, frame = frame}
end
local function spinner_finish(buf, exit_code, spinner)
  do end (spinner.timer):close()
  local _5_
  if (0 == exit_code) then
    _5_ = {"\226\156\147", "Comment"}
  else
    _5_ = {"\226\156\151", "WarningMsg"}
  end
  return draw_spinner(buf, _5_, spinner.extmark)
end
local function execute_request(request0, buf)
  local cb = vim.schedule_wrap(append_to_buf_cb(buf))
  local data_args
  if request0.data then
    data_args = {"-d", table.concat(request0.data, "\n")}
  else
    data_args = {}
  end
  local spinner = start_spinner(buf)
  local job
  local function _8_(_241, _242)
    return spinner_finish(buf, _242, spinner)
  end
  job = Job:new({command = "grpcurl", args = vim.fn.extend(data_args, request0.args), on_stdout = cb, on_stderr = cb, on_exit = vim.schedule_wrap(_8_)})
  if (-1 == vim.fn.bufwinnr(buf)) then
    vim.cmd(("vert sb" .. buf))
  else
  end
  api.nvim_buf_set_option(buf, "modifiable", true)
  return job:start()
end
local function make_result_header(request0)
  local function _10_(_241)
    return ("// " .. _241)
  end
  local function _11_()
    if request0.data then
      return request0.data
    else
      return {}
    end
  end
  return vim.fn.extend({("// grpcurl " .. table.concat(request0.args, " "))}, vim.tbl_map(_10_, _11_()))
end
local function execute_under_cursor()
  local _12_ = request["request-from-cursor"]()
  if (_12_ == nil) then
    return api.nvim_err_writeln("Failed to create request")
  elseif (nil ~= _12_) then
    local req = _12_
    local buf = buffer["get-or-create-tmp"](buffer_name)
    local header = make_result_header(req)
    buffer["highlight-range"](vim.api.nvim_get_current_buf(), api.nvim_create_namespace("grpc-nvim"), req.start, req["end"], 500)
    api.nvim_buf_set_lines(buf, 0, -1, false, header)
    return execute_request(req, buf)
  else
    return nil
  end
end
return {["execute-under-cursor"] = execute_under_cursor}