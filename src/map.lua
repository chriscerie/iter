--!native
--!strict
local map = {}

-- FIXME: This should convert `_type` to dict if `f` returns multiple values
function map.new(iter, new, f: (...any) -> ...any)
	local newIter = new(iter._value, iter._type, iter)

	function newIter:next(): ...any
		local next = { iter:next() }

		-- This cannot return as ternary or it will break if `f` returns multiple values
		if #next > 0 then
			return f(unpack(next))
		end
		return nil
	end

	function newIter:fold<T>(init: T, g: (T, ...any) -> T): T
		return iter:fold(init, function(acc, ...)
			return g(acc, f(...))
		end)
	end

	function newIter:tryFold<T>(init: T, g: (T, ...any) -> T?): T?
		return iter:tryFold(init, function(acc, ...)
			return g(acc, f(...))
		end)
	end

	return newIter
end

return map
