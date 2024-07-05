package mobile.flixel;

import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import mobile.flixel.FlxButton;
import openfl.display.BitmapData;
import openfl.display.Shape;

enum HitboxType
{
	DEFAULT;
	SPACE;
}

/**
 * A zone with 4 hint's (A hitbox).
 * It's really easy to customize the layout.
 *
 * @author Mihai Alexandru (M.A. Jigsaw)
 */
class FlxHitbox extends FlxSpriteGroup
{
	public var buttonLeft:FlxButton = new FlxButton(0, 0);
	public var buttonDown:FlxButton = new FlxButton(0, 0);
	public var buttonUp:FlxButton = new FlxButton(0, 0);
	public var buttonRight:FlxButton = new FlxButton(0, 0);
	public var buttonSpace:FlxButton = new FlxButton(0, 0);

	var spacepos:String = 'Middle';

	/**
	 * Create the zone.
	 * 
	 * @param ammo The ammount of hints you want to create.
	 * @param perHintWidth The width that the hints will use.
	 * @param perHintHeight The height that the hints will use.
	 * @param colors The color per hint.
	 */
	public function new(ammo:UInt, perHintWidth:Int, perHintHeight:Int, colors:Array<FlxColor>, type:HitboxType):Void
	{
		super();

		spacepos = Init.trueSettings.get('Hitbox Type');

		switch (type)
		{
			case DEFAULT:
				add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFF00FF));
				add(buttonDown = createHint(FlxG.width / 4, 0, Std.int(FlxG.width / 4), FlxG.height, 0x00FFFF));
				add(buttonUp = createHint(FlxG.width / 2, 0, Std.int(FlxG.width / 4), FlxG.height, 0x00FF00));
				add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, Std.int(FlxG.width / 4), FlxG.height, 0xFF0000));

			case SPACE:
				if (spacepos == 'Middle')
				{
					add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 5), FlxG.height, 0xFF00FF));
					add(buttonDown = createHint(FlxG.width / 5, 0, Std.int(FlxG.width / 5), FlxG.height, 0x00FFFF));
					add(buttonSpace = createHint(FlxG.width / 2.5, 0, Std.int(FlxG.width / 5), FlxG.height, 0xFFD000));
					add(buttonUp = createHint(FlxG.width / 2.5 + (FlxG.width / 5), 0, Std.int(FlxG.width / 5), FlxG.height, 0x00FF00));
					add(buttonRight = createHint(FlxG.width / 2.5 * 2, 0, Std.int(FlxG.width / 5), FlxG.height, 0xFF0000));
				}
				else if (spacepos == 'Down')
				{
					add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF00FF));
					add(buttonDown = createHint(FlxG.width / 4, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0x00FFFF));
					add(buttonSpace = createHint(0, Std.int(FlxG.height / 4) * 3, FlxG.width, Std.int(FlxG.height / 4), 0xFF7700));
					add(buttonUp = createHint(FlxG.width / 2, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0x00FF00));
					add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF0000));
				}
				else
				{
					add(buttonLeft = createHint(0, Std.int(FlxG.height / 4), Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF00FF));
					add(buttonDown = createHint(FlxG.width / 4, Std.int(FlxG.height / 4), Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0x00FFFF));
					add(buttonSpace = createHint(0, 0, FlxG.width, Std.int(FlxG.height / 4), 0xFF7700));
					add(buttonUp = createHint(FlxG.width / 2, Std.int(FlxG.height / 4), Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0x00FF00));
					add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), Std.int(FlxG.height / 4), Std.int(FlxG.width / 4),
						Std.int(FlxG.height / 4) * 3, 0xFF0000));
				}
		}

		scrollFactor.set();
	}

	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		super.destroy();

		buttonLeft = null;
		buttonDown = null;
		buttonUp = null;
		buttonRight = null;
		buttonSpace = null;
	}

	private function createHint(x:Float, y:Float, width:Int, height:Int, color:FlxColor = 0xFFFFFF):FlxButton
	{
		var hint:FlxButton = new FlxButton(x, y);
		hint.loadGraphic(createHintGraphic(width, height, color));
		hint.solid = false;
		hint.multiTouch = true;
		hint.immovable = true;
		hint.scrollFactor.set();
		hint.alpha = 0.00001;
		hint.onDown.callback = hint.onOver.callback = function()
		{
			if (hint.alpha != 0.2)
				hint.alpha = 0.2;
		}
		hint.onUp.callback = hint.onOut.callback = function()
		{
			if (hint.alpha != 0.00001)
				hint.alpha = 0.00001;
		}
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}

	private function createHintGraphic(width:Int, height:Int, color:FlxColor = 0xFFFFFF):BitmapData
	{
		var shape:Shape = new Shape();
		shape.graphics.beginFill(color);
		shape.graphics.drawRect(0, 0, width, height);

		var bitmap:BitmapData = new BitmapData(width, height, true, 0);
		bitmap.draw(shape, true);
		return bitmap;
	}
}
