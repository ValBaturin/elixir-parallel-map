defmodule Parallel do
    require TaskAssigner
    require ResultCollector

    def map(collection, func) do
        nodes = [node() | Node.list]
        tasks = collection |> Enum.with_index
        assignee = TaskAssigner.start
        collector = ResultCollector.start
        distributor(nodes, tasks, func, assignee, collector)
        spawn(fn -> troubleshooter(nodes, assignee, collector, func) end)
        result = ResultCollector.get_tasks_results(collector,
                                                    length(collection))
        List.keysort(result, 1) |> Enum.map(fn x -> elem(x, 0) end)
    end

    def troubleshooter(nodes, assignee, collector, func) do
        check(nodes, assignee, collector, func)
        :timer.sleep(5000)
        troubleshooter([node() | Node.list], assignee, collector, func)
    end

    def check([node_h | node_t], assignee, collector, func) do
        fix({Node.ping(node_h), node_h}, assignee, collector, func)
        check(node_t, assignee, collector, func)
    end

    def check([], _assignee, _collector, _func), do: nil

    def fix({:pang, broken}, assignee, collector, func) do
        tasks = TaskAssigner.get_tasks(assignee, broken)
        failed_tasks = ResultCollector.get_current_tasks(collector)
        tasks_to_retry = MapSet.difference(tasks, failed_tasks)
        distributor([node() | Node.list], tasks_to_retry,
                    func, assignee, collector)
        end

    def fix({:pong, _node}, _assignee, _collector, _func), do: nil

    def distributor(nodes, tasks, func, assignee, collector) do
        node_per_task = Enum.take(Stream.cycle(nodes), length(tasks))
        assign_loop(node_per_task, tasks, assignee)
        launch_tasks(nodes, assignee, func, collector)
    end

    def assign_loop([node_h | node_t], [task_h | task_t], assignee) do
        TaskAssigner.assign_task(assignee, node_h, task_h)
        assign_loop(node_t, task_t, assignee)
    end

    def assign_loop([], [], _assignee), do: nil

    def launch_tasks([current_node | rest], assignee, func, collector) do
        tasks = TaskAssigner.get_tasks(assignee, current_node)
        if tasks == nil do
            nil
        else
            tasks = MapSet.to_list(tasks)
            launch_machine(current_node, tasks, func, collector)
            launch_tasks(rest, assignee, func, collector)
        end
    end

    def launch_tasks([], _assignee, _func, _collector), do: nil

    def launch_machine(node, [collection_h | collection_t],
                        func, collector) do
        Node.spawn(node, __MODULE__, :launch, [collection_h, func, collector])
        launch_machine(node, collection_t, func, collector)
    end

    def launch_machine(_node, [], _func, _collector), do: nil

    def launch(elem, func, collector) do
        ResultCollector.send_result(collector,
             {func.(elem(elem, 0)), elem(elem, 1)})
    end
end
