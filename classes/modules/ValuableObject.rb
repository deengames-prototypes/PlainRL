module ValuableObject
	def effective_cost
		raw = self.cost
		if raw < 10000
			return raw
		elsif (raw >= 10000 && raw < 1000000)
			return "#{raw.to_s[0 ... -3]}k"
		else
			return "#{raw.to_s[0 ... -6]}m"
		end
	end
end