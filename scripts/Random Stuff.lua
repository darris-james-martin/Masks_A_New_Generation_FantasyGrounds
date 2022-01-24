-- Just made a random page to hold stuff. 
function FakeStart()
	DB.addHandler("partysheet.partyinformation","onChildUpdate", update); --"charsheet.*"  "charsheet.*.classes"
	
	
	if User.isHost() then
        DB.addHandler("partysheet.partyinformation","onChildUpdate", update); --"charsheet.*"  "charsheet.*.classes"
    end
end

function update()
    Debug.chat("test: ",test);
    Debug.chat("test: ",test," test: ",test);
end


function forNodes()
    
    -- get local node
    local node = window.getDatabaseNode();
    Debug.chat("node: ",node);
    
    --Single node Traversal
    local node = window.getDatabaseNode();
    for sClass,rRecord in pairs(node.getChildren()) do
        Debug.chat("sClass: ",sClass," rRecord: ",rRecord);
    end
    
    -- Double node traversal
    local nodeList = node.getChild("list");
    for sListClass,rListRecord in pairs(nodeList.getChildren()) do
        Debug.chat("sListClass: ",sListClass," rListRecord: ",rListRecord);
        
        for sClass,rRecord in pairs(rListRecord.getChildren()) do
            Debug.chat("sClass: ",sClass," rRecord: ",rRecord);
        end
    end
    
    -- window list traversal 
    local win1 = window.list.getWindows(); -- going down into the window list.
    Debug.chat("w: ",w);
    
    local win1 = window.windowlist.getWindows(); -- Traveling up from a windowlist.
    Debug.chat("win1: ",win1);
    
    for sWinClass,rWinRecord in pairs(win1) do
        Debug.chat("sWinClass: ",sWinClass," rWinRecord: ",rWinRecord);
        Debug.chat("rWinRecord.getClass(): ",rWinRecord.getClass());
        Debug.chat("rWinRecord.getDatabaseNode(): ",rWinRecord.getDatabaseNode());        
    end
    
    --travel up and down windows
    local sName = window.parentcontrol.window.header.subwindow.name.getValue();
end

function forDragData()
    Debug.chat("dragdata: ",dragdata);
    local scdata = dragdata.getShortcutData(); -- This tells you what kind of node this is. Helpful for future. 
    local ddnode = dragdata.getDatabaseNode();
    
    Debug.chat("getShortcutData: ",scdata);
    Debug.chat("getDatabaseNode: ",ddnode);
end

function forMessages()
	local nodeChar = window.getDatabaseNode();
    local msg = 
    {
        font = "narratorfont", 
        mode = "ooc",
        icon = "portrait_" .. nodeChar.getName() .. "_chat";
        text = nodeChar.getChild("name").getValue()..Interface.getString("attack_roll_out_of_resources");
    }
    local msg = 
    {
        font = "whisperfont", 
        mode = "whisper",
        icon = "portrait_" .. nodeChar.getName() .. "_chat"; --{ "indicator_whisper" },
        text = nodeChar.getChild("name").getValue()..Interface.getString("attack_roll_out_of_resources");
    }
    local msg = 
    {
        sender = "", 
        font = "chatfont", 
        icon = "portrait_gm_token", 
        mode = "story"
    }
    Comm.addChatMessage(msg);
    Comm.deliverChatMessage(msg);
end

function pics
	--set Icon
    local sNodeType, nodeChar = ActorManager.getTypeAndNode(rSource);
    if sNodeType == "pc" then
        rMessage.icon = "portrait_" .. nodeChar.getName() .. "_chat";
    else
        rMessage.icon = "portrait_gm_token";
    end  
end