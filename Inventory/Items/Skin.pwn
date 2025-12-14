// Copyright 2024 Maicol Castro <maicolcastro.abc@gmail.com>.
// Do not remove this comment. Respect the work of others.
//
// Distributed under the BSD 3-Clause License.
// See LICENSE.txt in the root directory of this project
// or at https://opensource.org/license/bsd-3-clause.

ItemSkinUse(playerid, slotID, itemID) {
    new currentSkinID = GetPlayerSkin(playerid);

    if (InventorySlotGetAmount(playerid, slotID) > 1) {
        if (InventoryAddItem(playerid, ItemCreate(ITEM_CLASS_SKIN, currentSkinID), 1) == INVENTORY_SLOT_INVALID_ID)
            return SendClientMessage(playerid, COLOR_ERROR, "> Voc� n�o pode trocar de roupa se n�o tiver espa�o para guardar as roupas atuais.");
    }
    else {
        InventorySlotSet(playerid, slotID, ItemCreate(ITEM_CLASS_SKIN, currentSkinID), 1);
    }

    SetPlayerSkin(playerid, itemID);

    return 0;
}

ItemSkinGetModel(itemID) {
    return itemID;
}

ItemSkinGetObjModel(itemID) {
    return 1275;
}

ItemSkinGetRot(&Float:x, &Float:y, &Float:z) {
    x = 0.0;
    y = 0.0;
    z = 0.0;
}

CMD:darskin(playerid, params[]) {
    new targetid;
    new skinID;

    if (sscanf(params, "rd", targetid, skinID))
        return SendClientMessage(playerid, COLOR_INFO, "> Use /darskin [Nome/ID do jogador] [Skin]");

    if (skinID < 0 || skinID > 311)
        return SendClientMessage(playerid, COLOR_ERROR, "> ID de skin inv�lido.");

    return TryToAddItemToInventory(playerid, targetid, ITEM_CLASS_SKIN, skinID, 1);
}
