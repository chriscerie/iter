--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local iter = require(ReplicatedStorage.Packages.iter)

return function()
	describe("last", function()
		it("should return last element of array", function()
			local i, last = iter.new({ 10, 20, 30 }):last()

			expect(i).to.be.equal(3)
			expect(last).to.be.equal(30)
		end)
	end)
end
