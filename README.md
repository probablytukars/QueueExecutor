# Roblox Queue Executor

A Roblox library for asynchronously executing functions as a Queue. The intention of this library is to make it easy to run functions that may otherwise crash Studio or your game, by executing the functions over many frames.
These will obviously be slower to evaluate than built-in implementations of control structures, so use this only where necessary, however this is still relatively fast.

## Example Usage

```lua
local queueExecutor = require(path.to.module)

queueExecutor.addToQueue(false, function()
	print("Hello World!")
end, function()
	print("Goodbye!")
end)

print("I think, therefore I am.")

queueExecutor.eval()

--Output:
-->> I think, therefore I am.
-->> Hello World!
-->> Goodbye!
```

## Features

- Add items to evaluation queue directly
- For loops (both iteration, and pairs)
- While loops (both while do, and do while)
- Control the maximum evaluation time the Queue can take per frame
- Pause and continue evaluation at any time
- Clear the queue at any time
- Get size of the queue at any time
- Set priority of when the queue evaluates (by default it's last)

## Documentation

In the below code `...` within a function definition represents code within a function.


- `queueExecutor.eval()`: Starts evaluation of the queue.

- `queueExecutor.stop()`: Stops evaluation of the queue.

- `queueExecutor.clear()`: Clears the queue.

- `queueExecutor.setPriority(newPriority: number)`: Sets the priority of the queue according to the `Enum.RenderPriority` Enum.

- `queueExecutor.setEvaluationTime(newEvaluationTime: number)`: Sets the maximum evaluation the queue can take per frame. For example, setting this to `1/30` would mean it could take up to 1/30th of a second per frame to evaluate functions on the stack. Numbers closer to zero keep the game framerate higher but evaluate less functions per frame, and numbers further from zero lower the framerate but evaluate more functions per frame.

- `queueExecutor.getSize(): number`: Returns the size of the queue.

- `queueExecutor.isPaused(): boolean`: Gets where the queue is paused of not, set by `.eval()` and `.stop()`.

- `queueExecutor.getEvaluationTime(): number`: Gets the evaluation time, set by `.setEvaluationTime()`, or the default value of 1/60.

- `queueExecutor.getPriority(): number`: Gets the priority of the queue, set by `.setPriority()`, or the default value of `Enum.RenderPriority.Last.Value`.

- `queueExecutor.addToQueue(insertBeginning: boolean, expression: (any) -> any, andThen: (any) -> ())`: Adds a function to to the queue. If `insertBeginning` is true, the function will be inserted at the beginning of the queue. If false, it will be inserted at the end of the queue. Once the function and all internal queued functions have completed (if any), the `andThen` function will be called. This is just like a callback in any other language. This may look like:

	`queueExecutor.addToQueue(false, function() ... end, function() ... end)`

- `queueExecutor.fori(startIndex: number, finalIndex: number, indexOffset: number, fncExec: (number) -> (), andThen: () -> ())`: This acts just like a regular iteration for loop (e.g. `for i = 1, 10 do`). This takes in 3 numbers, a function to be executed every iteration (which has the current iteration passed into it), and a callback function for when the loop has finished. This may look like: 

	`queueExecutor.fori(1, 10, 1, function(i) ... end, function() ... end)`.

- `queueExecutor.pairs(tab: { [a]: b }, fncExec: (string, any) -> (), andThen: () -> ())`: This acts like a pairs for loop (e.g `for k, v in pairs(tab) do`). This takes in a table (which can be either an array, or a dictionary), a function to be executed every iteration (which has the key and value of that iteration passed into it), and a callback function when the loop has finished. This may look like: 

	`queueExecutor.pairs(tab, function(k, v) ... end, function() ... end)`.

- `queueExecutor.ipairs(tab: { [a]: b }, fncExec: (number, any) -> (), andThen: () -> ())`: This acts like the above `pairs` function, except for each iteration, it returns the number of the current iteration instead of the current key. This may look like: 

	`queueExecutor.ipairs(tab, function(i, v) ... end, function() ... end)`.

- `queueExecutor.whileDo(condition: (any) -> boolean, fncExec: () -> (), andThen: () -> ())`: This acts just like a `while <condition> do` loop. This takes in three functions, a comparison function, a function to execute for each loop the comparison is true, and a callback function for when the while loop is finished. This will execute for as long as `condition` evaluates to true. This may look like: 

	`queueExecutor.whileDo(function() ... end,  function() ... end, function() ... end)`

- `queueExecutor.doWhile(condition: (any) -> boolean, fncExec: () -> (), andThen: () -> ())`: This is like the above function, except it will always execute the internal of the loop atleast once. This may look like: 

	`queueExecutor.doWhile(function() ... end,  function() ... end, function() ... end)`.


To do the equivalent of `break` inside of `fori`, `pairs`, and `ipairs`, use `return true` inside of the main loop function.

e.g:

```lua
queueExecutor.pairs(table, function(k, v)
	if k == "" then
		return true --equiv to break
	end
end, function()
	print("broken early")
end)
```

For a more thorough understanding of what the functions do and how to use them, a [documentation](docs.lua) file has been provided in this repository, showing you how you might use each of these functions.

## License

This project is licensed under the CC0 license.


