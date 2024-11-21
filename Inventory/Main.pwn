// Copyright 2024 Maicol Castro <maicolcastro.abc@gmail.com>.
// TextDraw Copyright 2024 vulgo_bl.
//
// Distributed under the BSD 3-Clause License.
// See LICENSE.txt in the root directory of this project
// or at https://opensource.org/license/bsd-3-clause.

#include <YSI_Coding\y_hooks>

static PlayerText:s_pTDs[MAX_PLAYERS][64];
static bool:s_pIsInventoryOpen[MAX_PLAYERS];
static s_pSlotSelected[MAX_PLAYERS];

static s_pItems[MAX_PLAYERS][INVENTORY_SLOTS_COUNT];
static s_pAmounts[MAX_PLAYERS][INVENTORY_SLOTS_COUNT];

stock InventoryOpen(playerid) {
    for (new i; i < sizeof s_pTDs[]; ++i)
        PlayerTextDrawShow(playerid, s_pTDs[playerid][i]);

    s_pIsInventoryOpen[playerid] = true;

    SelectTextDraw(playerid, 0xA020F07F);
}

stock InventoryClose(playerid) {
    s_pIsInventoryOpen[playerid] = false;

    for (new i; i < sizeof s_pTDs[]; ++i)
        PlayerTextDrawHide(playerid, s_pTDs[playerid][i]);

    CancelSelectTextDraw(playerid);
}

stock InventoryAddItem(playerid, item, amount) {
    new slotID = INVENTORY_SLOT_INVALID_ID;

    for (new i; i < INVENTORY_SLOTS_COUNT; ++i) {
        if (s_pAmounts[playerid][i] > 0)
            continue;

        slotID = i;
        break;
    }

    if (slotID == INVENTORY_SLOT_INVALID_ID)
        return INVENTORY_SLOT_INVALID_ID;

    s_pItems[playerid][slotID] = item;
    s_pAmounts[playerid][slotID] = amount;

    ViewUpdateSlot(playerid, slotID);

    return slotID;
}

stock InventorySlotSet(playerid, slotID, item, amount) {
    s_pItems[playerid][slotID] = item;
    s_pAmounts[playerid][slotID] = amount;

    ViewUpdateSlot(playerid, slotID);
}

stock InventorySlotGetAmount(playerid, slotID) {
    return s_pAmounts[playerid][slotID];
}

static UseItem(playerid, slotID, amount) {
    if (amount > s_pAmounts[playerid][slotID])
        return SendClientMessage(playerid, COLOR_ERROR, "> Você não tem essa quantidade.");

    if (ItemUse(playerid, slotID, s_pItems[playerid][slotID], amount)) {
        s_pAmounts[playerid][slotID] -= amount;

        if (s_pAmounts[playerid][slotID] == 0)
            s_pItems[playerid][slotID] = 0;

        ViewUpdateSlot(playerid, slotID);
    }

    s_pSlotSelected[playerid] = INVENTORY_SLOT_INVALID_ID;

    return 0;
}

static OnClickSlot(playerid, slotID) {
    if (s_pAmounts[playerid][slotID] > 0)
        s_pSlotSelected[playerid] = slotID;
    else
        s_pSlotSelected[playerid] = INVENTORY_SLOT_INVALID_ID;
}

static OnClickUse(playerid) {
    if (s_pSlotSelected[playerid] == INVENTORY_SLOT_INVALID_ID)
        return SendClientMessage(playerid, COLOR_ERROR, "> Você não selecionou um slot.");

    new amount = s_pAmounts[playerid][s_pSlotSelected[playerid]];

    if (amount == 1)
        return UseItem(playerid, s_pSlotSelected[playerid], 1);

    static buf[128];
    format(buf, sizeof buf, "Escreva a quantidade que você deseja usar.\nQuantidade disponível: %d.", amount);

    ShowPlayerDialog(playerid, DIALOG_SELECT_AMOUNT, DIALOG_STYLE_INPUT, "Quantidade", buf, "Usar", "Cancelar");

    return 0;
}

static OnClickDrop(playerid) {
    SendClientMessage(playerid, COLOR_ERROR, "Quer algo completo? @guil2k7");
}

/* ================================ HOOKS ================================ */

hook OnPlayerConnect(playerid) {
    s_pIsInventoryOpen[playerid] = false;
    s_pSlotSelected[playerid] = INVENTORY_SLOT_INVALID_ID;

    for (new i; i < INVENTORY_SLOTS_COUNT; ++i) {
        s_pItems[playerid][i] = ITEM_NONE;
        s_pAmounts[playerid][i] = 0;
    }

    ViewCreate(playerid);

    return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if (PRESSED(KEY_NO))
        InventoryOpen(playerid);

    return 1;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid) {
    if (!s_pIsInventoryOpen[playerid])
        return 1;

    if (clickedid == INVALID_TEXT_DRAW)
        InventoryClose(playerid);

    return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if (!s_pIsInventoryOpen[playerid] || !response)
        return 1;

    if (dialogid == DIALOG_SELECT_AMOUNT) {
        new amount;

        if (sscanf(inputtext, "d", amount))
            return SendClientMessage(playerid, COLOR_ERROR, "> Quantidade inválida.");

        UseItem(playerid, s_pSlotSelected[playerid], amount);
    }

    return 1;
}

/* ================================ VIEW ================================ */

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid) {
    if (!s_pIsInventoryOpen[playerid])
        return 1;

    if (playertextid == s_pTDs[playerid][40]) {
        OnClickUse(playerid);
    }
    else if (playertextid == s_pTDs[playerid][42]) {
        OnClickDrop(playerid);
    }
    else if (playertextid == s_pTDs[playerid][44]) {
        InventoryClose(playerid);
    }
    else {
        for (new i = 46; i < 64; ++i) {
            if (playertextid != s_pTDs[playerid][i])
                continue;

            OnClickSlot(playerid, i - 46);
            break;
        }
    }

    return 1;
}

static ViewUpdateSlot(playerid, slotID) {
    if (s_pAmounts[playerid][slotID] > 0) {
        new item = s_pItems[playerid][slotID];

        new Float:rotX, Float:rotY, Float:rotZ;
        ItemGetRotation(item, rotX, rotY, rotZ);

        PlayerTextDrawSetPreviewModel(playerid, s_pTDs[playerid][46 + slotID], ItemGetModel(item));
        PlayerTextDrawSetPreviewRot(playerid, s_pTDs[playerid][46 + slotID], rotX, rotY, rotZ);
    }
    else {
        PlayerTextDrawSetPreviewModel(playerid, s_pTDs[playerid][46 + slotID], 19300);
    }

    if (s_pIsInventoryOpen[playerid])
        PlayerTextDrawShow(playerid, s_pTDs[playerid][46 + slotID]);
}

static ViewCreate(playerid) {
    s_pTDs[playerid][0] = CreatePlayerTextDraw(playerid, 149.000, 130.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][0], 320.000, 184.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][0], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][0], 1887473822);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][0], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][0], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][0], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][0], 1);

    s_pTDs[playerid][1] = CreatePlayerTextDraw(playerid, 149.000, 105.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][1], 320.000, 23.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][1], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][1], 1887473864);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][1], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][1], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][1], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][1], 1);

    s_pTDs[playerid][2] = CreatePlayerTextDraw(playerid, 149.000, 128.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][2], 320.000, 3.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][2], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][2], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][2], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][2], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][2], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][2], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][2], 1);

    s_pTDs[playerid][3] = CreatePlayerTextDraw(playerid, 274.000, 111.000, "inventario");
    PlayerTextDrawLetterSize(playerid, s_pTDs[playerid][3], 0.300, 1.500);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][3], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][3], -1);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][3], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][3], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][3], 150);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][3], 2);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][3], 1);

    s_pTDs[playerid][4] = CreatePlayerTextDraw(playerid, 156.000, 135.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][4], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][4], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][4], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][4], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][4], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][4], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][4], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][4], 1);

    s_pTDs[playerid][5] = CreatePlayerTextDraw(playerid, 156.000, 182.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][5], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][5], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][5], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][5], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][5], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][5], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][5], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][5], 1);

    s_pTDs[playerid][6] = CreatePlayerTextDraw(playerid, 208.000, 135.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][6], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][6], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][6], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][6], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][6], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][6], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][6], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][6], 1);

    s_pTDs[playerid][7] = CreatePlayerTextDraw(playerid, 260.000, 135.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][7], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][7], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][7], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][7], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][7], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][7], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][7], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][7], 1);

    s_pTDs[playerid][8] = CreatePlayerTextDraw(playerid, 312.000, 135.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][8], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][8], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][8], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][8], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][8], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][8], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][8], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][8], 1);

    s_pTDs[playerid][9] = CreatePlayerTextDraw(playerid, 363.000, 135.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][9], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][9], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][9], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][9], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][9], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][9], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][9], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][9], 1);

    s_pTDs[playerid][10] = CreatePlayerTextDraw(playerid, 415.000, 135.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][10], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][10], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][10], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][10], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][10], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][10], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][10], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][10], 1);

    s_pTDs[playerid][11] = CreatePlayerTextDraw(playerid, 208.000, 182.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][11], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][11], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][11], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][11], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][11], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][11], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][11], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][11], 1);

    s_pTDs[playerid][12] = CreatePlayerTextDraw(playerid, 260.000, 182.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][12], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][12], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][12], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][12], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][12], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][12], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][12], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][12], 1);

    s_pTDs[playerid][13] = CreatePlayerTextDraw(playerid, 312.000, 182.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][13], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][13], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][13], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][13], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][13], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][13], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][13], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][13], 1);

    s_pTDs[playerid][14] = CreatePlayerTextDraw(playerid, 363.000, 182.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][14], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][14], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][14], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][14], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][14], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][14], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][14], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][14], 1);

    s_pTDs[playerid][15] = CreatePlayerTextDraw(playerid, 415.000, 182.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][15], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][15], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][15], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][15], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][15], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][15], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][15], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][15], 1);

    s_pTDs[playerid][16] = CreatePlayerTextDraw(playerid, 415.000, 191.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][16], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][16], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][16], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][16], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][16], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][16], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][16], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][16], 1);

    s_pTDs[playerid][17] = CreatePlayerTextDraw(playerid, 363.000, 191.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][17], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][17], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][17], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][17], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][17], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][17], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][17], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][17], 1);

    s_pTDs[playerid][18] = CreatePlayerTextDraw(playerid, 312.000, 191.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][18], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][18], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][18], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][18], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][18], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][18], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][18], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][18], 1);

    s_pTDs[playerid][19] = CreatePlayerTextDraw(playerid, 260.000, 191.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][19], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][19], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][19], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][19], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][19], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][19], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][19], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][19], 1);

    s_pTDs[playerid][20] = CreatePlayerTextDraw(playerid, 208.000, 191.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][20], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][20], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][20], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][20], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][20], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][20], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][20], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][20], 1);

    s_pTDs[playerid][21] = CreatePlayerTextDraw(playerid, 156.000, 191.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][21], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][21], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][21], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][21], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][21], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][21], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][21], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][21], 1);

    s_pTDs[playerid][22] = CreatePlayerTextDraw(playerid, 415.000, 238.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][22], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][22], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][22], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][22], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][22], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][22], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][22], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][22], 1);

    s_pTDs[playerid][23] = CreatePlayerTextDraw(playerid, 363.000, 238.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][23], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][23], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][23], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][23], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][23], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][23], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][23], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][23], 1);

    s_pTDs[playerid][24] = CreatePlayerTextDraw(playerid, 312.000, 238.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][24], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][24], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][24], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][24], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][24], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][24], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][24], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][24], 1);

    s_pTDs[playerid][25] = CreatePlayerTextDraw(playerid, 260.000, 238.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][25], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][25], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][25], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][25], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][25], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][25], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][25], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][25], 1);

    s_pTDs[playerid][26] = CreatePlayerTextDraw(playerid, 208.000, 238.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][26], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][26], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][26], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][26], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][26], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][26], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][26], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][26], 1);

    s_pTDs[playerid][27] = CreatePlayerTextDraw(playerid, 156.000, 238.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][27], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][27], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][27], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][27], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][27], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][27], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][27], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][27], 1);

    s_pTDs[playerid][28] = CreatePlayerTextDraw(playerid, 156.000, 248.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][28], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][28], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][28], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][28], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][28], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][28], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][28], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][28], 1);

    s_pTDs[playerid][29] = CreatePlayerTextDraw(playerid, 208.000, 248.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][29], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][29], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][29], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][29], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][29], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][29], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][29], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][29], 1);

    s_pTDs[playerid][30] = CreatePlayerTextDraw(playerid, 260.000, 248.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][30], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][30], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][30], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][30], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][30], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][30], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][30], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][30], 1);

    s_pTDs[playerid][31] = CreatePlayerTextDraw(playerid, 312.000, 248.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][31], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][31], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][31], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][31], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][31], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][31], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][31], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][31], 1);

    s_pTDs[playerid][32] = CreatePlayerTextDraw(playerid, 363.000, 248.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][32], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][32], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][32], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][32], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][32], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][32], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][32], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][32], 1);

    s_pTDs[playerid][33] = CreatePlayerTextDraw(playerid, 415.000, 248.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][33], 47.000, 48.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][33], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][33], 1887473919);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][33], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][33], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][33], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][33], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][33], 1);

    s_pTDs[playerid][34] = CreatePlayerTextDraw(playerid, 156.000, 295.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][34], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][34], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][34], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][34], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][34], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][34], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][34], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][34], 1);

    s_pTDs[playerid][35] = CreatePlayerTextDraw(playerid, 208.000, 295.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][35], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][35], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][35], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][35], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][35], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][35], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][35], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][35], 1);

    s_pTDs[playerid][36] = CreatePlayerTextDraw(playerid, 260.000, 295.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][36], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][36], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][36], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][36], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][36], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][36], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][36], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][36], 1);

    s_pTDs[playerid][37] = CreatePlayerTextDraw(playerid, 312.000, 295.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][37], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][37], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][37], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][37], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][37], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][37], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][37], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][37], 1);

    s_pTDs[playerid][38] = CreatePlayerTextDraw(playerid, 363.000, 295.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][38], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][38], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][38], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][38], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][38], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][38], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][38], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][38], 1);

    s_pTDs[playerid][39] = CreatePlayerTextDraw(playerid, 415.000, 295.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][39], 47.000, 2.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][39], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][39], 12582911);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][39], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][39], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][39], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][39], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][39], 1);

    s_pTDs[playerid][40] = CreatePlayerTextDraw(playerid, 478.000, 166.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][40], 54.000, 18.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][40], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][40], 1768516095);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][40], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][40], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][40], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][40], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][40], 1);
    PlayerTextDrawSetSelectable(playerid, s_pTDs[playerid][40], 1);

    s_pTDs[playerid][41] = CreatePlayerTextDraw(playerid, 488.000, 167.000, "Usar");
    PlayerTextDrawLetterSize(playerid, s_pTDs[playerid][41], 0.300, 1.500);
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][41], 521.000, -13.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][41], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][41], -1);
    PlayerTextDrawUseBox(playerid, s_pTDs[playerid][41], 1);
    PlayerTextDrawBoxColor(playerid, s_pTDs[playerid][41], 0);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][41], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][41], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][41], 150);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][41], 2);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][41], 1);

    s_pTDs[playerid][42] = CreatePlayerTextDraw(playerid, 478.000, 188.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][42], 54.000, 18.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][42], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][42], 1768516095);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][42], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][42], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][42], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][42], 4);
    PlayerTextDrawSetSelectable(playerid, s_pTDs[playerid][42], 1);

    s_pTDs[playerid][43] = CreatePlayerTextDraw(playerid, 481.000, 189.000, "Soltar");
    PlayerTextDrawLetterSize(playerid, s_pTDs[playerid][43], 0.299, 1.500);
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][43], 530.000, -13.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][43], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][43], -1);
    PlayerTextDrawUseBox(playerid, s_pTDs[playerid][43], 1);
    PlayerTextDrawBoxColor(playerid, s_pTDs[playerid][43], 0);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][43], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][43], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][43], 150);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][43], 2);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][43], 1);

    s_pTDs[playerid][44] = CreatePlayerTextDraw(playerid, 478.000, 211.000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][44], 54.000, 18.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][44], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][44], 1768516095);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][44], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][44], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][44], 255);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][44], 4);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][44], 1);
    PlayerTextDrawSetSelectable(playerid, s_pTDs[playerid][44], 1);

    s_pTDs[playerid][45] = CreatePlayerTextDraw(playerid, 481.000, 212.000, "Fechar");
    PlayerTextDrawLetterSize(playerid, s_pTDs[playerid][45], 0.309, 1.500);
    PlayerTextDrawTextSize(playerid, s_pTDs[playerid][45], 530.000, -13.000);
    PlayerTextDrawAlignment(playerid, s_pTDs[playerid][45], 1);
    PlayerTextDrawColor(playerid, s_pTDs[playerid][45], -1);
    PlayerTextDrawUseBox(playerid, s_pTDs[playerid][45], 1);
    PlayerTextDrawBoxColor(playerid, s_pTDs[playerid][45], 0);
    PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][45], 0);
    PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][45], 0);
    PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][45], 150);
    PlayerTextDrawFont(playerid, s_pTDs[playerid][45], 2);
    PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][45], 1);

    new Float:y = 135.0;

    for (new row; row < 3; ++row) {
        new Float:x = 156.0;

        for (new i = 46 + 6 * row, j; j < 6; ++i, ++j) {
            s_pTDs[playerid][i] = CreatePlayerTextDraw(playerid, x, y, "_");
            PlayerTextDrawTextSize(playerid, s_pTDs[playerid][i], 47.000, 46.000);
            PlayerTextDrawAlignment(playerid, s_pTDs[playerid][i], 1);
            PlayerTextDrawColor(playerid, s_pTDs[playerid][i], -1);
            PlayerTextDrawSetShadow(playerid, s_pTDs[playerid][i], 0);
            PlayerTextDrawSetOutline(playerid, s_pTDs[playerid][i], 0);
            PlayerTextDrawBackgroundColor(playerid, s_pTDs[playerid][i], 0);
            PlayerTextDrawFont(playerid, s_pTDs[playerid][i], 5);
            PlayerTextDrawSetProportional(playerid, s_pTDs[playerid][i], 0);
            PlayerTextDrawSetPreviewModel(playerid, s_pTDs[playerid][i], 19300);
            PlayerTextDrawSetPreviewRot(playerid, s_pTDs[playerid][i], 0.000, 0.000, 0.000, 1.000);
            PlayerTextDrawSetPreviewVehCol(playerid, s_pTDs[playerid][i], 142, 142);
            PlayerTextDrawSetSelectable(playerid, s_pTDs[playerid][i], 1);

            x += 52.0;
        }

        y += 57.0;
    }
}
