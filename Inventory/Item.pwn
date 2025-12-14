// Copyright 2024 Maicol Castro <maicolcastro.abc@gmail.com>.
// Do not remove this comment. Respect the work of others.
//
// Distributed under the BSD 3-Clause License.
// See LICENSE.txt in the root directory of this project
// or at https://opensource.org/license/bsd-3-clause.

stock ItemUse(playerid, slotID, item, amount) {
    new itemID = (item >> 8) & 0xFFFFFF;

    switch (item & 0xFF) {
        case ITEM_CLASS_WEAPON:
            return ItemWeaponUse(playerid, itemID, amount);

        case ITEM_CLASS_SKIN:
            return ItemSkinUse(playerid, slotID, itemID);

        case ITEM_CLASS_VEHICLE:
            return ItemVehicleUse(playerid, itemID);
    }

    return 0;
}

stock ItemGetModel(item) {
    new itemID = (item >> 8) & 0xFFFFFF;

    switch (item & 0xFF) {
        case ITEM_CLASS_WEAPON:
            return ItemWeaponGetModel(itemID);

        case ITEM_CLASS_SKIN:
            return ItemSkinGetModel();

        case ITEM_CLASS_VEHICLE:
            return ItemVehicleGetModel(itemID);
    }

    return 0;
}

stock ItemGetObjectModel(item) {
    new itemID = (item >> 8) & 0xFFFFFF;

    switch (item & 0xFF) {
        case ITEM_CLASS_WEAPON:
            return ItemWeaponGetObjModel(itemID);

        case ITEM_CLASS_SKIN:
            return ItemSkinGetObjModel(itemID);

        case ITEM_CLASS_VEHICLE:
            return ItemVehicleGetObjModel(itemID);
    }

    return 0;
}

stock ItemGetRotation(item, &Float:x, &Float:y, &Float:z) {
    switch (item & 0xFF) {
        case ITEM_CLASS_WEAPON:
            ItemWeaponGetRot(x, y, z);

        case ITEM_CLASS_SKIN:
            ItemSkinGetRot(x, y, z);

        case ITEM_CLASS_VEHICLE:
            ItemVehicleGetRot(x, y, z);
    }
}

stock bool:ItemCanDrop(item) {
    switch (item & 0xFF) {
        case ITEM_CLASS_WEAPON:
            return true;

        case ITEM_CLASS_SKIN:
            return true;

        case ITEM_CLASS_VEHICLE:
            return false;
    }

    return false;
}
