--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local iter = require(ReplicatedStorage.Packages.iter)

return function()
	describe("take", function()
		it("should take up to `n` elements", function()
			local a = { 1, 2, 3, 4, 5, 6 }

			local result = iter.new(a):take(3):collect()

			expect(#result).to.be.equal(3)
			expect(result[1]).to.be.equal(1)
			expect(result[2]).to.be.equal(2)
			expect(result[3]).to.be.equal(3)
		end)

		it("should take all elements if total num < `n`", function()
			local a = { 1, 2, 3 }

			local result = iter.new(a):take(6):collect()

			expect(#result).to.be.equal(3)
			expect(result[1]).to.be.equal(1)
			expect(result[2]).to.be.equal(2)
			expect(result[3]).to.be.equal(3)
		end)
	end)
end
