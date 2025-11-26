function generateIcon() {
	if (event.name == "Camera Fade") {
        if (event.params != null && !inMenu) {
			var group = new EventIconGroup();
			group.add(generateDefaultIcon(event.name));
			generateEventIconDurationArrow(group, event.params[1]);
			return group;
        }
    }
}