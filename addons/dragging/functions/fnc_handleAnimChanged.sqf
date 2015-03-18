// by commy2
#include "script_component.hpp"

private ["_unit", "_anim"];

_unit = _this select 0;
_anim = _this select 1;

if (_unit getVariable [QGVAR(isDragging), false]) then {

    // drop dragged object when not in valid animation
    if !(_anim in DRAG_ANIMATIONS) then {
        private "_draggedObject";
        _draggedObject = _unit getVariable [QGVAR(draggedObject), objNull];

        [_unit, _draggedObject] call FUNC(dropObject);
    };

};

if (_unit getVariable [QGVAR(isCarrying), false]) then {

    // drop carried object when not standing
    if (stance _unit != "STAND") then {
        private "_carriedObject";
        _carriedObject = _unit getVariable [QGVAR(carriedObject), objNull];

        [_unit, _carriedObject] call FUNC(dropObject_carry);
    };

};
