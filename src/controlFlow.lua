--!strict
local controlFlow = {}

controlFlow.None = setmetatable({}, {
	__tostring = function()
		return `Symbol(None)`
	end,
})

-- Since we're not wrapping non-nones as somes, we need this to differentiate between some(none) and none
-- This represents none
controlFlow.Nil = setmetatable({}, {
	__tostring = function()
		return `Symbol(Nil)`
	end,
})

local breakMetatable = {
	__tostring = function(self)
		return `Break({tostring(self.value)})`
	end,
	__eq = function(self, other)
		return getmetatable(self) == getmetatable(other) and self.value == other.value
	end,
}

function controlFlow.Break(value: any)
	return setmetatable({
		value = value,
	}, breakMetatable)
end

function controlFlow.isBreak(value: any)
	return getmetatable(value) == breakMetatable
end

return controlFlow
