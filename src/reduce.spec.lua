--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local iter = require(ReplicatedStorage.Packages.iter)

return function()
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
end
