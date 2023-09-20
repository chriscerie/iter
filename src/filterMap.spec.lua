--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local iter = require(ReplicatedStorage.Packages.iter)

return function()
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
end
