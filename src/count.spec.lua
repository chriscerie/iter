--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local iter = require(ReplicatedStorage.Packages.iter)

return function()
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
end
