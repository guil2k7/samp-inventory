// Copyright 2024 Maicol Castro <maicolcastro.abc@gmail.com>.
//
// Distributed under the BSD 3-Clause License.
// See LICENSE.txt in the root directory of this project
// or at https://opensource.org/license/bsd-3-clause.

#include <YSI_Coding\y_hooks>

static s_pVehicleID[MAX_PLAYERS] = { INVALID_VEHICLE_ID, ... };

hook OnPlayerDisconnect(playerid, reason) {
    if (s_pVehicleID[playerid] != INVALID_VEHICLE_ID) {
        DestroyVehicle(s_pVehicleID[playerid]);
        s_pVehicleID[playerid] = INVALID_VEHICLE_ID;
    }

    return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate) {
    if (oldstate == PLAYER_STATE_DRIVER && s_pVehicleID[playerid] != INVALID_VEHICLE_ID) {
        DestroyVehicle(s_pVehicleID[playerid]);
        s_pVehicleID[playerid] = INVALID_VEHICLE_ID;
    }

    return 1;
}

ItemVehicleUse(playerid, slotID, itemID, amount) {
    #pragma unused slotID
    #pragma unused amount

    if (IsPlayerInAnyVehicle(playerid)) {
        SendClientMessage(playerid, COLOR_ERROR, "> Você não pode pegar um veículo enquanto estiver em um.");
        return 0;
    }

    new Float:x, Float:y, Float:z, Float:rotZ;

    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, rotZ);

    new vehicleid = CreateVehicle(itemID, x, y, z, rotZ, random(255), random(255), -1);
    s_pVehicleID[playerid] = vehicleid;

    PutPlayerInVehicle(playerid, vehicleid, 0);

    new oldengine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, oldengine, lights, alarm, doors, bonnet, boot, objective);
    SetVehicleParamsEx(vehicleid, 1, lights, alarm, doors, bonnet, boot, objective);

    InventoryClose(playerid);

    return 0;
}

ItemVehicleGetModel(itemID) {
    return itemID;
}

ItemVehicleGetObjModel(itemID) {
    return itemID;
}

ItemVehicleGetRot(&Float:x, &Float:y, &Float:z) {
    x = 0.0;
    y = 0.0;
    z = 0.0;   
}

CMD:darveiculo(playerid, params[]) {
    new targetid;
    new vehicleModel;

    if (sscanf(params, "rK<vehicle>(-1)", targetid, vehicleModel))
        return SendClientMessage(playerid, COLOR_INFO, "> Use /darveiculo [Nome/ID do jogador] [Modelo]");

    if (vehicleModel == -1)
        return SendClientMessage(playerid, COLOR_ERROR, "> Modelo inválido.");

    return TryToAddItemToInventory(playerid, targetid, ITEM_CLASS_VEHICLE, vehicleModel, 1);
}
