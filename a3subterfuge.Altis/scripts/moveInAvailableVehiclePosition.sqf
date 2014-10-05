// Attempts to move unit to an available seat in the vehicle. If no seats are available,
// move the unit next to the vehicle.
// _param_unit unit to move
// _param_vehicle unit to move unit into

_param_unit = _this select 0;
_param_vehicle = _this select 1;

// Fuck this shitty language
if ((_param_vehicle emptyPositions "Driver") > 0) then {
    _param_unit moveInDriver _param_vehicle;
} else {
    if ((_param_vehicle emptyPositions "Commander") > 0) then {
        _param_unit moveInCommander _param_vehicle;
    } else {
        if ((_param_vehicle emptyPositions "Gunner") > 0) then {
            _param_unit moveInGunner _param_vehicle;
        } else {
            if ((_param_vehicle emptyPositions "Cargo") > 0) then {
                _param_unit moveInCargo _param_vehicle;
            } else {
                _param_unit setPos (position _param_vehicle);
            };
        };
    };
};