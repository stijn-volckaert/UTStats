class UTSDMPBoard extends UTSTeamBoard;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    bNoTeamGame = true;
}

defaultproperties
{
    FragGoal="Frag Limit:"
}
