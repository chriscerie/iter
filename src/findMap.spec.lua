--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local iter = require(ReplicatedStorage.Packages.iter)

return function()
	describe("findMap", function()
		it("should find the first non-nil", function()
			local a = { "lol", "hi", "2", "5" }

			local i, firstNumber = iter.new(a):findMap(function(_, s)
				return tonumber(s)
			end)

			expect(i).to.be.equal(3)
			expect(firstNumber).to.be.equal(2)
		end)

		it("should return nil if all are nil", function()
			local a = { "lol", "hi", "2", "5" }

			local key, value = iter.new(a):findMap(function()
				return nil
			end)

			expect(key).to.be.equal(nil)
			expect(value).to.be.equal(nil)
		end)
	end)
end
