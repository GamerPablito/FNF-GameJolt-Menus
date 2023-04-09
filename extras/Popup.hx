package gamejolt.extras;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import sys.FileSystem;

class Popup extends FlxUIGroup
{
	// Display Stuff
	var titleBox:FlxText;
	var descBox:FlxText;
	var daImage:FlxSprite;
	var daBG:FlxSprite;

	// Size Parameters
	var boxWidth:Int = Std.int(FlxG.width * (1 / 2.6));
	var boxHeight:Int = Std.int(FlxG.height * (1 / 5.5));

	// Miscellaneous Stuff
	var titleFont:String = Paths.font('pixel.otf');
	var descFont:String = "VCR OSD Mono";
	var titleSize:Int = 24;
	var descSize:Int = 16;

	public function new(title:String, desc:String, delay:Float = 0, ?image:String, ?bg:String)
	{
		super(x, y);

		scrollFactor.set();

		if (FileSystem.exists(Std.string(Paths.image(Std.string(bg)))) && bg != null)
		{
			daBG = new FlxSprite().loadGraphic(Paths.image(bg));
			daBG.setGraphicSize(boxWidth, boxHeight);
			daBG.updateHitbox();
		}
		else
		{
			daBG = new FlxSprite().makeGraphic(boxWidth, boxHeight, FlxColor.BLACK);
			daBG.alpha = 0.65;
		}

		if (FileSystem.exists(Std.string(Paths.image(Std.string(image)))) && image != null)
			daImage = new FlxSprite().loadGraphic(Paths.image(image));
		else
			daImage = new FlxSprite().loadGraphic(Paths.image('unknownMod'));

		var imgScale:Int = Std.int(daBG.height * (2 / 3));

		daImage.setGraphicSize(imgScale, imgScale);
		daImage.updateHitbox();
		daImage.x = daImage.width / 5;
		daImage.y = (daBG.height / 2) - (daImage.height / 2);

		var separation:Float = (daImage.x * 2) + daImage.width;
		var delimitation:Float = daBG.width - separation - daImage.x;

		titleBox = new FlxText(separation, 0, delimitation, title);
		titleBox.setFormat(titleFont, titleSize, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		titleBox.textField.multiline = false;
		titleBox.borderColor = FlxColor.BLACK;
		titleBox.y = (daBG.height * (1 / 3)) - (titleBox.height / 2);

		descBox = new FlxText(separation, 0, delimitation, desc);
		descBox.setFormat(descFont, descSize, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		descBox.textField.multiline = false;
		descBox.updateHitbox();
		descBox.borderColor = FlxColor.BLACK;
		descBox.y = (daBG.height * (2 / 3)) - (descBox.height / 2);

		add(daBG);
		add(daImage);
		add(titleBox);
		add(descBox);

		antialiasing = ClientPrefs.globalAntialiasing;
		screenCenter(X);

		y = 0 - this.height;

		if (delay > 0)
			new FlxTimer().start(delay, tmr -> drop());
		else
			drop();
	}

	function drop()
	{
		FlxTween.tween(this, {y: 0}, 1, {
			ease: FlxEase.bounceOut,
			onComplete: function(twn1:FlxTween)
			{
				FlxTween.tween(this, {y: 0 - this.height}, 0.5, {
					startDelay: 2.5,
					ease: FlxEase.smoothStepIn,
					onComplete: twn2 -> destroy()
				});
			}
		});
	}

	override function destroy()
	{
		super.destroy();
	}
}
