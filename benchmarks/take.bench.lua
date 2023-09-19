local ReplicatedStorage = game:GetService("ReplicatedStorage")

local iter = require(ReplicatedStorage.Packages.iter)

local ARRAY_SIZE = 5000

local function someExpensiveFn(value)
	local _ = Instance.new("MeshPart")
	return value ^ 99
end

local function consumeTable(tb)
	local newTable = {}
	for i = 1, 40 do
		table.insert(newTable, tb[i])
	end
	return newTable
end

local function consumeIterator(iterator)
	return iterator:take(40):collect()
end

return {
	ParameterGenerator = function()
		local arr = table.create(ARRAY_SIZE)
		for i = 1, ARRAY_SIZE do
			arr[i] = math.random(10000)
		end
		return table.freeze(arr)
	end,

	Functions = {
		-- 7.39 ms
		loop = function(_, t)
			-- In a practical scenario, if the consumer code is separate from the transformation code,
			-- you'd need to apply the transformation to the entire table even if you only need part of it
			-- because you don't know how much of the table the consumer will need
			local checkedValues = {}
			for _, value in t do
				table.insert(checkedValues, someExpensiveFn(value))
			end
			consumeTable(checkedValues)
		end,

		-- 0.11 ms
		iter = function(_, t)
			-- Using iterators we can avoid applying the transformation to the entire table
			local iterator = iter.new(t):map(function(_, value)
				return someExpensiveFn(value)
			end)
			consumeIterator(iterator)
		end,
	},
}
