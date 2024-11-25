// Copyright 2024 Maicol Castro <maicolcastro.abc@gmail.com>.
//
// Distributed under the BSD 3-Clause License.
// See LICENSE.txt in the root directory of this project
// or at https://opensource.org/license/bsd-3-clause.

TryToAddItemToInventory(playerid, targetid, itemClass, itemID, amount) {
    if (!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "> Jogador não conectado.");

    if (InventoryAddItem(targetid, ItemCreate(itemClass, itemID), amount) == INVENTORY_SLOT_INVALID_ID)
        return SendClientMessage(playerid, COLOR_ERROR, "> O inventário do jogador está cheio.");

    return SendClientMessage(playerid, COLOR_SUCCESS, "> Item adicionado ao inventário do jogador.");
}
