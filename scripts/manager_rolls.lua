function rollInit(charNode, sType, rAddText)
    --Debug.chat("rollInit - charNode: ",charNode, " sType: ",sType, " rAddText: ",rAddText);
    
    
    --Choose Roll Type
    if sType == "Action" then
        preActionRoll(charNode, sType, rAddText);
	elseif sType == "Label" then
		preLabelRoll(charNode, sType, rAddText);	
    end

end

--[[
*************************************************************************************************************************************
********************************************** Action Rolls *************************************************************************
*************************************************************************************************************************************
]]--

function preActionRoll(charNode, sType, rAddText)
	--Debug.chat("preActionRoll - charNode: ",charNode, " sType: ",sType, " rAddText: ",rAddText);
    
    -- Use Diff Stack to set Difficulty
    local sModDesc, nModNum = ModifierStack.getStack(false);
    --Debug.chat("sModDesc",sModDesc,"nModNum",nModNum);
    local nStatMod = tonumber(rAddText.nStat)
    --Debug.chat("rAddText.nMoveBonus",rAddText.nMoveBonus);
    local nMoveBonus = tonumber(rAddText.nMoveBonus);
    local nMod = nModNum + nStatMod + nMoveBonus;
    --Debug.chat("nMod",nMod);
    
    --correct Mod
    if tonumber(sModDesc) then
		if tonumber(sModDesc) == nModNum then
			sModDesc = "Bonus";
		end
    end
    
    --Add Team
    local nodeOngoing = charNode.getChild("wl_ongoing_effects");
    local nTeamPoint = 0;
    for sClass,rRecord in pairs(nodeOngoing.getChildren()) do
        --Debug.chat("sClass: ",sClass," rRecord: ",rRecord);
        local sName = DB.getValue(rRecord,"name","");
        if sName == "Added Team Point" then
			nTeamPoint = DB.getValue(rRecord,"num_ongoing",0);
			nMod = nMod + nTeamPoint;
			rRecord.delete();
        end
    end
    
    -- set Dice
    local sDieRollString = "2d6+"..nMod;
    
    -- set Description
    local sRollDescription = rAddText.sMoveName.."\n"..rAddText.sAttackStat.."["..nStatMod.."]";
    bModTotal = false;
    
    -- add Move Bonus
    if nMoveBonus > 0 then
		sRollDescription = sRollDescription.."\nMove Bonus".."["..nMoveBonus.."]";
		bModTotal = true;
    end
    
    -- add ModStack to Description
    if sModDesc ~= "" then
		sRollDescription = sRollDescription.."\n"..sModDesc.."["..nModNum.."]";
		bModTotal = true;
    end
    
    -- add TeamPoint to Description
    if nTeamPoint > 0 then
		sRollDescription = sRollDescription.."\nTeam Point["..nTeamPoint.."]";
		bModTotal = true;
    end
    
    -- add Total to Description
    if bModTotal then
		sRollDescription = sRollDescription.."\nTotal["..nMod.."]";
    end
    
    --Debug.chat("sRollDescription",sRollDescription);
    
    --Register Handler
    ActionsManager.registerResultHandler(sType, manager_rolls.postActionRoll);
    
    --add additional info into rRoll
    rAdditionalInfo = {
		sAttackSuccess = rAddText.sAttackSuccess, 
		sAttackSuccessCost=rAddText.sAttackSuccessCost, 		
		sAttackMiss = rAddText.sAttackMiss,
		nHoldSuccess = rAddText.nHoldSuccess;
		nHoldSuccessCost = rAddText.nHoldSuccessCost;
		nHoldMiss = rAddText.nHoldMiss;
		nOngoingSuccess = rAddText.nOngoingSuccess;
		nOngoingSuccessCost = rAddText.nOngoingSuccessCost;
		nOngoingMiss = rAddText.nOngoingMiss;
		sDescriptionEffect = rAddText.sDescriptionEffect;
		sMoveName = rAddText.sMoveName
	}; --Find with rRoll["nTotalDieNum"]
    
    --Use RSW Roller
    RulesetWizardDiceRoller.Roll(nil, charNode, sType, sRollDescription, sDieRollString, 0, rAdditionalInfo);    
     
end

function postActionRoll(rSource, rTarget, rRoll)
    --Debug.chat("postActionRoll");
    --Debug.chat("rSource: ",rSource);
    --Debug.chat("rTarget: ",rTarget);
    --Debug.chat("rRoll: ",rRoll);
    -- decalarations
    local sNameEffect = rRoll["sMoveName"];
    local sAttackDescription = "";
    local nOngoing = 0;
    local nHoldNum = 0;
    
    --create message
    local rMessage = ActionsManager.createActionMessage(rSource,rRoll);
    rMessage.font = "narratorfont";
	rMessage.mode = "ooc";
    
    --set Icon
    local sNodeType, nodeChar = ActorManager.getTypeAndNode(rSource);
    --Debug.chat("sNodeType",sNodeType,"nodeChar",nodeChar);
    if sNodeType == "pc" then
        rMessage.icon = "portrait_" .. nodeChar.getName() .. "_chat";
    else
        rMessage.icon = "portrait_gm_token";
    end    
    
    -- Display message
    local sMessage = "";
    local nDie1 = rRoll.aDice[1]["result"];
    local nDie2 = rRoll.aDice[2]["result"];
    local nDieResult = nDie1 + nDie2;
    local nBonus = rRoll.nBonuses;
    local nResult = nDieResult + nBonus;
    --Debug.chat("nDie1",nDie1,"nDie2",nDie1,"nResult",nResult);
    
    if nResult >=10 then
		sAttackDescription = rRoll.sAttackSuccess
		sMessage = sMessage..sAttackDescription;
		nOngoing = tonumber(rRoll["nOngoingSuccess"]);
		nHoldNum = tonumber(rRoll["nHoldSuccess"]);
	elseif nResult >=7 then
		sAttackDescription = rRoll.sAttackSuccessCost
		sMessage = sMessage..sAttackDescription;
		nOngoing = tonumber(rRoll["nOngoingSuccessCost"]);
		nHoldNum = tonumber(rRoll["nHoldSuccessCost"]);
	else
		sAttackDescription = rRoll.sAttackMiss
		sMessage = sMessage.."Watch Out!\n\n"..sAttackDescription.."\n\n***Mark an Experence!***";
		nOngoing = tonumber(rRoll["nOngoingMiss"]);
		nHoldNum = tonumber(rRoll["nHoldMiss"]);
    end    
    --Debug.chat("rMessage.text",rMessage.text);
    
    --set Hold and Ongoing
    if nOngoing > 0 or nHoldNum > 0 then
		local nodeOnGoingEffects = nodeChar.getChild("wl_ongoing_effects");
		--Debug.chat("nodeOnGoingEffects",nodeOnGoingEffects);
		local doNotFound = true;
		
		-- Update if Found
		for sListClass,rListRecord in pairs(nodeOnGoingEffects.getChildren()) do
			--Debug.chat("sListClass: ",sListClass," rListRecord: ",rListRecord);
			
			if rListRecord.getChild("name").getValue() == sNameEffect then
				--Debug.chat("rListRecord found Name");
				rListRecord.getChild("num_holds").setValue(nHoldNum);
				rListRecord.getChild("num_ongoing").setValue(nOngoing);
				rListRecord.getChild("str_description").setValue(sAttackDescription);
				doNotFound = false;
			end
		end
		
		-- Add if NOT Found
		if doNotFound then
			--Debug.chat("Move not Found. Add");
			local node = nodeOnGoingEffects.createChild();				
			
			node.getChild("name").setValue(sNameEffect);
			node.getChild("num_holds").setValue(nHoldNum);
			node.getChild("num_ongoing").setValue(nOngoing);
			node.getChild("str_description").setValue(sAttackDescription);
		end
    end
    
    --set message and deliver to chat
    rMessage.text = rMessage.text.."\n\n"..sMessage;
    Comm.deliverChatMessage(rMessage);
end

--[[
*************************************************************************************************************************************
********************************************** Label Rolls *************************************************************************
*************************************************************************************************************************************
]]--

function preLabelRoll(charNode, sType, rAddText)
	--Debug.chat("preLabelRoll - charNode: ",charNode, " sType: ",sType, " rAddText: ",rAddText);
    
    -- Use Diff Stack to set Difficulty
    local sModDesc, nModNum = ModifierStack.getStack(false);
    --Debug.chat("sModDesc",sModDesc,"nModNum",nModNum);
    local nStatMod = tonumber(rAddText.nStat);
    local nMod = nModNum + nStatMod;
    --Debug.chat("nMod",nMod);
    
    --correct Mod
    if tonumber(sModDesc) then
		if tonumber(sModDesc) == nModNum then
			sModDesc = "Bonus";
		end
    end
    
    --Add Team
    local nodeOngoing = DB.getChild(charNode,"wl_ongoing_effects");-- charNode.getChild("wl_ongoing_effects");
    local nTeamPoint = 0;
    
    if nodeOngoing then
		for sClass,rRecord in pairs(nodeOngoing.getChildren()) do
			--Debug.chat("sClass: ",sClass," rRecord: ",rRecord);
			local sName = DB.getValue(rRecord,"name","");
			if sName == "Added Team Point" then
				nTeamPoint = DB.getValue(rRecord,"num_ongoing",0);
				nMod = nMod + nTeamPoint;
				rRecord.delete();
			end
		end
    end
    
    -- set Dice
    local sDieRollString = "2d6+"..nMod;
    
    -- set Description
    local sRollDescription = rAddText.sAttackStat.."["..nStatMod.."]";
    bModTotal = false;
    
    -- add ModStack to Description
    if sModDesc ~= "" then
		sRollDescription = sRollDescription.."\n"..sModDesc.."["..nModNum.."]";
		bModTotal = true;
    end
    
    -- add TeamPoint to Description
    if nTeamPoint > 0 then
		sRollDescription = sRollDescription.."\nTeam Point["..nTeamPoint.."]";
		bModTotal = true;
    end
    
    -- add Total to Description
    if bModTotal then
		sRollDescription = sRollDescription.."\nTotal["..nMod.."]";
    end
    --Debug.chat("sRollDescription",sRollDescription);
    
    --Register Handler
    ActionsManager.registerResultHandler(sType, manager_rolls.postLabelRoll);
    
    --add additional info into rRoll
    rAdditionalInfo = { nBoolChat = rAddText.nBoolChat }; --Find with rRoll["nTotalDieNum"]
    
    --Use RSW Roller
    RulesetWizardDiceRoller.Roll(nil, charNode, sType, sRollDescription, sDieRollString, 0, rAdditionalInfo);    
     
end

function postLabelRoll(rSource, rTarget, rRoll)
    --Debug.chat("postLabelRoll");
    --Debug.chat("rSource: ",rSource);
    --Debug.chat("rTarget: ",rTarget);
    --Debug.chat("rRoll: ",rRoll);    
    
    --create message
    local rMessage = ActionsManager.createActionMessage(rSource,rRoll);
    rMessage.font = "narratorfont";
	rMessage.mode = "ooc";
    
    --set Icon
    local sNodeType, nodeChar = ActorManager.getTypeAndNode(rSource);
    --Debug.chat("sNodeType",sNodeType,"nodeChar",nodeChar);
    if rRoll.nBoolChat == "1" then
		if Session.IsHost then
			rMessage.icon = "portrait_gm_token";
		else
			rMessage.icon = "portrait_throw_dice";
		end
    elseif sNodeType == "pc" then
        rMessage.icon = "portrait_" .. nodeChar.getName() .. "_chat";
    else
        rMessage.icon = "portrait_gm_token";
    end    
    
    -- Display message
    local sMessage = "";
    local nDie1 = rRoll.aDice[1]["result"];
    local nDie2 = rRoll.aDice[2]["result"];
    local nDieResult = nDie1 + nDie2;
    local nBonus = rRoll.nBonuses;
    local nResult = nDieResult + nBonus;
    --Debug.chat("nDie1",nDie1,"nDie2",nDie1,"nResult",nResult);
    
    if nResult >=10 then
		sMessage = sMessage.."Strong Hit";
	elseif nResult >=7 then
		sMessage = sMessage.."Weak Hit";
	else
		sMessage = sMessage.."Miss! GM Moves.\n***Mark an Experence!***";
    end
    
    --Debug.chat("rMessage.text",rMessage.text);
    
    --set message and deliver to chat
    rMessage.text = rMessage.text.."\n\n"..sMessage;
    Comm.deliverChatMessage(rMessage);
end