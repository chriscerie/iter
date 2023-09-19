--!native
--!strict
local controlFlow = require(script.Parent.controlFlow)

local take = {}

function take.new(iter, new, n: number)
	local newIter = new(iter._value, iter._type, iter)

	function newIter:next(): ...any
		if n > 0 then
			n -= 1
			return iter:next()
		end
		return nil
	end

	function newIter:fold<T>(init: T, fold: (T, ...any) -> T): T
		return self:tryFold(init, fold)
	end

	function newIter:tryFold<T>(init: T, fold: (T, ...any) -> T?): T?
		return iter:tryFold(init, function(...)
			if n == 0 then
				return init
			else
				n -= 1
				if n == 0 then
					return controlFlow.Break(fold(...))
				else
					return fold(...)
				end
			end
		end)
	end

	return newIter
end

return take
