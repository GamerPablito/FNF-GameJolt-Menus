package gamejolt.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gamejolt.GJClient;
import gamejolt.menus.UserInfoSubState;

class FriendsSubState extends MusicBeatSubstate
{
    var bg:FlxSprite;
    var title:Alphabet;
    var leftArrow:Alphabet;
	var rightArrow:Alphabet;
    var missInfo:FlxText;

    var camPos:FlxObject;
    var curScreen:Int;
    var screenPos:Int;
    var yPos:Int;

    var friendList:Null<Array<User>>;
    var friendLine:Array<FlxText>;
    
    public function new()
    {
        super();
        openCallback = createMenu;
    }

    function createMenu()
    {
        friendList = GJClient.getFriendsList();
        
        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        bg.scrollFactor.set();
        bg.color = FlxColor.GRAY;
        bg.alpha = 0;
        add(bg);

        camPos = new FlxObject(0, 0, 1, 1);
		camPos.screenCenter();
		add(camPos);

        title = new Alphabet(0, 50, 'Friends', true);
		title.screenCenter(X);
        title.antialiasing = ClientPrefs.globalAntialiasing;
		title.scrollFactor.set();
        title.alpha = 0;
		add(title);

        leftArrow = new Alphabet(0, 25, '<', true);
		leftArrow.x = title.x - leftArrow.width - 20;
        leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		leftArrow.scrollFactor.set();
        leftArrow.alpha = 0;
		add(leftArrow);

		rightArrow = new Alphabet(0, 25, '>', true);
		rightArrow.x = title.x + title.width + 20;
        rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		rightArrow.scrollFactor.set();
        rightArrow.alpha = 0;
		add(rightArrow);

        curScreen = 0;
        screenPos = -1;
        yPos = -1;
        friendLine = [];

        var lineInstance:Int = 0;
        if (friendList != null)
        {
            for (f in friendList)
            {
                if (lineInstance % 5 == 0) screenPos++;

                yPos++;
                yPos = yPos % 10;

                var newFriend = new FlxText(0, 0, 0, '${lineInstance + 1}. ${f.developer_name} (@${f.username})');
                newFriend.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
                newFriend.x = (FlxG.width / 2) - (newFriend.width / 2) + (FlxG.width * screenPos);
                newFriend.y = (FlxG.height * 0.25) + ((newFriend.height + 20) * yPos);
                newFriend.alpha = 0;
                friendLine.push(newFriend);
                add(friendLine[lineInstance]);
                lineInstance++;
            }
        }
        else
        {
            missInfo = new FlxText(0, 0, 0, "You don't have any friends\nto track info from yet!\nPlease, go add some and retry later");
            missInfo.setFormat(Paths.font('pixel.otf'), 35, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
            missInfo.screenCenter();
            missInfo.antialiasing = ClientPrefs.globalAntialiasing;
            missInfo.scrollFactor.set();
            missInfo.visible = false;
            add(missInfo);

            FlxTween.tween(missInfo, {alpha: 0.25}, 0.5, {type: PINGPONG});
        }

        FlxTween.tween(bg, {alpha: 1}, 0.7, {onComplete: function (twn:FlxTween) {if (friendList == null) missInfo.visible = true;}});
        FlxTween.tween(title, {alpha: 1}, 0.7);
        FlxTween.tween(leftArrow, {alpha: 1}, 0.7);
        FlxTween.tween(rightArrow, {alpha: 1}, 0.7);
        for (j in friendLine) FlxTween.tween(j, {alpha: 1}, 0.7);

        FlxG.camera.follow(camPos, null, 1);
        FlxTween.tween(camPos, {y: camPos.y + 7}, 0.5, {type: PINGPONG});
    }

    function camTween()
    {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        FlxTween.cancelTweensOf(camPos, ['x']);
        FlxTween.tween(camPos, {x: FlxG.width / 2 + FlxG.width * curScreen}, 0.6, {ease: FlxEase.smootherStepOut});
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var isMinCount:Bool = curScreen <= 0;
		var isMaxCount:Bool = curScreen >= screenPos;

		leftArrow.visible = !isMinCount;
		rightArrow.visible = !isMaxCount;

        if (friendList != null)
        {
            for (i in 0...friendLine.length)
            {
                if (FlxG.mouse.overlaps(friendLine[i]))
                {
                    friendLine[i].color = FlxColor.YELLOW;

                    if (FlxG.mouse.justPressed)
                    {
                        UserInfoSubState.daUserID = friendList[i].id;
                        openSubState(new UserInfoSubState());
                    }
                }
                else friendLine[i].color = FlxColor.WHITE;
            }
        }

        if (screenPos > 0)
        {
            if (controls.UI_LEFT_P && !isMinCount) {curScreen--; camTween();}
            if (controls.UI_RIGHT_P && !isMaxCount) {curScreen++; camTween();}
        }

        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));

            FlxTween.tween(bg, {alpha: 0}, 0.7, {onComplete: function (twn:FlxTween) {close();}});
            FlxTween.tween(title, {alpha: 0}, 0.7);
            FlxTween.tween(leftArrow, {alpha: 0}, 0.7);
            FlxTween.tween(rightArrow, {alpha: 0}, 0.7);
            if (friendList == null)
            {
                FlxTween.cancelTweensOf(missInfo);
                FlxTween.tween(missInfo, {alpha: 0}, 0.7);
            }
            for (j in friendLine) FlxTween.tween(j, {alpha: 0}, 0.7);
        }
    }
}