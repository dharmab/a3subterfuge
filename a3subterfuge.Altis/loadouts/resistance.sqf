_character = _this select 0;

comment "Remove existing items";
removeAllWeapons _character;
removeAllItems _character;
removeAllAssignedItems _character;
removeUniform _character;
removeVest _character;
removeBackpack _character;
removeHeadgear _character;
removeGoggles _character;

comment "Add containers";
_character forceAddUniform "U_O_CombatUniform_oucamo";
for "_i" from 1 to 2 do {_character addItemToUniform "16Rnd_9x21_Mag";};
_character addItemToUniform "30Rnd_9x21_Mag";
_character addVest "V_TacVest_blk_POLICE";
for "_i" from 1 to 2 do {_character addItemToVest "SmokeShell";};
_character addItemToVest "SmokeShell";
_character addItemToVest "SmokeShellRed";
for "_i" from 1 to 2 do {_character addItemToVest "Chemlight_red";};
for "_i" from 1 to 2 do {_character addItemToVest "Chemlight_green";};
for "_i" from 1 to 2 do {_character addItemToVest "30Rnd_9x21_Mag";};
_character addHeadgear "H_HelmetB_black";
_character addGoggles "G_Balaclava_combat";

comment "Add weapons";
_character addWeapon "SMG_02_F";
_character addPrimaryWeaponItem "muzzle_snds_L";
_character addPrimaryWeaponItem "acc_flashlight";
_character addWeapon "hgun_P07_F";

comment "Add items";
_character linkItem "ItemMap";
_character linkItem "ItemCompass";
_character linkItem "ItemWatch";
_character linkItem "ItemRadio";
