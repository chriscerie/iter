local controlFlow = require(script.Parent.controlFlow)

type ValueWithBreak<T> = T | controlFlow.Break

export type AnyIter<K> = {
	all: (self: AnyIter<K>, f: (key: K, value: any) -> boolean) -> AnyIter<K>,
	asMut: (self: AnyIter<K>) -> AnyIter<K>,
	any: (self: AnyIter<K>, f: (key: K, value: any) -> boolean) -> boolean,
	count: (self: AnyIter<K>) -> number,
	collect: (self: AnyIter<K>) -> { [K]: any },
	collectArray: (self: AnyIter<K>) -> { any },
	filter: (self: AnyIter<K>, f: (key: K, value: any) -> boolean) -> AnyIter<K>,
	filterMap: <N>(self: AnyIter<K>, f: (key: K, value: any) -> N?) -> AnyIter<K>,
	find: (self: AnyIter<K>, f: (key: K, value: any) -> boolean) -> (K, any) | controlFlow.None,
	findMap: <N>(self: AnyIter<K>, f: (key: K, value: any) -> N?) -> (K, N) | controlFlow.None,
	fold: <T, N>(self: AnyIter<K>, init: T, f: (acc: T | N, key: K, value: any) -> N) -> T | N,
	tryFold: <T, N>(self: AnyIter<K>, init: T, f: (acc: T | N, key: K, value: any) -> N) -> T | N,
	forEach: (self: AnyIter<K>, f: (key: K, value: any) -> ()) -> (),
	inspect: (self: AnyIter<K>, f: (key: K, value: any) -> ()) -> AnyIter<K>,
	last: (self: AnyIter<K>) -> (K, any),
	map: <N>(self: AnyIter<K>, f: (key: K, value: any) -> N) -> AnyIter<K>,
	mapWhile: <N>(self: AnyIter<K>, f: (key: K, value: any) -> N?) -> AnyIter<K>,
	next: (self: AnyIter<K>) -> (K, any)?,
	reduce: <N>(self: AnyIter<K>, f: (acc: any | N, key: K, value: any) -> N) -> N,
	take: <N>(self: AnyIter<K>, n: number) -> AnyIter<K>,
}

export type Iter<K, V> = {
	all: (self: Iter<K, V>, f: (key: K, value: V) -> boolean) -> AnyIter<K>,
	asMut: (self: Iter<K, V>) -> Iter<K, V>,
	any: (self: Iter<K, V>, f: (key: K, value: V) -> boolean) -> boolean,
	count: (self: Iter<K, V>) -> number,
	collect: (self: Iter<K, V>) -> { [K]: V },
	collectArray: (self: Iter<K, V>) -> { V },
	filter: (self: Iter<K, V>, f: (key: K, value: V) -> boolean) -> Iter<K, V>,
	filterMap: <N>(self: Iter<K, V>, f: (key: K, value: V) -> N?) -> AnyIter<K>,
	find: (self: Iter<K, V>, f: (key: K, value: V) -> boolean) -> (K, V) | controlFlow.None,
	findMap: <N>(self: Iter<K, V>, f: (key: K, value: V) -> N?) -> (K, N) | controlFlow.None,
	fold: <T, N>(self: Iter<K, V>, init: T, f: (acc: T | N, key: K, value: V) -> N) -> T | N,
	forEach: (self: Iter<K, V>, f: (key: K, value: V) -> ()) -> (),
	inspect: (self: Iter<K, V>, f: (key: K, value: V) -> ()) -> Iter<K, V>,
	last: (self: Iter<K, V>) -> (K, V),
	map: <N>(self: Iter<K, V>, f: (key: K, value: V) -> N) -> AnyIter<K>,
	mapWhile: <N>(self: Iter<K, V>, f: (key: K, value: V) -> N?) -> AnyIter<K>,
	next: (self: Iter<K, V>) -> (K, V) | controlFlow.None,
	reduce: <N>(self: Iter<K, V>, f: (acc: V | N, key: K, value: V) -> N) -> V | N,
	take: <N>(self: Iter<K, V>, n: number) -> Iter<K, V>,
	tryFold: <T, N>(self: Iter<K, V>, init: T, f: (acc: T | N, key: K, value: V) -> N) -> T | N,

	_getInputTuple: (self: Iter<K, V>, key: K?, value: V?) -> (K, V) | controlFlow.None,
	_next: (self: Iter<K, V>, last: K?) -> (K, V)?,

	_value: { [K]: V },
	_lastKey: K?,
	_asMut: boolean,
	_iterationCount: number,
}

return {}
