hook.Add('CanTool', 'CanToolOwn', function(pl, trace, tool)
	local ent = trace.Entity
	return (IsValid(ent) and (ent:GetOwner(pl)))
end)