(local api vim.api)
(local buffer (require :grpc-nvim.buffer))
(local Job (require :plenary.job))
(local request (require :grpc-nvim.request))

;; The buffer we'll use to hold GRPC responses.
(local buffer-name :grpc_nvim_results)

(local spinner-frames ["⠋"
                       "⠙"
                       "⠹"
                       "⠸"
                       "⠼"
                       "⠴"
                       "⠦"
                       "⠧"
                       "⠇"
                       "⠏"])

(local namespace (api.nvim_create_namespace :grpc-nvim))

(fn append-to-buf-cb [buf]
  "Returns a fn that appends the second argument to buf"
  #(api.nvim_buf_set_lines buf -1 -1 false [$2]))

(fn draw-spinner [buf text id]
  "Draw the spinner, returning the extmark id"
  (api.nvim_buf_set_extmark buf namespace 0 0
                            (vim.tbl_extend :force
                                            {:virt_text_pos :eol
                                             :hl_mode :combine
                                             :virt_text [text]}
                                            (if id {: id} {}))))

(fn start-spinner [buf]
  (let [extmark (draw-spinner buf [(. spinner-frames 1) :Comment])
        timer (vim.loop.new_timer)]
    (var frame 1)
    (timer:start 0 150
                 (vim.schedule_wrap (fn []
                                      (set frame
                                           (if (< frame (length spinner-frames))
                                               (+ frame 1)
                                               1))
                                      (draw-spinner buf
                                                    [(. spinner-frames frame)
                                                     :Comment]
                                                    extmark)
                                      (vim.cmd :redraw))))
    {: extmark : timer : frame}))

(fn spinner-finish [buf exit-code spinner]
  (spinner.timer:close)
  (draw-spinner buf (if (= 0 exit-code) ["✓" :Comment] ["✗" :WarningMsg])
                spinner.extmark))

(fn execute-request [request buf]
  (let [cb (vim.schedule_wrap (append-to-buf-cb buf))
        data-args (if request.data [:-d (table.concat request.data "\n")] [])
        spinner (start-spinner buf)
        job (Job:new {:command :grpcurl
                      :args (vim.fn.extend data-args request.args)
                      :on_stdout cb
                      :on_stderr cb
                      :on_exit (vim.schedule_wrap #(spinner-finish buf $2
                                                                   spinner))})]
    ;; Open the buffer in a split, if not already open
    (when (= -1 (vim.fn.bufwinnr buf))
      (vim.cmd (.. "vert sb" buf)))
    ;; Make the buffer modifiable.
    (api.nvim_buf_set_option buf :modifiable true)
    ;; Start the job
    (job:start)))

(fn make-result-header [request]
  (vim.fn.extend ;; Write the command
                 [(.. "// grpcurl " (table.concat request.args " "))]
                 ;; Write the request's data
                 (vim.tbl_map #(.. "// " $1) (if request.data request.data []))))

(fn execute-under-cursor []
  (match (request.request-from-cursor)
    nil (api.nvim_err_writeln "Failed to create request")
    req (let [buf (buffer.get-or-create-tmp buffer-name)
              header (make-result-header req)]
          ;; Highlight the request we've pulled
          (buffer.highlight-range (vim.api.nvim_get_current_buf)
                                  (api.nvim_create_namespace :grpc-nvim)
                                  req.start req.end 500)
          ;; Write a header to the buffer
          (api.nvim_buf_set_lines buf 0 -1 false header)
          (execute-request req buf))))

{: execute-under-cursor}
