package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIAssets;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	var checkAuditory:FlxText;
	var checkRequireGood:FlxText;
	var checkOldTiming:FlxText;
	var checkEnableCool:FlxText;

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/menuBG.png');
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic('assets/images/menuDesat.png');
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = FlxAtlasFrames.fromSparrow('assets/images/FNF_main_menu_assets.png', 'assets/images/FNF_main_menu_assets.xml');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		checkAuditory = new FlxText(5, FlxG.height - 148, 0, "" + TitleState.auditoryFeedback, 12);
		checkAuditory.scrollFactor.set();
		checkAuditory.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(checkAuditory);

		checkRequireGood = new FlxText(5, FlxG.height - 124, 0, "" + TitleState.requireGood, 12);
		checkRequireGood.scrollFactor.set();
		checkRequireGood.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(checkRequireGood);

		checkEnableCool = new FlxText(5, FlxG.height - 100, 0, "" + TitleState.requireGood, 12);
		checkEnableCool.scrollFactor.set();
		checkEnableCool.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(checkEnableCool);

		checkOldTiming = new FlxText(5, FlxG.height - 76, 0, "" + TitleState.requireGood, 12);
		checkOldTiming.scrollFactor.set();
		checkOldTiming.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(checkOldTiming);
		
		#if mobile
		addVirtualPad(UP_DOWN, A_B_C_X_Y_Z);
		#end

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		checkAuditory.text = "Auditory Feedback (Press O (C) to toggle): " + TitleState.auditoryFeedback;
		checkRequireGood.text = "Require Good Rank at Song End (Press P (X) to toggle): " + TitleState.requireGood;
		checkEnableCool.text = "Enable Freestyling + Cool Rank (Press K (Y) to toggle): " + TitleState.enableCool;
		checkOldTiming.text = "Grading Style (Press L (Z) to toggle): ";
		if (TitleState.oldTiming)
			checkOldTiming.text += "Interval-based";
		else
			checkOldTiming.text += "Break-based (recommended in most cases)";

		if (!selectedSomethin)
		{
			if (FlxG.keys.justPressed.O #if mobile || virtualPad.buttonC.justPressed #end)
			{
				FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
				if (TitleState.auditoryFeedback)
					TitleState.auditoryFeedback = false;
				else
					TitleState.auditoryFeedback = true;
				FlxG.save.data.auditoryFeedback = TitleState.auditoryFeedback;
				FlxG.save.flush();
			}

			if (FlxG.keys.justPressed.L #if mobile || virtualPad.buttonZ.justPressed #end)
			{
				FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
				if (TitleState.oldTiming)
					TitleState.oldTiming = false;
				else
					TitleState.oldTiming = true;
				FlxG.save.data.oldTiming = TitleState.oldTiming;
				FlxG.save.flush();
			}

			if (FlxG.keys.justPressed.K #if mobile || virtualPad.buttonY.justPressed #end)
				{
					FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
					if (TitleState.enableCool)
						TitleState.enableCool = false;
					else
						TitleState.enableCool = true;
					FlxG.save.data.enableCool = TitleState.enableCool;
					FlxG.save.flush();
				}

			if (FlxG.keys.justPressed.P #if mobile || virtualPad.buttonX.justPressed #end)
			{
				FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
				if (TitleState.requireGood)
					TitleState.requireGood = false;
				else
					TitleState.requireGood = true;
				checkRequireGood.text = "Require Good Rank at Song End (Press P (X) to toggle): " + TitleState.requireGood;
				FlxG.save.data.requireGood = TitleState.requireGood;
				FlxG.save.flush();
			}

			if (controls.UP_P)
			{
				FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play('assets/sounds/confirmMenu' + TitleState.soundExt);

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										FlxG.switchState(new StoryMenuState());
										trace("Story Menu Selected");
									case 'freeplay':
										FlxG.switchState(new FreeplayState());

										trace("Freeplay Menu Selected");

									case 'options':
										openSubState(new mobile.MobileControlsSubState());
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
