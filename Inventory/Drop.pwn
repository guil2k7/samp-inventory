// Copyright 2024 Maicol Castro <maicolcastro.abc@gmail.com>.
//
// Distributed under the BSD 3-Clause License.
// See LICENSE.txt in the root directory of this project
// or at https://opensource.org/license/bsd-3-clause.

#include <YSI_Coding\y_hooks>

#define ITEM_DROP_MAX_COUNT      640
#define ITEM_DROP_EXPIRE_TIME    90
#define ITEM_DROP_INVALID_ID     -1

static enum E_ITEM_DROP {
    ItemDrop_Next,
    ItemDrop_Previous,

    ItemDrop_Item,
    ItemDrop_Amount,
    ItemDrop_ExpireTime,
    ItemDrop_Object
}

static s_drops[ITEM_DROP_MAX_COUNT][E_ITEM_DROP];
static s_droppedItemsHead;
static s_freeIDsHead;

hook OnGameModeInit() {
    for (new i; i < ITEM_DROP_MAX_COUNT; ++i) {
        s_drops[i][ItemDrop_Next] = i + 1;
        s_drops[i][ItemDrop_Previous] = i - 1;
    }

    s_drops[0][ItemDrop_Previous] = ITEM_DROP_INVALID_ID;
    s_drops[ITEM_DROP_MAX_COUNT - 1][ItemDrop_Next] = ITEM_DROP_INVALID_ID;

    s_droppedItemsHead = ITEM_DROP_INVALID_ID;
    s_freeIDsHead = 0;

    SetTimer("ItemDropProcess", ITEM_DROP_EXPIRE_TIME * 1000, true);

    return 1;
}

static DetachNode(nodeID) {
    new next = s_drops[nodeID][ItemDrop_Next];
    new previous = s_drops[nodeID][ItemDrop_Previous];

    if (next != ITEM_DROP_INVALID_ID)
        s_drops[next][ItemDrop_Previous] = previous;

    if (previous != ITEM_DROP_INVALID_ID)
        s_drops[previous][ItemDrop_Next] = next;
    
    if (nodeID == s_droppedItemsHead)
        s_droppedItemsHead = next;
    else if (nodeID == s_freeIDsHead)
        s_freeIDsHead = next;
}

ItemDropCreate(item, amount, Float:x, Float:y, Float:z) {
    if (s_freeIDsHead == ITEM_DROP_INVALID_ID)
        return ITEM_DROP_INVALID_ID;

    new nodeID = s_freeIDsHead;
    DetachNode(nodeID);

    s_drops[nodeID][ItemDrop_Next] = s_droppedItemsHead;
    s_drops[nodeID][ItemDrop_Previous] = ITEM_DROP_INVALID_ID;

    if (s_droppedItemsHead != ITEM_DROP_INVALID_ID)
        s_drops[s_droppedItemsHead][ItemDrop_Previous] = nodeID;

    s_droppedItemsHead = nodeID;

    /* ---------------------------------------------------------------- */

    new objectModel = ItemGetObjectModel(item);

    s_drops[nodeID][ItemDrop_Item] = item;
    s_drops[nodeID][ItemDrop_Amount] = amount;
    s_drops[nodeID][ItemDrop_ExpireTime] = gettime() + ITEM_DROP_EXPIRE_TIME;
    s_drops[nodeID][ItemDrop_Object] = CreateDynamicObject(objectModel, x, y, z, 90.0, 120.0, 0.0);

    /* ---------------------------------------------------------------- */

    return nodeID;
}

ItemDropDestroy(nodeID) {
    DestroyDynamicObject(s_drops[nodeID][ItemDrop_Object]);
    DetachNode(nodeID);

    s_drops[nodeID][ItemDrop_Next] = s_freeIDsHead;
    s_drops[nodeID][ItemDrop_Previous] = ITEM_DROP_INVALID_ID;

    if (s_freeIDsHead != ITEM_DROP_INVALID_ID)
        s_drops[s_freeIDsHead][ItemDrop_Previous] = nodeID;

    s_freeIDsHead = nodeID;   
}

ItemDropGetInPoint(Float:x, Float:y, Float:z) {
    new Float:distance;

    for (new nodeID = s_droppedItemsHead; nodeID != ITEM_DROP_INVALID_ID; nodeID = s_drops[nodeID][ItemDrop_Next]) {
        Streamer_GetDistanceToItem(
            x, y, z,
            STREAMER_TYPE_OBJECT,
            s_drops[nodeID][ItemDrop_Object],
            distance
        );

        if (distance > 3.0)
            continue;

        return nodeID;
    }   

    return ITEM_DROP_INVALID_ID;
}

forward ItemDropProcess();
public ItemDropProcess() {
    new now = gettime();
    new nodeID = s_droppedItemsHead;

    while (nodeID != ITEM_DROP_INVALID_ID) {
        new next = s_drops[nodeID][ItemDrop_Next];

        if (now >= s_drops[nodeID][ItemDrop_ExpireTime])
            ItemDropDestroy(nodeID);

        nodeID = next;
    }
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if (GetPlayerState(playerid) != PLAYER_STATE_ONFOOT || !PRESSED(KEY_YES))
        return 1;

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    new nodeID = ItemDropGetInPoint(x, y, z);

    if (nodeID == ITEM_DROP_INVALID_ID)
        return 1;

    new item = s_drops[nodeID][ItemDrop_Item];
    new amount = s_drops[nodeID][ItemDrop_Amount];

    if (InventoryAddItem(playerid, item, amount) == INVENTORY_SLOT_INVALID_ID)
        return SendClientMessage(playerid, COLOR_ERROR, "> O inventário do jogador está cheio.");

    ItemDropDestroy(nodeID);

    ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 0, 0, 0, 0, 0);

    return 1;
}
