--!native
--!strict
local filterMap = {}

local function isContiguous(index: number?, currentKey: any)
	if typeof(currentKey) ~= "number" and index then
		return false
	end

	return index == currentKey - 1
end

function filterMap.new(iter: any, new, f: (...any) -> ...any)
	local newIter = new(iter._value, iter)

	-- Used to check whether table is still a contiguous array
	local lastTableIndex: number? = 0

	-- For the resulting array index. This can deviate from real index if values are filtered out
	local currentArrayIndex = 0

	function newIter:next(): ...any
		return iter:findMap(f)
	end

	function newIter:fold<T>(init: T, fold: (T, ...any) -> T): T
		return iter:fold(init, function(acc, key, value)
			local isArray = false
			if isContiguous(lastTableIndex, key) then
				lastTableIndex = lastTableIndex and lastTableIndex + 1
				currentArrayIndex += 1
				isArray = true
			else
				lastTableIndex = nil
			end

			local newValue = f(key, value)
			if newValue ~= nil then
				if isArray then
					currentArrayIndex += 1
				end
				return fold(acc, if isArray then currentArrayIndex else key, newValue)
			else
				return acc
			end
		end)
	end

	function newIter:tryFold<T>(init: T, fold: (T, ...any) -> T?): T?
		return iter:tryFold(init, function(acc, key, value)
			local isArray = false
			if isContiguous(lastTableIndex, key) then
				lastTableIndex = lastTableIndex and lastTableIndex + 1
				isArray = true
			else
				lastTableIndex = nil
			end

			local newValue = f(key, value)
			if newValue ~= nil then
				if isArray then
					currentArrayIndex += 1
				end
				return fold(acc, if isArray then currentArrayIndex else key, newValue)
			else
				return acc
			end
		end)
	end

	return newIter
end

return filterMap
