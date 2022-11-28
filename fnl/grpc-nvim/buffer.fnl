(local api vim.api)

;; Tracks the current buffer.

(fn get-or-create-tmp [name]
  (match (vim.fn.bufnr name)
    ;; Buffer does not exist. Create one now.
    -1 (let [buf (api.nvim_create_buf false "nomodeline")]
	 (api.nvim_buf_set_name buf name)
	 (api.nvim_buf_set_option buf "buftype" "nofile")
	 (api.nvim_buf_set_option buf "ft" "proto")
	 buf)
    ;; Buffer already exists.
    buf buf))

{: get-or-create-tmp}
