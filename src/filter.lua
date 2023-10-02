--!native
--!strict
local types = require(script.Parent.types)

local filter = {}

function filter.new<K, V>(iter: types.Iter<K, V>, new: any, predicate: (key: K, value: any) -> boolean)
	local newIter = new(iter._value, iter)

	function newIter:next()
		return iter:find(predicate)
	end

	function newIter:fold<T>(init: T, g: (T, ...any) -> T): T
		return iter:fold(init, function(acc, ...)
			if predicate(...) then
				return g(acc, ...)
			else
				return acc
			end
		end)
	end

	function newIter:tryFold<T>(init: T, g: (T, ...any) -> T?): T?
		return iter:tryFold(init, function(acc, ...)
			if predicate(...) then
				return g(acc, ...)
			else
				return acc
			end
		end)
	end

	return newIter
end

return filter
