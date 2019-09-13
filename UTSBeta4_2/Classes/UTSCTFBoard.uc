class UTSCTFBoard extends UTSTeamBoard;

function PostBeginPlay ()
{
    Super.PostBeginPlay();
    bCTFGame=true;
}

defaultproperties
{
     FragGoal="Capture Limit:"
}
