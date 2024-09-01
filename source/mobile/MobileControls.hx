package mobile;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import mobile.flixel.FlxHitbox;
import mobile.flixel.FlxVirtualPad;
import haxe.macro.Type;

/**
 * @author Mihai Alexandru (M.A. Jigsaw)
 */
class MobileControls extends FlxSpriteGroup
{
	public static var customVirtualPad(get, set):FlxVirtualPad;
	public static var mode(get, set):String;

	public var virtualPad:FlxVirtualPad;
	public var hitbox:FlxHitbox;
	var isExtraButton:Bool = (Init.trueSettings.get('Mechanics Type') == "Button");
	public static var isDodge:Bool = false;

	// public var shutYoAss = FlxHitbox.buttonDodge;

	public function new(usesDodge:Bool = false)
	{
		super();

		isDodge = usesDodge;

		switch (MobileControls.mode)
		{
			case 'Pad-Right':
				virtualPad = new FlxVirtualPad(RIGHT_FULL, (usesDodge) ? DODGE : NONE);
				add(virtualPad);
			case 'Pad-Left':
				virtualPad = new FlxVirtualPad(LEFT_FULL, (usesDodge) ? DODGE : NONE);
				add(virtualPad);
			case 'Pad-Custom':
				virtualPad = MobileControls.customVirtualPad;
				add(virtualPad);
			case 'Pad-Duo':
				virtualPad = new FlxVirtualPad(BOTH_FULL, (usesDodge) ? DODGE : NONE);
				add(virtualPad);
			case 'Hitbox':
				hitbox = new FlxHitbox(3, Std.int(FlxG.width / 4), FlxG.height, [0xFF00FF, 0x00FFFF, 0x00FF00, 0xFF0000], (usesDodge && !isExtraButton) ? SPACE : DEFAULT);
				add(hitbox);
				if(usesDodge && isExtraButton){ //prevent to add button and hitbox
				virtualPad = MobileControls.customVirtualPad;
				add(virtualPad);
				}
			case 'Keyboard': // do nothing
		}
	}

	override public function destroy():Void
	{
		super.destroy();

		if (virtualPad != null)
			virtualPad = FlxDestroyUtil.destroy(virtualPad);

		if (hitbox != null)
			hitbox = FlxDestroyUtil.destroy(hitbox);
	}

	private static function get_mode():String
	{
		if (FlxG.save.data.controlsMode == null)
		{
			FlxG.save.data.controlsMode = 'Hitbox';
			FlxG.save.flush();
		}

		return FlxG.save.data.controlsMode;
	}

	private static function set_mode(mode:String = 'Hitbox'):String
	{
		FlxG.save.data.controlsMode = mode;
		FlxG.save.flush();

		return mode;
	}

	private static function get_customVirtualPad():FlxVirtualPad
	{
		var virtualPad:FlxVirtualPad = new FlxVirtualPad((MobileControls.mode == "Hitbox") ? NONE : RIGHT_FULL, (isDodge) ? DODGE : NONE);

		loadData(MobileControls.mode, virtualPad);
			
		return virtualPad;
	}

	private static function set_customVirtualPad(virtualPad:FlxVirtualPad):FlxVirtualPad
	{
		saveData(MobileControls.mode, virtualPad);

		return virtualPad;
	}


	private static function saveData(type:String, virtualPad:FlxVirtualPad):Void {
		var sussy = FlxG.save.data.buttons;
		if(type == "Hitbox") var sussy = FlxG.save.data.dodgepos;

		if (sussy == null)
		{
			trace("no data found creating one");

			sussy = new Array();
			for (buttons in virtualPad)
			{
				sussy.push(FlxPoint.get(buttons.x, buttons.y));
				FlxG.save.flush();
			}
		}
		else
		{
			trace("data found");

			var tempCount:Int = 0;
			for (buttons in virtualPad)
			{
				sussy[tempCount] = FlxPoint.get(buttons.x, buttons.y);
				FlxG.save.flush();
				tempCount++;
			}
		}

	}

	private static function loadData(type:String, virtualPad:FlxVirtualPad):Void {
		var sussy = FlxG.save.data.buttons;
		if(type == "Hitbox") var sussy = FlxG.save.data.dodgepos; //why it needs to create the var again :cccccccccccccccc

		if (sussy == null) return;

		trace("data found2");
		
		var tempCount:Int = 0;
		for (buttons in virtualPad)
		{
			buttons.x = sussy[tempCount].x;
			buttons.y = sussy[tempCount].y;
			tempCount++;
		}

	}
}
