
function prepRoll(nodeChar, nodeLink)
	-- declarations
	--local nodeChar = window.windowlist.window.getDatabaseNode();
    --local nodeLink = window.link.getTargetDatabaseNode();
    local rAddText = {};
    local sName = nodeLink.getChild("name").getValue();
    local sStats = nodeLink.getChild("str_stats").getValue();
    local sCondition = nodeLink.getChild("str_condition").getValue();
	local bShow = DB.getValue(nodeLink,"box_show",0) == 1;
	local bHold = DB.getValue(nodeLink,"box_hold",0) == 1;  
	local bOngoing = DB.getValue(nodeLink,"box_ongoing",0) == 1;  
	local nHoldNotRolled = DB.getValue(nodeLink,"num_notrolled_hold",0); 
	local nHoldSuccess = DB.getValue(nodeLink,"num_strong_hold",0);
	local nHoldSuccessCost = DB.getValue(nodeLink,"num_weak_hold",0);
	local nHoldMiss = DB.getValue(nodeLink,"num_miss_hold",0);
	local nOngoingNotRolled = DB.getValue(nodeLink,"num_ongoing_noroll",0);
	local nOngoingSuccess = DB.getValue(nodeLink,"num_ongoing_success",0);
	local nOngoingSuccessCost = DB.getValue(nodeLink,"num_ongoing_successcost",0);
	local nOngoingMiss = DB.getValue(nodeLink,"num_ongoing_miss",0);
	local nMoveBonus = DB.getValue(nodeLink,"num_bonus",0);
	local sDescription = DB.getValue(nodeLink,"str_description","");
	local sSuccess = DB.getValue(nodeLink,"str_success","");
	local sSuccessCost = DB.getValue(nodeLink,"str_success_cost","");
	local sMiss = DB.getValue(nodeLink,"str_miss","");
	
	-- if Show
	if bShow then
		--has hold or Ongoing Effects
		if bHold or bOngoing then
			local nodeOnGoingEffects = nodeChar.getChild("wl_ongoing_effects");
			--Debug.chat("nodeOnGoingEffects",nodeOnGoingEffects);
			local doNotFound = true;
			
			for sListClass,rListRecord in pairs(nodeOnGoingEffects.getChildren()) do
				--Debug.chat("sListClass: ",sListClass," rListRecord: ",rListRecord);
				
				if rListRecord.getChild("name").getValue() == sName then
					--Debug.chat("rListRecord found Name");
					rListRecord.getChild("num_holds").setValue(nHoldNotRolled);
					rListRecord.getChild("num_ongoing").setValue(nOngoingNotRolled);
					rListRecord.getChild("str_description").setValue(sDescription);
					doNotFound = false;
				end
			end
			
			if doNotFound then
				--Debug.chat("Move not Found. Add");
				local node = nodeOnGoingEffects.createChild();				
				
				node.getChild("name").setValue(sName);
				node.getChild("num_holds").setValue(nHoldNotRolled);
				node.getChild("num_ongoing").setValue(nOngoingNotRolled);
				node.getChild("str_description").setValue(sDescription);
			end
		end
	
		--set Message Name
		local msg = 
		{
			font = "narratorfont", 
			mode = "ooc",				
			text = nodeChar.getChild("name").getValue();
		}
		Comm.deliverChatMessage(msg);
		
		-- set Message
		local msg = 
		{
			font = "chatfont", 
			mode = "ooc",
			icon = "portrait_" .. nodeChar.getName() .. "_chat",
			text = sDescription;
		}
		Comm.deliverChatMessage(msg);
		return true;
	end
    
    -- Crap Out
	if sStats == "" then
		return;
	end
	
	-- get Attribute Value
	if sStats == "None" then
		rAddText.nStat = 0;
	elseif sStats == "Danger" then
		rAddText.nStat = nodeChar.getChild("num_danger").getValue();
	elseif sStats == "Freak" then
		rAddText.nStat = nodeChar.getChild("num_freak").getValue();
	elseif sStats == "Savior" then
		rAddText.nStat = nodeChar.getChild("num_savior").getValue();
	elseif sStats == "Superior" then
		rAddText.nStat = nodeChar.getChild("num_superior").getValue();
	elseif sStats == "Mundane" then
		rAddText.nStat = nodeChar.getChild("num_mundane").getValue();
	elseif sStats == "Conditions" then
		local nMod = 0;
		if nodeChar.getChild("box_afraid").getValue() == 1 then nMod = nMod+1; end
		if nodeChar.getChild("box_angry").getValue() == 1 then nMod = nMod+1; end
		if nodeChar.getChild("box_guilty").getValue() == 1 then nMod = nMod+1; end
		if nodeChar.getChild("box_hopeless").getValue() == 1 then nMod = nMod+1; end
		if nodeChar.getChild("box_insecure").getValue() == 1 then nMod = nMod+1; end
			
		-- get Attribute Value
		rAddText.nStat = nMod;
	end
	
	-- Add Bonus
	rAddText.nMoveBonus = nMoveBonus;
	
	--Add Ongoing and Holds
	rAddText.nHoldSuccess = nHoldSuccess;
	rAddText.nHoldSuccessCost = nHoldSuccessCost;
	rAddText.nHoldMiss = nHoldMiss;
	rAddText.nOngoingSuccess = nOngoingSuccess;
	rAddText.nOngoingSuccessCost = nOngoingSuccessCost;
	rAddText.nOngoingMiss = nOngoingMiss;	
	
	-- Condition
	if sCondtion == "None" then
		--do nothing.
	elseif sCondition == "Afraid" then
		if nodeChar.getChild("box_afraid").getValue() == 1 then
			ModifierStack.addSlot(sCondition, -2);
		end
	elseif sCondition == "Angry" then
		if nodeChar.getChild("box_angry").getValue() == 1 then
			ModifierStack.addSlot(sCondition, -2);
		end
	elseif sCondition == "Guilty" then
		if nodeChar.getChild("box_guilty").getValue() == 1 then
			ModifierStack.addSlot(sCondition, -2);
		end
	elseif sCondition == "Hopeless" then
		if nodeChar.getChild("box_hopeless").getValue() == 1 then
			ModifierStack.addSlot(sCondition, -2);
		end
	elseif sCondition == "Insecure" then
		if nodeChar.getChild("box_insecure").getValue() == 1 then
			ModifierStack.addSlot(sCondition, -2);
		end
	end
	
	-- Fix Miss (if miss is blank)
	if sMiss == "" then
		sMiss = "MISS! GM Makes a Move.";
	end
	
	-- set Text
	rAddText.sMoveName = sName;
	rAddText.sAttackStat = sStats;
	rAddText.sAttackSuccess = sSuccess;
	rAddText.sAttackSuccessCost = sSuccessCost;	
	rAddText.sAttackMiss = sMiss;
    
    --Send to Roller
    --Debug.chat("rAddText",rAddText);
    manager_rolls.rollInit(nodeChar, "Action", rAddText);
end
