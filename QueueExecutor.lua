local runService = game:GetService("RunService")

local queueExecutor = {}
local queue = {}

local bindName = "__queueExecutor__.process"
local priority = Enum.RenderPriority.Last.Value
local paused = true
local evaluationTime = 1/60
local frameStarted = 0


local function process(s)
	if #queue > 0 and not paused then
		local startExecution = tick()
		local spentTime = startExecution - frameStarted
		while tick() - startExecution < (evaluationTime - spentTime) and #queue > 0 do
			local first = queue[1]
			local fnexec, andThen = first[1], first[2]
			table.remove(queue, 1)
			local beforeSize = #queue
			local lastReturn = {fnexec()}
			if andThen then
				local insertInto = function() andThen(unpack(lastReturn)) end
				local difference = #queue - beforeSize
				table.insert(queue, difference + 1, {insertInto, nil})
			end
		end
	end
end

runService:BindToRenderStep(bindName..".main", priority, process)

runService:BindToRenderStep(bindName..".first", Enum.RenderPriority.First.Value, function()
	frameStarted = tick()
end)


function queueExecutor.eval() paused = false end
function queueExecutor.stop() paused = true end
function queueExecutor.clear() queue = {} end
function queueExecutor.getSize(): number return #queue end


function queueExecutor.setPriority(newPriority: number)
	priority = newPriority
	runService:UnbindFromRenderStep(bindName..".main")
	runService:BindToRenderStep(bindName..".main", priority, process)
end

function queueExecutor.setEvaluationTime(newEvaluationTime: number) 
	evaluationTime = newEvaluationTime
end


function queueExecutor.addToQueue(insertBeginning: boolean, expression: (any) -> any, andThen: (any) -> ())
	if insertBeginning then
		table.insert(queue, 1, {expression, andThen})
	else
		table.insert(queue, {expression, andThen})
	end
end

local function LT(a, b) return a < b end
local function GT(a, b) return a > b end


function queueExecutor.iterate(startIndex: number, finalIndex: number, indexOffset: number, fncExec: (number) -> (), andThen: () -> ())
	if not indexOffset then indexOffset = (finalIndex > startIndex) and 1 or -1 end
	if (startIndex > finalIndex and indexOffset > 0) or 
		(startIndex < finalIndex and indexOffset < 0) then 
		return false
	end
	
	local comparison = GT;
	if (startIndex > finalIndex) then comparison = LT end
	
	local function loop(currentIndex)
		if comparison(currentIndex, finalIndex) then 
			andThen()
		else
			queueExecutor.addToQueue(true,
				function()
					fncExec(currentIndex)
				end,
				function()
					loop(currentIndex + indexOffset)
				end
			)
		end
	end
	loop(startIndex)
end



function queueExecutor.pairs(tab: { [a]: b }, fncExec: (string, any) -> (), andThen: () -> ())
	local key, value = next(tab)
	
	local function loop(key, value)
		if key == nil then 
			andThen()
		else
			queueExecutor.addToQueue(true,
				function()
					fncExec(key, value)
				end,
				function()
					key, value = next(tab, key)
					loop(key, value)
				end
			)
		end
	end
	loop(key, value)
end

function queueExecutor.ipairs(tab: { [a]: b }, fncExec: (number, any) -> (), andThen: () -> ())
	local key, value = next(tab)
	local iteration = 1
	
	local function loop(key, value, iteration)
		if key == nil then 
			andThen()
		else
			queueExecutor.addToQueue(true,
				function()
					fncExec(iteration, value)
				end,
				function()
					key, value = next(tab, key)
					loop(key, value, iteration + 1)
				end
			)
		end
	end
	loop(key, value, iteration)
end

function queueExecutor.whileDo(condition: (any) -> boolean, fncExec: () -> (), andThen: () -> ())
	local function loop()
		if condition() then
			queueExecutor.addToQueue(true,
				function()
					fncExec()
				end,
				loop
			)
		else
			andThen()
		end
	end
	loop()
end

function queueExecutor.doWhile(condition: (any) -> boolean, fncExec: () -> (), andThen: () -> ())
	local function loop()
		queueExecutor.addToQueue(true,
			function()
				fncExec()
			end,
			function()
				if condition() then
					loop()
				else
					andThen()
				end
			end
		)
	end
	loop()
end


return queueExecutor

