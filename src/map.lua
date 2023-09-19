--!native
--!strict
local controlFlow = require(script.Parent.controlFlow)

local map = {}

function map.new(iter, new, f: (...any) -> ...any)
	local newIter = new(iter._value, iter)

	function newIter:next(): ...any
		local next = { iter:next() }

		if next[1] == controlFlow.None then
			return controlFlow.None
		end

		-- Must fallback to `Nil` as `_getInputTuple` uses default value for nil values
		local newValue = f(table.unpack(next)) or controlFlow.Nil

		return iter:_getInputTuple(nil, newValue)
	end

	function newIter:fold<T>(init: T, g: (T, ...any) -> T): T
		return iter:fold(init, function(acc, key, value)
			return g(acc, key, f(key, value))
		end)
	end

	function newIter:tryFold<T>(init: T, g: (T, ...any) -> T?): T?
		return iter:tryFold(init, function(acc, key, value)
			return g(acc, key, f(key, value))
		end)
	end

	return newIter
end

return map
