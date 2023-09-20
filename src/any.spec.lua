local ReplicatedStorage = game:GetService("ReplicatedStorage")

local iter = require(ReplicatedStorage.Packages.iter)

return function()
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
end
