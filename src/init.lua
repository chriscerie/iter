--!strict

--- @class iter
local iter = {}
iter.__index = iter

iter.dataTypes = {
	dict = "Dict",
	array = "Array",
}

local dataTypes = iter.dataTypes

function iter._iter(value, type: string, prevIter: any?)
	assert(typeof(value) == "table", "iter expected table, got " .. typeof(value))

	local self = setmetatable({
		_value = table.clone(value),
		_type = type or dataTypes.dict,
		_lastKey = nil,
		_enumerate = false,
		_asMut = false,
		_iterationCount = 0,
	}, iter)

	if prevIter then
		self._enumerate = prevIter._enumerate
		self._asMut = prevIter._asMut
	end

	return self
end

function iter._dict(value: { [any]: any })
	return iter._iter(value, dataTypes.dict)
end

function iter._array(value: { any })
	return iter._iter(value, dataTypes.array)
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
function iter:all(predicate: (...any) -> boolean): boolean
	for key, value in self do
		if predicate(self:_getInputTuple(key, value)) then
			return false
		end
	end

	return true
end

--[=[
	Ensures `table.freeze` doesn't get called when iterator gets collected.

	# Deviations
	In Rust this is done by specifying `mut` to the assigning variable,
	but this is not a feature in Lua.

	@return iter
]=]
function iter:asMut()
	self._asMut = true
	return iter._iter(self._value, self._type, self)
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
function iter:any(predicate: (...any) -> boolean): boolean
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
function iter:count(): number
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

	# Deviations
	The returned table is frozen by default if [`asMut`] was never called.
]=]
function iter:collect(): { [any]: any }
	local res = self._value

	if not self._asMut then
		res = table.freeze(self._value)
	end

	return res
end

--[=[
	Same thing as [`collect`], but turns table into arrays of its values and discards its keys.

	# Deviations
	* In Rust this would be done by using [`collect`] and specifying the type, but types in lua
	do not affect the runtime.
	* The returned table is frozen by default if [`asMut`] was never called.
]=]
function iter:collectArray(): { any }
	local res = {}
	for _, value in self do
		table.insert(res, value)
	end

	if not self._asMut then
		res = table.freeze(res)
	end

	return res
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

	@return iter
]=]
function iter:enumerate()
	self._enumerate = true
	return iter._iter(self._value, self._type, self)
end

--[=[
	Creates an iterator which uses a closure to determine if an element should be yielded.

	Given an element the closure must return true or false. The returned iterator will yield
	only the elements for which the closure returns true.

	@return iter
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

	return self._iter(newTable, self._type, self)
end

--[=[
	Folds every element into an accumulator by applying an operation, returning the final result.

	`fold()` takes two arguments: an initial value, and a closure with two arguments: an
	'accumulator', and an element. The closure returns the value that the accumulator should
	have for the next iteration.

	The initial value is the value the accumulator will have on the first call.

	After applying this closure to every element of the iterator, `fold()` returns the accumulator.

	This operation is sometimes called 'reduce' or 'inject'.

	Folding is useful whenever you have a collection of something, and want to produce a single
	value from it.

	# Errors
	* If the iterator is an infinite iterator (DEVIATION)

	# Examples
	Basic usage:

	```lua
	local a = {1, 2, 3}

	-- the sum of all of the elements of the array
	local sum = iter.array(a):fold(0, function(acc, x)
		return acc + x
	end)

	assert(sum == 6)
	```


	This example demonstrates the left-associative nature of fold(): it builds a string, starting
	with an initial value and continuing with each element from the front until the back:

	```lua
	local numbers = {1, 2, 3, 4, 5}

	local result = iter.array(numbers):fold("0", function(acc, x)
		return `({acc} + {x})`
	end);

	assert(result, "(((((0 + 1) + 2) + 3) + 4) + 5)");
	```
]=]
function iter:fold<T>(init: T, f: (T, any) -> T): T
	for _, value in self do
		init = f(init, value)
	end
	return init
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

--[=[
	Consumes the iterator, returning the last element.

	For non-arrays, this method will evaluate the iterator until it returns `nil`.
	While doing so, it keeps track of the current element. After `nil` is returned,
	`last()` will then return the last element it saw.

	# Examples
	Basic usage:

	```lua
	local a = {1, 2, 3}
	assert(array(a).last() == 3)

	local a = {1, 2, 3, 4, 5}
	assert(array(a).last() == 5)
	```
]=]
function iter:last(): ...any
	local res = {}
	while self:next() ~= nil do
		res = { self:_getInputTuple() }
	end

	return table.unpack(res)
end

--[=[
	Takes a closure and creates an iterator which calls that closure on each element.

	`map()` transforms one iterator into another. It produces a new iterator which calls this
	closure on each element of the original iterator.

	If you are good at thinking in types, you can think of `map()` like this: If you have an
	iterator that gives you elements of some type `A`, and you want an iterator of some other
	type `B`, you can use `map()`, passing a closure that takes an `A` and returns a `B`.

	`map()` is conceptually similar to a `for` loop. If you're doing some sort of looping for a side
	effect, it's considered more idiomatic to use for than `map()`.

	# Deviations
	The closure can return 2 values, in which case the first is used as the key and the second as the value.
	The iterator would immediately turn into a `dict` iterator if it wasn't one already.

	@return iter
]=]
function iter:map(transformer: (...any) -> any)
	local newTable = {}

	for key, value in self do
		local results = { transformer(self:_getInputTuple(key, value)) }

		if #results < 2 then
			newTable[key] = results[1]
		elseif #results == 2 then
			newTable[results[1]] = results[2]
		else
			error("`map()` must return 0 - 2 values")
		end
	end

	return self._iter(newTable, self._type, self)
end

--[=[
	Creates an iterator that both yields elements based on a predicate and maps.

	`mapWhile()` takes a function as an argument. It will call this function on each element
	of the iterator, and yield elements while it returns non-nil.

	@return iter
]=]
function iter:mapWhile(transformer: (...any) -> any)
	local newTable = {}

	for key, value in self do
		local results = { transformer(self:_getInputTuple(key, value)) }

		if #results == 0 then
			break
		elseif #results == 1 then
			newTable[key] = results[1]
		elseif #results == 2 then
			newTable[results[1]] = results[2]
		else
			error("`map()` must return 0 - 2 values")
		end
	end

	return self._iter(newTable, self._type, self)
end

--[=[
	Advances the iterator and returns the next value.

	Returns `nil` when iteration is finished.

	# Examples
	Basic usage:

	```lua
	local a = {1, 2, 3}

	local iterator = iter.array(a)

	-- A call to next() returns the next value...
	assert(1 == iter.next())
	assert(2 == iter.next())
	assert(3 == iter.next())

	-- ... and then `nil` once it's over.
	assert(nil == iter.next())
	```
]=]
function iter:next(): any
	self:_next(self._lastKey)
	return self:_getInputTuple()
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
