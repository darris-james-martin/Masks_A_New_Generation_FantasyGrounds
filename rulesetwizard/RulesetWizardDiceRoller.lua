function onInit()
end


function Roll(dragInfo, DatabaseNode, RollType, DescriptionText, DiceRollString, selfValue, additionalData)
	-- Remove spaces
	DiceRollString = DiceRollString:gsub("%s+", "");
	-- replace variable fields in Dice string
	for i = 1,2 do -- two iterations, for double reference fields
		for sVar in GetVariablesIterator(DiceRollString) do
			DiceRollString = ReplaceReferencedValue(DatabaseNode, DiceRollString, sVar, selfValue);
		end
		-- replace variable fields in Description
		if DescriptionText ~= "" then
			for sVar in GetVariablesIterator(DescriptionText) do
				DescriptionText = ReplaceReferencedValue(DatabaseNode, DescriptionText, sVar, selfValue);
			end
		end
	end

	if (RollType == nil) or (RollType == "") then
		RollType = "dice";
	end

	local rRoll;
	local aDice2, nMod2 = StringManager.convertStringToDice(DiceRollString);
	if Interface.getVersion() >= 4 then -- FGU
		rRoll = { sType = RollType, sDesc = DescriptionText, aDice = DiceRollString, nMod = 0, nBonuses = nMod2};
	else -- FGC
		rRoll = { sType = RollType, sDesc = DescriptionText, aDice = aDice2, nMod = nMod2};
	end

	local rollInfo = GameSystem.actions[RollType];
	if rollInfo then
		rRoll.bSecret = rollInfo.bSecret;
	end;
        
	if additionalData then
		for additionalDataKey, additionalDataValue in pairs(additionalData) do
			if type(additionalDataValue) == "string" then
				for sVar in GetVariablesIterator(additionalDataValue) do
					additionalDataValue = ReplaceReferencedValue(DatabaseNode, additionalDataValue, sVar, selfValue);
				end
			end
			rRoll[additionalDataKey] = additionalDataValue;        
		end        
	end

	local rCreature = ActorManager.resolveActor(getSheetDBNode(DatabaseNode));
		
	if dragInfo then
		encodeActionForDrag(dragInfo, rCreature, RollType, rRoll);
	end
		
	ActionsManager.performAction(dragInfo, rCreature, rRoll);
end

function encodeActionForDrag(draginfo, rSource, sType, rRolls)
	ActionsManager.encodeActors(draginfo, rSource);
	draginfo.setType(sType);
	draginfo.setDescription(rRolls.sDesc);
	draginfo.setSecret(rRolls.bSecret or false);
end

function getSheetDBNode(DatabaseNode)
	if (DatabaseNode == nil) or (type(DatabaseNode) == "windowinstance") then
		return DatabaseNode;
	end
		
	local nodeName = DatabaseNode.getNodeName();
	if string.sub(nodeName, 1, 9) == "charsheet" then
		i, j = string.find(nodeName, ".", 11, true);
		if i ~= null then
			return string.sub(nodeName, 1, i-1);
		end
	end;
	if string.sub(nodeName, 1, 13) == "combattracker" then
		i, j = string.find(nodeName, ".", 20, true);
		if i ~= null then
			return string.sub(nodeName, 1, i-1);
		end
	end;
	
	return DatabaseNode;
end

function ReplaceReferencedValue(DatabaseNode, RollString, varString, selfValue)
	local iIni = string.find(varString, "{[^{]*$");
	local iEnd = string.find(varString, "}");
	if iIni and iEnd and iIni < iEnd then        
		varString = string.sub(varString, iIni+1, iEnd-1);
		if varString == "self" then
			return string.gsub(RollString, "{" .. varString .. "}", selfValue);
		elseif varString == "modstack" then
			return string.gsub(RollString, "{" .. varString .. "}", ModifierStack.getSum());
		elseif varString == "modstackdesc" then
			return string.gsub(RollString, "{" .. varString .. "}", ModifierStack.getDescription());
		else
			if type(DatabaseNode) == "windowinstance" then
				fieldValue = DatabaseNode[varString].getValue();
			else
				fieldValue = DB.getValue(DatabaseNode, varString);
			end
			local newFieldValue = "";
			if fieldValue == nil then
				newFieldValue = "0";
			else
				if type(fieldValue) == 'table' then
					for _, vDie in ipairs(fieldValue) do
						if newFieldValue ~= "" then
							newFieldValue = newFieldValue .. "+";
						end
						newFieldValue = newFieldValue .. vDie;
					end
				else
					newFieldValue = fieldValue;
				end;
			end;
			return string.gsub(RollString, "{" .. varString .. "}", newFieldValue);
		end
	else
		return RollString;
	end
end         

function GetVariablesIterator(varString)
	return string.gmatch(varString, "{+.-}+");
end    
	