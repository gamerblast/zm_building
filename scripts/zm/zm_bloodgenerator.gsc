#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_laststand;

// MAIN
//*****************************************************************************

function main()
{
	thread init();

	level.vialFilled = 0; // 0 to 5
	level.hasVial = false;
	level.bloodgun_active = false;
	level.bloodgun_cost = 500; // make this more expensive

	bloodgun_trig = getEnt("bloodgun_trig", "targetname");
	bloodgenerator_trigs = getEntArray("bloodgenerator_trig", "targetname");

	bloodgun_trig SetCursorHint( "HINT_NOICON" );
	bloodgun_trig thread blood_think();

	for(i = 0; i < bloodgenerator_trigs.size; i++) 
	{
		bloodgenerator_trigs[i] SetCursorHint( "HINT_NOICON" );
		bloodgenerator_trigs[i] thread generator_think();
	}

	
}

function init(){
	callback::on_connect( &on_player_connect );
}

function on_player_connect()
{
	self.isInBloodMode = false;
}

function blood_think()
{
	while(true) 
	{
		self thread set_bloodgun_hintstring();
		self waittill("trigger", player);
		if(! (zm_utility::is_player_valid(player)) || level.bloodgun_active || level.hasVial || player.zombie_vars[ "zombie_powerup_minigun_on" ])
		{
			wait(0.05);
			continue;
		}
		if(player.score < level.bloodgun_cost)
		{
			player playSound("no_cha_ching"); // no idea if this sound exists, or if this function is right
			wait(0.05);
			continue;
		}

		level.bloodgun_active = true;
		player.isInBloodMode = true;
		player zm_score::minus_to_player_score(level.bloodgun_cost);
		bloodgun = GetWeapon("shotgun_pump_upgraded"); // this is temporary, obviously
		weapon_store = player GetCurrentWeapon();
		player TakeWeapon(weapon_store);
		IPrintLn(weapon_store.displayname + " stored");
		player GiveWeapon(bloodgun);
		player SwitchToWeapon(bloodgun);
		player DisableWeaponCycling();
		player DisableOffhandWeapons();
		player AllowMelee(false);

		start_kills = player.pers["kills"];
		success = false; 
		while(!success) 
		{
			if(!zm_utility::is_player_valid(player) && ! player laststand::player_is_in_laststand()) 
			{
				IPrintLn("FAILED! Yeah you're dead/dc'd kiddo...");
				wait(0.05);
				break;
			}
			else if(player laststand::player_is_in_laststand()) {
				IPrintLn("FAILED! REST IN PIECES DOWN FOR THE COUNT NO REVIVAL YOURE BLEEDING OUT!");
				player util::waittill_any("player_revived", "bled_out", "disconnect");
				if(zm_utility::is_player_valid(player)) 
				{
					IPrintLn("Yerr up it's time to get yer guns back!");
					player TakeWeapon(bloodgun);
					player GiveWeapon(weapon_store);
					player SwitchToWeapon(weapon_store);
					wait(0.05);
					break;
				}
			}
			if(level.vialFilled >= 5)
			{
				player TakeWeapon(bloodgun);
				player GiveWeapon(weapon_store);
				player SwitchToWeapon(weapon_store);

				IPrintLn("Vial Filled!");
				level.hasVial = true;
				success = true;
			}
			killsGained = player.pers["kills"] - start_kills;
			level.vialFilled += killsGained;
			//IPrintLn("start_kills" + start_kills);
			//IPrintLn("added " + killsGained + " kills");
			start_kills = player.pers["kills"];
			wait(0.05);
		}

		player EnableWeaponCycling();
		player EnableOffhandWeapons();
		player AllowMelee(true);
		level.bloodgun_active = false;
		level.vialFilled = 0;
		player.isInBloodMode = false;
	}
}

function generator_think() 
{
	while(true)
	{
		generator_name = self.script_noteworthy;
		self thread set_generator_hintstring();
		self waittill("trigger", player);
		IPrintLn(generator_name + " had an attempt to activate it");
		if(level.hasVial) 
		{
			IPrintLn(generator_name + " was successfully activated, and the blood vial was taken.");
			level.hasVial = false;
			// fix these notifies, make qr off at beginning of game, and add print statements for clarity
			switch(generator_name) {
				case "generator1":
					IPrintLn("There was an attempt to power speedy cola and jug");
					level notify("sleight_on");
					level notify("juggernog_on");
					break;
				case "generator2":
					IPrintLn("There was an attempt to power doble tap and quickies");
					level notify("doubletap_on");
					level notify("revive_on");
					break;

			}
			wait(0.05);
			break;
		}
		wait(0.05);
	}
	self TriggerEnable(false);
}

function set_generator_hintstring() {
	while(true) {
		if(level.hasVial)
			self SetHintString("Press and hold ^3[{+activate}]^7 to deposit a blood vial into the generator");
		else
			self SetHintString("Blood vial required");
		wait(0.05);
	}

}

function set_bloodgun_hintstring() {
	while(true) {
		if(level.hasVial)
			self SetHintString("Already have vial");
		else
			self SetHintString("Press and hold ^3[{+activate}]^7 to take a blood vial [Cost: " + level.bloodgun_cost + "]");
		wait(0.05);
	}

}