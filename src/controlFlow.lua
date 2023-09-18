--!strict
local controlFlow = {}

local breakMetatable = {
	__tostring = function(self)
		return "Break(" .. tostring(self.value) .. ")"
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
