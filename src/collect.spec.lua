--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local iter = require(ReplicatedStorage.Packages.iter)

return function()
	describe("collect", function()
		it("should be immutable by default if `asMut` was not called", function()
			local result = iter.new({}):collect()
			expect(table.isfrozen(result)).to.be.equal(true)
		end)
	end)
end
