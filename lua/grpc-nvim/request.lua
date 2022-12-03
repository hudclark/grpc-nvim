local function find_request_start()
  return vim.fn.search("^grpc", "cbn", 1)
end
local function read_request_args(pos)
  local _1_ = vim.fn.split(vim.fn.getline(pos), " ")
  local function _2_()
    local cmd = (_1_)[1]
    local args = {select(2, (table.unpack or _G.unpack)(_1_))}
    return (string.lower(cmd) == "grpc")
  end
  if (((_G.type(_1_) == "table") and (nil ~= (_1_)[1])) and _2_()) then
    local cmd = (_1_)[1]
    local args = {select(2, (table.unpack or _G.unpack)(_1_))}
    return args
  elseif true then
    local _ = _1_
    return nil
  else
    return nil
  end
end
local function read_request_data(pos)
  local stop = vim.fn.line("$")
  local read
  local function _4_(pos0, lines)
    if (pos0 > stop) then
      return lines
    else
      local _5_ = vim.fn.getline(pos0)
      if (_5_ == "") then
        return lines
      elseif (nil ~= _5_) then
        local line = _5_
        local function _6_()
          if lines then
            table.insert(lines, line)
            return lines
          else
            return {line}
          end
        end
        return read((pos0 + 1), _6_())
      else
        return nil
      end
    end
  end
  read = _4_
  return read(pos)
end
local function request_from_cursor()
  local _9_ = find_request_start()
  if (_9_ == -1) then
    return nil
  elseif (nil ~= _9_) then
    local start = _9_
    local args = read_request_args(start)
    local data = read_request_data((start + 1))
    local _end
    local function _10_()
      if data then
        return #data
      else
        return 0
      end
    end
    _end = (start + _10_())
    local cursor = vim.fn.getcurpos()[2]
    if (cursor <= _end) then
      return {start = start, ["end"] = _end, args = args, data = data}
    else
      return nil
    end
  else
    return nil
  end
end
return {["request-from-cursor"] = request_from_cursor}