--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local iter = require(ReplicatedStorage.Packages.iter)

return function()
	describe("map", function()
		it("should generate new iterator of transformed values", function()
			local t = { 1, 2, 3 }
			local result = iter.new(t)
				:map(function(_, value: number)
					return value * 2
				end)
				:collect()

			expect(#result).to.be.equal(#t)
			for i, v in result do
				expect(v).to.be.equal(t[i] * 2)
			end
		end)

		it("does not short circuit on nil", function()
			local t = { 1, 2, 3 }
			local result = iter.new(t)
				:map(function(_, value: number)
					return if value == 2 then nil else value * 2
				end)
				:collect()

			expect(result[1]).to.be.equal(2)
			expect(result[2]).to.be.equal(nil)
			expect(result[3]).to.be.equal(6)
		end)
	end)
end
