class WeaponSkill

	attr_accessor :subtype, :total_points
	
	def initialize(subtype)
		self.subtype = subtype
		self.total_points = 0
	end
	
	def points
		return self.total_points % Globals.point_per_weapon_skill_level
	end
	
	def level
		return self.total_points / Globals.point_per_weapon_skill_level
	end
end