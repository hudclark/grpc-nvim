local function find_request_start()
  return vim.fn.search("^grpc", "cbn", 1)
end
local function read_request_args(pos)
  local function parse(itr, cur, args, in_str_3f)
    local _1_ = itr()
    if (_1_ == nil) then
      if in_str_3f then
        return error("Unclosed string")
      else
        if (#cur > 0) then
          table.insert(args, cur)
        else
        end
        return args
      end
    elseif (_1_ == "\"") then
      if in_str_3f then
        table.insert(args, cur)
        return parse(itr, "", args)
      elseif (0 == #cur) then
        return parse(itr, "", args, true)
      else
        return error("Invalid string argument")
      end
    elseif (_1_ == " ") then
      if in_str_3f then
        return parse(itr, (cur .. " "), args, true)
      else
        if (#cur > 0) then
          table.insert(args, cur)
        else
        end
        return parse(itr, "", args)
      end
    elseif (nil ~= _1_) then
      local other = _1_
      return parse(itr, (cur .. other), args, in_str_3f)
    else
      return nil
    end
  end
  local line = vim.fn.getline(pos)
  local prefix = line:sub(1, 4)
  local suffix = line:sub(5)
  if ("grpc" == prefix:lower()) then
    return parse(suffix:gmatch("."), "", {})
  else
    return nil
  end
end
local function read_request_data(pos)
  local stop = vim.fn.line("$")
  local read
  local function _9_(pos0, lines)
    if (pos0 > stop) then
      return lines
    else
      local _10_ = vim.fn.getline(pos0)
      if (_10_ == "") then
        return lines
      elseif (nil ~= _10_) then
        local line = _10_
        local function _11_()
          if lines then
            table.insert(lines, line)
            return lines
          else
            return {line}
          end
        end
        return read((pos0 + 1), _11_())
      else
        return nil
      end
    end
  end
  read = _9_
  return read(pos)
end
local function request_from_cursor()
  local _14_ = find_request_start()
  if (_14_ == -1) then
    return nil
  elseif (nil ~= _14_) then
    local start = _14_
    local args = read_request_args(start)
    local data = read_request_data((start + 1))
    local _end
    local function _15_()
      if data then
        return #data
      else
        return 0
      end
    end
    _end = (start + _15_())
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