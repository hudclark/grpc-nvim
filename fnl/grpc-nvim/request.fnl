(fn find-request-start []
  "Returns the line number of the closest line behind the cursor that starts with 'grpc'"
  (vim.fn.search "^grpc" "cbn" 1))

(fn read-request-args [pos]
  "Returns space-separated arguments on a line starting with 'grpc'"
  (match (vim.fn.split (vim.fn.getline pos) " ")
    (where [cmd & args] (= (string.lower cmd) "grpc")) args
    _ nil))

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
  "Returns a request if the cursor is within its bounds, nil otherwise"
  (match (find-request-start)
    ;; Failed to find the start of a request
    -1 nil
    start (let [args (read-request-args start)
		data (read-request-data (+ start 1))
	        end (+ start (if data (length data) 0))
		cursor (. (vim.fn.getcurpos) 2)]
	    ;; Ensure that the cursor is actually within the bounds
	    ;; of the request.
	    (if (<= cursor end)
		{: start : end : args : data}
		nil))))

{: request-from-cursor}
