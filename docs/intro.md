---
sidebar_position: 1
---

# Introduction

**iter** is a composable immutable table library for Lua based on Rust's iterators. It makes complex data manipulations a breeze.

## Installation

### Wally

Add the latest version of iter to your `wally.toml`:

```console
iter = "chriscerie/iter@<version>"
```

## Goals

### Composable

Chaining operations and transformations in one operation makes the flow of complex data structures very predictable and easy to read. It's much more intuitive to transformations being applied to data as isolated layers than series of loops.

### Immutable

By default, tables returned by `iter` are frozen. This is a good thing! Mutating data structures when you don't expect it is a major source of bugs in software. Instead, when a table returned by `iter` needs to be directly modifiable, you must be [explicit](/iter/api/iter#asMut) about it.

## Example

As a basic example, imagine you have a dictionary of scores
```lua
local values = {
    player1 = 321,
    player2 = 521,
    player3 = 232,
    ...
}
```

And you want to transform the scores into an array for further processing. However you want to stop at the first score above 500 that you see. Then you want to count the number of scores that aren't part of the array.

### Without iter
Without iter, we can move the values into an array while keeping track of the checked values. Then we can calculate the total number of values to begin with, and get the number of scores that are left by subtracting the two values.
```lua
local checkedValues = {}
local countChecked = 0
for _, value in values do
	countChecked += 1
	if value > 500 then
		break
	end

	table.insert(checkedValues, value)
end

local countTotal = 0
for _, value in values do
	countTotal += 1
end

print(checkedValues)
print(countTotal - countChecked)
```

### With iter
With iter, this becomes easier. We can use `mapWhile` to keep the values until we see a score above 500, then collect the values as an array. As an aside, if we wanted to preserve the dictionary and collect the values as key-value pairs, we can just call `:collect()` instead to preserve the original data structure.

Then counting the rest of the values is easy. We can simply call `:count()` to grab the count of the remaining values.
```lua
local iterator = iter.new(a)
local checkedValues = iterator
	:mapWhile(function(_key, value)
		return if value > 500 then nil else value
	end)
	:collectArray()

print(checkedValues)
print(iterator:count())
```

## Next Steps

Check out the [API Reference](/iter/api)