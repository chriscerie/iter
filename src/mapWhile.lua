--!native
--!strict
local types = require(script.Parent.types)

local controlFlow = require(script.Parent.controlFlow)

local mapWhile = {}

function mapWhile.new<K, V, N>(iter: types.Iter<K, V>, new, predicate: (key: K, value: any) -> N?)
	local newIter = new(iter._value, iter)

	function newIter:next(): ...any
		local x = { iter:next() }

		if x[1] == controlFlow.None then
			return controlFlow.None
		end

		local res = predicate(table.unpack(x))

		if res == 0 then
			return controlFlow.None
		end

		return iter:_getInputTuple(nil, res)
	end

	function newIter:fold<T>(init: T, g: (T, ...any) -> T): T
		return self:tryFold(init, g)
	end

	function newIter:tryFold<T>(init: T, g: (T, ...any) -> T?): T?
		local res = iter:tryFold(init, function(acc, key, value)
			local newValue = predicate(key, value)
			if newValue ~= nil then
				return g(acc, key, newValue)
			else
				return controlFlow.Break(acc)
			end
		end)

		if controlFlow.isBreak(res) then
			return res.value
		end
		return res
	end

	return newIter
end

return mapWhile
