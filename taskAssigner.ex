defmodule TaskAssigner do
    def start do
        spawn(fn -> loop(%{}) end)
    end

    def loop(current) do
        new = receive do
            message -> process(current, message)
        end
        loop(new)
    end

    def assign_task(pid, node, task) do
        send(pid, {:assign, node, task})
    end

    def get_tasks(pid, node) do
        send(pid, {:get_tasks, node, self()})
        receive do
        {:response, tasks} -> tasks
        end
    end

    defp process(current, {:assign, node, task}) do
        new_task = MapSet.new() |> MapSet.put(task)
        tasks = Map.get(current, node)
        cond do
            tasks == nil -> Map.put(current, node, new_task)
            true -> Map.put(current, node, MapSet.union(
                                        new_task, tasks))
        end
    end

    defp process(current, {:get_tasks, node, caller}) do
        send(caller, {:response, Map.get(current, node)})
        current
    end
end
