local grpc = require("grpc-nvim.grpc")

vim.api.nvim_create_user_command("Grpc", function () grpc['execute-under-cursor']() end, {})
