(fn find-request-start []
  "Returns the line number of the closest line behind the cursor that starts with 'grpc'"
  (vim.fn.search "^grpc" "cbn" 1))

(fn read-request-args [pos]
  (let [line (vim.fn.getline pos)
	parts (vim.fn.split line " ")]
    (assert (> (length parts) 1))
    (assert (= (string.lower (. parts 1)) "grpc"))
    ;; Drop the 'grpc' prefix from the line
    (table.remove parts 1)
    parts))

(fn read-request-data [pos]
  "Reads JSON data starting from pos"
  (let [stop (vim.fn.line "$")
	read (fn [pos lines]
	       (if (> pos stop) lines
		   (match (vim.fn.getline pos)
		     "" lines
		     line (read (+ pos 1)
				(if lines
				    (do (table.insert lines line) lines)
				    [line])))))]
    (read pos)))


(fn request-from-cursor []
  (let [cursor-line (. (vim.fn.getcurpos) 2)
	;; buf (vim.api.nvim_win_get_buf 0)
	start (find-request-start)]
    (if (> start 0)
	{:args (read-request-args start)
	:data (read-request-data (+ start 1))}
	nil)))

{: request-from-cursor}
