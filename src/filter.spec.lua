--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local iter = require(ReplicatedStorage.Packages.iter)

return function()
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
end
