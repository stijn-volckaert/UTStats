class UTSMutator extends Mutator;

#exec audio Import File=..\UTS\Classes\hit.wav name=hit

// =============================================================================
// PostBeginPlay ~ Register ourselves as a damagemutator
// =============================================================================

function PostBeginPlay ()
{
    Level.Game.RegisterDamageMutator(Self);
}

// =============================================================================
// ModifyPlayer ~ Give each player a brightskin
// =============================================================================

/*function ModifyPlayer (Pawn A)
{
    local UTSBrightSkin UTSBS;

    if (A != None && !A.IsA('Spectator') && !A.IsA('StaticPawn'))
    {
        Log("### PLAYER SPAWN"@A.PlayerReplicationInfo.PlayerName);
        UTSBS = Spawn(class'UTSBrightSkin');
        if( UTSBS != None )
        {
           UTSBS.GiveTo(A);
        }
    }
    if (NextMutator != None)
        NextMutator.ModifyPlayer(A);
} */

// =============================================================================
// MutatorTakeDamage ~ Handle hitsounds
// =============================================================================

function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out Vector Momentum, name DamageType)
{
    if (!Level.Game.bTeamGame && Victim != None && PlayerPawn(InstigatedBy) != None)
    {
        //Log("### HITSOUND");
        PlayerPawn(InstigatedBy).ClientPlaySound(sound'hit');
    }
    else if (Victim != None && PlayerPawn(InstigatedBy) != None && Victim.PlayerReplicationInfo.Team != InstigatedBy.PlayerReplicationInfo.Team)
    {
        //Log("### HITSOUND");
        PlayerPawn(InstigatedBy).ClientPlaySound(sound'hit');
    }

    if (NextDamageMutator != None)
        NextDamageMutator.MutatorTakeDamage(ActualDamage,Victim,InstigatedBy,HitLocation,Momentum,DamageType);
}
