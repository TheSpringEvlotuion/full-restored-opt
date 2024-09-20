package gameObjects.userInterface;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Json;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.Song;
import meta.state.PlayState;
import openfl.utils.Assets;
import openfl.events.KeyboardEvent;

using StringTools;

typedef WordList = {
	var monochromeTexts:MonochromeWords;
	var missingnoTexts:MonochromeWords;
	var brimstoneTexts:MonochromeWords;
	var insomniaTexts:MonochromeWords;
	var ttfatfTexts:MonochromeWords;
}
typedef MonochromeWords = {
    var words:Array<String>;
	var rareWords:Array<String>;
	var impossibleWords:Array<String>;
	var harderWords:Array<String>;
}

class UnownSubstate extends MusicBeatSubState
{
	var selectedWord:String;
	var realWord:String = '';
	var position:Int = 0;

	var words:Array<String>;
	public static var publicWords:Array<String>;
	public static var rareWords:Array<String>;
	public static var impossibleWords:Array<String>;
	public static var harderWords:Array<String>;

	var lines:FlxTypedGroup<FlxSprite>;
	var unowns:FlxTypedSpriteGroup<FlxSprite>;
	public var win:Void->Void = null;
	public var lose:Void->Void = null;
	var timer:Int = 10;
	var timerTxt:FlxText;
	public function new(theTimer:Int = 15, word:String = '', ?wordList:Array<String>)
	{
		timer = theTimer;
		super();
		var overlay:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
		overlay.alpha = 0.4;
		add(overlay);

		//e
		FlxG.stage.window.textInputEnabled = true;

		words = publicWords;
        /*
		if (PlayState.gameplayMode == HELL_MODE) {
			for (i in hellModeWords)
				words.push(i);
		}
        */

		if (wordList!=null)
			words = wordList;
		else{
			var level:Int = 0;

			if (PlayState.dadOpponent.curCharacter == 'gold-headless')
				level++;
			if (PlayState.gameplayMode == HELL_MODE && PlayState.SONG.song.toLowerCase()=='monochrome' && FlxG.random.int(0,3)==0)
				level++;


			while (level < 3){
				if (FlxG.random.int(0, 10) == 0) 
					level++;
				else
					break;
			}
			switch(level){
				default:
					words = publicWords;
				case 1:
					words = harderWords;
				case 2:
					words = rareWords;
				case 3:
					words = impossibleWords;
			}
		}

		selectedWord = words[FlxG.random.int(0, words.length - 1)];
        // */
		
		if (word != '')
			selectedWord = word;

		if (selectedWord.toLowerCase()=='no more')
			if (PlayState.gameplayMode == HELL_MODE)
				selectedWord = "NO FUCKING WAY";
			else if (PlayState.gameplayMode == FUCK_YOU)
				selectedWord = "MAN REALLY SAID NO MORE THEN KEPT GOING?";

		selectedWord = selectedWord.toUpperCase();
		realWord = selectedWord.replace(" ", "");
		
		lines = new FlxTypedGroup<FlxSprite>();
		add(lines);

		unowns = new FlxTypedSpriteGroup<FlxSprite>();
		add(unowns);
		
		var realThing:Int = 0;
		var scale:Float = 1;
		var width:Float = 100 * (selectedWord.length-1);
		if(width > FlxG.width)
			scale *= FlxG.width / width;
		width *= scale;

		for (i in 0...selectedWord.length) {
			if (!selectedWord.isSpace(i)) 
			{
				var unown:FlxSprite = new FlxSprite(0, 90);
				var xPos = i * 100;
				unown.x = xPos;
				unown.scale.set(0.5, 0.5);
				unown.frames = Paths.getSparrowAtlas('UI/base/Unown_Alphabet');
				unown.animation.addByPrefix('idle', selectedWord.charAt(i), 24, true);
				unown.animation.play('idle');
				unowns.add(unown);

				var line:FlxSprite = new FlxSprite(unown.x, unown.y).loadGraphic(Paths.image('UI/base/line'));
				line.y += 500;
				line.updateHitbox();
				line.ID = realThing;
				lines.add(line);
				realThing++;
			}
		}

		for (i in 0...unowns.members.length){
			var u:FlxSprite = unowns.members[i];
			var l:FlxSprite = lines.members[i];

			u.scale.scale(scale);
			u.updateHitbox();
			u.x *= scale;
			//u.x += (FlxG.width - width)/2;
			l.x = u.x;
			l.scale.copyFrom(u.scale);
			l.updateHitbox();
		}

		unowns.screenCenter(X);
		unowns.y += 100;
		for (i in 0...lines.length) {
			lines.members[i].x = unowns.members[i].x;
		}

		timerTxt = new FlxText(FlxG.width / 2 - 5, 430, 0, '0', 32);
		timerTxt.alignment = 'center';
		timerTxt.font = Paths.font('metro.otf');
		add(timerTxt);
		timerTxt.text = Std.string(timer);

		#if mobile
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress); // detalhe super importante
		#end
	}
	static var wordsList:MonochromeWords;
    public static function init(?song:String) {
		var rawJson = Assets.getText(Paths.getPath('unownTexts.json', TEXT)).trim();
		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);
        // trace(rawJson);
		var faggot:WordList = cast Json.parse(rawJson);
		if (song == null)
			song = PlayState.SONG.song; // because i wanna add missingno words in brimstone!!

		switch (song.toLowerCase()){
			case 'brimstone':
				wordsList = faggot.brimstoneTexts;
			case 'missingno':
				wordsList = faggot.missingnoTexts;
			case 'insomnia':
				wordsList = faggot.insomniaTexts;
			case 'through-the-fire-and-the-flames':
				wordsList = faggot.ttfatfTexts;
			default:
				wordsList = faggot.monochromeTexts;
		}
		

		publicWords = wordsList.words;
		rareWords = wordsList.rareWords;
		impossibleWords = wordsList.impossibleWords;
		harderWords = wordsList.harderWords;
    }

	function correctLetter()
	{
		position++;
		if (position >= realWord.length)
		{
			close();
			win();
			FlxG.sound.play(Paths.sound('CORRECT'));
		}
	}
			
	private function onKeyDown(e:KeyboardEvent):Void
	{
		if (e.keyCode == 16 || e.keyCode == 17 || e.keyCode == 220 || e.keyCode == 27) // Do nothing for Shift, Ctrl, Esc, and flixel console hotkey
			return;
		else
		{
			if (e.charCode == 0) // Non-printable characters crash String.fromCharCode
				return;

			var daKey:String = String.fromCharCode(e.charCode);
			if (realWord.charAt(position) == daKey)
				correctLetter();
			else
				FlxG.sound.play(Paths.sound('CORRECT', 'shared'));
		}
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		timerTxt.text = Std.string(timer);

		for (i in lines)
		{
			if (i.ID == position)
			{
				FlxFlicker.flicker(i, 1.3, 1, true, false);
			}
			else if (i.ID < position)
			{
				i.visible = false;
				i.alpha = 0;
			}
		}
		
	}
		/*if (FlxG.keys.justPressed.ANY) {
			if (realWord.charAt(position) == '?') {
				if (FlxG.keys.justPressed.SLASH && FlxG.keys.pressed.SHIFT)
					correctLetter();
				else if (!FlxG.keys.justPressed.SHIFT)
					FlxG.sound.play(Paths.sound('BUZZER'));
			} else if (realWord.charAt(position) == '!') {
				if (FlxG.keys.justPressed.ONE && FlxG.keys.pressed.SHIFT)
					correctLetter();
				else if (!FlxG.keys.justPressed.SHIFT)
					FlxG.sound.play(Paths.sound('BUZZER'));
			} else {
				if (FlxG.keys.anyJustPressed([FlxKey.fromString(realWord.charAt(position))])) {
					correctLetter();
				} else
					FlxG.sound.play(Paths.sound('BUZZER'));
			}
		}
		/*if (FlxG.keys.justPressed.Z) {
			close();
			win();
		}
	}*/

	override function beatHit()
	{
		super.beatHit();
		if (timer > 0)
			timer--;
		else {
			close();
			lose();
		}
		timerTxt.text = Std.string(timer);
	}

	public function onKeyPress(e:KeyboardEvent):Void 
	{
		var needed:String = String.fromCharCode(e.keyCode);

		// Convert to string it in uppercase to see if it matches the key pressed
		if (realWord.charAt(position).toUpperCase() == needed.toUpperCase())
			correctLetter();
		else
			FlxG.sound.play(Paths.sound('BUZZER'));

		// Idklool, me cooked, go fix shaders lmao
	}

	 override function destroy():Void {
		#if mobile
		FlxG.stage.window.textInputEnabled = false;
		#end
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		super.destroy();
	}
}
