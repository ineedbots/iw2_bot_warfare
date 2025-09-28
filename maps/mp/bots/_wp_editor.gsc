/*
	_wp_editor
	Author: INeedGames
	Date: 09/12/2025
	The ingame waypoint editor. Designed to be ran on the client (not the server)
*/

#include maps\mp\_utility;
#include maps\mp\bots\_bot_utility;

init()
{
	if ( getcvar( "bots_main_debug" ) == "" )
	{
		setcvar( "bots_main_debug", 0 );
	}
	
	if ( !getcvarint( "bots_main_debug" ) )
	{
		return;
	}
	
	if ( !getcvarint( "developer" ) )
	{
		setcvar( "developer_script", 1 );
		setcvar( "developer", 2 );
		
		map( getcvar( "mapname" ) );
		return;
	}
	
	setcvar( "bots_main", 0 );
	setcvar( "bots_main_menu", 0 );
	setcvar( "bots_manage_fill_mode", 0 );
	setcvar( "bots_manage_fill", 0 );
	setcvar( "bots_manage_add", 0 );
	setcvar( "bots_manage_fill_kick", 1 );
	setcvar( "bots_manage_fill_spec", 1 );

	setcvar( "smoke", 0 );
	setcvar( "frag", 0 );
	setcvar( "speed", 0 );
	
	if ( getcvar( "bots_main_debug_distance" ) == "" )
	{
		setcvar( "bots_main_debug_distance", 512.0 );
	}
	
	if ( getcvar( "bots_main_debug_cone" ) == "" )
	{
		setcvar( "bots_main_debug_cone", 0.65 );
	}
	
	if ( getcvar( "bots_main_debug_minDist" ) == "" )
	{
		setcvar( "bots_main_debug_minDist", 32.0 );
	}
	
	if ( getcvar( "bots_main_debug_drawThrough" ) == "" )
	{
		setcvar( "bots_main_debug_drawThrough", false );
	}
	
	if ( getcvar( "bots_main_debug_commandWait" ) == "" )
	{
		setcvar( "bots_main_debug_commandWait", 0.5 );
	}
	
	level.waypoints = [];
	level.waypointcount = 0;
	
	level waittill( "connected", player );
	
	player thread onPlayerSpawned();
}

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

onPlayerSpawned()
{
	self endon( "disconnect" );
	
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self thread beginDebug();
	}
}

beginDebug()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	level.wptolink = -1;
	level.autolink = false;
	self.closest = -1;
	self.command = undefined;

	self.bot_model_fix = true;
	
	self freezecontrols( false );
	
	self thread debug();
	self thread addWaypoints();
	self thread linkWaypoints();
	self thread deleteWaypoints();
	self thread watchSaveWaypointsCommand();
	self thread sayExtras();
	
	self thread textScroll( "^1SecondaryOffhand - ^2Add Waypoint; ^3MeleeButton - ^4Link Waypoint; ^5FragButton - ^6delete Waypoint; ^7UseButton + AttackButton - ^8Save" );
}

sayExtras()
{
	self endon( "disconnect" );
	self endon( "death" );
	self iprintln( "Making a crouch waypoint with only one link..." );
	self iprintln( "Makes a camping waypoint." );
}

debug()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	for ( ;; )
	{
		wait 0.05;
		
		if ( isdefined( self.command ) )
		{
			continue;
		}
		
		closest = -1;
		myEye = self gettagorigin( "j_head" );
		myAngles = self getplayerangles();
		
		for ( i = 0; i < level.waypointcount; i++ )
		{
			if ( closest == -1 || closer( self.origin, level.waypoints[ i ].origin, level.waypoints[ closest ].origin ) )
			{
				closest = i;
			}
			
			wpOrg = level.waypoints[ i ].origin + ( 0, 0, 25 );
			
			if ( distance( level.waypoints[ i ].origin, self.origin ) < getcvarfloat( "bots_main_debug_distance" ) && ( bullettracepassed( myEye, wpOrg, false, self ) || getcvarint( "bots_main_debug_drawThrough" ) ) )
			{
				for ( h = level.waypoints[ i ].children.size - 1; h >= 0; h-- )
				{
					line( wpOrg, level.waypoints[ level.waypoints[ i ].children[ h ] ].origin + ( 0, 0, 25 ), ( 1, 0, 1 ) );
				}
				
				if ( getConeDot( wpOrg, myEye, myAngles ) > getcvarfloat( "bots_main_debug_cone" ) )
				{
					print3d( wpOrg, i, ( 1, 0, 0 ), 2 );
				}
				
				if ( isdefined( level.waypoints[ i ].angles ) && level.waypoints[ i ].type != "stand" )
				{
					line( wpOrg, wpOrg + vector_scale( anglestoforward( level.waypoints[ i ].angles ), 64 ), ( 1, 1, 1 ) );
				}
			}
		}
		
		self.closest = closest;
		
		if ( closest != -1 )
		{
			stringChildren = "";
			
			for ( i = 0; i < level.waypoints[ closest ].children.size; i++ )
			{
				if ( i != 0 )
				{
					stringChildren = stringChildren + "," + level.waypoints[ closest ].children[ i ];
				}
				else
				{
					stringChildren = stringChildren + level.waypoints[ closest ].children[ i ];
				}
			}
			
			print3d( level.waypoints[ closest ].origin + ( 0, 0, 35 ), stringChildren, ( 0, 1, 0 ), 2 );
			
			print3d( level.waypoints[ closest ].origin + ( 0, 0, 15 ), level.waypoints[ closest ].type, ( 0, 1, 0 ), 2 );
		}
	}
}

addWaypoints()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	for ( ;; )
	{
		while ( !self secondaryoffhandbuttonpressed() || isdefined( self.command ) )
		{
			wait 0.05;
		}
		
		pos = self getorigin();
		self.command = true;
		
		self iprintln( "Adding a waypoint..." );
		self iprintln( "ADS - climb; Attack + Use - tube" );
		self iprintln( "Attack - grenade; Use - claymore" );
		self iprintln( "Else(wait) - your stance" );
		
		wait getcvarfloat( "bots_main_debug_commandWait" );
		
		self addWaypoint( pos );
		
		self.command = undefined;
		
		while ( self secondaryoffhandbuttonpressed() )
		{
			wait 0.05;
		}
	}
}

linkWaypoints()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	for ( ;; )
	{
		while ( !self meleebuttonpressed() || isdefined( self.command ) )
		{
			wait 0.05;
		}
		
		self.command = true;
		
		self iprintln( "ADS - unlink; Else(wait) - Link" );
		
		wait getcvarfloat( "bots_main_debug_commandWait" );
		
		if ( !self adsbuttonpressed() )
		{
			self LinkWaypoint( self.closest );
		}
		else
		{
			self UnLinkWaypoint( self.closest );
		}
		
		self.command = undefined;
		
		while ( self meleebuttonpressed() )
		{
			wait 0.05;
		}
	}
}

deleteWaypoints()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	for ( ;; )
	{
		while ( !self fragbuttonpressed() || isdefined( self.command ) )
		{
			wait 0.05;
		}
		
		self.command = true;
		
		self iprintln( "Attack - deleteAll; ADS - Load" );
		self iprintln( "Else(wait) - delete" );
		
		wait getcvarfloat( "bots_main_debug_commandWait" );
		
		if ( self attackbuttonpressed() )
		{
			self deleteAllWaypoints();
		}
		else if ( self adsbuttonpressed() )
		{
			self LoadWaypoints();
		}
		else
		{
			self deleteWaypoint( self.closest );
		}
		
		self.command = undefined;
		
		while ( self fragbuttonpressed() )
		{
			wait 0.05;
		}
	}
}

watchSaveWaypointsCommand()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	for ( ;; )
	{
		while ( !self usebuttonpressed() || !self attackbuttonpressed() || isdefined( self.command ) )
		{
			wait 0.05;
		}
		
		self.command = true;
		
		self iprintln( "ADS - Autolink; Else(wait) - Save" );
		
		wait getcvarfloat( "bots_main_debug_commandWait" );
		
		if ( !self adsbuttonpressed() )
		{
			self checkForWarnings();
			wait 1;
			
			logprint( "***********ABiliTy's WPDump**************\n\n" );
			logprint( "\n\n\n\n" );
			mpnm = getMapName( getcvar( "mapname" ) );
			logprint( "\n\n" + mpnm + "()\n{\n/*" );
			logprint( "*/waypoints = [];\n/*" );
			
			for ( i = 0; i < level.waypointcount; i++ )
			{
				logprint( "*/waypoints[ " + i + " ] = spawnstruct();\n/*" );
				logprint( "*/waypoints[ " + i + " ].origin = " + level.waypoints[ i ].origin + ";\n/*" );
				logprint( "*/waypoints[ " + i + " ].type = \"" + level.waypoints[ i ].type + "\";\n/*" );
				
				for ( c = 0; c < level.waypoints[ i ].children.size; c++ )
				{
					logprint( "*/waypoints[ " + i + " ].children[ " + c + " ] = " + level.waypoints[ i ].children[ c ] + ";\n/*" );
				}
				
				if ( isdefined( level.waypoints[ i ].angles ) && ( level.waypoints[ i ].type == "claymore" || level.waypoints[ i ].type == "tube" || ( level.waypoints[ i ].type == "crouch" && level.waypoints[ i ].children.size == 1 ) || level.waypoints[ i ].type == "climb" || level.waypoints[ i ].type == "grenade" ) )
				{
					logprint( "*/waypoints[ " + i + " ].angles = " + level.waypoints[ i ].angles + ";\n/*" );
				}
			}
			
			logprint( "*/return waypoints;\n}\n\n\n\n" );
			
			filename = "waypoints/" + getcvar( "mapname" ) + "_wp.csv";
			
			println( "********* Start Bot Warfare WPDump *********" );
			println( level.waypointcount );

			// cod2 fprintln always ends the write with a comma...
			//f = openfile( filename, "write" );
			f = -1;
			
			if ( f >= 0 )
			{
				fprintln( f, level.waypointcount + "\n" );
			}
			
			for ( i = 0; i < level.waypointcount; i++ )
			{
				str = "";
				wp = level.waypoints[ i ];
				
				str += wp.origin[ 0 ] + " " + wp.origin[ 1 ] + " " + wp.origin[ 2 ] + ",";
				
				for ( h = 0; h < wp.children.size; h++ )
				{
					str += wp.children[ h ];
					
					if ( h < wp.children.size - 1 )
					{
						str += " ";
					}
				}
				
				str += "," + wp.type + ",";
				
				if ( isdefined( wp.angles ) )
				{
					str += wp.angles[ 0 ] + " " + wp.angles[ 1 ] + " " + wp.angles[ 2 ] + ",";
				}
				else
				{
					str += ",";
				}
				
				str += ",";
				
				println( str );
				
				if ( f >= 0 )
				{
					fprintln( f, str + "\n" );
				}
			}

			if ( f >= 0 )
			{
				closefile( f );
			}
			
			println( "\n\n\n\n\n\n" );
			
			self iprintln( "Saved!!! to " + filename );
		}
		else
		{
			if ( level.autolink )
			{
				self iprintlnbold( "Auto link disabled" );
				level.autolink = false;
				level.wptolink = -1;
			}
			else
			{
				self iprintlnbold( "Auto link enabled" );
				level.autolink = true;
				level.wptolink = self.closest;
			}
		}
		
		self.command = undefined;
		
		while ( self usebuttonpressed() && self attackbuttonpressed() )
		{
			wait 0.05;
		}
	}
}

LoadWaypoints()
{
	self deleteAllWaypoints();
	self iprintlnbold( "Loading WPS..." );
	load_waypoints();
	level.waypointcount = level.waypoints.size;
	
	wait 1;
	
	self checkForWarnings();
}

checkForWarnings()
{
	if ( level.waypointcount <= 0 )
	{
		self iprintln( "WARNING: waypointCount is " + level.waypointcount );
	}
	
	if ( level.waypointcount != level.waypoints.size )
	{
		self iprintln( "WARNING: waypointCount is not " + level.waypoints.size );
	}
	
	for ( i = 0; i < level.waypointcount; i++ )
	{
		if ( !isdefined( level.waypoints[ i ] ) )
		{
			self iprintln( "WARNING: waypoint " + i + " is undefined" );
			continue;
		}
		
		if ( level.waypoints[ i ].children.size <= 0 )
		{
			self iprintln( "WARNING: waypoint " + i + " childCount is " + level.waypoints[ i ].children.size );
		}
		else
		{
			if ( !isdefined( level.waypoints[ i ].children ) || !isdefined( level.waypoints[ i ].children.size ) )
			{
				self iprintln( "WARNING: waypoint " + i + " children is not defined" );
			}
			else
			{
				for ( h = level.waypoints[ i ].children.size - 1; h >= 0; h-- )
				{
					child = level.waypoints[ i ].children[ h ];
					
					if ( !isdefined( level.waypoints[ child ] ) )
					{
						self iprintln( "WARNING: waypoint " + i + " child " + child + " is undefined" );
					}
					else if ( child == i )
					{
						self iprintln( "WARNING: waypoint " + i + " child " + child + " is itself" );
					}
				}
			}
		}
		
		if ( !isdefined( level.waypoints[ i ].type ) )
		{
			self iprintln( "WARNING: waypoint " + i + " type is undefined" );
			continue;
		}
		
		if ( !isdefined( level.waypoints[ i ].angles ) && ( level.waypoints[ i ].type == "claymore" || level.waypoints[ i ].type == "tube" || ( level.waypoints[ i ].type == "crouch" && level.waypoints[ i ].children.size == 1 ) || level.waypoints[ i ].type == "climb" || level.waypoints[ i ].type == "grenade" ) )
		{
			self iprintln( "WARNING: waypoint " + i + " angles is undefined" );
		}
	}
}

deleteAllWaypoints()
{
	level.waypoints = [];
	level.waypointcount = 0;
	
	self iprintln( "DelAllWps" );
}

deleteWaypoint( nwp )
{
	if ( nwp == -1 || distance( self.origin, level.waypoints[ nwp ].origin ) > getcvarfloat( "bots_main_debug_minDist" ) )
	{
		self iprintln( "No close enough waypoint to delete." );
		return;
	}
	
	level.wptolink = -1;
	
	for ( i = level.waypoints[ nwp ].children.size - 1; i >= 0; i-- )
	{
		child = level.waypoints[ nwp ].children[ i ];
		
		level.waypoints[ child ].children = array_remove( level.waypoints[ child ].children, nwp );
	}
	
	for ( i = 0; i < level.waypointcount; i++ )
	{
		for ( h = level.waypoints[ i ].children.size - 1; h >= 0; h-- )
		{
			if ( level.waypoints[ i ].children[ h ] > nwp )
			{
				level.waypoints[ i ].children[ h ]--;
			}
		}
	}
	
	for ( entry = 0; entry < level.waypointcount; entry++ )
	{
		if ( entry == nwp )
		{
			while ( entry < level.waypointcount - 1 )
			{
				level.waypoints[ entry ] = level.waypoints[ entry + 1 ];
				entry++;
			}
			
			level.waypoints[ entry ] = undefined;
			break;
		}
	}
	
	level.waypointcount--;
	
	self iprintln( "DelWp " + nwp );
}

addWaypoint( pos )
{
	level.waypoints[ level.waypointcount ] = spawnstruct();
	
	level.waypoints[ level.waypointcount ].origin = pos;
	
	if ( self adsbuttonpressed() )
	{
		level.waypoints[ level.waypointcount ].type = "climb";
	}
	else if ( self attackbuttonpressed() && self usebuttonpressed() )
	{
		level.waypoints[ level.waypointcount ].type = "tube";
	}
	else if ( self attackbuttonpressed() )
	{
		level.waypoints[ level.waypointcount ].type = "grenade";
	}
	else if ( self usebuttonpressed() )
	{
		level.waypoints[ level.waypointcount ].type = "claymore";
	}
	else
	{
		level.waypoints[ level.waypointcount ].type = self getstance();
	}
	
	level.waypoints[ level.waypointcount ].angles = self getplayerangles();
	
	level.waypoints[ level.waypointcount ].children = [];
	
	self iprintln( level.waypoints[ level.waypointcount ].type + " Waypoint " + level.waypointcount + " Added at " + pos );
	
	if ( level.autolink )
	{
		if ( level.wptolink == -1 )
		{
			level.wptolink = level.waypointcount - 1;
		}
		
		level.waypointcount++;
		self LinkWaypoint( level.waypointcount - 1 );
	}
	else
	{
		level.waypointcount++;
	}
}

UnLinkWaypoint( nwp )
{
	if ( nwp == -1 || distance( self.origin, level.waypoints[ nwp ].origin ) > getcvarfloat( "bots_main_debug_minDist" ) )
	{
		self iprintln( "Waypoint unlink Cancelled " + level.wptolink );
		level.wptolink = -1;
		return;
	}
	
	if ( level.wptolink == -1 || nwp == level.wptolink )
	{
		level.wptolink = nwp;
		self iprintln( "Waypoint unlink Started " + nwp );
		return;
	}
	
	level.waypoints[ nwp ].children = array_remove( level.waypoints[ nwp ].children, level.wptolink );
	level.waypoints[ level.wptolink ].children = array_remove( level.waypoints[ level.wptolink ].children, nwp );
	
	self iprintln( "Waypoint " + nwp + " Broken to " + level.wptolink );
	level.wptolink = -1;
}

LinkWaypoint( nwp )
{
	if ( nwp == -1 || distance( self.origin, level.waypoints[ nwp ].origin ) > getcvarfloat( "bots_main_debug_minDist" ) )
	{
		self iprintln( "Waypoint Link Cancelled " + level.wptolink );
		level.wptolink = -1;
		return;
	}
	
	if ( level.wptolink == -1 || nwp == level.wptolink )
	{
		level.wptolink = nwp;
		self iprintln( "Waypoint Link Started " + nwp );
		return;
	}
	
	weGood = true;
	
	for ( i = level.waypoints[ level.wptolink ].children.size - 1; i >= 0; i-- )
	{
		if ( level.waypoints[ level.wptolink ].children[ i ] == nwp )
		{
			weGood = false;
			break;
		}
	}
	
	if ( weGood )
	{
		for ( i = level.waypoints[ nwp ].children.size - 1; i >= 0; i-- )
		{
			if ( level.waypoints[ nwp ].children[ i ] == level.wptolink )
			{
				weGood = false;
				break;
			}
		}
	}
	
	if ( !weGood )
	{
		self iprintln( "Waypoint Link Cancelled " + nwp + " and " + level.wptolink + " already linked." );
		level.wptolink = -1;
		return;
	}
	
	level.waypoints[ level.wptolink ].children[ level.waypoints[ level.wptolink ].children.size ] = nwp;
	level.waypoints[ nwp ].children[ level.waypoints[ nwp ].children.size ] = level.wptolink;
	
	self iprintln( "Waypoint " + nwp + " Linked to " + level.wptolink );
	level.wptolink = -1;
}

destroyOnDeath( hud )
{
	hud endon( "death" );
	self waittill_either( "death", "disconnect" );

	if ( isdefined(hud) )
	{
		hud destroy();
	}
}

textScroll( string )
{
	self endon( "death" );
	self endon( "disconnect" );
	
	text = newclienthudelem( self );
	self thread destroyOnDeath( text );

	text.font = "default";
	text.fontscale = 1.5;
	text.alignx = "center";
	text.aligny = "middle";
	text.horzalign = "center";
	text.vertalign = "middle";
	text.y = 220;
	// cod2 only allows localized strings...
	text settext( &"PLATFORM_PRESS_TO_SPAWN" );
	
	for ( ;; )
	{
		text.x = 1200;
		text moveovertime( 20 );
		text.x = -1200;

		wait 20;
	}
}
