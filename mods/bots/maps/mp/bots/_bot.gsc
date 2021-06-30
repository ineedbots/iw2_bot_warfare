#include maps\mp\_utility;
#include maps\mp\bots\_bot_utility;

/*
	Initiates the whole bot scripts.
*/
init()
{
	level.bw_VERSION = "2.0.1";

	if ( getCvar( "bots_main" ) == "" )
		setCvar( "bots_main", true );

	if ( !getCvarInt( "bots_main" ) )
		return;

	thread load_waypoints();
	thread hook_callbacks();

	if ( getCvar( "bots_main_GUIDs" ) == "" )
		setCvar( "bots_main_GUIDs", "" ); //guids of players who will be given host powers, comma seperated

	if ( getCvar( "bots_main_firstIsHost" ) == "" )
		setCvar( "bots_main_firstIsHost", true ); //first player to connect is a host

	if ( getCvar( "bots_main_waitForHostTime" ) == "" )
		setCvar( "bots_main_waitForHostTime", 10.0 ); //how long to wait to wait for the host player

	if ( getCvar( "bots_manage_add" ) == "" )
		setCvar( "bots_manage_add", 0 ); //amount of bots to add to the game

	if ( getCvar( "bots_manage_fill" ) == "" )
		setCvar( "bots_manage_fill", 0 ); //amount of bots to maintain

	if ( getCvar( "bots_manage_fill_spec" ) == "" )
		setCvar( "bots_manage_fill_spec", true ); //to count for fill if player is on spec team

	if ( getCvar( "bots_manage_fill_mode" ) == "" )
		setCvar( "bots_manage_fill_mode", 0 ); //fill mode, 0 adds everyone, 1 just bots, 2 maintains at maps, 3 is 2 with 1

	if ( getCvar( "bots_manage_fill_kick" ) == "" )
		setCvar( "bots_manage_fill_kick", false ); //kick bots if too many

	if ( getCvar( "bots_team" ) == "" )
		setCvar( "bots_team", "autoassign" ); //which team for bots to join

	if ( getCvar( "bots_team_amount" ) == "" )
		setCvar( "bots_team_amount", 0 ); //amount of bots on axis team

	if ( getCvar( "bots_team_force" ) == "" )
		setCvar( "bots_team_force", false ); //force bots on team

	if ( getCvar( "bots_team_mode" ) == "" )
		setCvar( "bots_team_mode", 0 ); //counts just bots when 1

	if ( getCvar( "bots_skill" ) == "" )
		setCvar( "bots_skill", 0 ); //0 is random, 1 is easy 7 is hard, 8 is custom, 9 is completely random

	if ( getCvar( "bots_skill_axis_hard" ) == "" )
		setCvar( "bots_skill_axis_hard", 0 ); //amount of hard bots on axis team

	if ( getCvar( "bots_skill_axis_med" ) == "" )
		setCvar( "bots_skill_axis_med", 0 );

	if ( getCvar( "bots_skill_allies_hard" ) == "" )
		setCvar( "bots_skill_allies_hard", 0 );

	if ( getCvar( "bots_skill_allies_med" ) == "" )
		setCvar( "bots_skill_allies_med", 0 );

	if ( getCvar( "bots_loadout_rank" ) == "" ) // what rank the bots should be around, -1 is around the players, 0 is all random
		setCvar( "bots_loadout_rank", -1 );

	if ( getCvar( "bots_play_move" ) == "" ) //bots move
		setCvar( "bots_play_move", true );

	if ( getCvar( "bots_play_knife" ) == "" ) //bots knife
		setCvar( "bots_play_knife", true );

	if ( getCvar( "bots_play_fire" ) == "" ) //bots fire
		setCvar( "bots_play_fire", true );

	if ( getCvar( "bots_play_nade" ) == "" ) //bots grenade
		setCvar( "bots_play_nade", true );

	if ( getCvar( "bots_play_obj" ) == "" ) //bots play the obj
		setCvar( "bots_play_obj", true );

	if ( getCvar( "bots_play_camp" ) == "" ) //bots camp and follow
		setCvar( "bots_play_camp", true );

	if ( getCvar( "bots_play_jumpdrop" ) == "" ) //bots jump and dropshot
		setCvar( "bots_play_jumpdrop", true );

	if ( getCvar( "bots_play_ads" ) == "" ) //bot ads
		setCvar( "bots_play_ads", true );

	if ( !isDefined( game["botWarfare"] ) )
		game["botWarfare"] = true;

	level.defuseObject = undefined;
	level.bots_smokeList = List();

	level.bots_minGrenadeDistance = 256;
	level.bots_minGrenadeDistance *= level.bots_minGrenadeDistance;
	level.bots_maxGrenadeDistance = 1024;
	level.bots_maxGrenadeDistance *= level.bots_maxGrenadeDistance;
	level.bots_maxKnifeDistance = 80;
	level.bots_maxKnifeDistance *= level.bots_maxKnifeDistance;
	level.bots_goalDistance = 27.5;
	level.bots_goalDistance *= level.bots_goalDistance;
	level.bots_noADSDistance = 200;
	level.bots_noADSDistance *= level.bots_noADSDistance;
	level.bots_maxShotgunDistance = 500;
	level.bots_maxShotgunDistance *= level.bots_maxShotgunDistance;
	level.bots_listenDist = 100;

	level.smokeRadius = 255;

	level.bots = [];
	level.players = [];

	level.bots_fullautoguns = [];
	level.bots_fullautoguns["greasegun"] = true;
	level.bots_fullautoguns["thompson"] = true;
	level.bots_fullautoguns["bar"] = true;
	level.bots_fullautoguns["pps42"] = true;
	level.bots_fullautoguns["sten"] = true;
	level.bots_fullautoguns["bren"] = true;
	level.bots_fullautoguns["mp44"] = true;
	level.bots_fullautoguns["ppsh"] = true;
	level.bots_fullautoguns["mp40"] = true;

	level thread fixGamemodes();

	level thread onPlayerConnect();
	level thread handleBots();
	level thread watchNades();
	level thread watchGameEnded();

	//level thread maps\mp\bots\_bot_http::doVersionCheck();

	level.teamBased = true;

	if ( getcvar( "g_gametype" ) == "dm" )
		level.teamBased = false;
}

/*
	Starts the threads for bots.
*/
handleBots()
{
	level thread teamBots();
	level thread diffBots();
	level addBots();

	while ( !level.mapended )
		wait 0.05;

	setCvar( "bots_manage_add", getBotArray().size );
}

/*
	The hook callback for when any player becomes damaged.
*/
onPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if ( self is_bot() )
	{
		self maps\mp\bots\_bot_internal::onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
		//self maps\mp\bots\_bot_script::onDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
	}

	self [[level.prevCallbackPlayerDamage]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
}

/*
	The hook callback when any player gets killed.
*/
onPlayerKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration )
{
	if ( self is_bot() )
	{
		self maps\mp\bots\_bot_internal::onKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
		//self maps\mp\bots\_bot_script::onKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
	}

	self [[level.prevCallbackPlayerKilled]]( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
}

/*
	Starts the callbacks.
*/
hook_callbacks()
{
	wait 0.05;
	level.prevCallbackPlayerDamage = level.callbackPlayerDamage;
	level.callbackPlayerDamage = ::onPlayerDamage;

	level.prevCallbackPlayerKilled = level.callbackPlayerKilled;
	level.callbackPlayerKilled = ::onPlayerKilled;
}

/*
	Adds the level.radio object for koth. Cause the iw3 script doesn't have it.
*/
fixKoth()
{
	level.radio = undefined;

	for ( ;; )
	{
		wait 0.05;

		if ( !isDefined( level.radioObject ) )
		{
			continue;
		}

		for ( i = level.radios.size - 1; i >= 0; i-- )
		{
			if ( level.radioObject != level.radios[i].gameobject )
				continue;

			level.radio = level.radios[i];
			break;
		}

		while ( isDefined( level.radioObject ) && level.radio.gameobject == level.radioObject )
			wait 0.05;
	}
}

/*
	Fixes gamemodes when level starts.
*/
fixGamemodes()
{
	for ( i = 0; i < 19; i++ )
	{
		if ( isDefined( level.bombZones ) && level.gametype == "sd" )
		{
			//for(i = 0; i < level.bombZones.size; i++)
			//level.bombZones[i].onUse = ::onUsePlantObjectFix;
			break;
		}

		if ( isDefined( level.radios ) && level.gametype == "koth" )
		{
			level thread fixKoth();

			break;
		}

		wait 0.05;
	}
}

/*
	Thread when any player connects. Starts the threads needed.
*/
onPlayerConnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );

		player thread onWeaponFired();
		player thread connected();
		player thread onDeath();
		player thread watchWeapons();
		player thread watchVelocity();
		player thread watchVars();
		player thread doPlayerModelFix();
	}
}

/*
	Fixes a weird iw3 bug when for a frame the player doesn't have any bones when they first spawn in.
*/
doPlayerModelFix()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" );
	wait 0.05;
	self.bot_model_fix = true;
}

/*
	CoD2
*/
watchWeapons()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		weap = self getCurrentWeapon();
		self thread watchAmmoUsage( weap );

		while ( weap == self getCurrentWeapon() )
			wait 0.05;

		self notify( "weapon_change", self getCurrentWeapon() );
	}
}

/*
	CoD2
*/
watchAmmoUsage( weap )
{
	self endon( "disconnect" );
	self endon( "weapon_change" );

	slot = self getWeaponSlot( weap );

	for ( ;; )
	{
		aCount = self GetWeaponSlotClipAmmo( slot );

		while ( aCount == self GetWeaponSlotClipAmmo( slot ) )
			wait 0.05;

		if ( self GetWeaponSlotClipAmmo( slot ) < aCount )
			self notify( "weapon_fired" );
		else
			self notify( "reload" );
	}
}

/*
	CoD2
*/
watchVars()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		self.team = self.pers["team"];

		wait 0.05;
	}
}

/*
	CoD2
*/
watchVelocity()
{
	self endon( "disconnect" );

	lastOrigin = self.origin;

	for ( ;; )
	{
		wait 0.05;
		self.velocity = vector_scale( self.origin - lastOrigin, 20 );
		lastOrigin = self.origin;
	}
}

/*
	Kills the tags for a player
*/
killTags()
{
	if ( isDefined( self.tags ) )
	{
		for ( i = 0; i < self.tags.size; i++ )
			self.tags[i] delete ();

		self.tags = undefined;
		self.tagMap = undefined;
	}
}

/*
	death
*/
onDeath()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill( "death" );

		self killTags();
	}
}

/*
	When a bot disconnects.
*/
onDisconnectPlayer()
{
	self waittill( "disconnect" );
	self killTags();

	level.players = array_remove( level.players, self );
}

/*
	When a bot disconnects.
*/
onDisconnect()
{
	self waittill( "disconnect" );

	level.bots = array_remove( level.bots, self );
}

/*
	Called when a player connects.
*/
connected()
{
	self endon( "disconnect" );

	level.players[level.players.size] = self;
	self thread onDisconnectPlayer();

	if ( !isDefined( self.pers["bot_host"] ) )
		self thread doHostCheck();

	if ( !self is_bot() )
		return;

	if ( !isDefined( self.pers["isBot"] ) )
	{
		// fast restart...
		self.pers["isBot"] = true;
	}

	if ( !isDefined( self.pers["isBotWarfare"] ) )
	{
		self.pers["isBotWarfare"] = true;
		self thread added();
	}

	self thread maps\mp\bots\_bot_internal::connected();
	//self thread maps\mp\bots\_bot_script::connected();

	level.bots[level.bots.size] = self;
	self thread onDisconnect();

	level notify( "bot_connected", self );

	self thread spawnBot();
}

spawnBot()
{
	self endon( "disconnect" );

	wait 5;

	self notify( "menuresponse", game["menu_team"], "autoassign" );

	wait 0.5;

	weap = "mp40_mp";

	if ( self.team == "allies" )
	{
		if ( game["allies"] == "american" )
			weap = "thompson_mp";
		else if ( game["allies"] == "british" )
			weap = "greasegun_mp";
		else
			weap = "ppsh_mp";
	}

	self notify( "menuresponse", game["menu_weapon_" + self.team], weap );
}

/*
	When a bot gets added into the game.
*/
added()
{
	self endon( "disconnect" );

	self thread maps\mp\bots\_bot_internal::added();
	//self thread maps\mp\bots\_bot_script::added();
}

/*
	Adds a bot to the game.
*/
add_bot()
{
	bot = addtestclient();

	if ( isdefined( bot ) )
	{
		bot.pers["isBot"] = true;
		bot.pers["isBotWarfare"] = true;
		bot thread added();
	}
}

/*
	A server thread for monitoring all bot's difficulty levels for custom server settings.
*/
diffBots_loop()
{
	var_allies_hard = getCvarInt( "bots_skill_allies_hard" );
	var_allies_med = getCvarInt( "bots_skill_allies_med" );
	var_axis_hard = getCvarInt( "bots_skill_axis_hard" );
	var_axis_med = getCvarInt( "bots_skill_axis_med" );
	var_skill = getCvarInt( "bots_skill" );

	allies_hard = 0;
	allies_med = 0;
	axis_hard = 0;
	axis_med = 0;

	if ( var_skill == 8 )
	{
		playercount = level.players.size;

		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[i];

			if ( !isDefined( player.pers["team"] ) )
				continue;

			if ( !player is_bot() )
				continue;

			if ( player.pers["team"] == "axis" )
			{
				if ( axis_hard < var_axis_hard )
				{
					axis_hard++;
					player.pers["bots"]["skill"]["base"] = 7;
				}
				else if ( axis_med < var_axis_med )
				{
					axis_med++;
					player.pers["bots"]["skill"]["base"] = 4;
				}
				else
					player.pers["bots"]["skill"]["base"] = 1;
			}
			else if ( player.pers["team"] == "allies" )
			{
				if ( allies_hard < var_allies_hard )
				{
					allies_hard++;
					player.pers["bots"]["skill"]["base"] = 7;
				}
				else if ( allies_med < var_allies_med )
				{
					allies_med++;
					player.pers["bots"]["skill"]["base"] = 4;
				}
				else
					player.pers["bots"]["skill"]["base"] = 1;
			}
		}
	}
	else if ( var_skill != 0 && var_skill != 9 )
	{
		playercount = level.players.size;

		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[i];

			if ( !player is_bot() )
				continue;

			player.pers["bots"]["skill"]["base"] = var_skill;
		}
	}
}

/*
	A server thread for monitoring all bot's difficulty levels for custom server settings.
*/
diffBots()
{
	for ( ;; )
	{
		wait 1.5;

		diffBots_loop();
	}
}

/*
	A server thread for monitoring all bot's teams for custom server settings.
*/
teamBots_loop()
{
	teamAmount = getCvarInt( "bots_team_amount" );
	toTeam = getCvar( "bots_team" );

	alliesbots = 0;
	alliesplayers = 0;
	axisbots = 0;
	axisplayers = 0;

	playercount = level.players.size;

	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[i];

		if ( !isDefined( player.pers["team"] ) )
			continue;

		if ( player is_bot() )
		{
			if ( player.pers["team"] == "allies" )
				alliesbots++;
			else if ( player.pers["team"] == "axis" )
				axisbots++;
		}
		else
		{
			if ( player.pers["team"] == "allies" )
				alliesplayers++;
			else if ( player.pers["team"] == "axis" )
				axisplayers++;
		}
	}

	allies = alliesbots;
	axis = axisbots;

	if ( !getCvarInt( "bots_team_mode" ) )
	{
		allies += alliesplayers;
		axis += axisplayers;
	}

	if ( toTeam != "custom" )
	{
		if ( getCvarInt( "bots_team_force" ) )
		{
			if ( toTeam == "autoassign" )
			{
				if ( abs( axis - allies ) > 1 )
				{
					toTeam = "axis";

					if ( axis > allies )
						toTeam = "allies";
				}
			}

			if ( toTeam != "autoassign" )
			{
				playercount = level.players.size;

				for ( i = 0; i < playercount; i++ )
				{
					player = level.players[i];

					if ( !isDefined( player.pers["team"] ) )
						continue;

					if ( !player is_bot() )
						continue;

					if ( player.pers["team"] == toTeam )
						continue;

					if ( toTeam == "allies" )
						player thread [[level.allies]]();
					else if ( toTeam == "axis" )
						player thread [[level.axis]]();
					else
						player thread [[level.spectator]]();

					break;
				}
			}
		}
	}
	else
	{
		playercount = level.players.size;

		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[i];

			if ( !isDefined( player.pers["team"] ) )
				continue;

			if ( !player is_bot() )
				continue;

			if ( player.pers["team"] == "axis" )
			{
				if ( axis > teamAmount )
				{
					player thread [[level.allies]]();
					break;
				}
			}
			else
			{
				if ( axis < teamAmount )
				{
					player thread [[level.axis]]();
					break;
				}
				else if ( player.pers["team"] != "allies" )
				{
					player thread [[level.allies]]();
					break;
				}
			}
		}
	}
}

/*
	A server thread for monitoring all bot's teams for custom server settings.
*/
teamBots()
{
	for ( ;; )
	{
		wait 1.5;

		teamBots_loop();
	}
}

/*
	A server thread for monitoring all bot's in game. Will add and kick bots according to server settings.
*/
addBots_loop()
{
	botsToAdd = GetCvarInt( "bots_manage_add" );

	if ( botsToAdd > 0 )
	{
		SetCvar( "bots_manage_add", 0 );

		if ( botsToAdd > 64 )
			botsToAdd = 64;

		for ( ; botsToAdd > 0; botsToAdd-- )
		{
			level add_bot();
			wait 0.25;
		}
	}

	fillMode = getCvarInt( "bots_manage_fill_mode" );

	if ( fillMode == 2 || fillMode == 3 )
		setCvar( "bots_manage_fill", getGoodMapAmount() );

	fillAmount = getCvarInt( "bots_manage_fill" );

	players = 0;
	bots = 0;
	spec = 0;

	playercount = level.players.size;

	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[i];

		if ( player is_bot() )
			bots++;
		else if ( !isDefined( player.pers["team"] ) || ( player.pers["team"] != "axis" && player.pers["team"] != "allies" ) )
			spec++;
		else
			players++;
	}

	if ( !randomInt( 999 ) )
	{
		setCvar( "testclients_doreload", true );
		wait 0.1;
		setCvar( "testclients_doreload", false );
		doExtraCheck();
	}

	if ( fillMode == 4 )
	{
		axisplayers = 0;
		alliesplayers = 0;

		playercount = level.players.size;

		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[i];

			if ( player is_bot() )
				continue;

			if ( !isDefined( player.pers["team"] ) )
				continue;

			if ( player.pers["team"] == "axis" )
				axisplayers++;
			else if ( player.pers["team"] == "allies" )
				alliesplayers++;
		}

		result = fillAmount - abs( axisplayers - alliesplayers ) + bots;

		if ( players == 0 )
		{
			if ( bots < fillAmount )
				result = fillAmount - 1;
			else if ( bots > fillAmount )
				result = fillAmount + 1;
			else
				result = fillAmount;
		}

		bots = result;
	}

	amount = bots;

	if ( fillMode == 0 || fillMode == 2 )
		amount += players;

	if ( getCvarInt( "bots_manage_fill_spec" ) )
		amount += spec;

	if ( amount < fillAmount )
		setCvar( "bots_manage_add", 1 );
	else if ( amount > fillAmount && getCvarInt( "bots_manage_fill_kick" ) )
	{
		tempBot = random( getBotArray() );

		if ( isDefined( tempBot ) )
			kick( tempBot getEntityNumber() );
	}
}

/*
	A server thread for monitoring all bot's in game. Will add and kick bots according to server settings.
*/
addBots()
{
	level endon( "game_ended" );

	bot_wait_for_host();

	for ( ;; )
	{
		wait 1.5;

		addBots_loop();
	}
}

/*
	A thread for ALL players when they fire.
*/
onWeaponFired()
{
	self endon( "disconnect" );
	self.bots_firing = false;

	for ( ;; )
	{
		self waittill( "weapon_fired" );
		self thread doFiringThread();
	}
}

/*
	Lets bot's know that the player is firing.
*/
doFiringThread()
{
	self endon( "disconnect" );
	self endon( "weapon_fired" );
	self.bots_firing = true;
	wait 1;
	self.bots_firing = false;
}

/*
	Launches the smoke
*/
launchSmoke( org )
{
	nade = spawnStruct();
	nade.origin = org;

	level.bots_smokeList ListAdd( nade );

	wait 11.5;

	level.bots_smokeList ListRemove( nade );
}

/*
	Deletes smoke grenades when they explode
*/
watchNade()
{
	self endon( "death" );

	lastOrigin = self.origin;
	creationTime = getTime();
	timeSlow = 0;

	wait 0.05;

	while ( isDefined( self ) )
	{
		velocity = vector_scale( self.origin - lastOrigin, 20 );
		lastOrigin = self.origin;

		if ( getTime() - creationTime > 4000 )
		{
			if ( lengthSquared( velocity ) <= 0.05 )
				timeSlow += 0.05;
			else
				timeSlow = 0;
		}

		if ( timeSlow > 1 )
		{
			thread launchSmoke( lastOrigin );
			self delete ();
		}

		wait 0.05;
	}
}

/*
	Watches nades
*/
watchNades_loop()
{
	nades = getentarray ( "grenade", "classname" );

	for ( i = 0; i < nades.size; i++ )
	{
		nade = nades[i];

		if ( !isDefined( nade ) )
			continue;

		if ( isDefined( nade.bot_audit ) )
			continue;

		nade.bot_audit = true;

		nade thread watchNade();
	}
}

/*
	Watches nades
*/
watchNades()
{
	for ( ;; )
	{
		wait 0.05;

		watchNades_loop();
	}
}

/*
	Watches the game to end
*/
watchGameEnded()
{
	level.gameEnded = false;

	for ( ;; )
	{
		wait 0.05;

		if ( isDefined( level.roundended ) )
		{
			if ( level.roundended )
				break;
		}
		else if ( isDefined( level.mapended ) )
		{
			if ( level.mapended )
				break;
		}
	}

	level.gameEnded = true;
	level notify( "game_ended" );
}
