local function find_request_start()
  return vim.fn.search("^grpc", "cbn", 1)
end
local function read_request_args(pos)
  local line = vim.fn.getline(pos)
  local parts = vim.fn.split(line, " ")
  assert((#parts > 1))
  assert((string.lower(parts[1]) == "grpc"))
  table.remove(parts, 1)
  return parts
end
local function read_request_data(pos)
  local stop = vim.fn.line("$")
  local read
  local function _1_(pos0, lines)
    if (pos0 > stop) then
      return lines
    else
      local _2_ = vim.fn.getline(pos0)
      if (_2_ == "") then
        return lines
      elseif (nil ~= _2_) then
        local line = _2_
        local function _3_()
          if lines then
            table.insert(lines, line)
            return lines
          else
            return {line}
          end
        end
        return read((pos0 + 1), _3_())
      else
        return nil
      end
    end
  end
  read = _1_
  return read(pos)
end
local function request_from_cursor()
  local cursor_line = vim.fn.getcurpos()[2]
  local start = find_request_start()
  if (start > 0) then
    return {args = read_request_args(start), data = read_request_data((start + 1))}
  else
    return nil
  end
end
return {["request-from-cursor"] = request_from_cursor}
