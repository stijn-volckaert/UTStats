class UTSTeamBoard extends TeamScoreBoard;

#exec Texture Import File=..\UTS\Classes\BG.pcx name=BG

struct PlayerInfo
{
   var PlayerReplicationInfo zzPRI;
   var UTSReplicationInfo zzRI;
};

var PlayerInfo zzPI[32];
var int zzIndex,zzOwnerIndex;
var bool bBT,bNoTeamGame;
var bool bCTFGame;

var color HeaderColor,DieColor,KillColor,ScoreColor,LoginColor;

var float StartY,RectHeight,HeaderTop;
var float EndY[4],zzEndY;

var() texture FlagIcon[4];

// =============================================================================
// ShowScores ~ Gets called in postrender if the scoreboard is activated
// =============================================================================

function ShowScores( canvas Canvas )
{
    if (bNoTeamGame)
        ShowScoresNoTeam(Canvas);
    else
        ShowScoresTeam(Canvas);
}

function ShowScoresTeam (Canvas Canvas)
{
    local PlayerReplicationInfo PRI;
    local int PlayerCount, i;
    local float LoopCountTeam[4];
    local float XL, YL, XL2, YL2, XOffset, YOffset, XStart;
    local int PlayerCounts[4];
    local int LongLists[4];
    local int BottomSlot[4];
    local int LastColor[4];
    local font CanvasFont;
    local bool bCompressed;
    local float r;
    local color OldColor;
    local font oldfont;

    CanvasFont = Canvas.Font;

    OwnerInfo = Pawn(Owner).PlayerReplicationInfo;
    OwnerGame = TournamentGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);

    // Header
    DrawHeader(Canvas);

    for ( i=0; i<32; i++ )
        Ordered[i] = None;

    for ( i=0; i<32; i++ )
    {
        if (PlayerPawn(Owner).GameReplicationInfo.PRIArray[i] != None)
        {
            PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
            if ( !PRI.bIsSpectator || PRI.bWaitingPlayer )
            {
                Ordered[PlayerCount] = PRI;
                PlayerCount++;

                if (!bNoTeamGame)
                PlayerCounts[PRI.Team]++;
            }
        }
    }

    SortScores(PlayerCount);
    Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
    Canvas.StrLen("TEXT", XL, YL);
    ScoreStart = 50 + YL*2;

    // Check if scoreboard has to be compressed
    if ( ScoreStart + PlayerCount * YL + 2 > Canvas.ClipY )
    {
        bCompressed = true;
        CanvasFont = Canvas.Font;
        Canvas.Font = font'SmallFont';
        r = YL;
        Canvas.StrLen("TEXT", XL, YL);
        r = YL/r;
        Canvas.Font = CanvasFont;
    }


    for ( I=0; I<PlayerCount; I++ )
    {
        if ( Ordered[I].Team < 4 )
        {
            if ( Ordered[I].Team % 2 == 0 ) // Draw left
                XOffset = (Canvas.ClipX-360*2)/7*3;
            else // Draw right
                XOffset = (Canvas.ClipX-360*2)/7*4 + 360;

            Canvas.StrLen("TEXT", XL, YL);
            Canvas.DrawColor = AltTeamColor[Ordered[I].Team];
            YOffset = ScoreStart + (LoopCountTeam[Ordered[I].Team] * YL) + 2;

            if (I == 0)
               StartY = YOffset;

            RectHeight = 2*YL;
            EndY[Ordered[I].Team] = YOffset+2*YL;

            DrawRect(Canvas,XOffset,YOffset,2*YL,360,(LastColor[Ordered[I].Team]++)%2,/*Ordered[I].Team*/511);

            if (( Ordered[I].Team > 1 ) && ( PlayerCounts[Ordered[I].Team-2] > 0 ))
            {
                BottomSlot[Ordered[I].Team] = 1;
                YOffset = ScoreStart + YL*11 + LoopCountTeam[Ordered[I].Team]*YL;
            }

            // Draw Name and Ping
            if ( (Ordered[I].Team < 2) && (BottomSlot[Ordered[I].Team] == 0) && (PlayerCounts[Ordered[I].Team+2] == 0))
            {
                LongLists[Ordered[I].Team] = 1;
                DrawNameAndPing( Canvas, Ordered[I], XOffset+100, YOffset, bCompressed);
            }
            else if (LoopCountTeam[Ordered[I].Team] < 8)
                DrawNameAndPing( Canvas, Ordered[I], XOffset+100, YOffset, bCompressed);


            if ( bCompressed )
                LoopCountTeam[Ordered[I].Team] += 1;
            else
                LoopCountTeam[Ordered[I].Team] += 2;
        }
    }

    for ( i=0; i<4; i++ )
    {
        Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
        if ( PlayerCounts[i] > 0 )
        {
            if ( i % 2 == 0 )
                XOffset = (Canvas.ClipX-360*2)/7*3;
            else
                XOffset = (Canvas.ClipX-360*2)/7*4 + 360;
            YOffset = ScoreStart - YL + 2;

            if ( i > 1 )
                YOffset = EndY[i-2] + 10;

            DrawRect(Canvas,XOffset,YOffset,StartY-YOffset,360,1,i);
            //DrawRect(Canvas,XOffset,YOffset,StartY-YOffset,360,1,511);
            Canvas.SetPos(XOffset + 1,YOffset + 1);
            Canvas.DrawColor = WhiteColor;
            Canvas.Style = ERenderStyle.STY_Translucent;
            Canvas.DrawIcon(ChallengeTeamHUD(PlayerPawn(Owner).myHUD).TeamIcon[i],0.35);

            Canvas.DrawColor = DieColor;

            // Top horizontal line
            Canvas.SetPos(XOffset,YOffset);
            DrawLine(Canvas,3,360);

            // Mid horizontal line
            Canvas.SetPos(XOffset,StartY);
            DrawLine(Canvas,3,360);

            // Bottom horizontal line
            Canvas.SetPos(XOffset,EndY[i]);
            DrawLine(Canvas,3,362);

            // Left vertical line
            Canvas.SetPos(XOffset,YOffset);
            DrawLine(Canvas,1,EndY[i]-YOffset);

            // Mid vertical line
            Canvas.SetPos(XOffset+80,StartY);
            DrawLine(Canvas,1,EndY[i]-StartY);

            // Right vertical line
            Canvas.SetPos(XOffset+360,YOffset);
            DrawLine(Canvas,1,EndY[i]-YOffset);

            // Topleft
            Canvas.SetPos(XOffset-28,YOffset-15);
            Canvas.DrawColor = WhiteColor;
            /*Canvas.Style = ERenderStyle.STY_Translucent;
            Canvas.DrawIcon(texture'topleft',1.00);
            Canvas.Style = ERenderStyle.STY_Normal;*/

            // Teamname
            Canvas.DrawColor = ScoreColor;
            Canvas.StrLen(TeamName[i],XL2,YL2);
            Canvas.SetPos(XOffset+180-XL2/2, YOffset+2);
            Canvas.DrawText(TeamName[i], false);

            // Teamscore
            Canvas.DrawColor = WhiteColor;
            Canvas.Style = ERenderStyle.STY_Normal;
            Canvas.Font = MyFonts.GetHugeFont(Canvas.ClipX);
            Canvas.StrLen(string(int(OwnerGame.Teams[i].Score)),XL2,YL2);

            DrawShadowText(Canvas,XOffset+350-XL2,YOffset-20,string(int(OwnerGame.Teams[i].Score)), false);

            if ( PlayerCounts[i] > 4 )
            {
                YOffset = EndY[i]+5;
                Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
                Canvas.SetPos(XOffset+100, YOffset);
                if (LongLists[i] == 0)
                    Canvas.DrawText(PlayerCounts[i] - 4 @ PlayersNotShown, false);
            }
        }
    }

    // Trailer
    if ( !Level.bLowRes )
    {
        Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
        DrawTrailer(Canvas);
    }

    // Draw personal accu info
    Canvas.Font = Font'SmallFont';
    DrawWeaponinfo(Canvas);

    Canvas.Font = CanvasFont;
    Canvas.DrawColor = WhiteColor;
}

function ShowScoresNoTeam (Canvas Canvas)
{
    local PlayerReplicationInfo PRI;
    local int PlayerCount, i;
    local float LoopCount,EndY;
    local float XL, YL, XL2, YL2, XOffset, YOffset, XStart;
    local font CanvasFont;
    local bool bCompressed;
    local float r;
    local color OldColor;
    local font oldfont;

    CanvasFont = Canvas.Font;

    // Header
    DrawHeader(Canvas);

    for ( i=0; i<32; i++ )
        Ordered[i] = None;

    for ( i=0; i<32; i++ )
    {
        if (PlayerPawn(Owner).GameReplicationInfo.PRIArray[i] != None)
        {
            PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
            if ( !PRI.bIsSpectator || PRI.bWaitingPlayer )
            {
                Ordered[PlayerCount] = PRI;
                PlayerCount++;
            }
        }
    }

    SortScores(PlayerCount);
    Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
    Canvas.StrLen("TEXT", XL, YL);
    ScoreStart = 50 + YL*2;

    // Check if scoreboard has to be compressed
    if ( ScoreStart + PlayerCount * YL + 2 > Canvas.ClipY )
    {
        bCompressed = true;
        CanvasFont = Canvas.Font;
        Canvas.Font = font'SmallFont';
        r = YL;
        Canvas.StrLen("TEXT", XL, YL);
        r = YL/r;
        Canvas.Font = CanvasFont;
    }

    for ( I=0; I<PlayerCount; I++ )
    {
        XOffset = Canvas.ClipX/2-180;
        Canvas.StrLen("TEXT", XL, YL);
        YOffset = ScoreStart + LoopCount*YL+2;

        RectHeight = 2*YL;
        EndY = YOffset+2*YL;

        DrawRect(Canvas,XOffset,YOffset,2*YL,360,I%2,5);
        DrawNameAndPing( Canvas, Ordered[I], XOffset+100, YOffset, bCompressed);

        if ( bCompressed )
            LoopCount += 1;
        else
            LoopCount += 2;
    }

    XOffset = Canvas.ClipX/2-180;
    YOffset = ScoreStart-YL+2;
    DrawRect(Canvas,XOffset,YOffset,YL,360,1,511);

    // Top horizontal line
    Canvas.SetPos(XOffset,YOffset);
    DrawLine(Canvas,3,360);

    // Mid horizontal line
    Canvas.SetPos(XOffset,StartY);
    DrawLine(Canvas,3,360);

    // Bottom horizontal line
    Canvas.SetPos(XOffset,EndY);
    DrawLine(Canvas,3,362);

    // Left vertical line
    Canvas.SetPos(XOffset,YOffset);
    DrawLine(Canvas,1,EndY-YOffset);

    // Mid vertical line
    Canvas.SetPos(XOffset+80,YOffset);
    DrawLine(Canvas,1,EndY-YOffset);

    // Right vertical line
    Canvas.SetPos(XOffset+360,YOffset);
    DrawLine(Canvas,1,EndY-YOffset);

    Canvas.DrawColor = HeaderColor;
    Canvas.StrLen("Players",XL2,YL2);
    Canvas.SetPos(XOffset+180-XL2/2, YOffset+2);
    Canvas.DrawText("Players", false);

    // Trailer
    if ( !Level.bLowRes )
    {
        Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
        DrawTrailer(Canvas);
    }

    // Draw personal accu info
    Canvas.Font = Font'SmallFont';
    DrawWeaponinfo(Canvas);

    Canvas.Font = CanvasFont;
    Canvas.DrawColor = WhiteColor;
}

// =============================================================================
// DrawScore ~ Overwritten the old DrawScore cause I needed other parameters
// =============================================================================

function DrawScore(Canvas C, float Score, float XOffset, float YOffset)
{
}

function myDrawScore(Canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset, int zzKill, int zzDeath)
{
    local font OldFont;
    local byte OldStyle;
    local float XL,YL;
    local int i;

    OldFont = Canvas.Font;
    OldStyle = Canvas.Style;

    Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);

    // Draw Score
    Canvas.DrawColor = ScoreColor;
    Canvas.StrLen(string(int(PRI.Score)),XL,YL);
    Canvas.SetPos(XOffset-96,YOffset+RectHeight/2-YL/2+2);
    Canvas.DrawText(string(int(PRI.Score)));

    // Draw Deaths
    Canvas.DrawColor=DieColor;
    Canvas.StrLen("000",XL,YL);
    Canvas.SetPos(XOffset-22-XL,YOffset+3*RectHeight/4-YL/2);
    Canvas.DrawText(zzDeath);

    // Draw Kills
    Canvas.DrawColor = KillColor;
    Canvas.SetPos(XOffset-22-XL,YOffset+RectHeight/4-YL/2+2);
    Canvas.DrawText(zzKill);

    Canvas.Style = OldStyle;
    Canvas.Font = OldFont;
}

// =============================================================================
// DrawNameAndPing ~ Draw name/Ping/Effi/Accu/Login/Location info etc
// =============================================================================

function DrawNameAndPing(Canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset, bool bCompressed)
{
    local float XL, YL, XL2, YL2, YB, zzTmpAccu;
    local String L,zzAccu,zzLogin,zzPlayerName,zzTmp;
    local Font CanvasFont;
    local int Time,zzI,zzKill,zzDeath,zzEffi,i,zzLen,zzSuicides,zzCaps;
    local color OldColor;
    local bool bReady;

    zzI = FindInfo(PRI);

    OldColor = Canvas.DrawColor;

    Canvas.Style = ERenderStyle.STY_Normal;

    Canvas.DrawColor = WhiteColor;
    CanvasFont = Canvas.Font;
    Canvas.Font = Font'SmallFont';

    if ((zzI != -1) && (zzPI[zzI].zzRI != None))
    {
       zzDeath = zzPI[zzI].zzRI.zzDeathCount;
       zzKill = zzPI[zzI].zzRI.zzKillCount;
       zzSuicides = zzPI[zzI].zzRI.zzSuicides;
       zzCaps = zzPI[zzI].zzRI.zzCaps;
       zzEffi = int(float(zzKill)/float(zzDeath+zzKill)*100.0);

       if (zzPI[zzI].zzRI.zzShotCount + zzPI[zzI].zzRI.zzHitCount == 0)
           zzTmpAccu = 0.00;
       else
           zzTmpAccu = float(zzPI[zzI].zzRI.zzHitCount)/float(zzPI[zzI].zzRI.zzShotCount)*100.00;

       zzAccu = Left(string(zzTmpAccu),InStr(string(zzTmpAccu),".")+3);

       zzLogin = zzPI[zzI].zzRI.zzLogin;

       bReady = zzPI[zzI].zzRI.bReady;
    }
    else
    {
       zzDeath = 0;
       zzKill = 0;
       zzSuicides = 0;
       zzCaps = 0;
       zzEffi = 0;
       zzAccu = "0.00";
       zzLogin = "";
    }

    // Draw Time
    Time = Max(1, (Level.TimeSeconds + PlayerPawn(Owner).PlayerReplicationInfo.StartTime - PRI.StartTime)/60);
    Canvas.StrLen(TimeString$":     ", XL, YL);
    Canvas.SetPos(XOffset-15, YOffset+5);
    Canvas.DrawText(TimeString$":"@Time, false);

    // Draw Ping
    Canvas.SetPos(XOffset-15, YOffset +5+ (YL+1));
    Canvas.DrawText(PingString$":"@PRI.Ping, false);

    // Draw Loss
    Canvas.SetPos(XOffset-15, YOffset +5+ 2*(YL+1));
    Canvas.DrawText("Loss:"@ PRI.PacketLoss@"%", false);

    if (!bCompressed && !bBT)
    {
        // Draw Effi
        Canvas.SetPos(XOffset-15, YOffset +5+ 3*(YL+1));
        Canvas.DrawText("Effi:"@ zzEffi@"%", false);

        // Draw Accu
        Canvas.SetPos(XOffset-15, YOffset +5+ 4*(YL+1));
        Canvas.DrawText("Accu:"@ zzAccu@"%", false);
    }
    else if (!bCompressed)
    {
        // Draw Suicides
        Canvas.SetPos(XOffset-15, YOffset +5+ 3*(YL+1));
        Canvas.DrawText("Suic:"@ zzSuicides, false);
    }

    Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);

    if (PRI.bAdmin)
      Canvas.DrawColor = HeaderColor;
    else if (PRI == PlayerPawn(Owner).PlayerReplicationInfo)
      Canvas.DrawColor = GoldColor;
    else
      Canvas.DrawColor = WhiteColor;

    Canvas.SetPos(XOffset+XL, YOffset+5);
    zzPlayerName = PRI.PlayerName;
    Canvas.StrLen(zzPlayerName, XL2, YB);
    if (XL+XL2 > 260) // Make name shorter
    {
        zzLen = Len(PRI.PlayerName);

        for (i=1;i<10;++i)
        {
            zzTmp = Left(zzPlayerName,zzLen-i);
            Canvas.StrLen(zzTmp,XL2,YL2);
            if (XL+XL2 < 260)
            {
                zzPlayerName = zzTmp;
                break;
            }
        }
    }
    Canvas.DrawText(zzPlayerName, false);

    Canvas.Font = Font'SmallFont';
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 0;
    Canvas.DrawColor.B = 0;

    // Draw location
    if ( !bNoTeamGame && !bCompressed && (PRI.Team == OwnerInfo.Team) )
    {
        if ( PRI.PlayerLocation != None )
            L = PRI.PlayerLocation.LocationName;
        else if ( PRI.PlayerZone != None )
            L = PRI.PlayerZone.ZoneName;
        else
            L = "";
        if ( L != "" )
        {
            Canvas.SetPos(XOffset+XL+5, YOffset +5+ YB);
            Canvas.DrawText(L, false);
        }
    }

    if (!bCompressed)
    {
        if ((zzPI[zzOwnerIndex].zzRI != None) && (zzPI[zzOwnerIndex].zzRI.bUTGLActive) && (zzLogin != ""))
        {
           Canvas.DrawColor = HeaderColor;
           Canvas.SetPos(XOffset+XL+5,YOffset+13+YB);
           Canvas.DrawText("Login:"@zzLogin);
        }
    }

    Canvas.DrawColor = WhiteColor;

    // Draw flag
    Canvas.SetPos(XOffset+XL-30,YOffset+5);
    if (bReady)
    {
        Canvas.Style = ERenderStyle.STY_Translucent;
        Canvas.DrawIcon(texture'BotPack.GreenFlag',1.0);
        Canvas.Style = ERenderStyle.STY_Normal;
    }
    else if (PRI.HasFlag != None)
    {
        Canvas.DrawIcon(FlagIcon[CTFFlag(PRI.HasFlag).Team], 1.0);
    }

    // Draw No of caps
    if (bCTFGame)
    {
        if (zzCaps != 0)
        {
            Canvas.SetPos(XOffset+240,YOffset-20+RectHeight);
            Canvas.DrawIcon(texture'BotPack.GreenFlag',0.50);

            Canvas.DrawColor = WhiteColor;
            Canvas.StrLen(string(zzCaps),XL,YL);
            Canvas.SetPos(XOffset+239-XL,YOffset-18+RectHeight);
            Canvas.DrawText(string(zzCaps));
        }
    }

    if (bBT)
        DrawScore(Canvas,PRI.Score,XOffset,YOffset);
    else
        myDrawScore(Canvas, PRI, XOffset, YOffset,zzKill,zzDeath);

    Canvas.Font = CanvasFont;
    Canvas.DrawColor = OldColor;
}

// =============================================================================
// DrawVictoryConditions. Used to draw frag & timelimit
// =============================================================================

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

    if ( TGRI.GoalTeamScore > 0 )
    {
        DrawShadowText(Canvas,Canvas.CurX,Canvas.CurY,FragGoal@TGRI.GoalTeamScore,false);
        Canvas.SetPos(0, Canvas.CurY + YL + 2);
    }

    if ( TGRI.TimeLimit > 0 )
        DrawShadowText(Canvas,Canvas.CurX,Canvas.CurY,TimeLimit@TGRI.TimeLimit$":00",false);

    Canvas.Font = OldFont;
    Canvas.Style = OldStyle;
    Canvas.DrawColor = OldColor;
    Canvas.bCenter = false;
}

// =============================================================================
// DrawHeader. Draw mapname and real time
// =============================================================================

function DrawHeader( canvas Canvas )
{
    local GameReplicationInfo GRI;
    local float XL, YL;
    local font CanvasFont;
    local color OldColor;
    local byte OldStyle;
    local PlayerPawn PlayerOwner;
    local string zzTime;

    OldColor = Canvas.DrawColor;
    OldStyle = Canvas.Style;

    Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.DrawColor = HeaderColor;
    Canvas.Font = MyFonts.GetHugeFont(Canvas.ClipX);

    PlayerOwner = PlayerPawn(Owner);
    GRI = PlayerPawn(Owner).GameReplicationInfo;

    Canvas.StrLen(PlayerOwner.GameReplicationInfo.GameName@MapTitle@Level.Title,XL,YL);
    HeaderTop = Canvas.ClipY-(YL*1.5)-1;
    DrawShadowText(Canvas,Canvas.ClipX/2-XL/2,HeaderTop,PlayerOwner.GameReplicationInfo.GameName@MapTitle@Level.Title,false);

    Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);
    Canvas.DrawColor = WhiteColor;
    zzTime = GetTime();
    Canvas.StrLen(zzTime,xl,yl);
    DrawShadowText(Canvas,Canvas.ClipX/2-xl/2,Canvas.ClipY-yl-1,zzTime,false);

    Canvas.DrawColor = OldColor;
    Canvas.Style = OldStyle;

    DrawVictoryConditions(Canvas);
}

// =============================================================================
// DrawTrailer. Used to draw the timer
// =============================================================================

function DrawTrailer( canvas Canvas )
{
    local int Hours, Minutes, Seconds;
    local float XL, YL;
    local PlayerPawn PlayerOwner;
    local color OldColor;
    local Font OldFont;
    local string zzRemTime;

    PlayerOwner = PlayerPawn(Owner);

    if ( bTimeDown || (PlayerOwner.GameReplicationInfo.RemainingTime > 0) )
    {
        bTimeDown = true;
        if ( PlayerOwner.GameReplicationInfo.RemainingTime <= 0 )
        {
            zzRemTime = "00:00";
        }
        else
        {
            Minutes = PlayerOwner.GameReplicationInfo.RemainingTime/60;
            Seconds = PlayerOwner.GameReplicationInfo.RemainingTime % 60;
            zzRemTime = TwoDigitString(Minutes)$":"$TwoDigitString(Seconds);
        }
    }
    else
    {
        Seconds = PlayerOwner.GameReplicationInfo.ElapsedTime;
        Minutes = Seconds / 60;
        Hours   = Minutes / 60;
        Seconds = Seconds - (Minutes * 60);
        Minutes = Minutes - (Hours * 60);
        zzRemTime = "-"$TwoDigitString(Hours)$":"$TwoDigitString(Minutes)$":"$TwoDigitString(Seconds);
    }

    OldFont = Canvas.Font;
    OldColor = Canvas.DrawColor;

    Canvas.Font = MyFonts.GetHugeFont(Canvas.ClipX);

    Canvas.StrLen("-00:00:00",XL,YL);

    Canvas.DrawColor = WhiteColor;
    DrawShadowText(Canvas,Canvas.ClipX-XL-2,0,zzRemTime,false);

    Canvas.DrawColor = OldColor;
    Canvas.Font = OldFont;
}

// =============================================================================
// DrawWeaponInfo ~ Display weapon statistics on the scoreboard
// =============================================================================

function DrawWeaponInfo (Canvas C)
{
   local float XL,YL,XL2,YL2,LeftXOffset,RightXOffset,XOffset,YOffset,Accu,LeftWeaponTop,RightWeaponTop;
   local int i,color;

   // Draw Total stats first
   C.StrLen("1",XL,YL);

   C.DrawColor = DieColor;

   LeftXOffset = (C.ClipX-360*2)/7*3;
   RightXOffset = (C.ClipX-360*2)/7*4 + 360;
   YOffset = HeaderTop - YL - 1;

   DrawRect(C,LeftXOffset,YOffset,YL+1,360,4,1);
   C.DrawColor = DieColor;

   C.SetPos(LeftXOffset+2,YOffset);
   C.DrawText("Damage Given: "$zzPI[zzOwnerIndex].zzRI.zzDamageGiven);

   C.SetPos(LeftXOffset+182,YOffset);
   C.DrawText("Damage Received: "$zzPI[zzOwnerIndex].zzRI.zzDamageReceived);

   DrawRect(C,RightXOffset,YOffset,YL+1,360,4,1);

   C.SetPos(RightXOffset+2,YOffset);
   C.DrawText("ShotCount: "$zzPI[zzOwnerIndex].zzRI.zzShotCount);

   C.StrLen("HitCount: 123456",XL,YL);
   C.SetPos(RightXOffset+180-XL/2,YOffset);
   C.DrawText("HitCount: "$zzPI[zzOwnerIndex].zzRI.zzHitCount);

   if (zzPI[zzOwnerIndex].zzRI.zzShotCount != 0)
       Accu = float(zzPI[zzOwnerIndex].zzRI.zzHitCount)/float(zzPI[zzOwnerIndex].zzRI.zzShotCount)*100.00;
   else
       Accu = 0.00;

   C.StrLen("Accuracy: 100.00 %",XL,YL);
   C.SetPos(RightXOffset+360-XL-2,YOffset);
   C.DrawText("Accuracy: "$Left(string(Accu),InStr(string(Accu),".")+2)$" %");

   LeftWeaponTop = YOffset;
   RightWeaponTop = YOffset;

   // Draw Per weapon stats
   for (i=0;i<zzPI[zzOwnerIndex].zzRI.zzIndex;++i)
   {
       if (i%2 == 0)
       {
           XOffset = LeftXOffset;
           YOffset = LeftWeaponTop - YL - 1;
           LeftWeaponTop = YOffset;
       }
       else
       {
           XOffset = RightXOffset;
           YOffset = RightWeaponTop - YL - 1;
           RightWeaponTop = YOffset;
       }

       DrawRect(C,XOffset,YOffset,YL,360,i%2,4);

       C.SetPos(XOffset+2,YOffset);
       C.DrawText(zzPI[zzOwnerIndex].zzRI.GetWeaponName(i));

       C.StrLen("12345678",XL,YL);
       C.SetPos(XOffset+180-XL/2,YOffset);
       C.DrawText(string(zzPI[zzOwnerIndex].zzRI.GetDamage(i)));

       C.SetPos(XOffset+180+XL/2+1,YOffset);
       C.DrawText(string(zzPI[zzOwnerIndex].zzRI.GetShotCount(i)));

       C.SetPos(XOffset+180+XL/2+2+XL,YOffset);
       C.DrawText(string(zzPI[zzOwnerIndex].zzRI.GetHitCount(i)));

       C.SetPos(XOffset+180+XL/2+3+2*XL,YOffset);
       Accu = zzPI[zzOwnerIndex].zzRI.GetAccu(i);
       C.DrawText(Left(string(Accu),InStr(string(Accu),".")+2)$" %");
   }

   if (zzPI[zzOwnerIndex].zzRI.zzIndex == 0)
       return;

   XOffset = LeftXOffset;
   YOffset = LeftWeaponTop-YL-1;

   DrawRect(C,XOffset,YOffset,YL,360,0,5);
   C.SetPos(XOffset+2,YOffset);
   C.DrawText("WeaponName:");
   C.SetPos(XOffset+180-XL/2,YOffset);
   C.DrawText("Damage:");
   C.SetPos(XOffset+180+XL/2+1,YOffset);
   C.DrawText("Shots:");
   C.SetPos(XOffset+180+XL/2+2+XL,YOffset);
   C.DrawText("Hits:");
   C.SetPos(XOffset+180+XL/2+3+2*XL,YOffset);
   C.DrawText("Accu:");

   if (zzPI[zzOwnerIndex].zzRI.zzIndex == 1)
       return;

   XOffset = RightXOffset;
   YOffset = RightWeaponTop-YL-1;

   DrawRect(C,XOffset,YOffset,YL,360,0,5);
   C.SetPos(XOffset+2,YOffset);
   C.DrawText("WeaponName:");
   C.SetPos(XOffset+180-XL/2,YOffset);
   C.DrawText("Damage:");
   C.SetPos(XOffset+180+XL/2+1,YOffset);
   C.DrawText("Shots:");
   C.SetPos(XOffset+180+XL/2+2+XL,YOffset);
   C.DrawText("Hits:");
   C.SetPos(XOffset+180+XL/2+3+2*XL,YOffset);
   C.DrawText("Accu:");

}

// =============================================================================
// DrawRect function, used for alterling the color.
// =============================================================================

function DrawRect(Canvas Canvas,float XOffset,float YOffset,float Height,float Width,int zzColor,int team)
{
    local Color OldColor;
    local byte OldStyle;

    OldColor = Canvas.DrawColor;
    OldStyle = Canvas.Style;

    Canvas.SetPos(XOffset,YOffset);

    team++;

    Canvas.Style = ERenderStyle.STY_Translucent;

    if (team == 512)
    {
      Canvas.DrawColor.R = 0;
      Canvas.DrawColor.G = 0;
      Canvas.DrawColor.B = 0;

      if (zzColor == 1)
      {
          Canvas.DrawRect(texture'BG',Width,Height);
          Canvas.SetPos(XOffset,YOffset);
      }

      Canvas.Style = ERenderStyle.STY_Modulated;
    }
    else if (team == 1)
    {
      Canvas.DrawColor.R = 127*(zzColor+1);
      Canvas.DrawColor.G = 32;
      Canvas.DrawColor.B = 32;
    }
    else if (team == 2)
    {
      Canvas.DrawColor.R = 32;
      Canvas.DrawColor.G = 32;
      Canvas.DrawColor.B = 127*(zzColor+1);
    }
    else if (team == 3)
    {
      Canvas.DrawColor.R = 32;
      Canvas.DrawColor.G = 127*(zzColor+1);
      Canvas.DrawColor.B = 32;
    }
    else if (team == 4)
    {
      Canvas.DrawColor.R = 127*(zzColor+1);
      Canvas.DrawColor.G = 127*(zzColor+1);
      Canvas.DrawColor.B = 32;
    }
    else if (team == 5)
    {
      Canvas.DrawColor.R = 96+32*zzColor;
      Canvas.DrawColor.G = 96+32*zzColor;
      Canvas.DrawColor.B = 96+32*zzColor;
    }
    else if (team == 6)
    {
      Canvas.DrawColor.R = 32+32*zzColor;
      Canvas.DrawColor.G = 32+32*zzColor;
      Canvas.DrawColor.B = 32+32*zzColor;
    }
    else
    {
      Canvas.DrawColor.R = 127*(zzColor+1);
      Canvas.DrawColor.G = 127*(zzColor+1);
      Canvas.DrawColor.B = 127*(zzColor+1);
    }

    Canvas.DrawRect(texture'BG',Width,Height);

    Canvas.Style = OldStyle;
    Canvas.DrawColor = OldColor;
}

// =============================================================================
// Functions from UT2004. Used to draw lines
// =============================================================================

function DrawVertical(Canvas Canvas,float X, float height)
{
    local float cX,cY;

    CX = Canvas.CurX; CY = Canvas.CurY;
    Canvas.CurX = X;
    Canvas.DrawTile(texture'BG', 1, height, 0, 0, 2, 2);
    Canvas.CurX = CX; Canvas.CurY = CY;
}

function DrawHorizontal(Canvas Canvas,float Y, float width)
{
    local float cx,cy;

    CX = Canvas.CurX; CY = Canvas.CurY;
    Canvas.CurY = Y;
    Canvas.DrawTile(texture'BG', width, 1, 0, 0, 2, 2);
    Canvas.CurX = CX; Canvas.CurY = CY;
}

function DrawLine(Canvas Canvas,int direction, float size)
{
    local float cx,cy;
    local color OldColor;
    local byte OldStyle;

    CX = Canvas.CurX; CY = Canvas.CurY;
    OldColor = Canvas.DrawColor;
    OldStyle = Canvas.Style;
    Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 0;
    Canvas.DrawColor.B = 0;

    switch (direction)
    {
        case 0:
            Canvas.CurY-=Size;
            DrawVertical(Canvas,Canvas.CurX,size);
            break;
        case 1:
            DrawVertical(Canvas,Canvas.CurX,size);
            break;
        case 2:
            Canvas.CurX-=Size;
            DrawHorizontal(Canvas,Canvas.CurY,size);
            break;
        case 3:
            DrawHorizontal(Canvas,Canvas.CurY,size);
            break;
    }

    Canvas.CurX = CX; Canvas.CurY = CY;
    Canvas.DrawColor = OldColor;
    Canvas.Style = OldStyle;

}

// =============================================================================
// DrawShadowText ~ Used to draw the teamscore
// =============================================================================

function DrawShadowText (Canvas Canvas, float XOffset, float YOffset, string zzText, bool zzParam, optional bool bGrayShadow,optional bool bSmall)
{
    local Color OldColor;
    local int XL,YL;

    OldColor = Canvas.DrawColor;

    if (bGrayShadow)
    {
      Canvas.DrawColor.R = 127;
      Canvas.DrawColor.G = 127;
      Canvas.DrawColor.B = 127;
    }
    else
    {
      Canvas.DrawColor.R = 0;
      Canvas.DrawColor.G = 0;
      Canvas.DrawColor.B = 0;
    }
    if (bSmall)
    {
      XL = 1;
      YL = 1;
    }
    else
    {
      XL = 2;
      YL = 2;
    }

    Canvas.SetPos(XOffset+XL,YOffset+YL);
    Canvas.DrawText(zzText,zzParam);

    Canvas.DrawColor = OldColor;
    Canvas.SetPos(XOffset,YOffset);
    Canvas.DrawText(zzText,zzParam);

}

// =============================================================================
// Time functions
// =============================================================================

function string GetTime()
{
    local string zzTime;
    local LevelInfo Level;

    Level = PlayerPawn(Owner).Level;

    zzTime = Level.Day@GetMonth(Level.Month)@Level.Year@"~"@Pad(Level.Hour)$":"$Pad(Level.Minute)$":"$Pad(Level.Second);

    return zzTime;
}

function string GetMonth(int Month)
{
   Switch(Month)
   {
       Case 1:
           return "January";
       Case 2:
           return "Februari";
       case 3:
           return "March";
       case 4:
           return "April";
       case 5:
           return "May";
       case 6:
           return "June";
       case 7:
           return "July";
       case 8:
           return "August";
       case 9:
           return "September";
       case 10:
           return "October";
       case 11:
           return "November";
       case 12:
           return "December";
   }
}

function string Pad (int zzPad)
{
    if (zzPad < 10)
      return "0"$zzPad;
    else
      return string(zzPad);
}

// =============================================================================
// Functions used for accessing and indexing the RI classes
// =============================================================================

function int FindInfo (PlayerReplicationInfo PRI)
{
   local int i;
   local UTSReplicationInfo zzRI;
   local bool bFound;

   // See if it's already initialized
   for (i=0;i<zzIndex;++i)
   {
       if (zzPI[i].zzPRI == PRI)
           return i;
   }

   // Not initialized, find the RI and init a new slot
   foreach Level.AllActors(class'UTSReplicationInfo',zzRI)
   {
       if (zzRI.zzPID == PRI.PlayerID)
       {
           bFound = true;
           break;
       }
   }

   // Couldn't find RI, this sucks
   if (!bFound)
       return -1;

   // Init the slot
   if (zzIndex < 32)
   {
       InitInfo(zzIndex,PRI,zzRI);
       zzIndex++;
       return zzIndex;
   }
   else
   {
       for (i=0;i<32;++i)
       {
           if (zzPI[i].zzRI == None)
               break;
       }

       InitInfo(i,PRI,zzRI);
       return i;
   }

}

function InitInfo (int zzI, PlayerReplicationInfo PRI, UTSReplicationInfo RI)
{
    local Pawn Target;

    zzPI[zzI].zzPRI = PRI;
    zzPI[zzI].zzRI = RI;

    if (PRI == PlayerPawn(Owner).PlayerReplicationInfo)
        zzOwnerIndex = zzI;
}

// =============================================================================
// Defaultproperties
// =============================================================================


defaultproperties
{
    HeaderColor=(R=255,G=128,B=0,A=0),
    DieColor=(R=0,G=0,B=0,A=255),
    KillColor=(R=128,G=128,B=128,A=255),
    ScoreColor=(R=255,G=255,B=255,A=255),
    LoginColor=(R=32,G=255,B=32,A=0),
    FlagIcon(0)=Texture'Botpack.Icons.RedFlag'
    FlagIcon(1)=Texture'Botpack.Icons.BlueFlag'
    FlagIcon(2)=Texture'Botpack.Icons.GreenFlag'
    FlagIcon(3)=Texture'Botpack.Icons.YellowFlag'
}
