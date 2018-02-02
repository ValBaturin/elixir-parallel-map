defmodule Parallel do
    require TaskAssigner
    require ResultCollector

    def map(collection, func) do
        nodes = [node() | Node.list]
        tasks = collection |> Enum.with_index
        return_pid = ResultCollector.collect(length(collection), self())
        assignee = TaskAssigner.start
        distributor(nodes, tasks, func, assignee, return_pid)
        IO.puts "WAIT FOR RECEIVE(MAIN)"
        receive do
            {:finish, response} -> List.keysort(response, 1) |>
                                Enum.map(fn x -> elem(x, 0) end)
        end
    end

    def distributor(nodes, tasks, func, assignee, return_pid) do
        IO.puts "DISTRIBUTION IS LAUNCHED"
        IO.inspect nodes
        IO.inspect tasks
        node_per_task = Enum.take(Stream.cycle(nodes), length(tasks))
        assign_loop(node_per_task, tasks, assignee)
        launch_tasks(nodes, assignee, func, return_pid)
    end

    def assign_loop([node_h | node_t], [task_h | task_t], assignee) do
        IO.puts "INTO ASSIGN LOOP"
        TaskAssigner.assign_task(assignee, node_h, task_h)
        assign_loop(node_t, task_t, assignee)
    end

    def assign_loop([], [], _assignee), do: nil

    def launch_tasks([current_node | rest], assignee, func, return_pid) do
        IO.puts "INTO LAUCNH TASKS"
        tasks = MapSet.to_list(TaskAssigner.get_tasks(assignee, current_node))
        IO.puts "FOR NODE"
        IO.inspect current_node
        IO.puts "TASKS FOR THE NODE ARE"
        IO.inspect tasks
        launch_machine(current_node, tasks, func, return_pid)
        launch_tasks(rest, assignee, func, return_pid)
    end

    def launch_tasks([], _assignee, _func, _return_pid), do: nil

    def launch_machine(node, [collection_h | collection_t],
                        func, return_pid) do
        Node.spawn(node, __MODULE__, :launch, [collection_h, func, return_pid])
        launch_machine(node, collection_t, func, return_pid)
    end

    def launch_machine(_node, [], _func, _return_pid), do: nil

    def launch(elem, func, return_pid) do
        IO.puts "TASK IS LAUNCHED"
        send(return_pid, {:ok,
            List.wrap({func.(elem(elem, 0)), elem(elem, 1)})})
    end
end
