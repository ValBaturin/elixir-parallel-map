defmodule Parallel do
    def map(collection, func) do
        nodes = Enum.take(Stream.cycle([ node() | Node.list ]),
                          length(collection))
        receiver_pid = spawn(__MODULE__, :receiver,
                            [length(collection), [], self()])
        enumerated = collection |> Enum.with_index
        spawn(__MODULE__, :launch_loop, [enumerated, func, nodes, receiver_pid])
        receive do
            {:finish, response} -> List.keysort(response, 1) |>
                                    Enum.map(fn x -> elem(x, 0) end)
        end
    end

    def receiver(collection_size, acc, dad_pid)
        when collection_size == length(acc) do
            send dad_pid, {:finish, acc}
        end

    def receiver(collection_size, acc, dad_pid)
        when collection_size > length(acc) do
        receive do
            {:ok, result} ->
                receiver(collection_size, acc ++ result, dad_pid)
        end
    end

    def launch_loop([ current_elem | elems_tail ], func,
    [current_node | nodes_tail], receiver_pid) do
        Node.spawn(current_node, __MODULE__, :launch, [receiver_pid, current_elem, func])
        launch_loop(elems_tail, func, nodes_tail, receiver_pid)
    end

    def launch_loop([], _func, [], _pid), do: nil

    def launch(dispatcher, elem, func) do
        send(dispatcher, {:ok, List.wrap({func.(elem(elem, 0)), elem(elem, 1)})})
    end

