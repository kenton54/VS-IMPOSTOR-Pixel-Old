import flixel.input.keyboard.FlxKey;
import flixel.util.FlxDirection;
import flixel.FlxObject;

class BindHint extends FunkinSprite {
    public var parent:FlxObject;

	public var position:FlxDirection;

    public var key:FlxKey;

	public function new(key:FlxKey, parent:FlxObject, ?position:FlxDirection) {
        super(0, 0);

        this.key = key;
        this.parent = parent;
		position ??= FlxDirection.DOWN;
        this.position = position;
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (parent != null) {}
    }

    override public function destroy() {
        super.destroy();
		parent = null;
		position = null;
    }

    function getKeyImage(key:FlxKey):String {
        switch (key) {

        }
    }
}