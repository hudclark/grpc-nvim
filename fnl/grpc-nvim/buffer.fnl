(local api vim.api)

(fn get-or-create-tmp [name]
  "Returns the named buffer or creates a new one"
  (match (vim.fn.bufnr name)
    ;; Buffer does not exist. Create one now.
    -1
    (let [buf (api.nvim_create_buf false :nomodeline)]
      (api.nvim_buf_set_name buf name)
      (api.nvim_buf_set_option buf :buftype :nofile)
      (api.nvim_buf_set_option buf :ft :javascript)
      buf)
    ;; Buffer already exists.
    buf
    buf))

(fn highlight-range [buf ns start end duration]
  "Highlights the range (inclusive) for a specified duration"
  (vim.highlight.range buf ns :Visual [(- start 1) 0] [end 0] {:inclusive true})
  (vim.defer_fn #(api.nvim_buf_clear_namespace buf ns 0 -1) duration))

{: get-or-create-tmp : highlight-range}
