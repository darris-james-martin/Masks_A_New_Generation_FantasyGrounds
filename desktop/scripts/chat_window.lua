-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onDiceLanded(draginfo)
	if ChatManager.onDiceLanded(draginfo) then
		return true;
	end
 	return ActionsManager.onDiceLanded(draginfo);
end

function onReceiveMessage(msg)
	return ChatManager.onReceiveMessage(msg);
end

function onDragStart(button, x, y, draginfo)
	return ActionsManager.onChatDragStart(draginfo);
	
end

function onDrop(x, y, draginfo)
	--Debug.chat("draginfo",draginfo);
	local sType = draginfo.getType();
	if sType == "dice" then
		local nDice = draginfo.getDieList();
		--Debug.chat("nDice",nDice,"count:",#nDice);
		
		-- Set Add Text
		local rAddText = {
			nStat = 0,
			sAttackStat = "Base",
			nBoolChat = 1,		
		}
		
		manager_rolls.rollInit(nil, "Label", rAddText);
	end
	
	
	
	
--	local bReturn = ActionsManager.actionDrop(draginfo, nil);
--	
--	
--	if bReturn then
--		local aDice = draginfo.getDieList();
--		if aDice and #aDice > 0 and not OptionsManager.isOption("MANUALROLL", "on") then
--			return;
--		end
--		return true;
--	end
--	
--	if draginfo.getType() == "language" then
--		LanguageManager.setCurrentLanguage(draginfo.getStringData());
--		return true;
--	end
end
