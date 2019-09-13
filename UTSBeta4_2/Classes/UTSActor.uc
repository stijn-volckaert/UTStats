class UTSActor extends MessagingSpectator;

var string zzGLTag;

var UTSDamageMut UTSDM;

var UTSProjectileSN UTSPSN;
var UTSShockBeamSN UTSSBSN;
var UTSSuperShockBeamSN UTSSSBSN;
var UTSComboSN UTSCSN;

var bool bNoTeamGame;

// =============================================================================
// Setup the boards
// =============================================================================

function PostBeginPlay()
{
    if (Level.Game.IsA('BunnyTrackGame'))
        Level.Game.ScoreBoardType = class'UTSBTBoard';
    else if (Level.Game.IsA('Domination'))
        Level.Game.ScoreBoardType = class'UTSDomBoard';
    else if (Level.Game.IsA('Assault'))
        Level.Game.ScoreBoardType = class'UTSAsBoard';
    else if (Level.Game.IsA('CTFGame'))
        Level.Game.ScoreBoardType = class'UTSCTFBoard';
    else if (Level.Game.IsA('TeamGamePlus'))
        Level.Game.ScoreBoardType = class'UTSTeamBoard';
    else if (Level.Game.IsA('LastManStanding'))
    {
        if (Level.Game.bTeamGame)
            Level.Game.ScoreBoardType = class'UTSTeamBoard';
        else
        {
            Level.Game.ScoreBoardType = class'UTSLMSBoard';
            bNoTeamGame = true;
        }
    }
    else
    {
        Level.Game.ScoreBoardType = class'UTSDMPBoard';
        bNoTeamGame = true;
    }

    // Spawn the mutator that will handle the accuracy
    UTSDM = UTSDamageMut(FindMutator("UTSDamageMut"));
    if (UTSDM == None)
    {
	    Level.Game.BaseMutator.AddMutator(Level.Spawn(class'UTSDamageMut'));
	    UTSDM = UTSDamageMut(FindMutator("UTSDamageMut"));

	    if (UTSDM == None)
	    {
	        Log("### ERROR: UTPro cannot run without the UTSAccu package!");
	        goto 'xEnd';
	    }
	    UTSDM.bNoTeamGame = !Level.Game.bTeamGame;

	    // Spawn projectile/effects catchers
        UTSPSN = Level.Spawn(class'UTSProjectileSN');
        UTSPSN.UTSDM = UTSDM;
        UTSSBSN = Level.Spawn(class'UTSShockBeamSN');
        UTSSBSN.UTSDM = UTSDM;
        UTSSSBSN = Level.Spawn(class'UTSSuperShockBeamSN');
        UTSSSBSN.UTSDM = UTSDM;
        UTSCSN = Level.Spawn(class'UTSComboSN');
        UTSCSN.UTSDM = UTSDM;
    }

    UTSDM.bClickboard = true;
    Log("### UTSAccu Package Found");
    Log("### UTS Started");

    //Level.Game.BaseMutator.AddMutator(Level.Spawn(class'UTSMutator'));

    Tag = 'UTGLCatcher';

    xEnd:
}

// =============================================================================
// Redirect UTGL touches to the mutator
// =============================================================================

function Touch(Actor A)
{
   UTSDM.zzGLTag = zzGLTag;
   UTSDM.Touch(A);
}

// =============================================================================
// FindMutator function
// =============================================================================

function Mutator FindMutator (string MutName)
{
   local Mutator M;

   M = Level.Game.BaseMutator;

   while (M != None)
   {
       if (InStr(M.class,MutName) != -1)
           return M;
       else
           M = M.NextMutator;
   }

   return M;
}

// =============================================================================
// Messaging functions
// =============================================================================

function ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	switch(Message)
	{
		case Level.Game.DeathMessageClass:
            switch(Switch)
		    {
			    Case 1:
				Case 2:
				Case 3:
				Case 4:
				Case 5:
				Case 6:
				case 7:
				    UTSDM.DoSuicide(RelatedPRI_1);
					break;
				Default:
					break;
			}
			break;
		case class'CTFMessage':
		    if (Switch == 0)
		        UTSDM.DoCap(RelatedPRI_1);
            break;
	}
}

event TeamMessage (PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep) {}
function ClientVoiceMessage (PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID) {}
event ClientMessage( coerce string S, optional name Type, optional bool bBeep ) {}

// =============================================================================
// Defaultproperties
// =============================================================================

defaultproperties
{
   bHidden=true;
}
