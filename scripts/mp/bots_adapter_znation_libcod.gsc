init()
{
	level.bot_builtins[ "printconsole" ] = ::do_printconsole;
	level.bot_builtins[ "botaction" ] = ::do_botaction;
	level.bot_builtins[ "botstop" ] = ::do_botstop;
	level.bot_builtins[ "botmovement" ] = ::do_botmovement;
	level.bot_builtins[ "isbot" ] = ::do_isbot;
	level.bot_builtins[ "botangles" ] = ::do_botangles;
	level.bot_builtins[ "botweapon" ] = ::do_botweapon;
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
			self adsaim( true ); // setaim
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
			self thrownade( true ); // throwgrenade
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
			// self activate( false ); // no equal in libcod
			break;
			
		case "+activate":
			// self activate( true );
			break;
			
		case "+smoke":
			// self throwsmokegrenade( true );
			break;
			
		case "-smoke":
			// self throwsmokegrenade( false );
			break;
			
		case "+holdbreath":
			// self holdbreath( true ); // no equal in libcod
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
	// self holdbreath( false );
	// self throwsmokegrenade( false );
	// self activate( false );
	self do_botweapon( self getcurrentweapon() );
	
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
	 
	// self botmovement( forward, right ); // setwalkvalues
}

do_isbot()
{
	return self isbot();
}

do_botangles( angles )
{
	self setplayerangles( angles ); // botangles
}

do_botweapon( weapon )
{
	if ( !isdefined( level.bot_weaponids ) )
	{
		level.bot_weaponids = [];
		
		weaps = getloadedweapons();
		
		for ( i = 0; i < weaps.size; i++ )
		{
			level.bot_weaponids[ weaps[ i ] ] = i;
		}
	}
	
	self switchtoweaponid( level.bot_weaponids[ weapon ] );

	// self switchtoweapon( weapon );
}
