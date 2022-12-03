local api = vim.api
local function get_or_create_tmp(name)
  local _1_ = vim.fn.bufnr(name)
  if (_1_ == -1) then
    local buf = api.nvim_create_buf(false, "nomodeline")
    api.nvim_buf_set_name(buf, name)
    api.nvim_buf_set_option(buf, "buftype", "nofile")
    api.nvim_buf_set_option(buf, "ft", "proto")
    return buf
  elseif (nil ~= _1_) then
    local buf = _1_
    return buf
  else
    return nil
  end
end
local function highlight_range(buf, ns, start, _end, duration)
  vim.highlight.range(buf, ns, "Visual", {(start - 1), 0}, {_end, 0}, {inclusive = true})
  local function _3_()
    return api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end
  return vim.defer_fn(_3_, duration)
end
return {["get-or-create-tmp"] = get_or_create_tmp, ["highlight-range"] = highlight_range}