--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local iter = require(ReplicatedStorage.Packages.iter)

return function()
	describe("forEach", function()
		it("should be called on each element", function()
			local t = { 1, 2, 3 }
			local calledNum = 0

			iter.new(t):forEach(function(_: number)
				calledNum = calledNum + 1
			end)

			expect(calledNum).to.be.equal(#t)
		end)
	end)
end
