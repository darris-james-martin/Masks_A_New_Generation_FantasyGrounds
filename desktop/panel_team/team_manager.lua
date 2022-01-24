--Global
local TEAM_CONTROL;

function registerControl(ctrl)
	TEAM_CONTROL = ctrl;
	if ctrl then
		updatePS();
		updateTeam();
	end
end

function updatePS()
	DB.addHandler("partysheet.num_total_team", "onUpdate", updateTeam);
end

function updateTeam()
	local nTeamDisplay = TEAM_CONTROL.num_team.getValue();
	local nTeamPS = DB.getValue("partysheet.num_total_team",0);
	TEAM_CONTROL.num_team.setValue(nTeamPS);
	--Debug.chat("nTeamDisplay",nTeamDisplay,"nTeamPS",nTeamPS);
	
end

function getTeamValue()
	return TEAM_CONTROL.num_team.getValue();
end

function setTeamValue(num)
	TEAM_CONTROL.num_team.setValue(nTeamPS);
end

