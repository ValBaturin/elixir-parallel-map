defmodule ResultCollector do
    def start do
        spawn(fn -> loop(MapSet.new) end)
    end

    def loop(current) do
        new = receive do
            message -> process(current, message)
        end
        loop(new)
    end

    def send_result(pid, result) do
        send(pid, {:ok, result})
    end

    def get_current_result(pid) do
        send(pid, {:current_results, self()})
        IO.puts "GETTING CURRENT TASKS"
        receive do
            {:current_results, result} -> result
        end
    end

    def get_tasks_results(pid, n) do
        send(pid, {:done?, n, self()})
        :timer.sleep(1000)
        receive do
            {:done, result} -> MapSet.to_list(result)
            {:not_ready} -> get_tasks_results(pid, n)
        end
    end

    defp process(current, {:ok, result}) do
        MapSet.put(current, result)
    end

    defp process(current, {:current_results, caller}) do
        send(caller, {:current_results, current})
        current
    end

    defp process(current, {:done?, n, caller}) do
        cond do
        MapSet.size(current) == n ->
            send(caller, {:done, current})
        MapSet.size(current) < n ->
            send(caller, {:not_ready})
        end
        current
    end

end
