class UTSBeltEffectSN extends SpawnNotify;

simulated event Actor SpawnNotification(Actor A)
{
    if (UT_ShieldBeltEffect(A) != None)
        UT_ShieldBeltEffect(A).ScaleGlow *= 2;
}

defaultproperties
{
    ActorClass=class'UT_ShieldBeltEffect'
}
