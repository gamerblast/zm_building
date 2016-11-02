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
}

function init(){
	callback::on_connect( &on_player_connect );
}

function on_player_connect()
{
	self.hasJug2 = false;
	self.hasSpeed2 = false;
	self.hasQuick2 = false;
	self.hasDouble2 = false;
}

function givePerkUpgrade(perkname)
{
	switch(perkname) {
		case PERK_JUGGERNOG:
			self.hasJug2 = true;
			break;
		case PERK_SLEIGHT_OF_HAND:
			self.hasSpeed2 = true;
			break;
		case PERK_QUICK_REVIVE:
			self.hasQuick2 = true;
			break;
		case PERK_DOUBLETAP2:
			self.hasDouble2 = true;
			break;
	}
}

function IsPerkUpgradeActive(perkname) {
	if(! hasPerk(perkname)) 
	{
		return false;
	}

	switch(perkname) {
		case PERK_JUGGERNOG:
			return self.hasJug2;
			break;
		case PERK_SLEIGHT_OF_HAND:
			return self.hasSpeed2;
			break;
		case PERK_QUICK_REVIVE:
			return self.hasQuick2;
			break;
		case PERK_DOUBLETAP2:
			return self.hasDouble2;
			break;
	}

	return false;
}