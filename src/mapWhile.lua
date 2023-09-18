--!native
--!strict
local controlFlow = require(script.Parent.controlFlow)

local mapWhile = {}

-- FIXME: This should convert `_type` to dict if `f` returns multiple values
function mapWhile.new(iter, new, predicate: (...any) -> ...any)
	local newIter = new(iter._value, iter._type, iter)

	function newIter:next(): ...any
		local x = { iter:next() }

		-- This cannot return as ternary or it will break if `f` returns multiple values
		if #x > 0 then
			return predicate(unpack(x))
		end
		return nil
	end

	function newIter:fold<T>(init: T, g: (T, ...any) -> T): T
		return self:tryFold(init, g)
	end

	function newIter:tryFold<T>(init: T, g: (T, ...any) -> T?): T?
		return iter:tryFold(init, function(acc, ...)
			if predicate(...) then
				return g(acc, ...)
			else
				return controlFlow.Break(acc)
			end
		end)
	end

	return newIter
end

return mapWhile
