init()
{
	level.bot_builtins["printconsole"] = ::do_printconsole;
	level.bot_builtins["botaction"] = ::do_botaction;
	level.bot_builtins["botstop"] = ::do_botstop;
	level.bot_builtins["botmovement"] = ::do_botmovement;
	level.bot_builtins["isbot"] = ::do_isbot;
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

		case "-smoke": // no equal in libcod
		case "-activate":
		case "-holdbreath":
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
	self switchtoweaponid( 1 ); // libcod needs weapon name to id

	// self botstop();
}

do_botmovement( forward, right )
{
	// best i can do for libcod...
	if ( forward > 63 )
	{
		self setwalkdir( "forward" );
		return;
	}

	if ( right > 63 )
	{
		self setwalkdir( "right" );
		return;
	}

	if ( forward < -63 )
	{
		self setwalkdir( "back" );
		return;
	}

	if ( right < -63 )
	{
		self setwalkdir( "left" );
		return;
	}

	self setwalkdir( "none" );

	// self botmovement( forward, right );
}

do_isbot()
{
	return false; // no equal in libcod
	// self isbot();
}
