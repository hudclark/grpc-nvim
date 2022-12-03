(let [{: build} (require :hotpot.api.make)]
  (build "./fnl" {:atomic? true :force? true}
         "(.+)/fnl/(.+)"
         (fn default [head tail {: join-path}]
	   (join-path head :lua tail))))
