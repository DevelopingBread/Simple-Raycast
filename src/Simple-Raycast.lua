local Raycast = {}

Raycast.constructers = {
	raycast = {},
	result = {}
}

Raycast.schemas = {
	raycast = {},
	result = {}
}

Raycast.metadata = {
	raycast = { __index = Raycast.schemas.raycast },
	result = { __index = Raycast.schemas.result }
}

export type RaycastPrams = {
	FilterDescendantsInstances: { Instance },
	FilterType: Enum.RaycastFilterType,
	IgnoreWater: boolean,
	CollisionGroup: string,
	RespectCanCollide: boolean
}

-- Constructors/Raycast
function Raycast.constructers.raycast.new(orgin_position: Vector3, direction: Vector3, raycast_prams: RaycastPrams): Raycast
	local self = setmetatable({}, Raycast.metadata.raycast)

	self.Orgin_position = orgin_position
	self.Direction = direction

	self.RaycastPrams = raycast_prams

	return self
end

function Raycast.constructers.raycast.new_with_points(orgin_position: Vector3, end_position: Vector3, raycast_prams: RaycastParams): Raycast
	local positional_sum = (end_position - orgin_position)

	return Raycast.constructers.raycast.new(
		orgin_position,
		positional_sum.Unit * positional_sum.Magnitude,
		raycast_prams
	)
end

-- Constructors/Result
function Raycast.constructers.result.new(raycast_result: RaycastResult, raycast_data: Raycast): Result
	local self = setmetatable({}, Raycast.metadata.result)

	self.RaycastResult = raycast_result
	self.RaycastData = raycast_data

	return raycast_result and self or nil
end

-- Methods/Raycast
function Raycast.schemas.raycast.ConvertRaycastPramsTable(self: Raycast): RaycastPrams
	local new_prams = RaycastParams.new()

	for key, value in pairs(self.RaycastPrams) do new_prams[key] = value end

	return new_prams
end

function Raycast.schemas.raycast.Cast(self: Raycast): Result
	local raycastResult = workspace:Raycast(
		self.Orgin_position,
		self.Direction,
		self:ConvertRaycastPramsTable()
	)

	return Raycast.constructers.result.new(raycastResult, self)
end

function Raycast.schemas.raycast.DrawLine(self: Raycast, part: BasePart?, color: Color3?, thickness: number?): Instance | nil
	local result = self:Cast()

	if not result then return nil end

	local new_part = part or Instance.new("Part")

	thickness = thickness or 0.1
	color = color or Color3.new(1, 1, 1)

	new_part.Anchored = true
	new_part.CanCollide = false

	new_part.Size = Vector3.new(thickness, thickness, result:GetDistance())
	new_part.Color = color

	new_part.CFrame = result:GetRaycastCenter()

	new_part.Parent = workspace

	return new_part
end

-- Methods/Result
function Raycast.schemas.result.GetHitPosition(self: Result): Vector3
	return self.RaycastResult.Position
end

function Raycast.schemas.result.GetNormal(self: Result): Vector3
	return self.RaycastResult.Normal
end

function Raycast.schemas.result.GetHitPart(self: Result): Instance
	return self.RaycastResult.Instance
end

function Raycast.schemas.result.GetHitMaterial(self: Result): Enum.Material
	return self.RaycastResult.Material
end

function Raycast.schemas.result.GetDistance(self: Result): number
	return self.RaycastResult.Distance
end

function Raycast.schemas.result.GetHitCFrame(self: Result): CFrame
	local normal = self:GetNormal()
	local position = self:GetHitPosition()

	return CFrame.lookAt(position, position + normal)
end

function Raycast.schemas.result.GetRaycastCenter(self: Result): CFrame
	return CFrame.lookAt(self.RaycastData.Orgin_position, self:GetHitPosition()) * CFrame.new(0, 0, -self:GetDistance() / 2)
end

-- Types
type Raycast = typeof(Raycast.constructers.raycast.new(table.unpack(...)))
type Result = typeof(Raycast.constructers.result.new(table.unpack(...)))

return Raycast.constructers.raycast