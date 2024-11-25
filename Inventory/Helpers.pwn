// Copyright 2024 Maicol Castro <maicolcastro.abc@gmail.com>.
//
// Distributed under the BSD 3-Clause License.
// See LICENSE.txt in the root directory of this project
// or at https://opensource.org/license/bsd-3-clause.

TryToAddItemToInventory(playerid, targetid, itemClass, itemID, amount) {
    if (!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "> Jogador n�o conectado.");

    if (InventoryAddItem(targetid, ItemCreate(itemClass, itemID), amount) == INVENTORY_SLOT_INVALID_ID)
        return SendClientMessage(playerid, COLOR_ERROR, "> O invent�rio do jogador est� cheio.");

    return SendClientMessage(playerid, COLOR_SUCCESS, "> Item adicionado ao invent�rio do jogador.");
}
