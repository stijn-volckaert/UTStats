class UTSBrightSkinEffect extends Effects;

var int FatnessOffset;

simulated function Destroyed()
{
    if ( bHidden && (Owner != None) )
    {
        if ( Level.NetMode == NM_Client )
        {
            Owner.Texture = Owner.Default.Texture;
            Owner.bMeshEnviromap = Owner.Default.bMeshEnviromap;
        }
        else
            Owner.SetDefaultDisplayProperties();
    }

    Super.Destroyed();
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     bOwnerNoSee=True
     bNetTemporary=false
     DrawType=DT_Mesh
     bAnimByOwner=True
     bHidden=False
     bMeshEnviroMap=True
     FatnessOffset=29
     Fatness=157
     Style=STY_Translucent
     DrawScale=0.25000
     ScaleGlow=0.5
     AmbientGlow=64
     bUnlit=true
     Physics=PHYS_Trailer
     bTrailerSameRotation=true
}

