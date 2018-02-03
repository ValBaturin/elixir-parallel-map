defmodule ResultCollector do
    def collect(n, dad_pid) do
        spawn(fn -> receiver(n, [], dad_pid)end)
    end

    def receiver(collection_size, acc, dad_pid)
        when collection_size == length(acc) do
            IO.puts "RECEIVER GOT :finish"
            send dad_pid, {:finish, acc}
        end

    def receiver(collection_size, acc, dad_pid)
        when collection_size > length(acc) do
        receive do
            {:ok, result} ->
                receiver(collection_size, acc ++ result, dad_pid)
        end
    end
end
