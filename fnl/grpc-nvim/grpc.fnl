(local api vim.api)
(local buffer (require "grpc-nvim.buffer"))
(local Job (require "plenary.job"))
(local request (require "grpc-nvim.request"))

;; The buffer we'll use to hold GRPC responses.
(local buffer-name "grpc_nvim_results")

;; Returns a callback that appends a job's output to the
;; given buffer.
(fn append-to-buf-cb [buf]
  #(api.nvim_buf_set_lines buf -1 -1 false [$2]))

(fn execute-request [request buf]
  (let [
	cb (vim.schedule_wrap (append-to-buf-cb buf))
	data-args (if request.data
		      ["-d" (table.concat request.data "\n")]
		      [])
	job (Job:new {:command "grpcurl"
			   :args (vim.fn.extend data-args request.args)
			   :on_stdout cb
			   :on_stderr cb})]
    ;; Open the buffer in a split, if not already open
    (when (= -1 (vim.fn.bufwinnr buf))
      (vim.cmd (.. "vert sb" buf)))
    ;; Make the buffer modifiable.
    (api.nvim_buf_set_option buf "modifiable" true)
    ;; Start the job
    (job:start)))

(fn make-result-header [request]
  (vim.fn.extend
    ;; Write the command
    [(.. "// grpcurl " (table.concat request.args " "))]
    ;; Write the request's data
    (vim.tbl_map #(.. "// " $1)
		 (if request.data request.data []))))

(fn execute-under-cursor []
  (match (request.request-from-cursor)
    nil (api.nvim_err_writeln "Failed to create request")
    req (let [buf (buffer.get-or-create-tmp buffer-name)
	      header (make-result-header req)]
	  ;; Highlight the request we've pulled
	  (buffer.highlight-range (vim.api.nvim_get_current_buf)
				  (api.nvim_create_namespace "grpc-nvim")
				  req.start
				  req.end
				  500)
	  ;; Write a header to the buffer
	  (api.nvim_buf_set_lines buf 0 -1 false header)
	  (execute-request req buf))))

{: execute-under-cursor}
