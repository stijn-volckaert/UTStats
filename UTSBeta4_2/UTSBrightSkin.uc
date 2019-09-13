class UTSBrightSkin extends TournamentPickup;

var UTSBrightSkinEffect zzMyEffect;
var int TeamNum;
var Texture TeamTextures[4];
var string TeamTextureStrings[4];

// =============================================================================
// Tick ~ Wait till playerteam is set
// =============================================================================

function Tick (float DeltaTime)
{

    if (!Level.Game.bTeamGame || Pawn(Owner).PlayerReplicationInfo.Team != 255)
        SetEffectTexture(Pawn(Owner).PlayerReplicationInfo.Team);
}

// =============================================================================
// SetEffectTexture ~ Handle the color of the brightskin
// =============================================================================

function SetEffectTexture(int zzTeamNum)
{
    local texture zzTex;
    local Inventory I;

    Disable('Tick');

    zzMyEffect = Spawn(class'UTSBrightSkinEffect', Pawn(Owner),,Pawn(Owner).Location, Pawn(Owner).Rotation);
    zzMyEffect.mesh = Owner.mesh;
    zzMyEffect.DrawScale = Owner.Drawscale;

    //Log("### SETTING TEXTURE for"@Pawn(Owner).PlayerReplicationInfo.PlayerName@zzTeamNum);

    if ( TeamTextures[zzTeamNum] == None )
        TeamTextures[zzTeamNum] = Texture(DynamicLoadObject(TeamTextureStrings[zzTeamNum], class'Texture'));

    zzMyEffect.texture = TeamTextures[zzTeamNum];


    I = Pawn(Owner).FindInventoryType(class'UT_Invisibility');
    if ( I != None )
        zzMyEffect.bHidden = true;
}

// =============================================================================
// Destroyed ~ Clean up
// =============================================================================

function Destroyed()
{
    //Log("### DESTROYING BRIGHTSKIN");

    if ( Owner != None )
    {
        Owner.SetDefaultDisplayProperties();
        if( Owner.Inventory != None )
            Owner.Inventory.SetOwnerDisplay();
    }
    if ( zzMyEffect != None )
        zzMyEffect.Destroy();
    Super.Destroyed();
}

// =============================================================================
// HandlePickupQuery ~ Don't log pickup to ngWorldStats
// =============================================================================

function bool HandlePickupQuery( inventory Item )
{
    return Inventory.HandlePickupQuery(Item);
}

// =============================================================================
// Pickupfunction ~ Don't need this
// =============================================================================

function PickupFunction(Pawn Other) {}

// =============================================================================
// Defaultproperties
// =============================================================================

defaultproperties
{
    itemname="UTPro BrightSkin"
    //TeamTextureStrings(0)="UnrealShare.Belt_fx.ShieldBelt.newred"
    //TeamTextureStrings(1)="UnrealShare.Belt_fx.ShieldBelt.newblue"
    //TeamTextureStrings(2)="UnrealShare.Belt_fx.ShieldBelt.newgreen"
    //TeamTextureStrings(3)="UnrealShare.Belt_fx.ShieldBelt.newgold"
    TeamTextureStrings(0)="UTSTextures.Red"
    TeamTextureStrings(1)="UTSTextures.Blue"
    TeamTextureStrings(2)="UTSTextures.Green"
    TeamTextureStrings(3)="UTSTextures.Yellow"
    bIsAnArmor=False
}

