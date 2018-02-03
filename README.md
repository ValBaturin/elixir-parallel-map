### EDGE CASE
`c "taskAssigner.ex"; c "resultCollector.ex"; c "parallel.ex"; Parallel.map([1], &(&1 * 10))`
### BASIC CASE
`c "taskAssigner.ex"; c "resultCollector.ex"; c "parallel.ex"; Parallel.map([1, 2, 3, 4], &(&1 * 10))`

