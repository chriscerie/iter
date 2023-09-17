--!strict

--- @class iter
local iter = {}
iter.__index = iter

iter.dataTypes = {
	dict = "Dict",
	array = "Array",
}

local dataTypes = iter.dataTypes

function iter._iter(tb, type: string, enumerate: boolean)
	assert(typeof(tb) == "table", "iter expected table, got " .. typeof(tb))

	return setmetatable({
		_value = tb,
		_type = type or dataTypes.dict,
		_lastKey = nil,
		_enumerate = enumerate,
		_iterationCount = 0,
	}, iter)
end

function iter._dict(tb: { [any]: any })
	return iter._iter(tb, dataTypes.dict, false)
end

function iter._array(tb: { any })
	return iter._iter(tb, dataTypes.array, false)
end

function iter:_next(last)
	local key, value = next(self._value, last)

	if key == nil then
		self._lastKey = nil
		return nil
	end

	self._iterationCount = 1 + self._iterationCount :: number
	self._lastKey = key
	return key, value
end

function iter:__iter()
	return iter._next, self
end

--[=[
	Tests if every element of the iterator matches a predicate.

	`all()` takes a closure that returns true or false. It applies this closure
	to each element of the iterator, and if they all return true, then so does
	all(). If any of them return false, it returns false.

	`all()` is short-circuiting; in other words, it will stop processing as soon
	as it finds a false, given that no matter what else happens, the result will
	also be false.

	An empty iterator returns true.

	# Examples

	Basic usage:

	```lua
	local a = {1, 2, 3}

	assert(iter(a):all(function(x)
		return x > 0
	end))

	assert(not iter(a):all(function(x)
		return x > 2
	end))
	```

	Stopping at the first false:

	```lua
	local a = {1, 2, 3}

	local iterator = iter(a)

	assert(not iterator:all(function(x)
		return x ~= 2
	end))

	-- we can still use `iter`, as there are more elements.
	assert(next(iterator) == 3)
	```
]=]
function iter:all(predicate: (...any) -> boolean)
	for key, value in self do
		if predicate(self:_getInputTuple(key, value)) then
			return false
		end
	end

	return true
end

--[=[
	Tests if any element of the iterator matches a predicate.

	`any()` takes a function that returns `true` or `false`. It applies this
	function to each element of the iterator, and if any of them return
	`true`, then so does `any()`. If they all return `false`, it returns `false`.

	`any()` is short-circuiting; in other words, it will stop processing
	as soon as it finds a true, given that no matter what else happens,
	the result will also be true.

	An empty iterator returns `false`.

	# Examples

	Basic usage:

	```lua
	local a = {1, 2, 3}

	assert(iter(a):all(function(x)
		return x > 0
	end))

	assert(not iter(a):all(function(x)
		return x > 5
	end))
	```

	Stopping at the first true:

	```lua
	local a = {1, 2, 3}

	local iterator = iter(a)

	assert(not iterator:all(function(x)
		return x ~= 2
	end))

	-- we can still use `iter`, as there are more elements.
	assert(next(iterator) == 2)
	```
]=]
function iter:any(predicate: (...any) -> boolean)
	for key, value in self do
		if predicate(self:_getInputTuple(key, value)) then
			return true
		end
	end

	return false
end

--[=[
	Consumes the iterator, counting the number of iterations and returning it.

	This method will call [`next`] repeatedly until `nil` is encountered, returning the
	number of times it saw values. Note that [`next`] has to be called at least once even
	if the iterator does not have any elements.
]=]
function iter:count()
	local count = 0
	while self:next() ~= nil do
		count += 1
	end

	return count
end

--[=[
	Transforms an iterator into a table.

	`collect()` can take anything iterable, and turn it into a relevant table.
	This is one of the more powerful methods in the standard library, used in a variety of contexts.

	The most basic pattern in which `collect()` is used is to turn one table into
	another. You take a table, call [`iter`] on it, do a bunch of transformations,
	and then `collect()` at the end.
]=]
function iter:collect()
	return self._value
end

--[=[
	Creates an iterator which gives the current iteration count as well as the next value.

	The iterator returned yields pairs `(i, val)` for arrays and `(i, key, val)` for dicts,
	where i is the current index of iteration.

	# Examples
	```lua
	local a = {'a', 'b', 'c'}

	local iterator = array(a).enumerate()

	print(iterator:next()) -> 1, "a"
	print(iterator:next()) -> 2, "b"
	print(iterator:next()) -> 3, "c"
	print(iterator:next()) -> nil

	local b = {
		akey = 'a',
		bkey = 'b',
		ckey = 'c',
	}

	iterator = dict(b).enumerate()

	print(iterator:next()) -> 1, "akey", "a"
	print(iterator:next()) -> 2, "bkey", "b"
	print(iterator:next()) -> 3, "ckey", "c"
	print(iterator:next()) -> nil
	```

	# Deviations
	* For dicts, the iterator returned yields tuples `(i, key, val)`
	* Indexing starts at 1
]=]
function iter:enumerate()
	return self._iter(self._value, self._type, true)
end

--[=[
	Consumes the iterator, returning the last element.

	For non-arrays, this method will evaluate the iterator until it returns `nil`.
	While doing so, it keeps track of the current element. After `nil` is returned,
	`last()` will then return the last element it saw.

	# Examples
	Basic usage:

	```lua
	local a = {1, 2, 3};
	assert(array(a).last() == 3);

	local a = {1, 2, 3, 4, 5};
	assert(array(a).last() == 5);
	```
]=]
function iter:last(): any
	local res = {}
	while self:next() ~= nil do
		res = { self:_getInputTuple() }
	end

	return table.unpack(res)
end

function iter:map(transformer: (...any) -> any)
	local newTable = {}

	for key, value in self do
		newTable[key] = transformer(self:_getInputTuple(key, value))
	end

	return self._iter(newTable, self._type, self._enumerate)
end

--[=[
	Creates an iterator that both yields elements based on a predicate and maps.

	`mapWhile()` takes a function as an argument. It will call this function on each element
	of the iterator, and yield elements while it returns non-nil.
]=]
function iter:mapWhile(transformer: (...any) -> any)
	local newTable = {}

	for key, value in self do
		local newValue = transformer(self:_getInputTuple(key, value))
		newTable[key] = newValue

		if newValue == nil then
			break
		end
	end

	return self._iter(newTable, self._type, self._enumerate)
end

function iter:next()
	self:_next(self._lastKey)
	return self:_getInputTuple()
end

--[=[
	Creates an iterator which uses a closure to determine if an element should be yielded.

	Given an element the closure must return true or false. The returned iterator will yield
	only the elements for which the closure returns true.
]=]
function iter:filter(predicate: (any, any) -> boolean)
	local newTable = {}

	for key, value in self do
		if predicate(self:_getInputTuple()) then
			if self._type == dataTypes.array then
				table.insert(newTable, value)
			else
				newTable[key] = value
			end
		end
	end

	return self._iter(newTable, self._type, self._enumerate)
end

--[=[
	Calls a closure on each element of an iterator.

	This is equivalent to using a for loop on the iterator, although break
	and continue are not possible from a closure. It's generally more idiomatic
	to use a for loop, but for_each may be more legible when processing items at
	the end of longer iterator chains.

	#Examples
	Basic usage:

	```lua
	tb.array({ 0, 1, 2 })
		:map(function(x: number)
			return x * 100
		end)
		:enumerate()
		:filter(function(i: number, x: number)
			return (i + x) % 3 == 0
		end)
		:for_each(function(i: number, x: number)
			print(`{i}:{x}`)
		end)
	```
]=]
function iter:forEach(f: (...any) -> ())
	for key, value in self do
		f(self:_getInputTuple(key, value))
	end
end

--[[
	For arrays, just returns the value

	For dicts, returns the key and value

	If enumerated, includes iteration count at the beginning for both arrays and dicts
]]
function iter:_getInputTuple(key, value)
	key = key or self._lastKey

	-- This can happen if the iterator is already consumed
	if key == nil then
		return nil
	end

	value = value or self._value[key]

	local res = {}

	if self._enumerate then
		table.insert(res, self._iterationCount)
	end

	if self._type == dataTypes.dict then
		table.insert(res, key)
		table.insert(res, value)
	else
		table.insert(res, value)
	end

	return table.unpack(res)
end

local exports = {
	dict = iter._dict,
	array = iter._array,
}

return exports
