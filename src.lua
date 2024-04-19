local mod = {}

--Types

type void = '0' 



local INITVALUETICK = tick()

type CombatCases = {
	[string] : number,
	CurrentCase : number,
	MaxCases : number,
	CaseDelay : number,
	CaseTimer : number,

	CanAttack : boolean,
	

	init : () -> void,


	Threads : {[thread] : thread}

}

type Constructor = {
	cases : CombatCases,
	
	new: () -> CombatCases

}

--

type Attack = { 
	Attacked : () -> void,
	
}

type State = {}

type HumanoidParams = {
	human : Humanoid,
	FadeOutAnimation : number,
	Priority : Enum.AnimationPriority,

	Animations : {
		
		[string] : Animation
	}
}


--

type SkillParams = {

	ActivateKey : Enum.KeyCode,
	IsPressing : boolean,

	Cooldown : number,
}

type Skill = {
	Start : () -> void,
	

}

---

mod.__index = mod


--[[=>{
--Metodos:
GetContext(name : string, constructor : {} | nil)


--=>}]]


function mod:GetContext(name : string, constructor : Constructor)
	
	local Definitions = {
		_CurrentContext = self,
		_CurrentContextName = name,

	}


	local self = constructor
	
	self.new = function()
		return constructor.cases
	end
	
	

	for  key, value in self do
		if type(self[key]) ~= 'boolean' or type(self[key]) ~= 'number' then continue end
		
		if not (self[key]>1) then  
			self[key] = 1
		end
	end

	print(self.cases)

	setmetatable(self, mod)	
	
	mod['defines'] = Definitions
	

	return self

end

local RecursiveAttributeValues = {
	['CurrentCase'] = 0,
	['MaxCases]'] = 1,
	['CaseDelay'] = 1,
	['CaseTimer'] = 1,
	
}

function mod:Init(HumanoidParams : HumanoidParams)
	
	local AnimsRecursive = {}

	pcall(function (args)
		for k,v in HumanoidParams.Animations do
			AnimsRecursive[k] = HumanoidParams.human:FindFirstChildOfClass('Animator'):LoadAnimation(v)
			
		end
		for _, anim : AnimationTrack in AnimsRecursive do
			anim.AnimationPriority = HumanoidParams.Priority

		end
	end)

	local MethodsManagerTemplate  = {}
	
	do
		for k, v in RecursiveAttributeValues do
			if not self.cases[k] then
				self.cases[k] = v
			end
		end
	end
	
	local _self = self
	
	
	function MethodsManagerTemplate:Attack(PostAttack : Attack)
		if not _self.cases.CanAttack then return end
		
		_self.cases.CanAttack = false
		
		
		local _el = 0
		
		_self.cases.CurrentCase = (_self.cases.CurrentCase % _self.cases.MaxCases) + 1
		
		pcall(function (args)
			AnimsRecursive[_self.cases.CurrentCase]:Play(HumanoidParams.FadeOutAnimation)

		end)
		
		local threads = {}
		
		for k, v in PostAttack do
			threads[k] = v
		end
		
		for k, v in threads do
			task.defer(v)
		end
		
		task.spawn(function()
			while task.wait() do
				_el = tick() - INITVALUETICK
				if _el >= _self.cases.CaseDelay then
					
					INITVALUETICK = tick()
					_self.cases.CanAttack = true
				end
			end
		end)

	end
	
	
	
	local AttackManager = setmetatable({}, {__index = MethodsManagerTemplate})
	
	
	return AttackManager
end

function mod:InitActivate(SkillParams : SkillParams)

	local Skill : Skill = {
		Start = function() end,
	}

	local uis = game:GetService('UserInputService')

	local MethodsManagerTemplate  = {}

	function MethodsManagerTemplate:Activate()
		task.defer(Skill.Start)
	end
	

	local isntance = setmetatable({}, {__index = MethodsManagerTemplate})

	uis.InputBegan:Connect(function(input, gameProcessedEvent)
		if input.KeyCode == SkillParams.ActivateKey and not gameProcessedEvent then
			


		end
	end)

end	


return mod
