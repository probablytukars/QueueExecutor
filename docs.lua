
local libs = script.Parent.Folder
local queueExecutor = require(libs.QueueExecutor)

print()
print("==============================")
print("     Basic Queue Functions    ")
print("==============================")
print()


--Getting the status of the queue:
print("Is paused:", queueExecutor.isPaused())

-->> Is paused: true

--Unpause the queue:
queueExecutor.eval()
print("Is paused:", queueExecutor.isPaused())

-->> Is paused: false

--Pause the queue again:
queueExecutor.stop()
print("Is paused:", queueExecutor.isPaused())

-->> Is paused: true


--Getting the size of the queue:
print("Size:", queueExecutor.getSize())

-->> Size: 0

--Lets add some stuff to the queue and then get the size

--These will not work, since `addToQueue` requires a function in the second argument
--However, we are not actually using these, so it is okay.
queueExecutor.addToQueue(true)
queueExecutor.addToQueue(true)
queueExecutor.addToQueue(true)

print("Size:", queueExecutor.getSize())

-->> Size: 3

--Clear the queue:

queueExecutor.clear()
print("Size:", queueExecutor.getSize())

-->> Size: 0


--Getting the evaluation time of the queue:
print("Evaluation Time:", queueExecutor.getEvaluationTime())

-->> Evaluation Time: 0.016666666666666666

--Setting the evaluation time of the queue:
queueExecutor.setEvaluationTime(1/30)
print("Evaluation Time:", queueExecutor.getEvaluationTime())

-->> Evaluation Time: 0.03333333333333333


--Getting the priority of the queue:
print("Priority:", queueExecutor.getPriority())

-->> Priority: 2000

--Setting the priority of the queue:
queueExecutor.setPriority(Enum.RenderPriority.Character.Value)
print("Priority:", queueExecutor.getPriority())

-->> Priority: 300



print()
print("==============================")
print("       Adding to Queue        ")
print("==============================")
print()

--Without these, the below functions will actually evaluate before the above
task.wait()


queueExecutor.addToQueue(true, function()
	local x, y = 5, 3
	print("<<| x, y:", x, y)
	return x, y
end, function(x, y)
	print("|>> x, y:", x, y)
end)

queueExecutor.addToQueue(false, function()
	print("And then, he remembered.")
end, function(x, y)
	print("Oh, wait, I'm on mars.")
end)

queueExecutor.addToQueue(true, function()
	print("Hello world!")
end, function()
	print("Goodbye!")
end)

print("We're about to evaluate!")

queueExecutor.eval()

--[[
	>> We're about to evaluate!
	>> Hello world!
	>> Goodbye!
	>> <<| x, y: 5 3
	>> |>> x, y: 5 3
	>> And, then, he remembered.
	>> Oh, wait, I'm on mars.
]]

task.wait()


--Nested add to queue:

queueExecutor.addToQueue(true, function()
	print("This is the outer queue function")
	queueExecutor.addToQueue(true, function() --It's very important that 'true' is used here.
		print("This is the inner queue.")
	end, function()
		print("Inner queue callback.")
	end)
end, function()
	print("Outer queue callback.")
end)

queueExecutor.eval()

--[[
	>> This is the outer queue function
	>> This is the inner queue.
	>> Inner queue callback.
	>> Outer queue callback.
]]

task.wait()


print()
print("==============================")
print("          For loops           ")
print("==============================")
print()

task.wait()

--An example of a for loop

--[[
	The below would typically look like:
	
	for i = 1, 3 do
		print("i:", i)
		for j = 1, 3 do
			print("--j:", j)
			if j == 3 then
				print("----inner added")
				print("----inner complete")
			end
		end
		print("--j complete")
	end
	print("i complete")
]]


queueExecutor.fori(1, 3, 1, function(i)
	print("i:", i)
	queueExecutor.fori(1, 3, 1, function(j)
		print("--j:", j)
		if j == 3 then
			queueExecutor.addToQueue(true, function()
				print("----inner added")
			end, function()
				print("----inner complete")
			end)
		end
	end, function()
		print("--j complete")
	end)
end, function()
	print("i complete")
end)

--[[
	>> i: 1
	>> --j: 1
	>> --j: 2
	>> --j: 3
	>> ----inner added
	>> ----inner complete
	>> --j complete
	>> i: 2
	>> --j: 1
	>> --j: 2
	>> --j: 3
	>> ----inner added
	>> ----inner complete
	>> --j complete
	>> i: 3
	>> --j: 1
	>> --j: 2
	>> --j: 3
	>> ----inner added
	>> ----inner complete
	>> --j complete
	>> i complete
]]

--An example of what may hang your computer (which won't under this):

task.wait()

queueExecutor.stop() --We're not actually going to run the below function

queueExecutor.fori(1, 1e5, 1, function(i)
	print("loop:", i)
end)

queueExecutor.clear()
queueExecutor.eval()

task.wait()

print()
print("==============================")
print("         Pairs loops          ")
print("==============================")
print()

task.wait()


local mixTable = {
	clan1 = {
		players = {"player8", "player7", "player5"}, 
		wars = 497,
		wins = 237,
		level = 7,
	},
	clan2 = {
		players = {"player4", "player6", "player2"}, 
		wars = 497,
		wins = 237,
		level = 7,
	},
	clan3 = {
		players = {"player1", "player9", "player3"}, 
		wars = 497,
		wins = 237,
		level = 7,
	}
}


queueExecutor.ipairs(mixTable, function(i, value)
	print(i, value)
	queueExecutor.pairs(value, function(key2, value2)
		print("--", key2, value2)
		if key2 == "players" then
			queueExecutor.pairs(value2, function(key3, value3)
				print("----", key3, value3)
			end, function()
				print("----Looped over players.")
			end)
		end
	end, function()
		print("--Finished inside looping")
	end)
end, function()
	print("Finished outside looping")
end)

--[[
	
	>> 1 table: 0x...
	>> -- players table: 0x...
	>> ---- 1 player4
	>> ---- 2 player6
	>> ---- 3 player2
	>> ----Looped over players.
	>> -- wins 237
	>> -- wars 497
	>> -- level 7
	>> --Finished inside looping
	>> 2 table: 0x...
	>> -- players table: 0x...
	>> ---- 1 player8
	>> ---- 2 player7
	>> ---- 3 player5
	>> ----Looped over players.
	>> -- wins 237
	>> -- wars 497
	>> -- level 7
	>> --Finished inside looping
	>> 3 table: 0x...
	>> -- players table: 0x...
	>> ---- 1 player1
	>> ---- 2 player9
	>> ---- 3 player3
	>> ----Looped over players.
	>> -- wins 237
	>> -- wars 497
	>> -- level 7
	>> --Finished inside looping
	>> Finished outside looping

]]

task.wait()

print()
print("==============================")
print("         While loops          ")
print("==============================")
print()

task.wait()

local i = 1;

queueExecutor.whileDo(function() return i < 10 end, function()
	print(i)
	i += 1
end, function()
	print("While loop completed")
end)

--[[

	>> 1
	>> 2
	>> 3
	>> 4
	>> 5
	>> 6
	>> 7
	>> 8
	>> 9
	>> While loop completed

]]

--doWhile works the same, but always executes atleast once

queueExecutor.stop()
