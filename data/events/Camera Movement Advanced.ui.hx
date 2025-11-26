function generateIcon() {
    if (event.name == "Camera Movement Advanced") {
		var doArrow:Bool = false;
		var icon:Null<FlxSprite> = null;
        var advIcon:Null<FlxSprite> = null;
		if (event.params != null) {
			doArrow = event.params[4] != "classic";
			icon = getIconFromStrumline(event.params[0]);
        }

        if (icon == null) icon = generateDefaultIcon(event.name);
		else advIcon = getEventComponent("advanced", 14, 10);

		if (event.params != null && doArrow && !inMenu) {
            var group = new EventIconGroup();
			group.add(icon);
			if (advIcon != null) group.add(advIcon);
			group.members[0].x -= 8;
			group.members[0].y -= 8;
			generateEventIconDurationArrow(group, event.params[3]);
			return group;
        }
        else {
			var group = new EventIconGroup();
			group.add(icon);
			if (advIcon != null) group.add(advIcon);
			group.members[0].x -= 8;
			group.members[0].y -= 8;
			return group;
        }
    }
}