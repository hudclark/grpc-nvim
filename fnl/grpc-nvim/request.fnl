(fn find-request-start []
  "Returns the line number of the closest line behind the cursor that starts with 'grpc'"
  (vim.fn.search :^grpc :cbn 1))

(fn read-request-args [pos]
  "Read arguments from a line starting with 'grpc'"

  (fn parse [itr cur args in-str?]
    ;; Get the next char from the line
    (match (itr)
      ;; Base case: reached end of line.
      nil (if
           ;; Were we within a quoted string?
           in-str?
           (error "Unclosed string")
           (do
             ;; Add cur if not empty
             (when (> (length cur) 0)
               (table.insert args cur))
             args))
      ;; Hit a quotation mark
      "\"" (if
             ;; Closing a string
             in-str?
             (do
               (table.insert args cur)
               (parse itr "" args))
             ;; Starting a new string. Make sure that cur is empty
             (= 0 (length cur))
             (parse itr "" args true)
             (error "Invalid string argument"))
      ;; Hit whitespace
      " " (if
            ;; If we're in a string, do not start a new arg
            in-str?
            (parse itr (.. cur " ") args true)
            ;; Otherwise, store the new arg and recurse
            (do
              (when (> (length cur) 0)
                (table.insert args cur))
              (parse itr "" args)))
      ;; Normal case
      other (parse itr (.. cur other) args in-str?)))

  ;; Ensure the line starts with 'grpc'.
  (let [line (vim.fn.getline pos)
        prefix (line:sub 1 4)
        suffix (line:sub 5)]
    ;; Verify that the line starts with "grpc"
    (if (= :grpc (prefix:lower))
        (parse (suffix:gmatch ".") "" [])
        nil)))

(fn read-request-data [pos]
  "Reads JSON data starting from pos"
  (let [stop (vim.fn.line "$")
        read (fn [pos lines]
               (if (> pos stop) lines
                   (match (vim.fn.getline pos)
                     "" lines
                     line (read (+ pos 1)
                                (if lines
                                    (do
                                      (table.insert lines line)
                                      lines)
                                    [line])))))]
    (read pos)))

(fn request-from-cursor []
  "Returns a request if the cursor is within its bounds, nil otherwise"
  (match (find-request-start)
    ;; Failed to find the start of a request
    -1
    nil
    start
    (let [args (read-request-args start)
          data (read-request-data (+ start 1))
          end (+ start (if data (length data) 0))
          cursor (. (vim.fn.getcurpos) 2)]
      ;; Ensure that the cursor is actually within the bounds
      ;; of the request.
      (if (<= cursor end) {: start : end : args : data} nil))))

{: request-from-cursor}
