class UTSAsBoard extends UTSTeamBoard;

var localized string AssaultCondition;

function DrawVictoryConditions(Canvas Canvas)
{
    local TournamentGameReplicationInfo TGRI;
    local float XL, YL;
    local color OldColor;
    local font OldFont;
    local byte OldStyle;

    TGRI = TournamentGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);
    if ( TGRI == None )
        return;

    OldColor = Canvas.DrawColor;
    OldFont = Canvas.Font;
    OldStyle = Canvas.Style;

    Canvas.Font = MyFonts.GetHugeFont(Canvas.ClipX);
    Canvas.DrawColor = HeaderColor;
    Canvas.Style = ERenderStyle.STY_Normal;

    Canvas.StrLen("TEXT",XL,YL);
    Canvas.SetPos(0,10);
    Canvas.bCenter = true;

    DrawShadowText(Canvas,Canvas.CurX,Canvas.CurY,AssaultCondition,false);
    Canvas.SetPos(0, Canvas.CurY + YL + 2);

    if ( TGRI.TimeLimit > 0 )
        DrawShadowText(Canvas,Canvas.CurX,Canvas.CurY,TimeLimit@TGRI.TimeLimit$":00",false);

    Canvas.Font = OldFont;
    Canvas.Style = OldStyle;
    Canvas.DrawColor = OldColor;
    Canvas.bCenter = false;
}

defaultproperties
{
    AssaultCondition="Assault the Base!"
    FragGoal="Score Limit:"
}
