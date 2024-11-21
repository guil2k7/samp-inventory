// Copyright 2024 Maicol Castro (maicolcastro.abc@gmail.com).
//
// Distributed under the BSD 3-Clause License.
// See LICENSE.txt in the root directory of this project
// or at https://opensource.org/license/bsd-3-clause.

static enum E_ITEM_VTABLE {
    ITEM_VFN_USE,
    ITEM_VFN_GETMODEL,
    ITEM_VFN_GETROT,
}

stock g_itemsClasses[ITEM_CLASS_COUNT][E_ITEM_VTABLE] = {
    { 0, 0, 0 },
    { __addressof(ItemWeaponUse), __addressof(ItemWeaponGetModel), __addressof(ItemWeaponGetRot) },
    { __addressof(ItemSkinUse), __addressof(ItemSkinGetModel), __addressof(ItemSkinGetRot) },
    { __addressof(ItemVehicleUse), __addressof(ItemVehicleGetModel), __addressof(ItemVehicleGetRot) }
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
    #emit LOAD.S.PRI vfunction
    #emit CALL.PRI
    #emit STOR.S.PRI returnValue

    return returnValue;
}

stock ItemGetModel(item) {
    new vfunction = g_itemsClasses[item & 0xFF][ITEM_VFN_GETMODEL];
    new itemID = (item >> 8) & 0xFFFFFF;
    new returnValue;

    #emit PUSH.S itemID
    #emit PUSH.C 4
    #emit LOAD.S.PRI vfunction
    #emit CALL.PRI
    #emit STOR.S.PRI returnValue

    return returnValue;
}

stock ItemGetRotation(item, &Float:x, &Float:y, &Float:z) {
    new vfunction = g_itemsClasses[item & 0xFF][ITEM_VFN_GETROT];

    #emit PUSH.S z
    #emit PUSH.S y
    #emit PUSH.S x
    #emit PUSH.C 12
    #emit LOAD.S.PRI vfunction
    #emit CALL.PRI
}
