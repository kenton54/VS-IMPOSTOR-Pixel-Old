import flixel.addons.display.FlxBackdrop;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxVelocity;
import flixel.math.FlxRect;
import flixel.FlxBasic;
import openfl.geom.Rectangle;

class StarsBackdrop extends FlxBasic {
	public var layers(default, set):Int;

    public var speed(default, set):Float;

	public var verticalSpeed(default, set):Float;

	public var scale(default, set):FlxPoint;

	public var scrollFactor(default, set):FlxPoint;

    public var shootingStarChance:Bool;

    var starArray:Array<FlxSprite> = [];
    var shootingStars:Array<FlxSprite> = [];
    var _drawRect:FlxRect;

    /**
     * Creates a set of backdrops filled with a star field, it automatically adds them to the current state
     * @param speed The speed the stars travel
     * @param layerAmount How many layers of star fields should there be
     */
    public function new(speed:Float = -40, layerAmount:Int = 3) {
        super();

		if (Options.lowMemoryMode)
			layerAmount = Math.ceil(layerAmount / 2);

		layers = layerAmount;
        this.speed = speed;
		verticalSpeed = 0;
    
        scale = FlxPoint.get(2, 2);
		scrollFactor = FlxPoint.get(0, 0);

		shootingStarChance = 1;

		_drawRect = new FlxRect(0, 0, camera.width, camera.height);
    }

	override public function destroy() {
		super.destroy();

		clear();

		shootingStars = null;
		starArray = null;
	}

    override public function update(elapsed:Float) {
        for (stars in starArray) {
			if (stars != null && stars.exists && stars.active)
				stars.update(elapsed);
        }

		for (shootStar in shootingStars) {
			if (shootStar != null && shootStar.exists && shootStar.active) {
				shootStar.update(elapsed);

				if (shootStar.velocity.x > 0 && shootStar.x > _drawRect.x + _drawRect.width)
                    removeShootingStar(shootStar);
				else if (shootStar.velocity.x < 0 && shootStar.x + shootStar.width < _drawRect.x)
                    removeShootingStar(shootStar);

				if (shootStar.y > _drawRect.y + _drawRect.height)
					removeShootingStar(shootStar);
            }
		}

		if (FlxG.random.bool(shootingStarChance))
            spawnShootingStar();
    }

    override public function draw() {
		for (camera in cameras) {
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
				continue;

			for (stars in starArray) {
				if (stars != null && stars.exists && stars.active)
					stars.draw();
			}

			for (shootStar in shootingStars) {
				if (shootStar != null && shootStar.exists && shootStar.active)
					shootStar.draw();
			}
		}
    }

    override public function kill() {
		for (shootStar in shootingStars) {
			if (shootStar != null && shootStar.exists)
				shootStar.kill();
		}

		for (stars in starArray) {
			if (stars != null && stars.exists)
				stars.kill();
		}

        super.kill();
    }

	override public function revive() {
		for (shootStar in shootingStars) {
			if (shootStar != null && !shootStar.exists)
				shootStar.revive();
		}

		for (stars in starArray) {
			if (stars != null && !stars.exists)
				stars.revive();
		}

		super.revive();
	}

	public function isOnScreen(?camera:FlxCamera):Bool {
		if (camera == null)
			camera = getDefaultCamera();

		return camera.containsRect(_drawRect);
	}

	public function setBounds(x:Float = 0, y:Float = 0, ?width:Float, ?height:Float) {
		if (width == null) width = camera.width;
		if (height == null) height = camera.width;
		setPosition(x, y);
		setLimits(width, height);
	}

	/**
	 * Sets the coordinates of the drawing rectangle
	 * @param x The position in the x-axis
	 * @param y The position in the y-axis
	 */
	public function setPosition(x:Float, y:Float) {
		_drawRect.x = x;
		_drawRect.y = y;
	}

	/**
	 * Sets the limits of the drawing rectangle
	 * @param width The horizontal limit
	 * @param height The vertical limit
	 */
	public function setLimits(width:Float, height:Float) {
		_drawRect.width = width;
		_drawRect.height = height;
	}

	/**
	 * Applies a function to all Star Field layers
	 * @param func The function to run
	 */
	public function forEachStarField(func:FlxBackdrop->Void) {
		for (stars in starArray) {
			if (stars != null)
				func(stars);
		}
	}

	/**
	 * Spawns a shooting star
	 */
	function spawnShootingStar() {
        var sprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image("ambience/shooting-star"));
		sprite.moves = true;

		var starScale:Float = FlxG.random.float(this.scale.x / 8, this.scale.x / 2);
		sprite.scale.set(starScale, starScale);
		sprite.updateHitbox();

        var fromRight:Bool = false;
        if (FlxG.random.bool(50)) {
            fromRight = true;
			sprite.flipX = true;
			sprite.flipY = true;
		}

		// horizontal position gets randomized
		sprite.x = FlxG.random.float(_drawRect.x - sprite.width, _drawRect.x + _drawRect.width + sprite.width);

		// vertical position gets randomized
		sprite.y = FlxG.random.float(_drawRect.y, _drawRect.y + _drawRect.height / 2);
		sprite.y -= sprite.height;

		// if the sprite is inside the drawing rectangle, it gets positioned outside of the rectangle
		if ((sprite.x + sprite.width) > _drawRect.x && (sprite.x + sprite.width) < (_drawRect.x + _drawRect.width))
			sprite.y = _drawRect.y - sprite.height;

		// speed gets randomized
		var minSpeed:Float = 2000 * starScale;
		var maxSpeed:Float = minSpeed * 2;
		var choosenSpeed:Float = FlxG.random.float(minSpeed, maxSpeed) * (fromRight ? 1 : -1);

		// launch angle gets randomized
		// left = 0 degrees, up = 90 degrees, right = 180 degrees, down = 270 degrees
		var minAngle:Float = 190;
		var maxAngle:Float = 225;
		var chosenAngle:Float = FlxG.random.float(minAngle, maxAngle) * (fromRight ? -1 : 1);
		sprite.angle = chosenAngle;

		// velocity gets calculated depending on the chosen angle, and gets applied to the sprite
		var vel:FlxPoint = FlxVelocity.velocityFromAngle(chosenAngle, choosenSpeed);
		sprite.velocity.x = vel.x;
		sprite.velocity.y = vel.y;

		// gets stretched horizontally depending on how fast is going
		var absSpeed:Float = Math.abs(choosenSpeed) * 2;
		var absHVel:Float = Math.abs(vel.x);
		var xStretch:Float = (absSpeed / absHVel);
		var yStretch:Float = (absHVel / absSpeed);
		sprite.scale.x *= xStretch;
		sprite.scale.y *= yStretch;

		shootingStars.push(sprite);
    }

	function removeShootingStar(shootingStar:FlxSprite) {
		if (shootingStars == null)
            return;

		shootingStars.remove(shootingStar);
		shootingStar.destroy();
    }

	function clear() {
		if (shootingStars != null) {
			var count:Int = shootingStars.length;
			while (count-- > 0) {
				final shootStar = shootingStars.shift();
				if (shootStar != null)
					shootStar.destroy();
			}
		}

		if (starArray != null) {
			var count:Int = starArray.length;
			while (count-- > 0) {
				final starLayer = starArray.shift();
				if (starLayer != null)
					starLayer.destroy();
			}
		}
	}

	function set_layers(value:Int) {
		clear();

        layers = value;

		for (i in 0...layers) {
			var star:FlxBackdrop = new FlxBackdrop(Paths.image("ambience/stars"));
			star.frames = FlxTileFrames.fromGraphic(star.graphic, FlxPoint.get(400, 200));
			star.animation.add("animation", [0, 1, 2, 3], 4);
			star.animation.play("animation");
			star.updateHitbox();
			star.setPosition(60 * i, 60 * i);
			star.scrollFactor.set(0, 0);
			star.velocity.x = speed / layers * FlxMath.remapToRange(i, 0, layers, layers, 0) * 2;

			var alphaValue:Float = (1 / layers) * FlxMath.remapToRange(i, 0, layers, layers, 0);
			star.alpha = alphaValue;

			starArray.push(star);
		}
	}

    function set_speed(value:Float) {
		speed = value;

		var i:Int = 0;
		forEachStarField(function(stars) {
			stars.velocity.x = this.speed / layers * FlxMath.remapToRange(i, 0, layers, layers, 0) * 2;
			i++;
        });
    }

	function set_verticalSpeed(value:Float) {
		verticalSpeed = value;

		var i:Int = 0;
		forEachStarField(function(stars) {
			stars.velocity.y = this.verticalSpeed / layers * FlxMath.remapToRange(i, 0, layers, layers, 0) * 2;
			i++;
		});
    }

    function set_scale(value:FlxPoint) {
        scale = value;

        var i:Int = 0;
		forEachStarField(function(stars) {
			stars.scale.x = this.scale.x / (i + 1);
			stars.scale.y = this.scale.y / (i + 1);
			stars.updateHitbox();
            i++;
		});
    }

    function set_scrollFactor(value:FlxPoint) {
		scrollFactor = value;

		var i:Int = 0;
		forEachStarField(function(stars) {
			stars.scrollFactor.x = this.scrollFactor.x / (i + 1);
			stars.scrollFactor.y = this.scrollFactor.y / (i + 1);
            i++;
		});
    }
}