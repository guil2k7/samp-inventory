// Copyright 2024 Maicol Castro <maicolcastro.abc@gmail.com>.
//
// Distributed under the BSD 3-Clause License.
// See LICENSE.txt in the root directory of this project
// or at https://opensource.org/license/bsd-3-clause.

/* ================================================ */

#if !defined PRESSED
    #define PRESSED(%0) \
    (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#endif

#define DIALOG_SELECT_AMOUNT_TO_USE     872
#define DIALOG_SELECT_AMOUNT_TO_DROP    873

#define COLOR_SUCCESS      0x00FF00FF
#define COLOR_ERROR        0xF44336FF
#define COLOR_WARNING      0xFFA726FF
#define COLOR_INFO         0x29B6F6FF

/* ================ Inventory ================ */

#define INVENTORY_SLOTS_COUNT 18
#define INVENTORY_SLOT_INVALID_ID -1

/* ================ Item ================ */

#define ITEM_NONE 0

enum {
    ITEM_CLASS_NONE,
    ITEM_CLASS_WEAPON,
    ITEM_CLASS_SKIN,
    ITEM_CLASS_VEHICLE,

    ITEM_CLASS_COUNT,
}

// ItemCreate(class, itemID)
#define ItemCreate(%0,%1) ((%0) | ((%1) << 8))
