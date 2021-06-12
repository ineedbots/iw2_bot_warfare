init()
{
	level.clientid = 0;

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);

		player.clientid = level.clientid;
		level.clientid++;	// Is this safe? What if a server runs for a long time and many people join/leave

		player thread ok();
	}
}

ok()
{
	self endon("disconnect");
	for (;;)
	{
		wait 0.05;
		self sayall("hi");
	}
}
