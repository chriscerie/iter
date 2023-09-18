"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[9],{48818:e=>{e.exports=JSON.parse('{"functions":[{"name":"all","desc":"Tests if every element of the iterator matches a predicate.\\n\\n`all()` takes a closure that returns true or false. It applies this closure\\nto each element of the iterator, and if they all return true, then so does\\nall(). If any of them return false, it returns false.\\n\\n`all()` is short-circuiting; in other words, it will stop processing as soon\\nas it finds a false, given that no matter what else happens, the result will\\nalso be false.\\n\\nAn empty iterator returns true.\\n\\n# Examples\\n\\nBasic usage:\\n\\n```lua\\nlocal a = {1, 2, 3}\\n\\nassert(iter(a):all(function(x)\\n\\treturn x > 0\\nend))\\n\\nassert(not iter(a):all(function(x)\\n\\treturn x > 2\\nend))\\n```\\n\\nStopping at the first false:\\n\\n```lua\\nlocal a = {1, 2, 3}\\n\\nlocal iterator = iter(a)\\n\\nassert(not iterator:all(function(x)\\n\\treturn x ~= 2\\nend))\\n\\n-- we can still use `iter`, as there are more elements.\\nassert(next(iterator) == 3)\\n```","params":[{"name":"predicate","desc":"","lua_type":"(...any) -> boolean"}],"returns":[{"desc":"","lua_type":"boolean\\n"}],"function_type":"method","source":{"line":103,"path":"src/init.lua"}},{"name":"asMut","desc":"Ensures `table.freeze` doesn\'t get called when iterator gets collected.\\n\\n# Deviations\\nIn Rust this is done by specifying `mut` to the assigning variable,\\nbut this is not a feature in Lua.","params":[],"returns":[{"desc":"","lua_type":"iter"}],"function_type":"method","source":{"line":122,"path":"src/init.lua"}},{"name":"any","desc":"Tests if any element of the iterator matches a predicate.\\n\\n`any()` takes a function that returns `true` or `false`. It applies this\\nfunction to each element of the iterator, and if any of them return\\n`true`, then so does `any()`. If they all return `false`, it returns `false`.\\n\\n`any()` is short-circuiting; in other words, it will stop processing\\nas soon as it finds a true, given that no matter what else happens,\\nthe result will also be true.\\n\\nAn empty iterator returns `false`.\\n\\n# Examples\\n\\nBasic usage:\\n\\n```lua\\nlocal a = {1, 2, 3}\\n\\nassert(iter(a):all(function(x)\\n\\treturn x > 0\\nend))\\n\\nassert(not iter(a):all(function(x)\\n\\treturn x > 5\\nend))\\n```\\n\\nStopping at the first true:\\n\\n```lua\\nlocal a = {1, 2, 3}\\n\\nlocal iterator = iter(a)\\n\\nassert(not iterator:all(function(x)\\n\\treturn x ~= 2\\nend))\\n\\n-- we can still use `iter`, as there are more elements.\\nassert(next(iterator) == 2)\\n```","params":[{"name":"predicate","desc":"","lua_type":"(...any) -> boolean"}],"returns":[{"desc":"","lua_type":"boolean\\n"}],"function_type":"method","source":{"line":171,"path":"src/init.lua"}},{"name":"count","desc":"Consumes the iterator, counting the number of iterations and returning it.\\n\\nThis method will call [`next`] repeatedly until `nil` is encountered, returning the\\nnumber of times it saw values. Note that [`next`] has to be called at least once even\\nif the iterator does not have any elements.","params":[],"returns":[{"desc":"","lua_type":"number\\n"}],"function_type":"method","source":{"line":188,"path":"src/init.lua"}},{"name":"collect","desc":"Transforms an iterator into a table.\\n\\n`collect()` can take anything iterable, and turn it into a relevant table.\\nThis is one of the more powerful methods in the standard library, used in a variety of contexts.\\n\\nThe most basic pattern in which `collect()` is used is to turn one table into\\nanother. You take a table, call [`iter`] on it, do a bunch of transformations,\\nand then `collect()` at the end.\\n\\n# Deviations\\nThe returned table is frozen by default if [`asMut`] was never called.","params":[],"returns":[{"desc":"","lua_type":"{ [any]: any }\\n"}],"function_type":"method","source":{"line":210,"path":"src/init.lua"}},{"name":"collectArray","desc":"Same thing as [`collect`], but turns table into arrays of its values and discards its keys.\\n\\n# Deviations\\n* In Rust this would be done by using [`collect`] and specifying the type, but types in lua\\ndo not affect the runtime.\\n* The returned table is frozen by default if [`asMut`] was never called.","params":[],"returns":[{"desc":"","lua_type":"{ any }\\n"}],"function_type":"method","source":{"line":228,"path":"src/init.lua"}},{"name":"enumerate","desc":"Creates an iterator which gives the current iteration count as well as the next value.\\n\\nThe iterator returned yields pairs `(i, val)` for arrays and `(i, key, val)` for dicts,\\nwhere i is the current index of iteration.\\n\\n# Examples\\n```lua\\nlocal a = {\'a\', \'b\', \'c\'}\\n\\nlocal iterator = array(a).enumerate()\\n\\nprint(iterator:next()) -> 1, \\"a\\"\\nprint(iterator:next()) -> 2, \\"b\\"\\nprint(iterator:next()) -> 3, \\"c\\"\\nprint(iterator:next()) -> nil\\n\\nlocal b = {\\n\\takey = \'a\',\\n\\tbkey = \'b\',\\n\\tckey = \'c\',\\n}\\n\\niterator = dict(b).enumerate()\\n\\nprint(iterator:next()) -> 1, \\"akey\\", \\"a\\"\\nprint(iterator:next()) -> 2, \\"bkey\\", \\"b\\"\\nprint(iterator:next()) -> 3, \\"ckey\\", \\"c\\"\\nprint(iterator:next()) -> nil\\n```\\n\\n# Deviations\\n* For dicts, the iterator returned yields tuples `(i, key, val)`\\n* Indexing starts at 1","params":[],"returns":[{"desc":"","lua_type":"iter"}],"function_type":"method","source":{"line":278,"path":"src/init.lua"}},{"name":"last","desc":"Consumes the iterator, returning the last element.\\n\\nFor non-arrays, this method will evaluate the iterator until it returns `nil`.\\nWhile doing so, it keeps track of the current element. After `nil` is returned,\\n`last()` will then return the last element it saw.\\n\\n# Examples\\nBasic usage:\\n\\n```lua\\nlocal a = {1, 2, 3}\\nassert(array(a).last() == 3)\\n\\nlocal a = {1, 2, 3, 4, 5}\\nassert(array(a).last() == 5)\\n```","params":[],"returns":[{"desc":"","lua_type":"any\\n"}],"function_type":"method","source":{"line":301,"path":"src/init.lua"}},{"name":"map","desc":"Takes a closure and creates an iterator which calls that closure on each element.\\n\\n`map()` transforms one iterator into another. It produces a new iterator which calls this\\nclosure on each element of the original iterator.\\n\\nIf you are good at thinking in types, you can think of `map()` like this: If you have an\\niterator that gives you elements of some type `A`, and you want an iterator of some other\\ntype `B`, you can use `map()`, passing a closure that takes an `A` and returns a `B`.\\n\\n`map()` is conceptually similar to a `for` loop. If you\'re doing some sort of looping for a side\\neffect, it\'s considered more idiomatic to use for than `map()`.","params":[{"name":"transformer","desc":"","lua_type":"(...any) -> any"}],"returns":[{"desc":"","lua_type":"iter"}],"function_type":"method","source":{"line":325,"path":"src/init.lua"}},{"name":"mapWhile","desc":"Creates an iterator that both yields elements based on a predicate and maps.\\n\\n`mapWhile()` takes a function as an argument. It will call this function on each element\\nof the iterator, and yield elements while it returns non-nil.","params":[{"name":"transformer","desc":"","lua_type":"(...any) -> any"}],"returns":[{"desc":"","lua_type":"iter"}],"function_type":"method","source":{"line":343,"path":"src/init.lua"}},{"name":"next","desc":"Advances the iterator and returns the next value.\\n\\nReturns `nil` when iteration is finished.\\n\\n# Examples\\nBasic usage:\\n\\n```lua\\nlocal a = {1, 2, 3}\\n\\nlocal iterator = iter.array(a)\\n\\n-- A call to next() returns the next value...\\nassert(1 == iter.next())\\nassert(2 == iter.next())\\nassert(3 == iter.next())\\n\\n-- ... and then `nil` once it\'s over.\\nassert(nil == iter.next())\\n```","params":[],"returns":[{"desc":"","lua_type":"any\\n"}],"function_type":"method","source":{"line":380,"path":"src/init.lua"}},{"name":"filter","desc":"Creates an iterator which uses a closure to determine if an element should be yielded.\\n\\nGiven an element the closure must return true or false. The returned iterator will yield\\nonly the elements for which the closure returns true.","params":[{"name":"predicate","desc":"","lua_type":"(any, any) -> boolean"}],"returns":[{"desc":"","lua_type":"iter"}],"function_type":"method","source":{"line":393,"path":"src/init.lua"}},{"name":"forEach","desc":"Calls a closure on each element of an iterator.\\n\\nThis is equivalent to using a for loop on the iterator, although break\\nand continue are not possible from a closure. It\'s generally more idiomatic\\nto use a for loop, but for_each may be more legible when processing items at\\nthe end of longer iterator chains.\\n\\n#Examples\\nBasic usage:\\n\\n```lua\\ntb.array({ 0, 1, 2 })\\n\\t:map(function(x: number)\\n\\t\\treturn x * 100\\n\\tend)\\n\\t:enumerate()\\n\\t:filter(function(i: number, x: number)\\n\\t\\treturn (i + x) % 3 == 0\\n\\tend)\\n\\t:for_each(function(i: number, x: number)\\n\\t\\tprint(`{i}:{x}`)\\n\\tend)\\n```","params":[{"name":"f","desc":"","lua_type":"(...any) -> ()"}],"returns":[],"function_type":"method","source":{"line":434,"path":"src/init.lua"}}],"properties":[],"types":[],"name":"iter","desc":"","source":{"line":4,"path":"src/init.lua"}}')}}]);