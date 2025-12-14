// Copyright 2024 Maicol Castro <maicolcastro.abc@gmail.com>.
// Do not remove this comment. Respect the work of others.
//
// Distributed under the BSD 3-Clause License.
// See LICENSE.txt in the root directory of this project
// or at https://opensource.org/license/bsd-3-clause.

new const WEAPON_MODELS[] = {
    0,
    331,
    333,
    334,
    335,
    336,
    337,
    338,
    339,
    341,
    321,
    322,
    323,
    324,
    325,
    326,
    342,
    343,
    344,
    0,
    0,
    0,
    346,
    347,
    348,
    349,
    350,
    351,
    352,
    353,
    355,
    356,
    372,
    357,
    358,
    359,
    360,
    361,
    362,
    363,
    364,
    365,
    366,
    367
};

ItemWeaponUse(playerid, itemID, amount) {
    GivePlayerWeapon(playerid, itemID, amount);

    return 1;
}

ItemWeaponGetModel(itemID) {
    return WEAPON_MODELS[itemID];
}

ItemWeaponGetObjModel(itemID) {
    return WEAPON_MODELS[itemID];
}

ItemWeaponGetRot(&Float:x, &Float:y, &Float:z) {
    x = 0.0;
    y = 0.0;
    z = 0.0;
}

CMD:dararma(playerid, params[]) {
    new targetid;
    new weaponID;
    new ammo;

    if (sscanf(params, "rK<weapon>(-1)d", targetid, weaponID, ammo))
        return SendClientMessage(playerid, COLOR_INFO, "> Use /dararma [Nome/ID do jogador] [Arma] [Muni��o]");

    if (weaponID == -1)
        return SendClientMessage(playerid, COLOR_ERROR, "> Arma inv�lida.");

    return TryToAddItemToInventory(playerid, targetid, ITEM_CLASS_WEAPON, weaponID, ammo);
}
