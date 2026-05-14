import flixel.addons.display.FlxBackdrop;
import impostor.BackButton;
import impostor.StarsBackdrop;

var stars:StarsBackdrop;

var baseScale:Float = 5;

var backButton:BackButton;

function create() {
	stars = new StarsBackdrop(-20, 4);
    add(stars);

    var topBorder:FlxBackdrop = new FlxBackdrop(Paths.image("menus/general/topBorder"), FlxAxes.X);
    topBorder.scale.set(baseScale, baseScale);
    topBorder.updateHitbox();
	topBorder.scrollFactor.set(0, 0);
    add(topBorder);

    backButton = new BackButton(baseScale, baseScale, () -> {
        setTransition("fade");
        FlxG.switchState(new ModState("impostorMenuState"));
    }, baseScale, "menus/x", false, true);
	backButton.scrollFactor.set(0, 0);
    add(backButton);

    FlxG.mouse.visible = true;
}

function destroy() {
    backButton.destroy();
}