#include maps\mp\_utility;
#include maps\mp\bots\_bot_utility;

/*
	Initiates the whole bot scripts.
*/
init()
{
	level.bw_version = "2.1.0";

	if ( getcvar( "bots_main" ) == "" )
		setcvar( "bots_main", true );

	if ( !getcvarint( "bots_main" ) )
		return;

	if ( !wait_for_builtins() )
		println( "FATAL: NO BUILT-INS FOR BOTS" );

	thread load_waypoints();
	thread hook_callbacks();

	if ( getcvar( "bots_main_GUIDs" ) == "" )
		setcvar( "bots_main_GUIDs", "" ); //guids of players who will be given host powers, comma seperated

	if ( getcvar( "bots_main_firstIsHost" ) == "" )
		setcvar( "bots_main_firstIsHost", true ); //first player to connect is a host

	if ( getcvar( "bots_main_waitForHostTime" ) == "" )
		setcvar( "bots_main_waitForHostTime", 10.0 ); //how long to wait to wait for the host player

	if ( getcvar( "bots_main_kickBotsAtEnd" ) == "" )
		setcvar( "bots_main_kickBotsAtEnd", false ); //kicks the bots at game end

	if ( getcvar( "bots_manage_add" ) == "" )
		setcvar( "bots_manage_add", 0 ); //amount of bots to add to the game

	if ( getcvar( "bots_manage_fill" ) == "" )
		setcvar( "bots_manage_fill", 0 ); //amount of bots to maintain

	if ( getcvar( "bots_manage_fill_spec" ) == "" )
		setcvar( "bots_manage_fill_spec", true ); //to count for fill if player is on spec team

	if ( getcvar( "bots_manage_fill_mode" ) == "" )
		setcvar( "bots_manage_fill_mode", 0 ); //fill mode, 0 adds everyone, 1 just bots, 2 maintains at maps, 3 is 2 with 1

	if ( getcvar( "bots_manage_fill_kick" ) == "" )
		setcvar( "bots_manage_fill_kick", false ); //kick bots if too many

	if ( getcvar( "bots_team" ) == "" )
		setcvar( "bots_team", "autoassign" ); //which team for bots to join

	if ( getcvar( "bots_team_amount" ) == "" )
		setcvar( "bots_team_amount", 0 ); //amount of bots on axis team

	if ( getcvar( "bots_team_force" ) == "" )
		setcvar( "bots_team_force", false ); //force bots on team

	if ( getcvar( "bots_team_mode" ) == "" )
		setcvar( "bots_team_mode", 0 ); //counts just bots when 1

	if ( getcvar( "bots_skill" ) == "" )
		setcvar( "bots_skill", 0 ); //0 is random, 1 is easy 7 is hard, 8 is custom, 9 is completely random

	if ( getcvar( "bots_skill_axis_hard" ) == "" )
		setcvar( "bots_skill_axis_hard", 0 ); //amount of hard bots on axis team

	if ( getcvar( "bots_skill_axis_med" ) == "" )
		setcvar( "bots_skill_axis_med", 0 );

	if ( getcvar( "bots_skill_allies_hard" ) == "" )
		setcvar( "bots_skill_allies_hard", 0 );

	if ( getcvar( "bots_skill_allies_med" ) == "" )
		setcvar( "bots_skill_allies_med", 0 );

	if ( getcvar( "bots_skill_min" ) == "" )
		setcvar( "bots_skill_min", 1 );

	if ( getcvar( "bots_skill_max" ) == "" )
		setcvar( "bots_skill_max", 7 );

	if ( getcvar( "bots_loadout_rank" ) == "" ) // what rank the bots should be around, -1 is around the players, 0 is all random
		setcvar( "bots_loadout_rank", -1 );

	if ( getcvar( "bots_play_move" ) == "" ) //bots move
		setcvar( "bots_play_move", true );

	if ( getcvar( "bots_play_knife" ) == "" ) //bots knife
		setcvar( "bots_play_knife", true );

	if ( getcvar( "bots_play_fire" ) == "" ) //bots fire
		setcvar( "bots_play_fire", true );

	if ( getcvar( "bots_play_nade" ) == "" ) //bots grenade
		setcvar( "bots_play_nade", true );

	if ( getcvar( "bots_play_obj" ) == "" ) //bots play the obj
		setcvar( "bots_play_obj", true );

	if ( getcvar( "bots_play_camp" ) == "" ) //bots camp and follow
		setcvar( "bots_play_camp", true );

	if ( getcvar( "bots_play_jumpdrop" ) == "" ) //bots jump and dropshot
		setcvar( "bots_play_jumpdrop", true );

	if ( getcvar( "bots_play_ads" ) == "" ) //bot ads
		setcvar( "bots_play_ads", true );

	if ( getcvar( "bots_play_aim" ) == "" )
		setcvar( "bots_play_aim", true );

	if ( !isdefined( game[ "botWarfare" ] ) )
		game[ "botWarfare" ] = true;

	level.defuseobject = undefined;
	level.bots_smokelist = List();

	level.bots_mingrenadedistance = 256;
	level.bots_mingrenadedistance *= level.bots_mingrenadedistance;
	level.bots_maxgrenadedistance = 1024;
	level.bots_maxgrenadedistance *= level.bots_maxgrenadedistance;
	level.bots_maxknifedistance = 80;
	level.bots_maxknifedistance *= level.bots_maxknifedistance;
	level.bots_goaldistance = 27.5;
	level.bots_goaldistance *= level.bots_goaldistance;
	level.bots_noadsdistance = 200;
	level.bots_noadsdistance *= level.bots_noadsdistance;
	level.bots_maxshotgundistance = 500;
	level.bots_maxshotgundistance *= level.bots_maxshotgundistance;
	level.bots_listendist = 100;

	level.smokeradius = 255;

	level.bots = [];
	level.players = [];

	level.bots_fullautoguns = [];
	level.bots_fullautoguns[ "greasegun" ] = true;
	level.bots_fullautoguns[ "thompson" ] = true;
	level.bots_fullautoguns[ "bar" ] = true;
	level.bots_fullautoguns[ "pps42" ] = true;
	level.bots_fullautoguns[ "sten" ] = true;
	level.bots_fullautoguns[ "bren" ] = true;
	level.bots_fullautoguns[ "mp44" ] = true;
	level.bots_fullautoguns[ "ppsh" ] = true;
	level.bots_fullautoguns[ "mp40" ] = true;

	level.bots_weapon_clip_sizes = [];
	level.bots_weapon_clip_sizes[ "m1carbine_mp" ] = 15;
	level.bots_weapon_clip_sizes[ "m1garand_mp" ] = 8;
	level.bots_weapon_clip_sizes[ "bar_mp" ] = 20;
	level.bots_weapon_clip_sizes[ "shotgun_mp" ] = 6;
	level.bots_weapon_clip_sizes[ "thompson_mp" ] = 20;
	level.bots_weapon_clip_sizes[ "springfield_mp" ] = 5;
	level.bots_weapon_clip_sizes[ "sten_mp" ] = 32;
	level.bots_weapon_clip_sizes[ "enfield_mp" ] = 10;
	level.bots_weapon_clip_sizes[ "bren_mp" ] = 30;
	level.bots_weapon_clip_sizes[ "enfield_scope_mp" ] = 10;
	level.bots_weapon_clip_sizes[ "svt40_mp" ] = 10;
	level.bots_weapon_clip_sizes[ "pps42_mp" ] = 35;
	level.bots_weapon_clip_sizes[ "ppsh_mp" ] = 71;
	level.bots_weapon_clip_sizes[ "g43_mp" ] = 10;
	level.bots_weapon_clip_sizes[ "mosin_nagant_mp" ] = 5;
	level.bots_weapon_clip_sizes[ "mosin_nagant_sniper_mp" ] = 5;
	level.bots_weapon_clip_sizes[ "mp40_mp" ] = 32;
	level.bots_weapon_clip_sizes[ "kar98k_mp" ] = 5;
	level.bots_weapon_clip_sizes[ "kar98k_sniper_mp" ] = 5;
	level.bots_weapon_clip_sizes[ "mp44_mp" ] = 30;
	level.bots_weapon_clip_sizes[ "colt_mp" ] = 7;
	level.bots_weapon_clip_sizes[ "webley_mp" ] = 6;
	level.bots_weapon_clip_sizes[ "luger_mp" ] = 8;
	level.bots_weapon_clip_sizes[ "tt30_mp" ] = 8;
	level.bots_weapon_clip_sizes[ "greasegun_mp" ] = 32;

	level.bots_weapon_class_names = [];
	level.bots_weapon_class_names[ "m1carbine_mp" ] = "rifle";
	level.bots_weapon_class_names[ "m1garand_mp" ] = "rifle";
	level.bots_weapon_class_names[ "bar_mp" ] = "lmg";
	level.bots_weapon_class_names[ "shotgun_mp" ] = "spread";
	level.bots_weapon_class_names[ "thompson_mp" ] = "smg";
	level.bots_weapon_class_names[ "springfield_mp" ] = "sniper";
	level.bots_weapon_class_names[ "sten_mp" ] = "smg";
	level.bots_weapon_class_names[ "enfield_mp" ] = "sniper";
	level.bots_weapon_class_names[ "bren_mp" ] = "lmg";
	level.bots_weapon_class_names[ "enfield_scope_mp" ] = "sniper";
	level.bots_weapon_class_names[ "svt40_mp" ] = "rifle";
	level.bots_weapon_class_names[ "pps42_mp" ] = "smg";
	level.bots_weapon_class_names[ "ppsh_mp" ] = "smg";
	level.bots_weapon_class_names[ "g43_mp" ] = "rifle";
	level.bots_weapon_class_names[ "mosin_nagant_mp" ] = "sniper";
	level.bots_weapon_class_names[ "mosin_nagant_sniper_mp" ] = "sniper";
	level.bots_weapon_class_names[ "mp40_mp" ] = "smg";
	level.bots_weapon_class_names[ "kar98k_mp" ] = "sniper";
	level.bots_weapon_class_names[ "kar98k_sniper_mp" ] = "sniper";
	level.bots_weapon_class_names[ "mp44_mp" ] = "rifle";
	level.bots_weapon_class_names[ "colt_mp" ] = "pistol";
	level.bots_weapon_class_names[ "webley_mp" ] = "pistol";
	level.bots_weapon_class_names[ "luger_mp" ] = "pistol";
	level.bots_weapon_class_names[ "tt30_mp" ] = "pistol";
	level.bots_weapon_class_names[ "greasegun_mp" ] = "smg";

	level thread fixGamemodes();

	level thread onPlayerConnect();
	level thread handleBots();
	level thread watchNades();
	level thread watchGameEnded();

	level.teambased = true;

	if ( getcvar( "g_gametype" ) == "dm" )
		level.teambased = false;
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

	setcvar( "bots_manage_add", getBotArray().size );

	if ( !getcvarint( "bots_main_kickBotsAtEnd" ) )
		return;

	bots = getBotArray();

	for ( i = 0; i < bots.size; i++ )
	{
		kick( bots[ i ] getentitynumber() );
	}
}

/*
	The hook callback for when any player becomes damaged.
*/
onPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if ( self is_bot() )
	{
		self maps\mp\bots\_bot_internal::onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
		self maps\mp\bots\_bot_script::onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
	}

	self [[ level.prevcallbackplayerdamage ]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
}

/*
	The hook callback when any player gets killed.
*/
onPlayerKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration )
{
	if ( self is_bot() )
	{
		self maps\mp\bots\_bot_internal::onKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
		self maps\mp\bots\_bot_script::onKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
	}

	self [[ level.prevcallbackplayerkilled ]]( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
}

/*
	Starts the callbacks.
*/
hook_callbacks()
{
	wait 0.05;
	level.prevcallbackplayerdamage = level.callbackplayerdamage;
	level.callbackplayerdamage = ::onPlayerDamage;

	level.prevcallbackplayerkilled = level.callbackplayerkilled;
	level.callbackplayerkilled = ::onPlayerKilled;
}

/*
	Fixes gamemodes when level starts.
*/
fixGamemodes()
{
	for ( i = 0; i < 19; i++ )
	{
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
		weap = self getcurrentweapon();
		self thread watchAmmoUsage( weap );

		while ( weap == self getcurrentweapon() )
			wait 0.05;

		self notify( "weapon_change", self getcurrentweapon() );
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
		aCount = self getweaponslotclipammo( slot );

		while ( aCount == self getweaponslotclipammo( slot ) )
			wait 0.05;

		if ( self getweaponslotclipammo( slot ) < aCount )
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
		self.team = self.pers[ "team" ];

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
	if ( isdefined( self.tags ) )
	{
		for ( i = 0; i < self.tags.size; i++ )
			self.tags[ i ] delete();

		self.tags = undefined;
		self.tagmap = undefined;
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

	level.players[ level.players.size ] = self;
	self thread onDisconnectPlayer();

	if ( !isdefined( self.pers[ "bot_host" ] ) )
		self thread doHostCheck();

	if ( !self is_bot() )
		return;

	if ( !isdefined( self.pers[ "isBot" ] ) )
	{
		// fast restart...
		self.pers[ "isBot" ] = true;
	}

	if ( !isdefined( self.pers[ "isBotWarfare" ] ) )
	{
		self.pers[ "isBotWarfare" ] = true;
		self thread added();
	}

	self thread maps\mp\bots\_bot_internal::connected();
	self thread maps\mp\bots\_bot_script::connected();

	level.bots[ level.bots.size ] = self;
	self thread onDisconnect();

	level notify( "bot_connected", self );

	self thread watchBotDebugEvent();
}

/*
	DEBUG
*/
watchBotDebugEvent()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill( "bot_event", msg, str, b, c, d, e, f, g );

		if ( getcvarint( "bots_main_debug" ) >= 2 )
		{
			big_str = "Bot Warfare debug: " + self.name + ": " + msg;

			if ( isdefined( str ) && isstring( str ) )
				big_str += ", " + str;

			if ( isdefined( b ) && isstring( b ) )
				big_str += ", " + b;

			if ( isdefined( c ) && isstring( c ) )
				big_str += ", " + c;

			if ( isdefined( d ) && isstring( d ) )
				big_str += ", " + d;

			if ( isdefined( e ) && isstring( e ) )
				big_str += ", " + e;

			if ( isdefined( f ) && isstring( f ) )
				big_str += ", " + f;

			if ( isdefined( g ) && isstring( g ) )
				big_str += ", " + g;

			BotBuiltinPrintConsole( big_str );
		}
		else if ( msg == "debug" && getcvarint( "bots_main_debug" ) )
		{
			BotBuiltinPrintConsole( "Bot Warfare debug: " + self.name + ": " + str );
		}
	}
}

/*
	When a bot gets added into the game.
*/
added()
{
	self endon( "disconnect" );

	self thread maps\mp\bots\_bot_internal::added();
	self thread maps\mp\bots\_bot_script::added();
}

/*
	Adds a bot to the game.
*/
add_bot()
{
	bot = addtestclient();

	if ( isdefined( bot ) )
	{
		bot.pers[ "isBot" ] = true;
		bot.pers[ "isBotWarfare" ] = true;
		bot thread added();
	}
}

/*
	A server thread for monitoring all bot's difficulty levels for custom server settings.
*/
diffBots_loop()
{
	var_allies_hard = getcvarint( "bots_skill_allies_hard" );
	var_allies_med = getcvarint( "bots_skill_allies_med" );
	var_axis_hard = getcvarint( "bots_skill_axis_hard" );
	var_axis_med = getcvarint( "bots_skill_axis_med" );
	var_skill = getcvarint( "bots_skill" );

	allies_hard = 0;
	allies_med = 0;
	axis_hard = 0;
	axis_med = 0;

	if ( var_skill == 8 )
	{
		playercount = level.players.size;

		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[ i ];

			if ( !isdefined( player.pers[ "team" ] ) )
				continue;

			if ( !player is_bot() )
				continue;

			if ( player.pers[ "team" ] == "axis" )
			{
				if ( axis_hard < var_axis_hard )
				{
					axis_hard++;
					player.pers[ "bots" ] [ "skill" ][ "base" ] = 7;
				}
				else if ( axis_med < var_axis_med )
				{
					axis_med++;
					player.pers[ "bots" ][ "skill" ][ "base" ] = 4;
				}
				else
					player.pers[ "bots" ][ "skill" ][ "base" ] = 1;
			}
			else if ( player.pers[ "team" ] == "allies" )
			{
				if ( allies_hard < var_allies_hard )
				{
					allies_hard++;
					player.pers[ "bots" ][ "skill" ][ "base" ] = 7;
				}
				else if ( allies_med < var_allies_med )
				{
					allies_med++;
					player.pers[ "bots" ][ "skill" ][ "base" ] = 4;
				}
				else
					player.pers[ "bots" ][ "skill" ][ "base" ] = 1;
			}
		}
	}
	else if ( var_skill != 0 && var_skill != 9 )
	{
		playercount = level.players.size;

		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[ i ];

			if ( !player is_bot() )
				continue;

			player.pers[ "bots" ][ "skill" ][ "base" ] = var_skill;
		}
	}

	playercount = level.players.size;
	min_diff = getcvarint( "bots_skill_min" );
	max_diff = getcvarint( "bots_skill_max" );

	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[ i ];

		if ( !player is_bot() )
			continue;

		player.pers[ "bots" ][ "skill" ][ "base" ] = int( clamp( player.pers[ "bots" ][ "skill" ][ "base" ], min_diff, max_diff ) );
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
	teamAmount = getcvarint( "bots_team_amount" );
	toTeam = getcvar( "bots_team" );

	alliesbots = 0;
	alliesplayers = 0;
	axisbots = 0;
	axisplayers = 0;

	playercount = level.players.size;

	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[ i ];

		if ( !isdefined( player.pers[ "team" ] ) )
			continue;

		if ( player is_bot() )
		{
			if ( player.pers[ "team" ] == "allies" )
				alliesbots++;
			else if ( player.pers[ "team" ] == "axis" )
				axisbots++;
		}
		else
		{
			if ( player.pers[ "team" ] == "allies" )
				alliesplayers++;
			else if ( player.pers[ "team" ] == "axis" )
				axisplayers++;
		}
	}

	allies = alliesbots;
	axis = axisbots;

	if ( !getcvarint( "bots_team_mode" ) )
	{
		allies += alliesplayers;
		axis += axisplayers;
	}

	if ( toTeam != "custom" )
	{
		if ( getcvarint( "bots_team_force" ) )
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
					player = level.players[ i ];

					if ( !isdefined( player.pers[ "team" ] ) )
						continue;

					if ( !player is_bot() )
						continue;

					if ( player.pers[ "team" ] == toTeam )
						continue;

					if ( toTeam == "allies" )
						player thread [[ level.allies ]]();
					else if ( toTeam == "axis" )
						player thread [[ level.axis ]]();
					else
						player thread [[ level.spectator ]]();

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
			player = level.players[ i ];

			if ( !isdefined( player.pers[ "team" ] ) )
				continue;

			if ( !player is_bot() )
				continue;

			if ( player.pers[ "team" ] == "axis" )
			{
				if ( axis > teamAmount )
				{
					player thread [[ level.allies ]]();
					break;
				}
			}
			else
			{
				if ( axis < teamAmount )
				{
					player thread [[ level.axis ]]();
					break;
				}
				else if ( player.pers[ "team" ] != "allies" )
				{
					player thread [[ level.allies ]]();
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
	botsToAdd = getcvarint( "bots_manage_add" );

	if ( botsToAdd > 0 )
	{
		setcvar( "bots_manage_add", 0 );

		if ( botsToAdd > 64 )
			botsToAdd = 64;

		for ( ; botsToAdd > 0; botsToAdd-- )
		{
			level add_bot();
			wait 0.25;
		}
	}

	fillMode = getcvarint( "bots_manage_fill_mode" );

	if ( fillMode == 2 || fillMode == 3 )
		setcvar( "bots_manage_fill", getGoodMapAmount() );

	fillAmount = getcvarint( "bots_manage_fill" );

	players = 0;
	bots = 0;
	spec = 0;

	playercount = level.players.size;

	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[ i ];

		if ( player is_bot() )
			bots++;
		else if ( !isdefined( player.pers[ "team" ] ) || ( player.pers[ "team" ] != "axis" && player.pers[ "team" ] != "allies" ) )
			spec++;
		else
			players++;
	}

	if ( !randomint( 999 ) )
	{
		setcvar( "testclients_doreload", true );
		wait 0.1;
		setcvar( "testclients_doreload", false );
		doExtraCheck();
	}

	if ( fillMode == 4 )
	{
		axisplayers = 0;
		alliesplayers = 0;

		playercount = level.players.size;

		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[ i ];

			if ( player is_bot() )
				continue;

			if ( !isdefined( player.pers[ "team" ] ) )
				continue;

			if ( player.pers[ "team" ] == "axis" )
				axisplayers++;
			else if ( player.pers[ "team" ] == "allies" )
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

	if ( getcvarint( "bots_manage_fill_spec" ) )
		amount += spec;

	if ( amount < fillAmount )
		setcvar( "bots_manage_add", 1 );
	else if ( amount > fillAmount && getcvarint( "bots_manage_fill_kick" ) )
	{
		tempBot = getBotToKick();

		if ( isdefined( tempBot ) )
			kick( tempBot getentitynumber() );
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
	nade = spawnstruct();
	nade.origin = org;

	level.bots_smokelist ListAdd( nade );

	wait 11.5;

	level.bots_smokelist ListRemove( nade );
}

/*
	Deletes smoke grenades when they explode
*/
watchNade()
{
	self endon( "death" );

	lastOrigin = self.origin;
	creationTime = gettime();
	timeSlow = 0;

	wait 0.05;

	while ( isdefined( self ) )
	{
		velocity = vector_scale( self.origin - lastOrigin, 20 );
		lastOrigin = self.origin;

		if ( gettime() - creationTime > 4000 )
		{
			if ( lengthsquared( velocity ) <= 0.05 )
				timeSlow += 0.05;
			else
				timeSlow = 0;
		}

		if ( timeSlow > 1 )
		{
			thread launchSmoke( lastOrigin );
			self delete();
		}

		wait 0.05;
	}
}

/*
	Watches nades
*/
watchNades_loop()
{
	nades = getentarray( "grenade", "classname" );

	for ( i = 0; i < nades.size; i++ )
	{
		nade = nades[ i ];

		if ( !isdefined( nade ) )
			continue;

		if ( isdefined( nade.bot_audit ) )
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
	level.gameended = false;

	for ( ;; )
	{
		wait 0.05;

		if ( isdefined( level.roundended ) )
		{
			if ( level.roundended )
				break;
		}
		else if ( isdefined( level.mapended ) )
		{
			if ( level.mapended )
				break;
		}
	}

	level.gameended = true;
	level notify( "game_ended" );
}
