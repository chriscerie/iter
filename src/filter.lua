--!native
--!strict
local filter = {}

function filter.new(iter, new, predicate: (any, any) -> boolean)
	local newIter = new(iter._value, iter._type, iter)

	function newIter:next(): any
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
