/*
	_menu
	Author: INeedGames
	Date: 08/16/2026
	The ingame menu.
*/

#include maps\mp\_utility;
#include maps\mp\bots\_bot_utility;


secondaryoffhandbuttonpressed()
{
	return getcvarint( "smoke" );
}

fragbuttonpressed()
{
	return getcvarint( "frag" );
}

adsbuttonpressed()
{
	return getcvarint( "speed" ) || self playerads() > 0.05;
}

setparent( parent )
{
}

setpoint(a, b, x, y)
{
}

createfontstring( font, fontScale )
{
	fontElem = newclienthudelem( self );
	fontElem.elemType = "font";
	fontElem.font = font;
	fontElem.fontscale = fontScale;
	fontElem.x = 0;
	fontElem.y = 0;
	fontElem.width = 0;
	fontElem.height = int( 12 * fontScale );
	fontElem.xOffset = 0;
	fontElem.yOffset = 0;
	fontElem.children = [];
	fontElem setparent( level.uiparent );
	fontElem.hidden = false;
	return fontElem;
}

destroyelem()
{
}


init()
{
	if ( getcvar( "bots_main_menu" ) == "" )
	{
		setcvar( "bots_main_menu", true );
	}
	
	if ( !getcvarint( "bots_main_menu" ) )
	{
		return;
	}
	
	thread watchPlayers();
}

watchPlayers()
{
	for ( ;; )
	{
		wait 1;
		
		if ( !getcvarint( "bots_main_menu" ) )
		{
			return;
		}
		
		for ( i = level.players.size - 1; i >= 0; i-- )
		{
			player = level.players[ i ];
			
			if ( !player is_host() )
			{
				continue;
			}
			
			if ( isdefined( player.menuinit ) && player.menuinit )
			{
				continue;
			}
			
			player thread init_menu();
		}
	}
}

init_menu()
{
	self.menuinit = true;
	
	self.menuopen = false;
	self.submenu = "Main";
	self.curs[ "Main" ][ "X" ] = 0;
	self AddOptions();
	
	self thread watchPlayerOpenMenu();
	self thread MenuSelect();
	self thread RightMenu();
	self thread LeftMenu();
	
	self thread watchDisconnect();
	
	self thread doGreetings();
}

destroyFixed()
{
	if ( !isdefined( self ) )
	{
		return;
	}
	
	self destroy();
}

removeChildFixed( element )
{
	temp = [];
	
	for ( i = 0; i < self.children.size ; i++ )
	{
		if ( isdefined( self.children[ i ] ) && self.children[ i ] != element )
		{
			self.children[ i ].index = temp.size;
			temp[ temp.size ] = self.children[ i ];
		}
	}
	
	self.children = temp;
}

destroyElemFixed()
{
	if ( !isdefined( self ) )
	{
		return;
	}
	
	if ( isdefined( self.parent ) )
	{
		self.parent removeChildFixed( self );
	}
	
	self destroyelem();
}

kill_menu()
{
	self notify( "bots_kill_menu" );
	self.menuinit = undefined;
}

watchDisconnect()
{
	self waittill_either( "disconnect", "bots_kill_menu" );
	
	if ( self.menuopen )
	{
		if ( isdefined( self.menutexty ) )
		{
			for ( i = 0; i < self.menutexty.size; i++ )
			{
				if ( isdefined( self.menutexty[ i ] ) )
				{
					self.menutexty[ i ] destroyElemFixed();
				}
			}
		}
		
		if ( isdefined( self.menutext ) )
		{
			for ( i = 0; i < self.menutext.size; i++ )
			{
				if ( isdefined( self.menutext[ i ] ) )
				{
					self.menutext[ i ] destroyElemFixed();
				}
			}
		}
		
		if ( isdefined( self.menu ) && isdefined( self.menu[ "X" ] ) )
		{
			if ( isdefined( self.menu[ "X" ][ "Shader" ] ) )
			{
				self.menu[ "X" ][ "Shader" ] destroyElemFixed();
			}
			
			if ( isdefined( self.menu[ "X" ][ "Scroller" ] ) )
			{
				self.menu[ "X" ][ "Scroller" ] destroyElemFixed();
			}
		}
		
		if ( isdefined( self.menuversionhud ) )
		{
			self.menuversionhud destroyFixed();
		}
	}
}

doGreetings()
{
	self endon ( "disconnect" );
	self endon ( "bots_kill_menu" );
	wait 1;
	self iprintln( "Welcome to Bot Warfare " + self.name + "!" );
	wait 5;
	self iprintln( "Press [{+frag}] + [{+smoke}] to open menu!" );
}

watchPlayerOpenMenu()
{
	self endon ( "disconnect" );
	self endon ( "bots_kill_menu" );
	
	for ( ;; )
	{
		while ( !self fragbuttonpressed() || !self secondaryoffhandbuttonpressed() )
		{
			wait 0.05;
		}
		
		if ( !self.menuopen )
		{
			self playlocalsound( "mouse_click" );
			self thread OpenSub( self.submenu );
		}
		else
		{
			self playlocalsound( "mouse_click" );
			
			if ( self.submenu != "Main" )
			{
				self ExitSub();
			}
			else
			{
				self ExitMenu();
				
				if ( level.gameended )
				{
					self freezecontrols( true );
				}
				else
				{
					self freezecontrols( false );
				}
			}
		}
		
		while ( self fragbuttonpressed() && self secondaryoffhandbuttonpressed() )
		{
			wait 0.05;
		}
	}
}

MenuSelect()
{
	self endon ( "disconnect" );
	self endon ( "bots_kill_menu" );
	
	for ( ;; )
	{
		while ( !self meleebuttonpressed() )
		{
			wait 0.05;
		}
		
		if ( self.menuopen )
		{
			self playlocalsound( "mouse_click" );
			
			if ( self.submenu == "Main" )
			{
				self thread [[ self.option[ "Function" ][ self.submenu ][ self.curs[ "Main" ][ "X" ] ] ]]( self.option[ "Arg1" ][ self.submenu ][ self.curs[ "Main" ][ "X" ] ], self.option[ "Arg2" ][ self.submenu ][ self.curs[ "Main" ][ "X" ] ] );
			}
			else
			{
				self thread [[ self.option[ "Function" ][ self.submenu ][ self.curs[ self.submenu ][ "Y" ] ] ]]( self.option[ "Arg1" ][ self.submenu ][ self.curs[ self.submenu ][ "Y" ] ], self.option[ "Arg2" ][ self.submenu ][ self.curs[ self.submenu ][ "Y" ] ] );
			}
		}
		
		while ( self meleebuttonpressed() )
		{
			wait 0.05;
		}
	}
}

LeftMenu()
{
	self endon ( "disconnect" );
	self endon ( "bots_kill_menu" );
	
	for ( ;; )
	{
		while ( !self attackbuttonpressed() )
		{
			wait 0.05;
		}
		
		if ( self.menuopen )
		{
			self playlocalsound( "mouse_over" );
			
			if ( self.submenu == "Main" )
			{
				self.curs[ "Main" ][ "X" ]--;
				
				if ( self.curs[ "Main" ][ "X" ] < 0 )
				{
					self.curs[ "Main" ][ "X" ] = self.option[ "Name" ][ self.submenu ].size - 1;
				}
				
				self CursMove( "X" );
			}
			else
			{
				self.curs[ self.submenu ][ "Y" ]--;
				
				if ( self.curs[ self.submenu ][ "Y" ] < 0 )
				{
					self.curs[ self.submenu ][ "Y" ] = self.option[ "Name" ][ self.submenu ].size - 1;
				}
				
				self CursMove( "Y" );
			}
		}
		
		while ( self attackbuttonpressed() )
		{
			wait 0.05;
		}
	}
}

RightMenu()
{
	self endon ( "disconnect" );
	self endon ( "bots_kill_menu" );
	
	for ( ;; )
	{
		while ( !self adsbuttonpressed() )
		{
			wait 0.05;
		}
		
		if ( self.menuopen )
		{
			self playlocalsound( "mouse_over" );
			
			if ( self.submenu == "Main" )
			{
				self.curs[ "Main" ][ "X" ]++;
				
				if ( self.curs[ "Main" ][ "X" ] > self.option[ "Name" ][ self.submenu ].size - 1 )
				{
					self.curs[ "Main" ][ "X" ] = 0;
				}
				
				self CursMove( "X" );
			}
			else
			{
				self.curs[ self.submenu ][ "Y" ]++;
				
				if ( self.curs[ self.submenu ][ "Y" ] > self.option[ "Name" ][ self.submenu ].size - 1 )
				{
					self.curs[ self.submenu ][ "Y" ] = 0;
				}
				
				self CursMove( "Y" );
			}
		}
		
		while ( self adsbuttonpressed() )
		{
			wait 0.05;
		}
	}
}

OpenSub( menu, menu2 )
{
	if ( menu != "Main" && ( !isdefined( self.menu[ menu ] ) || !!isdefined( self.menu[ menu ][ "FirstOpen" ] ) ) )
	{
		self.curs[ menu ][ "Y" ] = 0;
		self.menu[ menu ][ "FirstOpen" ] = true;
	}
	
	logOldi = true;
	self.submenu = menu;
	
	if ( self.submenu == "Main" )
	{
		if ( isdefined( self.menutext ) )
		{
			for ( i = 0; i < self.menutext.size; i++ )
			{
				if ( isdefined( self.menutext[ i ] ) )
				{
					self.menutext[ i ] destroyElemFixed();
				}
			}
		}
		
		if ( isdefined( self.menu ) && isdefined( self.menu[ "X" ] ) )
		{
			if ( isdefined( self.menu[ "X" ][ "Shader" ] ) )
			{
				self.menu[ "X" ][ "Shader" ] destroyElemFixed();
			}
			
			if ( isdefined( self.menu[ "X" ][ "Scroller" ] ) )
			{
				self.menu[ "X" ][ "Scroller" ] destroyElemFixed();
			}
		}
		
		if ( isdefined( self.menuversionhud ) )
		{
			self.menuversionhud destroyFixed();
		}
		
		for ( i = 0 ; i < self.option[ "Name" ][ self.submenu ].size ; i++ )
		{
			self.menutext[ i ] = self createfontstring( "default", 1.6 );
			self.menutext[ i ] setpoint( "CENTER", "CENTER", -300 + ( i * 100 ), -226 );
			// self.menutext[ i ] settext( self.option[ "Name" ][ self.submenu ][ i ] );
			
			if ( logOldi )
			{
				self.oldi = i;
			}
			
			if ( self.menutext[ i ].x > 300 )
			{
				logOldi = false;
				x = i - self.oldi;
				self.menutext[ i ] setpoint( "CENTER", "CENTER", ( ( ( -300 ) - ( i * 100 ) ) + ( i * 100 ) ) + ( x * 100 ), -196 );
			}
			
			self.menutext[ i ].alpha = 1;
			self.menutext[ i ].sort = 999;
		}
		
		if ( !logOldi )
		{
			self.menu[ "X" ][ "Shader" ] = self createRectangle( "CENTER", "CENTER", 0, -225, 1000, 90, ( 0, 0, 0 ), -2, 1, "white" );
		}
		else
		{
			self.menu[ "X" ][ "Shader" ] = self createRectangle( "CENTER", "CENTER", 0, -225, 1000, 30, ( 0, 0, 0 ), -2, 1, "white" );
		}
		
		self.menu[ "X" ][ "Scroller" ] = self createRectangle( "CENTER", "CENTER", self.menutext[ self.curs[ "Main" ][ "X" ] ].x, -225, 105, 22, ( 1, 0, 0 ), -1, 1, "white" );
		
		self CursMove( "X" );
		
		self.menuversionhud = initHudElem( "Bot Warfare " + level.bw_version, 0, 0 );
		
		self.menuopen = true;
	}
	else
	{
		if ( isdefined( self.menutexty ) )
		{
			for ( i = 0 ; i < self.menutexty.size ; i++ )
			{
				if ( isdefined( self.menutexty[ i ] ) )
				{
					self.menutexty[ i ] destroyElemFixed();
				}
			}
		}
		
		for ( i = 0 ; i < self.option[ "Name" ][ self.submenu ].size ; i++ )
		{
			self.menutexty[ i ] = self createfontstring( "default", 1.6 );
			self.menutexty[ i ] setpoint( "CENTER", "CENTER", self.menutext[ self.curs[ "Main" ][ "X" ] ].x, -160 + ( i * 20 ) );
			//self.menutexty[ i ] settext( self.option[ "Name" ][ self.submenu ][ i ] );
			self.menutexty[ i ].alpha = 1;
			self.menutexty[ i ].sort = 999;
		}
		
		self CursMove( "Y" );
	}
}

CursMove( direction )
{
	self notify( "scrolled" );
	
	if ( self.submenu == "Main" )
	{
		if ( isdefined( self.menutext ) )
		{
			self.menu[ "X" ][ "Scroller" ].x = self.menutext[ self.curs[ "Main" ][ "X" ] ].x;
			self.menu[ "X" ][ "Scroller" ].y = self.menutext[ self.curs[ "Main" ][ "X" ] ].y;
			
			for ( i = 0; i < self.menutext.size; i++ )
			{
				if ( isdefined( self.menutext[ i ] ) )
				{
					self.menutext[ i ].fontscale = 1.5;
					self.menutext[ i ].color = ( 1, 1, 1 );
					self.menutext[ i ].glowalpha = 0;
				}
			}
		}
		
		self thread ShowOptionOn( direction );
	}
	else
	{
		if ( isdefined( self.menutexty ) )
		{
			for ( i = 0; i < self.menutexty.size; i++ )
			{
				if ( isdefined( self.menutexty[ i ] ) )
				{
					self.menutexty[ i ].fontscale = 1.5;
					self.menutexty[ i ].color = ( 1, 1, 1 );
					self.menutexty[ i ].glowalpha = 0;
				}
			}
		}
		
		if ( isdefined( self.menutext ) )
		{
			for ( i = 0; i < self.menutext.size; i++ )
			{
				if ( isdefined( self.menutext[ i ] ) )
				{
					self.menutext[ i ].fontscale = 1.5;
					self.menutext[ i ].color = ( 1, 1, 1 );
					self.menutext[ i ].glowalpha = 0;
				}
			}
		}
		
		self thread ShowOptionOn( direction );
	}
}

ShowOptionOn( variable )
{
	self endon( "scrolled" );
	self endon( "disconnect" );
	self endon( "exit" );
	self endon( "bots_kill_menu" );
	
	for ( time = 0;; time += 0.05 )
	{
		if ( !self isonground() && isalive( self ) && !level.gameended )
		{
			self freezecontrols( false );
		}
		else
		{
			self freezecontrols( true );
		}
		
		self setclientcvar( "r_blur", "5" );
		self setclientcvar( "sc_blur", "4" );
		self AddOptions();
		
		if ( self.submenu == "Main" )
		{
			if ( isdefined( self.curs[ self.submenu ][ variable ] ) && isdefined( self.menutext ) && isdefined( self.menutext[ self.curs[ self.submenu ][ variable ] ] ) )
			{
				self.menutext[ self.curs[ self.submenu ][ variable ] ].fontscale = 2.0;
				// self.menutext[ self.curs[ self.submenu ][ variable ] ].color = (randomint(256)/255, randomint(256)/255, randomint(256)/255);
				color = ( 6 / 255, 69 / 255, 173 + randomintrange( -5, 5 ) / 255 );
				
				if ( int( time * 4 ) % 2 )
				{
					color = ( 11 / 255, 0 / 255, 128 + randomintrange( -10, 10 ) / 255 );
				}
				
				self.menutext[ self.curs[ self.submenu ][ variable ] ].color = color;
			}
			
			if ( isdefined( self.menutext ) )
			{
				for ( i = 0; i < self.option[ "Name" ][ self.submenu ].size; i++ )
				{
					if ( isdefined( self.menutext[ i ] ) )
					{
						// self.menutext[ i ] settext( self.option[ "Name" ][ self.submenu ][ i ] );
					}
				}
			}
		}
		else
		{
			if ( isdefined( self.curs[ self.submenu ][ variable ] ) && isdefined( self.menutexty ) && isdefined( self.menutexty[ self.curs[ self.submenu ][ variable ] ] ) )
			{
				self.menutexty[ self.curs[ self.submenu ][ variable ] ].fontscale = 2.0;
				// self.menutexty[ self.curs[ self.submenu ][ variable ] ].color = (randomint(256)/255, randomint(256)/255, randomint(256)/255);
				color = ( 6 / 255, 69 / 255, 173 + randomintrange( -5, 5 ) / 255 );
				
				if ( int( time * 4 ) % 2 )
				{
					color = ( 11 / 255, 0 / 255, 128 + randomintrange( -10, 10 ) / 255 );
				}
				
				self.menutexty[ self.curs[ self.submenu ][ variable ] ].color = color;
			}
			
			if ( isdefined( self.menutexty ) )
			{
				for ( i = 0; i < self.option[ "Name" ][ self.submenu ].size; i++ )
				{
					if ( isdefined( self.menutexty[ i ] ) )
					{
						//self.menutexty[ i ] settext( self.option[ "Name" ][ self.submenu ][ i ] );
					}
				}
			}
		}
		
		wait 0.05;
	}
}

AddMenu( menu, num, text, function, arg1, arg2 )
{
	self.option[ "Name" ][ menu ][ num ] = text;
	self.option[ "Function" ][ menu ][ num ] = function;
	self.option[ "Arg1" ][ menu ][ num ] = arg1;
	self.option[ "Arg2" ][ menu ][ num ] = arg2;
}

AddBack( menu, back )
{
	self.menu[ "Back" ][ menu ] = back;
}

ExitSub()
{
	if ( isdefined( self.menutexty ) )
	{
		for ( i = 0; i < self.menutexty.size; i++ )
		{
			if ( isdefined( self.menutexty[ i ] ) )
			{
				self.menutexty[ i ] destroyElemFixed();
			}
		}
	}
	
	self.submenu = self.menu[ "Back" ][ self.submenu ];
	
	if ( self.submenu == "Main" )
	{
		self CursMove( "X" );
	}
	else
	{
		self CursMove( "Y" );
	}
}

ExitMenu()
{
	if ( isdefined( self.menutext ) )
	{
		for ( i = 0; i < self.menutext.size; i++ )
		{
			if ( isdefined( self.menutext[ i ] ) )
			{
				self.menutext[ i ] destroyElemFixed();
			}
		}
	}
	
	if ( isdefined( self.menu ) && isdefined( self.menu[ "X" ] ) )
	{
		if ( isdefined( self.menu[ "X" ][ "Shader" ] ) )
		{
			self.menu[ "X" ][ "Shader" ] destroyElemFixed();
		}
		
		if ( isdefined( self.menu[ "X" ][ "Scroller" ] ) )
		{
			self.menu[ "X" ][ "Scroller" ] destroyElemFixed();
		}
	}
	
	if ( isdefined( self.menuversionhud ) )
	{
		self.menuversionhud destroyFixed();
	}
	
	self.menuopen = false;
	self notify( "exit" );
	
	self setclientcvar( "r_blur", "0" );
	self setclientcvar( "sc_blur", "2" );
}

initHudElem( txt, xl, yl )
{
	hud = newclienthudelem( self );
	//hud settext( txt );
	hud.alignx = "center";
	hud.aligny = "bottom";
	hud.horzalign = "center";
	hud.vertalign = "bottom";
	hud.x = xl;
	hud.y = yl;
	hud.foreground = true;
	hud.fontscale = 1.4;
	hud.font = "default";
	hud.alpha = 1;
	hud.glow = 0;
	hud.glowcolor = ( 0, 0, 0 );
	hud.glowalpha = 1;
	hud.color = ( 1.0, 1.0, 1.0 );
	
	return hud;
}

createRectangle( align, relative, x, y, width, height, color, sort, alpha, shader )
{
	barElemBG = newclienthudelem( self );
	barElemBG.elemtype = "bar_";
	barElemBG.width = width;
	barElemBG.height = height;
	barElemBG.align = align;
	barElemBG.relative = relative;
	barElemBG.xoffset = 0;
	barElemBG.yoffset = 0;
	barElemBG.children = [];
	barElemBG.sort = sort;
	barElemBG.color = color;
	barElemBG.alpha = alpha;
	barElemBG setparent( level.uiparent );
	//barElemBG setshader( shader, width, height );
	barElemBG.hidden = false;
	barElemBG setpoint( align, relative, x, y );
	return barElemBG;
}

AddOptions()
{
	self AddMenu( "Main", 0, "Manage bots", ::OpenSub, "man_bots", "" );
	self AddBack( "man_bots", "Main" );
	
	_temp = "";
	_tempcvar = getcvarint( "bots_manage_add" );
	self AddMenu( "man_bots", 0, "Add 1 bot", ::man_bots, "add", 1 + _tempcvar );
	self AddMenu( "man_bots", 1, "Add 3 bot", ::man_bots, "add", 3 + _tempcvar );
	self AddMenu( "man_bots", 2, "Add 7 bot", ::man_bots, "add", 7 + _tempcvar );
	self AddMenu( "man_bots", 3, "Add 11 bot", ::man_bots, "add", 11 + _tempcvar );
	self AddMenu( "man_bots", 4, "Add 17 bot", ::man_bots, "add", 17 + _tempcvar );
	self AddMenu( "man_bots", 5, "Kick a bot", ::man_bots, "kick", 1 );
	self AddMenu( "man_bots", 6, "Kick all bots", ::man_bots, "kick", getBotArray().size );
	
	_tempcvar = getcvarint( "bots_manage_fill_kick" );
	
	if ( _tempcvar )
	{
		_temp = "true";
	}
	else
	{
		_temp = "false";
	}
	
	self AddMenu( "man_bots", 7, "Toggle auto bot kicking: " + _temp, ::man_bots, "autokick", _tempcvar );
	
	_tempcvar = getcvarint( "bots_manage_fill_mode" );
	
	switch ( _tempcvar )
	{
		case 0:
			_temp = "everyone";
			break;
			
		case 1:
			_temp = "just bots";
			break;
			
		case 2:
			_temp = "everyone, adjust to map";
			break;
			
		case 3:
			_temp = "just bots, adjust to map";
			break;
			
		case 4:
			_temp = "bots used as team balance";
			break;
			
		case 5:
			_temp = "bots used as team balance, adjust to map";
			break;
			
		default:
			_temp = "out of range";
			break;
	}
	
	self AddMenu( "man_bots", 8, "Change bot_fill_mode: " + _temp, ::man_bots, "fillmode", _tempcvar );
	
	_tempcvar = getcvarint( "bots_manage_fill" );
	self AddMenu( "man_bots", 9, "Increase bots to keep in-game: " + _tempcvar, ::man_bots, "fillup", _tempcvar );
	self AddMenu( "man_bots", 10, "Decrease bots to keep in-game: " + _tempcvar, ::man_bots, "filldown", _tempcvar );
	
	_tempcvar = getcvarint( "bots_manage_fill_spec" );
	
	if ( _tempcvar )
	{
		_temp = "true";
	}
	else
	{
		_temp = "false";
	}
	
	self AddMenu( "man_bots", 11, "Count players for fill on spectator: " + _temp, ::man_bots, "fillspec", _tempcvar );
	
	//
	
	self AddMenu( "Main", 1, "Teams and difficulty", ::OpenSub, "man_team", "" );
	self AddBack( "man_team", "Main" );
	
	_tempcvar = getcvar( "bots_team" );
	self AddMenu( "man_team", 0, "Change bot team: " + _tempcvar, ::bot_teams, "team", _tempcvar );
	
	_tempcvar = getcvarint( "bots_team_amount" );
	self AddMenu( "man_team", 1, "Increase bots to be on axis team: " + _tempcvar, ::bot_teams, "teamup", _tempcvar );
	self AddMenu( "man_team", 2, "Decrease bots to be on axis team: " + _tempcvar, ::bot_teams, "teamdown", _tempcvar );
	
	_tempcvar = getcvarint( "bots_team_force" );
	
	if ( _tempcvar )
	{
		_temp = "true";
	}
	else
	{
		_temp = "false";
	}
	
	self AddMenu( "man_team", 3, "Toggle forcing bots on team: " + _temp, ::bot_teams, "teamforce", _tempcvar );
	
	_tempcvar = getcvarint( "bots_team_mode" );
	
	if ( _tempcvar )
	{
		_temp = "only bots";
	}
	else
	{
		_temp = "everyone";
	}
	
	self AddMenu( "man_team", 4, "Toggle bot_team_bot: " + _temp, ::bot_teams, "teammode", _tempcvar );
	
	_tempcvar = getcvarint( "bots_skill" );
	
	switch ( _tempcvar )
	{
		case 0:
			_temp = "random for all";
			break;
			
		case 1:
			_temp = "too easy";
			break;
			
		case 2:
			_temp = "easy";
			break;
			
		case 3:
			_temp = "easy-medium";
			break;
			
		case 4:
			_temp = "medium";
			break;
			
		case 5:
			_temp = "hard";
			break;
			
		case 6:
			_temp = "very hard";
			break;
			
		case 7:
			_temp = "hardest";
			break;
			
		case 8:
			_temp = "custom";
			break;
			
		case 9:
			_temp = "complete random";
			break;
			
		default:
			_temp = "out of range";
			break;
	}
	
	self AddMenu( "man_team", 5, "Change bot difficulty: " + _temp, ::bot_teams, "skill", _tempcvar );
	
	_tempcvar = getcvarint( "bots_skill_axis_hard" );
	self AddMenu( "man_team", 6, "Increase amount of hard bots on axis team: " + _tempcvar, ::bot_teams, "axishardup", _tempcvar );
	self AddMenu( "man_team", 7, "Decrease amount of hard bots on axis team: " + _tempcvar, ::bot_teams, "axisharddown", _tempcvar );
	
	_tempcvar = getcvarint( "bots_skill_axis_med" );
	self AddMenu( "man_team", 8, "Increase amount of med bots on axis team: " + _tempcvar, ::bot_teams, "axismedup", _tempcvar );
	self AddMenu( "man_team", 9, "Decrease amount of med bots on axis team: " + _tempcvar, ::bot_teams, "axismeddown", _tempcvar );
	
	_tempcvar = getcvarint( "bots_skill_allies_hard" );
	self AddMenu( "man_team", 10, "Increase amount of hard bots on allies team: " + _tempcvar, ::bot_teams, "allieshardup", _tempcvar );
	self AddMenu( "man_team", 11, "Decrease amount of hard bots on allies team: " + _tempcvar, ::bot_teams, "alliesharddown", _tempcvar );
	
	_tempcvar = getcvarint( "bots_skill_allies_med" );
	self AddMenu( "man_team", 12, "Increase amount of med bots on allies team: " + _tempcvar, ::bot_teams, "alliesmedup", _tempcvar );
	self AddMenu( "man_team", 13, "Decrease amount of med bots on allies team: " + _tempcvar, ::bot_teams, "alliesmeddown", _tempcvar );
	
	//
	
	self AddMenu( "Main", 2, "Bot settings", ::OpenSub, "set1", "" );
	self AddBack( "set1", "Main" );
	
	_tempcvar = getcvarint( "bots_loadout_reasonable" );
	
	if ( _tempcvar )
	{
		_temp = "true";
	}
	else
	{
		_temp = "false";
	}
	
	self AddMenu( "set1", 0, "Bots use only good class setups: " + _temp, ::bot_func, "reasonable", _tempcvar );
	
	_tempcvar = getcvarint( "bots_loadout_allow_op" );
	
	if ( _tempcvar )
	{
		_temp = "true";
	}
	else
	{
		_temp = "false";
	}
	
	self AddMenu( "set1", 1, "Bots can use op and annoying class setups: " + _temp, ::bot_func, "op", _tempcvar );
	
	_tempcvar = getcvarint( "bots_play_move" );
	
	if ( _tempcvar )
	{
		_temp = "true";
	}
	else
	{
		_temp = "false";
	}
	
	self AddMenu( "set1", 2, "Bots can move: " + _temp, ::bot_func, "move", _tempcvar );
	
	_tempcvar = getcvarint( "bots_play_knife" );
	
	if ( _tempcvar )
	{
		_temp = "true";
	}
	else
	{
		_temp = "false";
	}
	
	self AddMenu( "set1", 3, "Bots can knife: " + _temp, ::bot_func, "knife", _tempcvar );
	
	_tempcvar = getcvarint( "bots_play_fire" );
	
	if ( _tempcvar )
	{
		_temp = "true";
	}
	else
	{
		_temp = "false";
	}
	
	self AddMenu( "set1", 4, "Bots can fire: " + _temp, ::bot_func, "fire", _tempcvar );
	
	_tempcvar = getcvarint( "bots_play_nade" );
	
	if ( _tempcvar )
	{
		_temp = "true";
	}
	else
	{
		_temp = "false";
	}
	
	self AddMenu( "set1", 5, "Bots can nade: " + _temp, ::bot_func, "nade", _tempcvar );
	
	_tempcvar = getcvarint( "bots_play_obj" );
	
	if ( _tempcvar )
	{
		_temp = "true";
	}
	else
	{
		_temp = "false";
	}
	
	self AddMenu( "set1", 6, "Bots play the objective: " + _temp, ::bot_func, "obj", _tempcvar );
	
	_tempcvar = getcvarint( "bots_play_camp" );
	
	if ( _tempcvar )
	{
		_temp = "true";
	}
	else
	{
		_temp = "false";
	}
	
	self AddMenu( "set1", 7, "Bots can camp: " + _temp, ::bot_func, "camp", _tempcvar );
	
	_tempcvar = getcvarint( "bots_play_jumpdrop" );
	
	if ( _tempcvar )
	{
		_temp = "true";
	}
	else
	{
		_temp = "false";
	}
	
	self AddMenu( "set1", 8, "Bots can jump and dropshot: " + _temp, ::bot_func, "jump", _tempcvar );
	
	_tempcvar = getcvarint( "bots_play_target_other" );
	
	if ( _tempcvar )
	{
		_temp = "true";
	}
	else
	{
		_temp = "false";
	}
	
	self AddMenu( "set1", 9, "Bots can target other script objects: " + _temp, ::bot_func, "targetother", _tempcvar );
	
	_tempcvar = getcvarint( "bots_play_killstreak" );
	
	if ( _tempcvar )
	{
		_temp = "true";
	}
	else
	{
		_temp = "false";
	}
	
	self AddMenu( "set1", 10, "Bots can use killstreaks: " + _temp, ::bot_func, "killstreak", _tempcvar );
	
	_tempcvar = getcvarint( "bots_play_ads" );
	
	if ( _tempcvar )
	{
		_temp = "true";
	}
	else
	{
		_temp = "false";
	}
	
	self AddMenu( "set1", 11, "Bots can ads: " + _temp, ::bot_func, "ads", _tempcvar );
}

bot_func( a, b )
{
	switch ( a )
	{
		case "reasonable":
			setcvar( "bots_loadout_reasonable", !b );
			self iprintln( "Bots using reasonable setups: " + !b );
			break;
			
		case "op":
			setcvar( "bots_loadout_allow_op", !b );
			self iprintln( "Bots using op setups: " + !b );
			break;
			
		case "move":
			setcvar( "bots_play_move", !b );
			self iprintln( "Bots move: " + !b );
			break;
			
		case "knife":
			setcvar( "bots_play_knife", !b );
			self iprintln( "Bots knife: " + !b );
			break;
			
		case "fire":
			setcvar( "bots_play_fire", !b );
			self iprintln( "Bots fire: " + !b );
			break;
			
		case "nade":
			setcvar( "bots_play_nade", !b );
			self iprintln( "Bots nade: " + !b );
			break;
			
		case "obj":
			setcvar( "bots_play_obj", !b );
			self iprintln( "Bots play the obj: " + !b );
			break;
			
		case "camp":
			setcvar( "bots_play_camp", !b );
			self iprintln( "Bots camp: " + !b );
			break;
			
		case "jump":
			setcvar( "bots_play_jumpdrop", !b );
			self iprintln( "Bots jump: " + !b );
			break;
			
		case "targetother":
			setcvar( "bots_play_target_other", !b );
			self iprintln( "Bots target other: " + !b );
			break;
			
		case "killstreak":
			setcvar( "bots_play_killstreak", !b );
			self iprintln( "Bots use killstreaks: " + !b );
			break;
			
		case "ads":
			setcvar( "bots_play_ads", !b );
			self iprintln( "Bots ads: " + !b );
			break;
	}
}

bot_teams( a, b )
{
	switch ( a )
	{
		case "team":
			switch ( b )
			{
				case "autoassign":
					setcvar( "bots_team", "allies" );
					self iprintlnbold( "Changed bot team to allies." );
					break;
					
				case "allies":
					setcvar( "bots_team", "axis" );
					self iprintlnbold( "Changed bot team to axis." );
					break;
					
				case "axis":
					setcvar( "bots_team", "custom" );
					self iprintlnbold( "Changed bot team to custom." );
					break;
					
				default:
					setcvar( "bots_team", "autoassign" );
					self iprintlnbold( "Changed bot team to autoassign." );
					break;
			}
			
			break;
			
		case "teamup":
			setcvar( "bots_team_amount", b + 1 );
			self iprintln( ( b + 1 ) + " bot(s) will try to be on axis team." );
			break;
			
		case "teamdown":
			setcvar( "bots_team_amount", b - 1 );
			self iprintln( ( b - 1 ) + " bot(s) will try to be on axis team." );
			break;
			
		case "teamforce":
			setcvar( "bots_team_force", !b );
			self iprintln( "Forcing bots to team: " + !b );
			break;
			
		case "teammode":
			setcvar( "bots_team_mode", !b );
			self iprintln( "Only count bots on team: " + !b );
			break;
			
		case "skill":
			switch ( b )
			{
				case 0:
					self iprintlnbold( "Changed bot skill to easy." );
					setcvar( "bots_skill", 1 );
					break;
					
				case 1:
					self iprintlnbold( "Changed bot skill to easy-med." );
					setcvar( "bots_skill", 2 );
					break;
					
				case 2:
					self iprintlnbold( "Changed bot skill to medium." );
					setcvar( "bots_skill", 3 );
					break;
					
				case 3:
					self iprintlnbold( "Changed bot skill to med-hard." );
					setcvar( "bots_skill", 4 );
					break;
					
				case 4:
					self iprintlnbold( "Changed bot skill to hard." );
					setcvar( "bots_skill", 5 );
					break;
					
				case 5:
					self iprintlnbold( "Changed bot skill to very hard." );
					setcvar( "bots_skill", 6 );
					break;
					
				case 6:
					self iprintlnbold( "Changed bot skill to hardest." );
					setcvar( "bots_skill", 7 );
					break;
					
				case 7:
					self iprintlnbold( "Changed bot skill to custom. Base is easy." );
					setcvar( "bots_skill", 8 );
					break;
					
				case 8:
					self iprintlnbold( "Changed bot skill to complete random. Takes effect at restart." );
					setcvar( "bots_skill", 9 );
					break;
					
				default:
					self iprintlnbold( "Changed bot skill to random. Takes effect at restart." );
					setcvar( "bots_skill", 0 );
					break;
			}
			
			break;
			
		case "axishardup":
			setcvar( "bots_skill_axis_hard", ( b + 1 ) );
			self iprintln( ( ( b + 1 ) ) + " hard bots will be on axis team." );
			break;
			
		case "axisharddown":
			setcvar( "bots_skill_axis_hard", ( b - 1 ) );
			self iprintln( ( ( b - 1 ) ) + " hard bots will be on axis team." );
			break;
			
		case "axismedup":
			setcvar( "bots_skill_axis_med", ( b + 1 ) );
			self iprintln( ( ( b + 1 ) ) + " med bots will be on axis team." );
			break;
			
		case "axismeddown":
			setcvar( "bots_skill_axis_med", ( b - 1 ) );
			self iprintln( ( ( b - 1 ) ) + " med bots will be on axis team." );
			break;
			
		case "allieshardup":
			setcvar( "bots_skill_allies_hard", ( b + 1 ) );
			self iprintln( ( ( b + 1 ) ) + " hard bots will be on allies team." );
			break;
			
		case "alliesharddown":
			setcvar( "bots_skill_allies_hard", ( b - 1 ) );
			self iprintln( ( ( b - 1 ) ) + " hard bots will be on allies team." );
			break;
			
		case "alliesmedup":
			setcvar( "bots_skill_allies_med", ( b + 1 ) );
			self iprintln( ( ( b + 1 ) ) + " med bots will be on allies team." );
			break;
			
		case "alliesmeddown":
			setcvar( "bots_skill_allies_med", ( b - 1 ) );
			self iprintln( ( ( b - 1 ) ) + " med bots will be on allies team." );
			break;
	}
}

man_bots( a, b )
{
	switch ( a )
	{
		case "add":
			setcvar( "bots_manage_add", b );
			
			if ( b == 1 )
			{
				self iprintln( "Adding " + b + " bot." );
			}
			else
			{
				self iprintln( "Adding " + b + " bots." );
			}
			
			break;
			
		case "kick":
			result = false;
			
			for ( i = 0; i < b; i++ )
			{
				tempBot = getBotToKick();
				
				if ( isdefined( tempBot ) )
				{
					kick( tempBot getentitynumber() );
					result = true;
				}
				
				wait 0.25;
			}
			
			if ( !result )
			{
				self iprintln( "No bots to kick" );
			}
			
			break;
			
		case "autokick":
			setcvar( "bots_manage_fill_kick", !b );
			self iprintln( "Kicking bots when bots_fill is exceeded: " + !b );
			break;
			
		case "fillmode":
			switch ( b )
			{
				case 0:
					setcvar( "bots_manage_fill_mode", 1 );
					self iprintln( "bot_fill will now count only bots." );
					break;
					
				case 1:
					setcvar( "bots_manage_fill_mode", 2 );
					self iprintln( "bot_fill will now count everyone, adjusting to map." );
					break;
					
				case 2:
					setcvar( "bots_manage_fill_mode", 3 );
					self iprintln( "bot_fill will now count only bots, adjusting to map." );
					break;
					
				case 3:
					setcvar( "bots_manage_fill_mode", 4 );
					self iprintln( "bot_fill will now use bots as team balance." );
					break;
					
				case 4:
					setcvar( "bots_manage_fill_mode", 5 );
					self iprintln( "bot_fill will now use bots as team balance, adjusting to map." );
					break;
					
				default:
					setcvar( "bots_manage_fill_mode", 0 );
					self iprintln( "bot_fill will now count everyone." );
					break;
			}
			
			break;
			
		case "fillup":
			setcvar( "bots_manage_fill", b + 1 );
			self iprintln( "Increased to maintain " + ( b + 1 ) + " bot(s)." );
			break;
			
		case "filldown":
			setcvar( "bots_manage_fill", b - 1 );
			self iprintln( "Decreased to maintain " + ( b - 1 ) + " bot(s)." );
			break;
			
		case "fillspec":
			setcvar( "bots_manage_fill_spec", !b );
			self iprintln( "Count players on spectator for bots_fill: " + !b );
			break;
	}
}
