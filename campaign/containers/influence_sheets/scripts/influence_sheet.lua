function onInit()
	onLockChanged();
	DB.addHandler(DB.getPath(getDatabaseNode(), "locked"), "onUpdate", onLockChanged);
end

function onClose()
	DB.removeHandler(DB.getPath(getDatabaseNode(), "locked"), "onUpdate", onLockChanged);
end

function onLockChanged()
	if header.subwindow then
		header.subwindow.update();
	end
	if content.subwindow then
		content.subwindow.update();
	end
end
