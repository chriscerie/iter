--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local iter = require(ReplicatedStorage.Packages.iter)

return function()
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
end
