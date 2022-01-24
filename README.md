# Masks: A New Generation
### by Magpie Games
This is a complete ruleset I designed and built for Fantasy Grounds. This was built with XML and LUA. </br>
YouTube: https://www.youtube.com/watch?v=A-0rbqU8C6g&t=3s&ab_channel=frostbyte000jm </br>
Forge: https://forge.fantasygrounds.com/shop/items/477/view

## Game Information
Masks is a game where you get to play a teenage superhero. Think of shows like Teen Titans, Young Justice, Young Avengers, and more. The characters have not found their place as superheroes in the world and through the game their stats will shift until they do. The game does a really good job of relating the stories seen on screen or read in comics and translates them into game play. 

## Ruleset
### Character Sheet
![image](https://user-images.githubusercontent.com/93277335/150872088-e26ea3db-2d26-4916-969a-b05bb2f8426b.png) </br>
This is the character sheet in Fantasy Grounds. You enter your labels by using the left and right arrow keys that will shift the stats from -2 to +3.  </br>
You can also store the characters Basic Moves, Playbook Moves, and Who has Influence on them as well as who they have Influence on. At the bottom of the sheet stores Ongoing Effects, Conditions, and Potential. </br>
#### Code
The labels shift from left to right by changing out an image where I highlight a different number.  </br>
```lua
function onClickRelease(button, x, y)
	local nIndex = window.ic_danger.getIndex();
	local nodeChar = window.getDatabaseNode();
	--Debug.chat("nIndex (before)",nIndex);
	if (nIndex < 6) then
		window.ic_danger.setIndex(nIndex+1);
	else
		 local msg = 
		{
			font = "narratorfont", 
			mode = "ooc",
			icon = "portrait_" .. nodeChar.getName() .. "_chat";
			text = nodeChar.getChild("name").getValue()..Interface.getString("charsheet_label_limit");
		}
		Comm.deliverChatMessage(msg);
	end
	
	--Debug.chat("nIndex (after)",window.ic_danger.getIndex());
end
```
window.ic_danger.setIndex(nIndex+1) calls on the cycling container that has stored 6 images. It sets its index then stores the numeric value so it can be later called by the application.
```lua
function setLabelValue()
	local index = getIndex();
	--Debug.chat("setLabelValue() - index",index);
	local value = -99;
	if		index == 1 then value = -2;
	elseif	index == 2 then value = -1;
	elseif	index == 3 then value = 0;
	elseif	index == 4 then value = 1;
	elseif	index == 5 then value = 2;
	elseif	index == 6 then value = 3;
	end
	
	--Debug.chat("label value",value);
	window.num_danger.setValue(value);
end
```
### Moves
![image](https://user-images.githubusercontent.com/93277335/150872430-8356b2e7-12b0-4135-90b7-a9e413601bb9.png) </br>
This is your Move Container. Once you name it you choose some options from it being a custom move or if it is rolled or not. Then you set what labels the move uses and which conditions will give the move a negative. </br>
Set the rules, and verbiage you wish the app to give when you roll a 10+, 7-9, or 6 and lower.  </br>
![image](https://user-images.githubusercontent.com/93277335/150872985-424e8011-6a92-4896-9f00-9888b415007b.png) </br>
If you grab the link (the red icon in the top left corner you can drop it on the character sheet where it creates this detail. </br>
![image](https://user-images.githubusercontent.com/93277335/150873564-a3e84027-c2c2-42a4-9f99-eaadbf488f13.png) </br>
From here, when you click roll it will take the values from the container and the values from the character sheet and send the roll to the screen. </br>
![image](https://user-images.githubusercontent.com/93277335/150873682-ee271cfd-e3f0-4212-9a0b-6ea3c234bf0a.png) </br>

## Combat Tracker
![image](https://user-images.githubusercontent.com/93277335/150873810-03ed3ed3-fa0e-43fd-aae7-1caf61487424.png) </br>
When fights break out, this will keep track of which characters have acted and who still has yet to act. It will also keep track of the characters conditions (health), and display it for the players. </br>
The players screen looks different. </br>
![image](https://user-images.githubusercontent.com/93277335/150873963-eaddc2f0-796c-4aad-878f-c7cff95c15f7.png) </br>
There Combat Tacker is more condensed. This is because they do not need as much information as the Game Master (GM) has. They also see the conditions as a health bar.  </br>
The combat Tracker also keeps similar information that is on individual character sheets for quick GM reference.  </br>
![image](https://user-images.githubusercontent.com/93277335/150874379-422ead91-fb94-4307-9731-d14d5a282ae3.png) </br>
#### Code
This had to be done by creating watchers on certain objects. When those objects change, the watcher turns off one of the objects, deletes everything, then copies over all the objects into the combat tracker. 
```lua
function onUpdateNode()
	-- turn off handler
	DB.removeHandler(NODECTOngoing.getPath(), "onChildUpdate", onUpdateCharNode);
	
	-- makes sure both nodes exist
	if NODECharOngoing and NODECTOngoing then
		--Debug.chat("Both Exist");
		-- Delete all child nodes, then copy all nodes from the character sheet into the Combat Tracker
		DB.deleteChildren(NODECTOngoing);
		DB.copyNode(NODECharOngoing, NODECTOngoing);
	end	
	-- Turn on handler
	DB.addHandler(NODECTOngoing.getPath(), "onChildUpdate", onUpdateCharNode);
End
```
## NPC Sheet
This keeps tracks of Non Playing Characters for the GM. </br>
![image](https://user-images.githubusercontent.com/93277335/150874985-531e50ea-0ea7-4a21-9f9a-bec0d1819a11.png) </br>
It is not too different from the character sheet except the NPCs have a fluctuating number of Conditions. These conditions match and link to the Combat Tracker so the GM can change them on the character sheet or on the Combat Tracker. </br>

## Rolling
The dice rolling is mostly handled by Fantasy Grounds, but the developer has to create the logic. The code is roughly 300+ lines long, but most of that is gathering up values of stats, conditions, and more before rolling. Once rolled I just check if the value is 10+, 7-9 or <7 and place the appropriate message in a string before delivering to the screen. </br>
```lua
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
```
## Team Pool
![image](https://user-images.githubusercontent.com/93277335/150875670-3cd47903-dec0-4d79-a98c-1f744747a679.png) </br>
This panel was a little difficult. Fantasy Grounds is not played on one computer. There is one Host and everyone else is a Client. The Host has access to the local database so they can change values and the DB will reflect to the client on change. The Clients do not have access to the Host DB and to get around this has to use message passing. </br>
```lua
function onDragStart(button, x, y, draginfo)
	local value = getValue();
	if value > 0 then
		draginfo.setType("teamPoint");
		draginfo.setIcon(window.icon_team_point.activeicon[1]);
		
		local bOwner = DB.isOwner("partysheet.num_total_team");
		if bOwner then
			DB.setValue("partysheet.num_total_team","number",value-1);
		else
			RulesetWizard.changeDBValueOOB("partysheet.num_total_team", value-1);
		end
				
		return true;
	end
	return false;
end
```
What is going on here is when it senses the user dragging this Team Point, I setup the drag information, and if the user is not the Host (Owner), it will set up an out of bounds (OOB) message that the Host has setup a listener. When it receives this message, it reads what is the object value, where is it trying to write, and what value would it like to place in the DB.  </br>
It will then update the value and then push that out to all the clients. This allows the user to pass Team Points to other players. 
