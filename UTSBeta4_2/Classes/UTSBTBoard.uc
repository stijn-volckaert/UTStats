class UTSBTBoard extends UTSTeamBoard;

function PostBeginPlay()
{
         super.PostBeginPlay();
         bBT = true;
}

function DrawScore(Canvas Canvas, float Score, float XOffset, float YOffset)
{
    local float XL, YL;
	local color restore;
	local string sScore, sec;
	local int intScore, secs;
	local font OldFont;
    local byte OldStyle;

	intScore = int(2000 - Score);

	OldFont = Canvas.Font;
    OldStyle = Canvas.Style;

    Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);

    if ( intScore > 1 && intScore < 1999 )
    {
          secs = int(intScore % 60);
          if ( secs < 10 )
                sec = "0" $string(secs);
          else
                sec = "" $string(secs);
          restore = Canvas.DrawColor;
          sScore = string(intScore / 60) $":" $sec;
          Canvas.DrawColor = GreenColor;
          Canvas.StrLen(sScore,XL,YL);
          Canvas.SetPos(XOffset-56-XL/2,YOffset+RectHeight/2-YL/2+2);
          Canvas.DrawText(sScore);
	      Canvas.DrawColor = restore;
    }

    Canvas.Style = OldStyle;
    Canvas.Font = OldFont;
}

defaultproperties
{
     FragGoal="Finish Limit:"
}
