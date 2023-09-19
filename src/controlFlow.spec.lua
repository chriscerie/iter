--!strict
local controlFlow = require(script.Parent.controlFlow)

return function()
	describe("controlFlow", function()
		describe("break", function()
			it("should be able to be compared", function()
				local a = controlFlow.Break(1)
				local b = controlFlow.Break(1)
				local c = controlFlow.Break(2)

				expect(a).to.be.equal(b)
				expect(a).to.never.be.equal(c)
				expect(a).to.never.be.equal(1)
			end)
		end)
	end)
end
