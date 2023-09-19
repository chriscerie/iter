--!native
--!strict
local controlFlow = require(script.Parent.controlFlow)

local take = {}

function take.new(iter, new, n: number)
	local newIter = new(iter._value, iter)

	function newIter:next(): ...any
		if n > 0 then
			n -= 1
			return iter:next()
		end
		return controlFlow.None
	end

	function newIter:fold<T>(init: T, fold: (T, ...any) -> T): T
		return self:tryFold(init, fold)
	end

	function newIter:tryFold<T>(init: T, fold: (T, ...any) -> T?): T?
		local res = iter:tryFold(init, function(...)
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

		if controlFlow.isBreak(res) then
			return res.value
		end
		return res
	end

	return newIter
end

return take
