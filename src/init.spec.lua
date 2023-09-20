--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local iter = require(ReplicatedStorage.Packages.iter)

return function()
	describe("iter", function()
		describe("any", function()
			it("should return true if any predicate is true", function()
				local result = iter.new({ 1, 2, 3 }):any(function()
					return true
				end)
				expect(result).to.be.equal(true)
			end)

			it("should return false if all predicates are false", function()
				local result = iter.new({ 1, 2, 3 }):any(function()
					return false
				end)
				expect(result).to.be.equal(false)
			end)

			it("should return false if the iterator is empty", function()
				local result = iter.new({}):any(function()
					return true
				end)
				expect(result).to.be.equal(false)
			end)

			it("should short circuit on the first true", function()
				local a = { 1, 2, 3 }

				local iterator = iter.new(a)

				expect(iterator:any(function(_, x)
					return x == 2
				end)).to.be.equal(true)

				-- we can still use `iter`, as there are more elements.
				expect(iterator:next()).to.be.equal(3)
			end)

			it("should short circuit on the first true when appended to other operations", function()
				local a = { 1, 2, 3 }
				local numCalledMap = 0
				local numCalledFilter = 0

				local iterator = iter.new(a)

				expect(iterator
					:map(function(i, x)
						numCalledMap += 1
						expect(i).to.be.a("number")
						expect(x).to.be.a("number")
						return -x
					end)
					:filter(function(i, x)
						numCalledFilter += 1
						expect(i).to.be.a("number")
						expect(x).to.be.a("number")
						return true
					end)
					:all(function(i, x)
						expect(i).to.be.a("number")
						expect(x).to.be.a("number")
						return x ~= -2
					end)).to.be.equal(false)

				expect(numCalledMap).to.be.equal(2)
				expect(numCalledFilter).to.be.equal(2)

				-- we can still use `iter`, as there are more elements.
				expect(iterator:next()).to.be.equal(3)
			end)
		end)

		describe("count", function()
			it("should return 0 for empty iterator", function()
				expect(iter.new({}):count()).to.be.equal(0)
				expect(iter.new({}):count()).to.be.equal(0)
			end)

			it("should return number of elements", function()
				local result = iter.new({ 1, 2, 3 }):count()
				expect(result).to.be.equal(3)

				result = iter.new({ a = 1, b = 2, c = 3 }):count()
				expect(result).to.be.equal(3)
			end)
		end)

		describe("collect", function()
			it("should be immutable by default if `asMut` was not called", function()
				local result = iter.new({}):collect()
				expect(table.isfrozen(result)).to.be.equal(true)
			end)
		end)

		describe("collectArray", function()
			it("should be immutable by default if `asMut` was not called", function()
				local result = iter.new({}):collectArray()
				expect(table.isfrozen(result)).to.be.equal(true)
			end)
		end)

		describe("filter", function()
			it("should generate new iterator of filtered values", function()
				local t = { 1, 2, 3 }
				local result = iter.new(t)
					:filter(function(_, value: number)
						return value % 2 == 0
					end)
					:collect()

				expect(result[1]).to.be.equal(nil)
				expect(result[2]).to.be.equal(2)
				expect(result[3]).to.be.equal(nil)
			end)
		end)

		describe("filter", function()
			it("should filter and move values forward in an array", function()
				local t = { 1, 2, 3 }
				local result = iter.new(t)
					:filterMap(function(_, value: number)
						return if value % 2 == 0 then nil else -value
					end)
					:collect()

				print(result)

				expect(result[1]).to.be.equal(-1)
				expect(result[2]).to.be.equal(-3)
				expect(result[3]).to.be.equal(nil)
			end)
		end)

		describe("findMap", function()
			it("should find the first non-nil", function()
				local a = { "lol", "hi", "2", "5" }

				local i, firstNumber = iter.new(a):findMap(function(_, s)
					return tonumber(s)
				end)

				expect(i).to.be.equal(3)
				expect(firstNumber).to.be.equal(2)
			end)

			it("should return nil if all are nil", function()
				local a = { "lol", "hi", "2", "5" }

				local key, value = iter.new(a):findMap(function()
					return nil
				end)

				expect(key).to.be.equal(nil)
				expect(value).to.be.equal(nil)
			end)
		end)

		describe("fold", function()
			it("should accumulate numbers", function()
				local a = { 1, 2, 3 }

				local sum = iter.new(a):fold(0, function(acc, _, x)
					return acc + x
				end)

				expect(sum).to.be.equal(6)
			end)

			it("should accumulate strings", function()
				local numbers = { 1, 2, 3, 4, 5 }

				local result = iter.new(numbers):fold("0", function(acc, _, x)
					return `({acc} + {x})`
				end)

				expect(result).to.be.equal("(((((0 + 1) + 2) + 3) + 4) + 5)")
			end)
		end)

		describe("forEach", function()
			it("should be called on each element", function()
				local t = { 1, 2, 3 }
				local calledNum = 0

				iter.new(t):forEach(function(_: number)
					calledNum = calledNum + 1
				end)

				expect(calledNum).to.be.equal(#t)
			end)
		end)

		describe("last", function()
			it("should return last element of array", function()
				local i, last = iter.new({ 10, 20, 30 }):last()

				expect(i).to.be.equal(3)
				expect(last).to.be.equal(30)
			end)
		end)

		describe("map", function()
			it("should generate new iterator of transformed values", function()
				local t = { 1, 2, 3 }
				local result = iter.new(t)
					:map(function(_, value: number)
						return value * 2
					end)
					:collect()

				expect(#result).to.be.equal(#t)
				for i, v in result do
					expect(v).to.be.equal(t[i] * 2)
				end
			end)

			it("does not short circuit on nil", function()
				local t = { 1, 2, 3 }
				local result = iter.new(t)
					:map(function(_, value: number)
						return if value == 2 then nil else value * 2
					end)
					:collect()

				expect(result[1]).to.be.equal(2)
				expect(result[2]).to.be.equal(nil)
				expect(result[3]).to.be.equal(6)
			end)
		end)

		describe("mapWhile", function()
			it("should generate new iterator of transformed values", function()
				local t = { 1, 2, 3 }
				local result = iter.new(t)
					:mapWhile(function(_, value: number)
						return value * 2
					end)
					:collect()

				expect(iter.new(result):count()).to.be.equal(#t)
				for i, v in result do
					expect(v).to.be.equal(t[i] * 2)
				end
			end)

			it("should short circuit on nil", function()
				local t = { 1, 2, 3 }
				local result = iter.new(t)
					:mapWhile(function(_, value: number)
						return if value == 2 then nil else value * 2
					end)
					:collect()

				expect(iter.new(result):count()).to.be.equal(1)
				expect(result[1]).to.be.equal(2)
			end)

			it("should work when chained to other operations", function()
				local t = { 1, 2, 3 }
				local result = iter.new(t)
					:mapWhile(function(_, value)
						return if value == 2 then nil else value
					end)
					:filter(function(_, value)
						expect(value).to.be.a("number")
						return true
					end)
					:count()

				expect(result).to.be.equal(1)
			end)

			it("should short circuit when chained to other operations", function()
				local t = { 1, 2, 3, 4, 5, 6 }
				local countMap = 0

				iter.new(t)
					:mapWhile(function(_, value)
						countMap += 1
						return if value == 5 then nil else value
					end)
					:filter(function(_, value)
						countMap += 1
						return value <= 5
					end)
					:mapWhile(function(_, value)
						return if value == 2 then nil else value
					end)
					:fold(0, function(acc, _, value)
						return acc + value
					end)

				expect(countMap).to.be.equal(4)
			end)
		end)

		describe("reduce", function()
			it("should accumulate numbers", function()
				local a = { 1, 2, 3 }

				local sum = iter.new(a):reduce(function(acc, _, x)
					return acc + x
				end)

				expect(sum).to.be.equal(6)
			end)

			it("should accumulate strings", function()
				local numbers = { 0, 1, 2, 3, 4, 5 }

				local result = iter.new(numbers):reduce(function(acc, _, x)
					return `({acc} + {x})`
				end)

				expect(result).to.be.equal("(((((0 + 1) + 2) + 3) + 4) + 5)")
			end)
		end)

		describe("take", function()
			it("should take up to `n` elements", function()
				local a = { 1, 2, 3, 4, 5, 6 }

				local result = iter.new(a):take(3):collect()

				expect(#result).to.be.equal(3)
				expect(result[1]).to.be.equal(1)
				expect(result[2]).to.be.equal(2)
				expect(result[3]).to.be.equal(3)
			end)

			it("should take all elements if total num < `n`", function()
				local a = { 1, 2, 3 }

				local result = iter.new(a):take(6):collect()

				expect(#result).to.be.equal(3)
				expect(result[1]).to.be.equal(1)
				expect(result[2]).to.be.equal(2)
				expect(result[3]).to.be.equal(3)
			end)
		end)

		describe("tryFold", function()
			it("should accumulate numbers", function()
				local a = { 1, 2, 3 }

				local sum = iter.new(a):tryFold(0, function(acc, _, x)
					return acc + x
				end)

				expect(sum).to.be.equal(6)
			end)

			it("should accumulate strings", function()
				local numbers = { 1, 2, 3, 4, 5 }

				local result = iter.new(numbers):tryFold("0", function(acc, _, x)
					return `({acc} + {x})`
				end)

				expect(result).to.be.equal("(((((0 + 1) + 2) + 3) + 4) + 5)")
			end)

			it("should return `None` if fn returns `nil`", function()
				local numbers = { 1, 2, 3, 4, 5 }

				local iterator = iter.new(numbers)

				local result = iterator:tryFold("0", function(acc, _, x)
					if x == 3 then
						return nil
					end
					return `({acc} + {x})`
				end)

				expect(result).to.be.equal(iter.None)
				expect(iterator:next()).to.be.equal(4)
			end)
		end)
	end)
end
