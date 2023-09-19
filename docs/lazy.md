---
sidebar_position: 2
---

# Lazy evaluation

Iterators are lazy, meaning they don't do any processing work until you need them. This code won't run because `map` by itself doesn't do anything, because the would-be result is never used.

```lua
    iter.array(t):map(function(value: number)
        -- This never runs
        return value * 2
    end)
```

Iterators only run when they are needed and consumed. There's several ways to consume iterators. One of the most common ways is to grab the resulting table with `collect`.

```lua
    iter.array(t)
        :map(function(value: number)
            -- Now this runs
            return value * 2
        end)
        :collect()
```

This mechanism enables `iter` to perform aggressive optimizations when it can. Imagine you want to apply some expensive transformation function to an array, but you only want to get the first 40 elements. `iter` will see that you don't need the entire array to be transformed, so it will stop at the first 40. If the original array is some extreme size, it's that many iterations that `iter` avoids.

```lua
    iter.array(t)
        :map(function(value: number)
            -- Only runs 40 times even if array is much larger
            return someExpensiveFn(value)
        end)
        :take(40)
        :collect()
```

While this short circuiting behavior can also be implemented in traditional loops (use a counter and break out of the loop after 40 iterations), it requires the consuming logic to be next to the transformation logic.

Imagine you own a table, want to apply some transformation to it, then pass it off to another part of the code to ultimately consume. Many times you don't have any information on how the table will eventually get used - the downstream consumer can read the entire table, just the first few elements, or even just check if a condition holds true (like if any elements is even). In these cases, traditional loops would require you to apply the transformation function for the entire table, no matter how much of the table the consumer needs.

Instead, with `iter` we can queue transformations, but they won't take effect immediately. We can then pass the entire iterator to the consumer and `iter` will make any optimizations as necessary when it ultimately gets consumed.
