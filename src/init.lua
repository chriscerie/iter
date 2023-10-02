--!native
--!strict

local types = require(script.types)
local controlFlow = require(script.controlFlow)
local filter = require(script.filter)
local filterMap = require(script.filterMap)
local map = require(script.map)
local mapWhile = require(script.mapWhile)
local take = require(script.take)

--- @class iter
local iter = {}
iter.__index = iter

--[=[
	Constructs new `iter`

	@return iter
]=]
function iter.new<K, V>(value: { [K]: V }): types.Iter<K, V>
	return iter._new(value)
end

function iter._new<K, V>(value: { [K]: V }, prevIter: any?): types.Iter<K, V>
	assert(typeof(value) == "table", "iter expected table, got " .. typeof(value))

	local self = setmetatable({
		_value = value,
		_lastKey = nil,
		_asMut = false,
		_iterationCount = 0,
	}, iter)

	if prevIter then
		self._asMut = prevIter._asMut
	end

	return self :: any
end

function iter._next<K, V>(self: types.Iter<K, V>, last)
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

	assert(iter(a):all(function(_, x)
		return x > 0
	end))

	assert(not iter(a):all(function(_, x)
		return x > 2
	end))
	```

	Stopping at the first false:

	```lua
	local a = {1, 2, 3}

	local iterator = iter(a)

	assert(not iterator:all(function(_, x)
		return x ~= 2
	end))

	-- we can still use `iter`, as there are more elements.
	assert(next(iterator) == 3)
	```
]=]
function iter.all<K, V>(self: types.Iter<K, V>, f)
	local res = self:tryFold(true, function(_, ...)
		if f(...) then
			return true
		end
		-- FIXME: handle controlflow type
		return controlFlow.Break(true) :: any
	end)

	return not controlFlow.isBreak(res)
end

--[=[
	Ensures `table.freeze` doesn't get called when iterator gets collected.

	# Deviations
	In Rust this is done by specifying `mut` to the assigning variable,
	but this is not a feature in Lua.

	@return iter
]=]
function iter.asMut<K, V>(self: types.Iter<K, V>)
	self._asMut = true
	return self
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

	assert(iter(a):all(function(_, x)
		return x > 0
	end))

	assert(not iter(a):all(function(_, x)
		return x > 5
	end))
	```

	Stopping at the first true:

	```lua
	local a = {1, 2, 3}

	local iterator = iter(a)

	assert(not iterator:all(function(_, x)
		return x ~= 2
	end))

	-- we can still use `iter`, as there are more elements.
	assert(next(iterator) == 2)
	```
]=]
function iter.any<K, V>(self: types.Iter<K, V>, f)
	local hasAny = false

	self:tryFold(true, function(_, ...): boolean?
		if f(...) then
			hasAny = true
			return nil
		end
		return true
	end)

	return hasAny
end

--[=[
	Consumes the iterator, counting the number of iterations and returning it.

	This method will call [`next`] repeatedly until `nil` is encountered, returning the
	number of times it saw values. Note that [`next`] has to be called at least once even
	if the iterator does not have any elements.
]=]
function iter.count<K, V>(self: types.Iter<K, V>)
	return self:fold(0, function(count: number)
		return count + 1
	end)
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
function iter.collect<K, V>(self: types.Iter<K, V>)
	local res = {}

	self:tryFold(true, function(_, key, value)
		res[key] = value
		return true
	end)

	if not self._asMut then
		res = table.freeze(res)
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
function iter.collectArray<K, V>(self: types.Iter<K, V>)
	local res = {}

	self:tryFold(true, function(_, _, value)
		table.insert(res, value)
		return true
	end)

	if not self._asMut then
		res = table.freeze(res)
	end

	return res
end

--[=[
	Creates an iterator which uses a closure to determine if an element should be yielded.

	Given an element the closure must return true or false. The returned iterator will yield
	only the elements for which the closure returns true.

	@return iter
]=]
function iter.filter<K, V>(self: types.Iter<K, V>, predicate)
	return filter.new(self, iter._new, predicate)
end

--[=[
	Creates an iterator that both filters and maps.

	The returned iterator yields only the values for which the supplied closure returns non-nil.

	`filterMap` can be used to make chains of [`filter`] and [`map`] more concise.

	# Examples
	Basic usage:

	```lua
	local a = {"1", "two", "hi", "four", "5"}

	local iterator = iter.new(a):filterMap(function(s)
		return tonumber(a)
	end)

	iterator:next() -> 1, 1
	iterator.next() -> 1, 5
	iterator.next() -> iter.None
	```

	# Deviations
	`filterMap` will assume arrays the table is an array and will slide entries down if values are
	removed as long as the table is contiguous. The first time a non-array key is encountered (key
	that jumps or non-numeric key), `filterMap` will act the same as `map`.
]=]
function iter.filterMap<K, V>(self: types.Iter<K, V>, f)
	return filterMap.new(self, iter._new, f)
end

--[=[
	Searches for an element of an iterator that satisfies a predicate.

	`find()` takes a closure that returns true or false. It applies this closure to each element
	of the iterator, and if any of them return true, then `find()` returns the element. If
	they all return false, it returns `None`.

	`find()` is short-circuiting; in other words, it will stop processing as soon as the closure
	returns `true`
]=]
function iter.find<K, V>(self: types.Iter<K, V>, predicate)
	local res = self:tryFold(false, function(_, key, value): boolean | controlFlow.Break
		if predicate(key, value) then
			return controlFlow.Break({ key, value } :: { K | V })
		end
		return false
	end)

	if controlFlow.isBreak(res) then
		return table.unpack((res :: any).value)
	end

	return controlFlow.None
end

--[=[
	Applies function to the elements of iterator and returns the first non-nil result.

	`iter:findMap(f)` is equivalent to `iter:filterMap(f):next()`.

	# Examples
	```lua
	local a = {"lol", "hi", "2", "5"}

	local _, firstNumber = iter.new(a):findMap(function(_k, s)
		return tonumber(s)
	end)

	assert(firstNumber == 2)
	```
]=]
function iter.findMap<K, V>(self: types.Iter<K, V>, f)
	local res = self:tryFold(true, function(_, key, value)
		local x = f(key, value)
		return if x == nil then true else controlFlow.Break({ key, x })
	end)

	if controlFlow.isBreak(res) then
		return table.unpack((res :: any).value)
	end
	return nil
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
	local sum = iter.new(a):fold(0, function(acc, x)
		return acc + x
	end)

	assert(sum == 6)
	```


	This example demonstrates the left-associative nature of fold(): it builds a string, starting
	with an initial value and continuing with each element from the front until the back:

	```lua
	local numbers = {1, 2, 3, 4, 5}

	local result = iter.new(numbers):fold("0", function(acc, x)
		return `({acc} + {x})`
	end);

	assert(result, "(((((0 + 1) + 2) + 3) + 4) + 5)");
	```
]=]
function iter.fold<K, V>(self: types.Iter<K, V>, init, f)
	local accum = init
	local next = { self:next() }
	while next[1] ~= controlFlow.None do
		local value = if #next == 2 then next[2] else next[3]
		accum = f(accum, self:_getInputTuple(nil, value))
		next = { self:next() }
	end
	return accum
end

--[=[
	Calls a closure on each element of an iterator.

	This is equivalent to using a for loop on the iterator, although break
	and continue are not possible from a closure. It's generally more idiomatic
	to use a for loop, but for_each may be more legible when processing items at
	the end of longer iterator chains.

	# Examples
	Basic usage:

	```lua
	iter.new({ 0, 1, 2 })
		:map(function(_, x: number)
			return x * 100
		end)
		:filter(function(i: number, x: number)
			return (i + x) % 3 == 0
		end)
		:for_each(function(i: number, x: number)
			print(`{i}:{x}`)
		end)
	```
]=]
function iter.forEach<K, V>(self: types.Iter<K, V>, f)
	self:fold(nil, function(_, ...)
		f(...)
		return nil
	end)
end

--[=[
	Does something with each element of an iterator, passing the value on.

	When using iterators, you'll often chain several of them together. While working
	on such code, you might want to check out what's happening at various parts in
	the pipeline. To do that, insert a call to `inspect()`.

	It's more common for `inspect()` to be used as a debugging tool than to exist in
	your final code, but applications may find it useful in certain situations when
	errors need to be logged before being discarded.

	# Examples
	Basic usage:

	```lua
	local a = {1, 4, 2, 3}

	-- this iterator sequence is complex.
	local sum = iter.new(a)
		:cloned()
		:filter(function(x) 
			return x % 2 == 0
		end)
		:fold(0, function(sum, i)
			return sum + i
		end)

	print("{sum}")

	-- let's add some inspect() calls to investigate what's happening
	let sum = a.iter()
		:inspect(function(x)
			print("about to filter: {x}")
		end)
		:filter(function(x)
			return x % 2 == 0
		end)
		:inspect(function(x)
			print("made it through filter: {x}")
		end)
		:fold(0, function(sum, i)
			return sum + i
		end)

	print(`{sum}`)
	```
	This will print:

	```
	6
	about to filter: 1
	about to filter: 4
	made it through filter: 4
	about to filter: 2
	made it through filter: 2
	about to filter: 3
	6
	```
]=]
function iter.inspect<K, V>(self: types.Iter<K, V>, f)
	for key, value in self do
		f(self:_getInputTuple(key, value))
	end
	return self
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
	assert(iter.new(a).last() == 3)

	local a = {1, 2, 3, 4, 5}
	assert(iter.new(a).last() == 5)
	```
]=]
function iter.last<K, V>(self: types.Iter<K, V>)
	local res = self:fold(nil, function(_, ...)
		return { ... }
	end)

	return table.unpack(res or {})
end

--[=[
	Takes a closure and creates an iterator which calls that closure on each element.

	`map()` transforms one iterator into another. It produces a new iterator which calls this
	closure on each element of the original iterator.

	If you are good at thinking in types, you can think of `map()` like this: If you have an
	iterator that gives you elements of some type `A`, and you want an iterator of some other
	type `B`, you can use `map()`, passing a closure that takes an `A` and returns a `B`.

	`map()` is conceptually similar to a `for` loop. If you're doing some sort of looping for a side
	effect, it's considered more idiomatic to use `for` than `map()`.

	@return iter
]=]
function iter.map<K, V>(self: types.Iter<K, V>, f)
	return map.new(self, iter._new, f)
end

--[=[
	Creates an iterator that both yields elements based on a predicate and maps.

	`mapWhile()` takes a function as an argument. It will call this function on each element
	of the iterator, and yield elements while it returns non-nil.

	@return iter
]=]
function iter.mapWhile<K, V>(self: types.Iter<K, V>, predicate)
	return mapWhile.new(self, iter._new, predicate)
end

--[=[
	Advances the iterator and returns the next value.

	Returns `nil` when iteration is finished.

	# Examples
	Basic usage:

	```lua
	local a = {1, 2, 3}

	local iterator = iter.new(a)

	-- A call to next() returns the next value...
	assert(1 == iter.next())
	assert(2 == iter.next())
	assert(3 == iter.next())

	-- ... and then `nil` once it's over.
	assert(nil == iter.next())
	```
]=]
function iter.next<K, V>(self: types.Iter<K, V>)
	self:_next(self._lastKey)
	return self:_getInputTuple()
end

--[=[
	Reduces the elements to a single one, by repeatedly applying a reducing operation.

	If the iterator is empty, returns `iter.None`; otherwise, returns the result of the reduction.

	The reducing function is a closure with two arguments: an 'accumulator', and an element. For iterators
	with at least one element, this is the same as [`fold`] with the first element of the iterator as the
	initial accumulator value, folding every subsequent element into it.

	# Example
	```lua
	local a = { 1, 2, ..., 10 }
	local reduced = iter.new(a):reduce(function(acc, _key, value)
		return acc + value
	end)
	assert(reduced == 45)

	-- Which is equivalent to doing it with `fold`:
	local folded = iter.new(a):fold(0, function(acc, _key, value)
		return acc + value
	end)
	assert(reduced == folded)
	```
]=]
function iter.reduce<K, V>(self: types.Iter<K, V>, f)
	local _, first = self:next()

	if first == nil then
		return controlFlow.None
	end

	return self:fold(first, f)
end

--[=[
	Creates an iterator that yields the first `n` elements, or fewer if the underlying iterator ends sooner.

	`take(n)` yields elements until `n` elements are yielded or the end of the iterator is reached (whichever
	happens first). The returned iterator is a prefix of length `n` if the original iterator contains at least
	`n` elements, otherwise it contains all of the (fewer than `n`) elements of the original iterator.
]=]
function iter.take<K, V>(self: types.Iter<K, V>, n)
	return take.new(self, iter._new, n)
end

--[=[
	An iterator method that applies a function as long as it returns successfully, producing a single,
		final value.

	`tryFold()` takes two arguments: an initial value, and a closure with two arguments: an 'accumulator',
	and an element. The closure either returns successfully, with the value that the accumulator should
	have for the next iteration, or it returns `nil` that is propagated back to the caller immediately
	(short-circuiting).

	The initial value is the value the accumulator will have on the first call. If applying the closure
	succeeded against every element of the iterator, `tryFold()` returns the final accumulator as success.

	Folding is useful whenever you have a collection of something, and want to produce a single value from it.
]=]
function iter.tryFold<K, V>(self: types.Iter<K, V>, init, f)
	local accum = init
	local next = { self:next() }
	while next[1] ~= controlFlow.None do
		local newValue = f(accum, self:_getInputTuple(nil, next[2]))

		if newValue == nil then
			return controlFlow.None
		end

		if controlFlow.isBreak(newValue) then
			return newValue
		end

		-- Luau isn't able to convert T? to T
		accum = newValue :: any
		next = { self:next() }
	end

	return accum
end

function iter._getInputTuple<K, V>(self: types.Iter<K, V>, key, value)
	key = key or self._lastKey

	-- This can happen if the iterator is already consumed
	if key == nil then
		return controlFlow.None
	end

	value = value or self._value[key]

	if value == nil then
		warn(`'iter' did not find value for key '{key}' in table. Did the input table mutate?`)
	end

	if value :: any == controlFlow.Nil then
		value = nil
	end

	return key, value
end

local exports = {
	new = iter.new,

	Break = controlFlow.Break,
	None = controlFlow.None,
}

return exports
