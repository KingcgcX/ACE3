/*
 * Author: BaerMitUmlaut
 * Handles any audible, visual and physical effects of fatigue.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Fatigue <NUMBER>
 * 2: Speed <NUMBER>
 * 3: Overexhausted <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_player, 0.5, 3.3, true] call ace_advanced_fatigue_fnc_handleEffects
 *
 * Public: No
 */
#include "script_component.hpp"
params ["_unit", "_fatigue", "_speed", "_overexhausted"];

#ifdef DEBUG_MODE_FULL
    systemChat str _fatigue;
    systemChat str vectorMagnitude velocity _unit;
#endif

// - Audible effects ----------------------------------------------------------
GVAR(lastBreath) = GVAR(lastBreath) + 1;
if (_fatigue > 0.4 && {GVAR(lastBreath) > (_fatigue * -10 + 9)} && {!underwater _unit}) then {
    switch (true) do {
        case (_fatigue < 0.6): {
            playSound (QGVAR(breathLow) + str(floor random 6));
        };
        case (_fatigue < 0.85): {
            playSound (QGVAR(breathMid) + str(floor random 6));
        };
        default {
            playSound (QGVAR(breathMax) + str(floor random 6));
        };
    };
    GVAR(lastBreath) = 0;
};

// - Visual effects -----------------------------------------------------------
GVAR(ppeBlackoutLast) = GVAR(ppeBlackoutLast) + 1;
if (GVAR(ppeBlackoutLast) == 1) then {
    GVAR(ppeBlackout) ppEffectAdjust [1,1,0,[0,0,0,1],[0,0,0,0],[1,1,1,1],[10,10,0,0,0,0.1,0.5]];
    GVAR(ppeBlackout) ppEffectCommit 1;
} else {
    if (_fatigue > 0.85) then {
        if (GVAR(ppeBlackoutLast) > (100 - _fatigue * 100) / 3) then {
            GVAR(ppeBlackout) ppEffectAdjust [1,1,0,[0,0,0,1],[0,0,0,0],[1,1,1,1],[2,2,0,0,0,0.1,0.5]];
            GVAR(ppeBlackout) ppEffectCommit 1;
            GVAR(ppeBlackoutLast) = 0;
        };
    };
};

// - Physical effects ---------------------------------------------------------
if (GVAR(isSwimming)) exitWith {
    _unit setAnimSpeedCoef (1 - _fatigue / 3);
};

private _animSpeedCoef = (linearConversion [0.3333, 1, _fatigue, 1, 0.75, true]) max GVAR(maxSlowdown);
_unit setAnimSpeedCoef _animSpeedCoef;

if (_overexhausted) then {
    [_unit, "forceWalk", QUOTE(ADDON), true] call EFUNC(common,statusEffect_set);
} else {
    if (isForcedWalk _unit && {_fatigue < 0.7}) then {
        [_unit, "forceWalk", QUOTE(ADDON), false] call EFUNC(common,statusEffect_set);
    } else {
        if ((isSprintAllowed _unit) && {_fatigue > 0.7}) then {
            [_unit, "blockSprint", QUOTE(ADDON), true] call EFUNC(common,statusEffect_set);
        } else {
            if ((!isSprintAllowed _unit) && {_fatigue < 0.6}) then {
                [_unit, "blockSprint", QUOTE(ADDON), false] call EFUNC(common,statusEffect_set);
            };
        };
    };
};

switch (stance _unit) do {
    case ("CROUCH"): {
        _unit setCustomAimCoef (1.0 + _fatigue ^ 2 * 0.1);
    };
    case ("PRONE"): {
        _unit setCustomAimCoef (1.0 + _fatigue ^ 2 * 2.0);
    };
    default {
        _unit setCustomAimCoef (1.5 + _fatigue ^ 2 * 3.0);
    };
};
