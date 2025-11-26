import flixel.util.FlxArrayUtil;
import flixel.FlxBasic;

/**
 * This is pretty much just a `FlxGroup` or `FlxTypedGroup<FlxBasic>`, but compatible with Codename's hscript class inheterance.
 */
class FunkinGroup extends FlxBasic {
    /**
     * The `Array` containing all members of this group.
     */
    public var members(default, null):Array<FlxBasic>;

    /**
     * The maximum capacity of this group.
     * 
     * The default is `0`, meaning no max capacity, which means this group can grow infinitely larger.
     */
    public var maxSize(default, set):Int;

    /**
     * The number of entries this group currently contains.
     */
    public var length(get, never):Int;

    /**
     * Creates a new `FunkinGroup`
     * @param maxSize Maximum amount of members allowed.
     */
    public function new(maxSize:Int = 0) {
        super();

        members = [];
        this.maxSize = Std.int(Math.abs(maxSize));
        flixelType = 2; // GROUP
    }

    override public function destroy() {
        super.destroy();

        if (members != null) {
            var count = length;
            while (count-- > 0) {
                final object = members.shift();
                if (object != null)
                    object.destroy();
            }

			members = null;
        }
    }

    override public function update(elapsed:Float) {
        for (object in members) {
            if (object != null && object.exists && object.visible)
                object.update(elapsed);
        }
    }

    override public function draw() {
        final oldDefaultCameras = FlxCamera._defaultCameras;
        if (_cameras != null)
			FlxCamera._defaultCameras = _cameras;

		for (object in members) {
			if (object != null && object.exists && object.visible)
				object.draw();
		}

		FlxCamera._defaultCameras = oldDefaultCameras;
    }

    /**
     * Adds a new `FlxBasic` to the group.
     * 
     * If said `FlxBasic` is already on the group, it will be immediatly returned.
     * 
     * This group will try to replace a `null` member with the `FlxBasic`.
     * 
     * If that fails, the group will just add it at the end of the members list, unless the group reached its maximum capacity.
     * 
     * @param object The `FlxBasic` you want to add to the group.
     * @return The same `FlxBasic` that was passed in.
     */
    public function add(object:FlxBasic):FlxBasic {
		if (object == null)
            return null;

        if (members.indexOf(object) >= 0)
			return object;

        final index:Int = getFirstNull();
        if (index != -1) {
			members[index] = object;
			return object;
        }

        if (maxSize > 0 && length >= maxSize)
			return object;

		members.push(object);
		return object;
    }

	/**
	 * Adds a new `FlxBasic` to the group at the specified position.
	 * 
	 * If said `FlxBasic` is already on the group, it will be immediatly returned.
	 * 
	 * This group will try to replace a `null` member at the specified position with the `FlxBasic`.
	 * 
	 * If that fails, the group will just add it at the specified position, unless the group reached its maximum capacity.
	 * 
	 * @param object The `FlxBasic` you want to add to the group.
	 * @return The same `FlxBasic` that was passed in.
	 */
    public function insert(position:Int, object:FlxBasic):FlxBasic {
		if (object == null)
			return null;

		if (members.indexOf(object) >= 0)
			return object;

		if (position < length && members[position] == null) {
			members[position] = object;
			return object;
		}

		if (maxSize > 0 && length >= maxSize)
			return object;

		members.insert(position, object);
		return object;
    }

    /**
     * Removes an object from the group.
     * @param object The `FlxBasic` you want to remove.
     * @param splice Whether the object should be cut from the array entirely or not.
     * @return The removed object.
     */
    public function remove(object:FlxBasic, splice:Bool = false):FlxBasic {
        if (members == null)
            return null;

        final index = members.indexOf(object);
        if (index < 0)
            return null;

        if (splice)
            members.splice(index, 1);
        else
            members[index] = null;

        return null;
    }

	/**
	 * Replaces an existing `FlxBasic` with a new one.
	 * @param object The object you want to replace.
	 * @param newObject The new object you want to use.
	 * @return The new object.
	 */
	public function replace(object:FlxBasic, newObject:FlxBasic):FlxBasic {
        final index = members.indexOf(object);

        if (index < 0)
            return null;

        members[index] = newObject;
		return newObject;
    }

    /**
     * Searches for, and returns the first member that satifies the given function.
     * @param func The function that tests each member inside this group.
     * @return The object that passed the test.
     */
    public function getFirst(func:FlxBasic->Bool):Null<FlxBasic> {
        var result:FlxBasic = null;
        for (object in members) {
            if (object != null && func(object)) {
				result = object;
                break;
            }
        }
        return result;
    }

	/**
	 * Searches for, and returns the last member that satifies the given function.
	 * @param func The function that tests each member inside this group.
	 * @return The object that passed the test.
	 */
	public function getLast(func:FlxBasic->Bool):Null<FlxBasic> {
		var result:FlxBasic = null;
        var i:Int = length;
        while(i-- > 0) {
            final object = members[i];
			if (object != null && func(object)) {
				result = object;
				break;
			}
        }
		return result;
    }

	/**
	 * Searches for, and returns the index of the first member that satifies the given function.
	 * @param func The function that tests each member inside this group.
	 * @return The index of the object that passed the test.
	 */
	public function getFirstIndex(func:FlxBasic->Bool):Int {
        var result:Int = -1;
		for (i => object in members) {
			if (object != null && func(object)) {
				result = i;
				break;
			}
		}
        return result;
    }

	/**
	 * Searches for, and returns the index of the last member that satifies the given function.
	 * @param func The function that tests each member inside this group.
	 * @return The index of the object that passed the test.
	 */
	public function getLastIndex(func:FlxBasic->Bool):Int {
		var result:Int = -1;
		var i:Int = length;
		while (i-- > 0) {
			final object = members[i];
			if (object != null && func(object)) {
				result = i;
				break;
			}
		}
		return result;
    }

    /**
     * @return The position of the first `null` slot inside the group. If none where found, it returns `-1`.
     */
    public function getFirstNull():Int {
        return members.indexOf(null);
    }

	/**
	 * @return The position of the last `null` slot inside the group. If none where found, it returns `-1`.
	 */
	public function getLastNull():Int {
		return members.lastIndexOf(null);
	}

	/**
	 * Tests whether any member satisfies the given function.
	 * @param func The function that tests each member inside this group.
	 * @return Whether if any passed or not.
	 */
	public function any(func:FlxBasic->Bool):Bool {
        for (object in members) {
			if (object != null && func(object))
                return true;
        }
        return false;
    }

	/**
	 * Tests whether every member satisfies the given function.
	 * @param func The function that tests each member inside this group.
	 * @return Whether if all passed or not.
	 */
	public function every(func:FlxBasic->Bool):Bool {
		for (object in members) {
			if (object != null && !func(object))
				return false;
		}
		return true;
	}

    /**
     * @return The amoung of objects flagged as not dead. Returns `-1` if the group is empty, or all members are dead.
     */
    public function getAliveAmount():Int {
        var count:Int = -1;

        for (object in members) {
            if (object != null) {
                if (count < 0) count = 0;
                if (object.exists && object.alive)
                    count++;
            }
        }

        return count;
    }

	/**
	 * @return The amoung of objects flagged as dead. Returns `-1` if the group is empty, or all members are not dead.
	 */
	public function getDeadAmount():Int {
		var count:Int = -1;

		for (object in members) {
			if (object != null) {
				if (count < 0) count = 0;
				if (!object.alive)
					count++;
			}
		}

		return count;
	}

    /**
     * Removes all members of the group.
     * 
     * WARNING: This doesn't `destroy()` or `kill()` any of these objects!
     */
    public function clear() {
		FlxArrayUtil.clearArray(members);
    }

    override public function kill() {
        for (object in members) {
            if (object != null && object.exists)
                object.kill();
        }

        super.kill();
    }

	override public function revive() {
		for (object in members) {
			if (object != null && !object.exists)
				object.revive();
		}

		super.revive();
	}

    /**
     * Iterates through every member and their index.
     */
    public function keyValueIterator() {
        return members.keyValueIterator();
    }

	/**
	 * Applies a function to all members.
	 * @param func A function that modifies all members.
	 * @param recurse Whether or not to apply the function to members of subgroups as well.
	 */
	public function forEach(func:FlxBasic->Bool, recurse:Bool = false) {
        for (object in members) {
            if (object != null) {
                if (recurse) {
                    final group = FlxGroup.resolveGroup(object);
                    if (group != null)
                        group.forEach(func, recurse);
                }

                func(object);
            }
        }
    }

	/**
	 * Applies a function to all `alive` members.
	 * @param func A function that modifies all members.
	 * @param recurse Whether or not to apply the function to members of subgroups as well.
	 */
	public function forEachAlive(func:FlxBasic->Bool, recurse:Bool = false) {
		for (object in members) {
			if (object != null && object.exists && object.alive) {
				if (recurse) {
					final group = FlxGroup.resolveGroup(object);
					if (group != null)
						group.forEach(func, recurse);
				}

				func(object);
			}
		}
	}

	/**
	 * Applies a function to all dead members.
	 * @param func A function that modifies all members.
	 * @param recurse Whether or not to apply the function to members of subgroups as well.
	 */
	public function forEachDead(func:FlxBasic->Bool, recurse:Bool = false) {
		for (object in members) {
			if (object != null && !object.alive) {
				if (recurse) {
					final group = FlxGroup.resolveGroup(object);
					if (group != null)
						group.forEach(func, recurse);
				}

				func(object);
			}
		}
	}

	/**
	 * Applies a function to all existing members
	 * @param func A function that modifies all members.
	 * @param recurse Whether or not to apply the function to members of subgroups as well.
	 */
	public function forEach(func:FlxBasic->Bool, recurse:Bool = false) {
		for (object in members) {
			if (object != null && object.exists) {
				if (recurse) {
					final group = FlxGroup.resolveGroup(object);
					if (group != null)
						group.forEach(func, recurse);
				}

				func(object);
			}
		}
	}

    function set_maxSize(size:Int):Int {
        maxSize = Std.int(Math.abs(size));

		if (maxSize == 0 || members == null || maxSize >= length)
			return maxSize;

        while (length > maxSize) {
            final object = members.splice(maxSize - 1, 1)[0];
			if (object != null)
				object.destroy();
        }

		return maxSize;
    }

    function get_length():Int {
		return members != null ? members.length : 0;
    }
}