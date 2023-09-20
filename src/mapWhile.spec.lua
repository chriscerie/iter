--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local iter = require(ReplicatedStorage.Packages.iter)

return function()
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
end
