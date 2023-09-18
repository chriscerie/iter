--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local iter = require(ReplicatedStorage.Packages.iter)

return function()
	describe("iter", function()
		describe("any", function()
			it("should return true if any predicate is true", function()
				local result = iter.array({ 1, 2, 3 }):any(function()
					return true
				end)
				expect(result).to.be.equal(true)
			end)

			it("should return false if all predicates are false", function()
				local result = iter.array({ 1, 2, 3 }):any(function()
					return false
				end)
				expect(result).to.be.equal(false)
			end)

			it("should return false if the iterator is empty", function()
				local result = iter.array({}):any(function()
					return true
				end)
				expect(result).to.be.equal(false)
			end)

			it("should short circuit on the first true", function()
				local a = { 1, 2, 3 }

				local iterator = iter.array(a)

				expect(iterator:all(function(x)
					return x ~= 2
				end)).to.be.equal(false)

				-- we can still use `iter`, as there are more elements.
				expect(iterator:next()).to.be.equal(2)
			end)
		end)

		describe("count", function()
			it("should return 0 for empty iterator", function()
				expect(iter.array({}):count()).to.be.equal(0)
				expect(iter.dict({}):count()).to.be.equal(0)
			end)

			it("should return number of elements", function()
				local result = iter.array({ 1, 2, 3 }):count()
				expect(result).to.be.equal(3)
			end)
		end)

		describe("collect", function()
			it("should be immutable by default if `asMut` was not called", function()
				local result = iter.array({}):collect()
				expect(table.isfrozen(result)).to.be.equal(true)
			end)
		end)

		describe("collectArray", function()
			it("should be immutable by default if `asMut` was not called", function()
				local result = iter.array({}):collectArray()
				expect(table.isfrozen(result)).to.be.equal(true)
			end)
		end)

		describe("enumerate", function()
			it("should give the index and value of array.last", function()
				local t = { "a", "b", "c" }
				local i, value = iter.array(t):enumerate():last()

				expect(i).to.be.equal(#t)
				expect(value).to.be.equal(t[i])
			end)

			it("should give index, key, and value of dict.last", function()
				local t = {
					akey = "a",
					bkey = "b",
					ckey = "c",
				}
				local i, key, value = iter.dict(t):enumerate():last()

				expect(i).to.be.equal(3)
				expect(key).to.be.ok()
				expect(value).to.be.equal(t[key])
			end)
		end)

		describe("filter", function()
			it("should generate new iterator of filtered values", function()
				local t = { 1, 2, 3 }
				local result = iter.array(t)
					:filter(function(value: number)
						return value % 2 == 0
					end)
					:collect()

				expect(#result).to.be.equal(1)
				expect(result[1]).to.be.equal(2)
			end)
		end)

		describe("forEach", function()
			it("should be called on each element", function()
				local t = { 1, 2, 3 }
				local calledNum = 0

				iter.array(t):forEach(function(_value: number)
					calledNum = calledNum + 1
				end)

				expect(calledNum).to.be.equal(#t)
			end)
		end)

		describe("last", function()
			it("should return last element of array", function()
				local last = iter.array({ 10, 20, 30 }):last()

				expect(last).to.be.equal(30)
			end)
		end)

		describe("map", function()
			it("should generate new iterator of transformed values", function()
				local t = { 1, 2, 3 }
				local result = iter.array(t)
					:map(function(value: number)
						return value * 2
					end)
					:collect()

				expect(#result).to.be.equal(#t)
				for i, v in result do
					expect(v).to.be.equal(t[i] * 2)
				end
			end)

			it("should set values to appropriate keys when returning 2 values", function()
				local t = { 1, 2, 3 }
				local result = iter.array(t)
					:map(function(value: number)
						return value * 2, true
					end)
					:collect()

				for _, v in t do
					expect(result[v * 2]).to.be.equal(true)
				end
			end)
		end)

		describe("mapWhile", function()
			it("should generate new iterator of transformed values", function()
				local t = { 1, 2, 3 }
				local result = iter.array(t)
					:mapWhile(function(value: number)
						return value * 2
					end)
					:collect()

				expect(iter.dict(result):count()).to.be.equal(#t)
				for i, v in result do
					expect(v).to.be.equal(t[i] * 2)
				end
			end)

			it("should short circuit on nil", function()
				local t = { 1, 2, 3 }
				local result = iter.array(t)
					:mapWhile(function(value: number)
						return if value == 2 then nil else value * 2
					end)
					:collect()

				expect(iter.dict(result):count()).to.be.equal(1)
				expect(result[1]).to.be.equal(2)
			end)

			it("should set values to appropriate keys when returning 2 values", function()
				local t = { 1, 2, 3 }
				local result = iter.array(t)
					:mapWhile(function(value: number)
						return value * 2, true
					end)
					:collect()

				for _, v in t do
					expect(result[v * 2]).to.be.equal(true)
				end
			end)
		end)
	end)
end
