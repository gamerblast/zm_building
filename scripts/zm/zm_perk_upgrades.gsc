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
#using scripts\zm\_zm_perk_electric_cherry;

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
}

function init(){
	callback::on_connect( &on_player_connect );
}

function on_player_connect()
{
	self.hasJug2 = false;
	self.hasElectric2 = false;
	self.hasQuick2 = false;
	self.hasDouble2 = false;

	self.isUpgradingJug = false;
	self.isUpgradingCherry = false;
	self.isUpgradingQuick = false;
	self.isUpgradingDouble = false;

	self.cherry_kills = 0;

	self thread electric_cherry_upgrade();
}

function givePerkUpgrade(perkname)
{
	switch(perkname) {
		case "specialty_armorvest":
			self.hasJug2 = true;
			break;
		case"specialty_electriccherry":
			self.hasElectric2 = true;
			break;
		case "specialty_revive":
			self.hasQuick2 = true;
			break;
		case "specialty_rof":
			self.hasDouble2 = true;
			break;
	}
}

function IsPerkUpgradeActive(perkname) {
	if(! self HasPerk(perkname)) 
	{
		return false;
	}

	switch(perkname) {
		case "specialty_armorvest":
			return self.hasJug2;
			break;
		case "specialty_electriccherry":
			return self.hasElectric2;
			break;
		case "specialty_revive":
			return self.hasQuick2;
			break;
		case "specialty_rof":
			return self.hasDouble2;
			break;
	}

	return false;
}

function electric_cherry_upgrade() {
	self endon("disconnect");
	while(! self.hasElectric2) 
	{
		IPrintLn("Looping");
		if(self HasPerk("specialty_electriccherry") && ! self.isUpgradingCherry)
		{
			//IPrintLn("got cherry");
			self.isUpgradingCherry = true;
			self IPrintLnBold("Gained Challenge: Electric Cherry Upgrade (Begins next round)");
			currentRound = level.round_number;
			while(level.round_number <= currentRound)
			{
				wait(0.05);
			}
			if(self HasPerk("specialty_electriccherry"))
			{
				self IPrintLnBold("Electric Cherry Upgrade: Get 10 kills with Electric Cherry (Time limit: 2 rounds)");
				currentRound = level.round_number;
				current_cherry_kills = 0;
				if(isdefined(self.cherry_kills))
				{
					current_cherry_kills = self.cherry_kills;
				}

				IPrintLn("current cherry kills " + self.cherry_kills);
				while(level.round_number < currentRound + 2)
				{
					if(! self HasPerk("specialty_electriccherry"))
					{
						self.isUpgradingCherry = false;
						IPrintLnBold("Electric Cherry Upgrade Failed!");
						break;
					}
					if(self.cherry_kills >= current_cherry_kills + 10)
					{
						self.isUpgradingCherry = false;
						self givePerkUpgrade("specialty_electriccherry");
						IPrintLnBold("Electric Cherry Upgraded! (Effects: Increased reload and barrier rebuild speeds)");
						break;
					}
					IPrintLn("current cherry kills " + self.cherry_kills);
					wait(0.05);
				}
				if(! self.hasElectric2)
				{
					self.isUpgradingCherry = false;
					IPrintLnBold("Electric Cherry Upgrade Failed!");
				}

			}
			else 
			{
				self.isUpgradingCherry = false;
				self IPrintLnBold("Electric Cherry Upgrade Failed!");
			}
		}
		wait(0.05);
	}
}

function 