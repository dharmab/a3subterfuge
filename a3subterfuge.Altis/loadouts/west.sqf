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
_character forceAddUniform "U_C_Driver_4";
for "_i" from 1 to 2 do {_character addItemToUniform "16Rnd_9x21_Mag";};
_character addHeadgear "H_RacingHelmet_1_blue_F";

comment "Add weapons";
_character addWeapon "hgun_Rook40_F";

comment "Add items";
_character linkItem "ItemMap";
_character linkItem "ItemCompass";
_character linkItem "ItemWatch";
_character linkItem "ItemRadio";
