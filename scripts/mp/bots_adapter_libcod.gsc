init()
{
	level.bot_builtins[ "printconsole" ] = ::do_printconsole;
	level.bot_builtins[ "botaction" ] = ::do_botaction;
	level.bot_builtins[ "botstop" ] = ::do_botstop;
	level.bot_builtins[ "botmovement" ] = ::do_botmovement;
	level.bot_builtins[ "isbot" ] = ::do_isbot;
	level.bot_builtins[ "botangles" ] = ::do_botangles;
	level.bot_builtins[ "botweapon" ] = ::do_botweapon;
	
	thread setup_weaponid_map();
}

register_weaponid( weap )
{
	if ( !isdefined( level.bot_weaponids[ weap ] ) )
	{
		level.bot_weaponids[ weap ] = level.bot_weaponids.size;
	}
}

setup_weaponid_map()
{
	waittillframeend;
	
	level.bot_weaponids = [];
	register_weaponid( "none" );
	register_weaponid( "defaultweapon_mp" );
	
	turrets = getentarray( "misc_turret", "classname" );
	
	for ( i = 0; i < turrets.size; i++ )
	{
		if ( !isdefined( turrets[i].weaponinfo ) )
		{
			continue;
		}
		
		register_weaponid( turrets[i].weaponinfo );
	}
	
	// in the order of precache
	switch ( game[ "allies" ] )
	{
		case "american":
			register_weaponid( "frag_grenade_american_mp" );
			register_weaponid( "smoke_grenade_american_mp" );
			register_weaponid( "colt_mp" );
			register_weaponid( "m1carbine_mp" );
			register_weaponid( "m1garand_mp" );
			register_weaponid( "thompson_mp" );
			register_weaponid( "bar_mp" );
			register_weaponid( "springfield_mp" );
			register_weaponid( "greasegun_mp" );
			register_weaponid( "shotgun_mp" );
			break;
			
		case "british":
			register_weaponid( "frag_grenade_british_mp" );
			register_weaponid( "smoke_grenade_british_mp" );
			register_weaponid( "webley_mp" );
			register_weaponid( "enfield_mp" );
			register_weaponid( "sten_mp" );
			register_weaponid( "bren_mp" );
			register_weaponid( "enfield_scope_mp" );
			register_weaponid( "m1garand_mp" );
			register_weaponid( "thompson_mp" );
			register_weaponid( "shotgun_mp" );
			break;
			
		case "russian":
			register_weaponid( "frag_grenade_russian_mp" );
			register_weaponid( "smoke_grenade_russian_mp" );
			register_weaponid( "TT30_mp" );
			register_weaponid( "mosin_nagant_mp" );
			register_weaponid( "SVT40_mp" );
			register_weaponid( "PPS42_mp" );
			register_weaponid( "ppsh_mp" );
			register_weaponid( "mosin_nagant_sniper_mp" );
			register_weaponid( "shotgun_mp" );
			break;
	}
	
	register_weaponid( "frag_grenade_german_mp" );
	register_weaponid( "smoke_grenade_german_mp" );
	register_weaponid( "luger_mp" );
	register_weaponid( "kar98k_mp" );
	register_weaponid( "g43_mp" );
	register_weaponid( "mp40_mp" );
	register_weaponid( "mp44_mp" );
	register_weaponid( "kar98k_sniper_mp" );
	register_weaponid( "shotgun_mp" );
	register_weaponid( "binoculars_mp" );
}

get_weaponid_for_string( weap )
{
	ans = level.bot_weaponids[ weap ];
	
	if ( !isdefined( ans ) )
	{
		return 1;
	}
	
	return ans;
}

do_printconsole( s )
{
	println( s );
}

do_botaction( action )
{
	switch ( action )
	{
		case "+fire":
			self fireweapon( true );
			break;
			
		case "-fire":
			self fireweapon( false );
			break;
			
		case "+ads":
			self adsaim( true );
			break;
			
		case "-ads":
			self adsaim( false );
			break;
			
		case "-reload":
			self reloadweapon( false );
			break;
			
		case "+reload":
			self reloadweapon( true );
			break;
			
		case "-melee":
			self meleeweapon( false );
			break;
			
		case "+melee":
			self meleeweapon( true );
			break;
			
		case "+frag":
			self thrownade( true );
			break;
			
		case "-frag":
			self thrownade( false );
			break;
			
		case "-gocrouch":
		case "-goprone":
		case "-gostand":
			self setbotstance( "stand" );
			break;
			
		case "+gocrouch":
			self setbotstance( "crouch" );
			break;
			
		case "+goprone":
			self setbotstance( "prone" );
			break;
			
		case "+gostand":
			self setbotstance( "jump" );
			break;
		
		case "-activate":
			self activate( false ); // no equal in libcod
			break;
		
		case "+activate":
			self activate( true );
			break;
		
		case "+smoke":
			// self throwsmoke( true );
			break;
		
		case "-smoke":
			// self throwsmoke( false );
			break;
			
		case "+holdbreath":
			// self holdbreath( true );
			break;
			
		case "-holdbreath":
			// self holdbreath( false );
			break;
	}
	
	// self botaction( action );
}

do_botstop()
{
	self adsaim( false );
	self reloadweapon( false );
	self meleeweapon( false );
	self fireweapon( false );
	self thrownade( false );
	self setbotstance( "stand" );
	self setlean( "none" );
	self setwalkdir( "none" );
	self switchtoweaponid( get_weaponid_for_string( self getcurrentweapon() ) );
	
	// self botstop();
}

do_botmovement( forward, right )
{
	// best i can do for libcod...
	self setwalkdir( "none" );
	
	if ( forward > 63 )
	{
		self setwalkdir( "forward" );
	}
	
	if ( forward < -63 )
	{
		self setwalkdir( "back" );
	}
	
	if ( right > 63 )
	{
		self setwalkdir( "right" );
	}
	
	if ( right < -63 )
	{
		self setwalkdir( "left" );
	}
	
	// self botmovement( forward, right );
}

do_isbot()
{
	return false; // no equal in libcod
	// self isbot();
}

do_botangles( angles )
{
	self setplayerangles( angles );
	// self botangles( angles[ 0 ], angles[ 1 ], angles[ 2 ] );
}

do_botweapon( weapon )
{
	self switchtoweaponid( get_weaponid_for_string( weapon ) );
	// self switchtoweapon( weapon );
}
