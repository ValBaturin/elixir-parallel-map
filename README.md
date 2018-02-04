## DO NOT FOTGET TO SET UP SEVERAL NODES AND CONNECT THEM
Don't forget cookie and to compile libs on every node.
### USEFUL COMMANDS:
`Node.list` checks connection

`node` prints a name of a node

`Node.connect "node_name"` connects host to "node_name" and vise versa
### COMPILATION
`c "taskAssigner.ex"; c "resultCollector.ex"; c "parallel.ex"`
### EDGE CASE
`Parallel.map([1], &(&1 * 10))`
### BASIC CASE
`Parallel.map([1, 2, 3, 4], &(&1 * 10))`
### NODE DIES CASE
You have to kill a node to check task relaunch feature.

`Parallel.map([1, 2, 3, 4], &(&1 * :timer.sleep(&1 * 1000))`
