// Copyright 2024 Maicol Castro <maicolcastro.abc@gmail.com>.
// Do not remove this comment. Respect the work of others.
//
// Distributed under the BSD 3-Clause License.
// See LICENSE.txt in the root directory of this project
// or at https://opensource.org/license/bsd-3-clause.

static enum E_ITEM_CLASS {
    ITEM_VFN_USE,
    ITEM_VFN_GETMODEL,
    ITEM_VFN_GETOBJMODEL,
    ITEM_VFN_GETROT,

    bool:ITEM_ATTR_CAN_DROP,
}

stock g_itemsClasses[ITEM_CLASS_COUNT][E_ITEM_CLASS] = {
    // ITEM_NONE
    { 0, 0, 0, 0, false },

    {
        __addressof(ItemWeaponUse), 
        __addressof(ItemWeaponGetModel),
        __addressof(ItemWeaponGetObjModel),
        __addressof(ItemWeaponGetRot),
        true
    },
    {
        __addressof(ItemSkinUse),
        __addressof(ItemSkinGetModel),
        __addressof(ItemSkinGetObjModel),
        __addressof(ItemSkinGetRot),
        true
    },
    {
        __addressof(ItemVehicleUse),
        __addressof(ItemVehicleGetModel),
        __addressof(ItemVehicleGetObjModel),
        __addressof(ItemVehicleGetRot),
        false
    }
};

/* ================================================================ */

stock ItemUse(playerid, slotID, item, amount) {
    new vfunction = g_itemsClasses[item & 0xFF][ITEM_VFN_USE];
    new itemID = (item >> 8) & 0xFFFFFF;
    new returnValue;

    #emit PUSH.S amount
    #emit PUSH.S itemID
    #emit PUSH.S slotID
    #emit PUSH.S playerid
    #emit PUSH.C 16

    // Why the Windows version of SA-MP doesn't have CALL.PRI?
    #emit LCTRL 6
    #emit ADD.C 28
    #emit PUSH.PRI
    #emit LOAD.S.PRI vfunction
    #emit SCTRL 6

    #emit STOR.S.PRI returnValue

    return returnValue;
}

stock ItemGetModel(item) {
    new vfunction = g_itemsClasses[item & 0xFF][ITEM_VFN_GETMODEL];
    new itemID = (item >> 8) & 0xFFFFFF;
    new returnValue;

    #emit PUSH.S itemID
    #emit PUSH.C 4
    #emit LCTRL 6
    #emit ADD.C 28
    #emit PUSH.PRI
    #emit LOAD.S.PRI vfunction
    #emit SCTRL 6
    #emit STOR.S.PRI returnValue

    return returnValue;
}

stock ItemGetObjectModel(item) {
    new vfunction = g_itemsClasses[item & 0xFF][ITEM_VFN_GETOBJMODEL];
    new itemID = (item >> 8) & 0xFFFFFF;
    new returnValue;

    #emit PUSH.S itemID
    #emit PUSH.C 4
    #emit LCTRL 6
    #emit ADD.C 28
    #emit PUSH.PRI
    #emit LOAD.S.PRI vfunction
    #emit SCTRL 6
    #emit STOR.S.PRI returnValue

    return returnValue;
}

stock ItemGetRotation(item, &Float:x, &Float:y, &Float:z) {
    new vfunction = g_itemsClasses[item & 0xFF][ITEM_VFN_GETROT];

    #emit PUSH.S z
    #emit PUSH.S y
    #emit PUSH.S x
    #emit PUSH.C 12

    #emit LCTRL 6
    #emit ADD.C 28
    #emit PUSH.PRI
    #emit LOAD.S.PRI vfunction
    #emit SCTRL 6
}

stock bool:ItemCanDrop(item) {
    return g_itemsClasses[item & 0xFF][ITEM_ATTR_CAN_DROP];
}
