_RESISTANCE_TEAM_PRESENT = ((resistance countSide allUnits) > 0);
_INGRESS_DISTANCE = 1000;

// Expose a variable to the public mission namespace
// _param_name variable name
// _param_value variable value
_fnc_exportToPublicMissionNamespace = {
    _param_name = _this select 0;
    _param_value = _this select 1;
    missionNamespace setVariable [_param_name, _param_value];
    publicVariable _param_name;
};

_fnc_applyLoadouts = {
    {
        _script = "";
        if (side _x == west) then {
            _script = "loadouts\west.sqf";
        };
        if (side _x == resistance) then {
            _script = "loadouts\resistance.sqf";
        };
        if (side _x == east) then {
            _script = "loadouts\east.sqf";
        };

        [_x] call compile preprocessFileLineNumbers _script;
    } forEach allUnits;
};

// Returns true if is over water
// _param_position position to check
_fnc_isPositionInWater = {
    _param_position = _this select 0;

    _height = getTerrainHeightASL [_param_position select 0, _param_position select 1];
    (_height <= -1)
};

// Helper function for remote execution of an SQF script in a scheduled environment.
// _param_args array of arguments to pass to script
// _param_script path to script to execute remotely
_fnc_remoteExecVm = {
    _param_args = _this select 0;
    _param_script = _this select 1;
    [[_param_args, _param_script], "BIS_fnc_execVM", true, true] call BIS_fnc_MP;
};

// Returns a random location on the map.
_fnc_selectRandomLocation = {
    _locations = [];
    waitUntil {
        // Sample a random point
        _random_position = [random 25000, random 25000];

        // Get all viable locations within 1km
        _locations = nearestLocations [_random_position, ["NameCity", "NameVillage", "NameLocal"], 1000];

        // Ensure at least one location was found
        count _locations > 0;
    };
    // Return a random location
    _locations call BIS_fnc_selectRandom;
};

_fnc_computeOffset = {
    _param_origin = _this select 0;
    _param_distance = _this select 1;
    _param_angle = _this select 2;

    // Sanitize angle
    _angle = _param_angle % 360;
    if (_angle < 0) then {
        _angle = 360 + _angle;
    };

    // use the quadrant and angle to determine ratio and sign of x and y offsets
    _x_offset_direction = 1;
    _y_offset_direction = 1;
    _x_to_y_ratio = 0.0;
    if (0 <= _angle && _angle < 90) then {
        _x_to_y_ratio = _angle / 90;
    };
    if (90 <= _angle && _angle < 180) then {
        _x_to_y_ratio = 1 - ((_angle - 90) / 90);
        _y_offset_direction = -1;
    };
    if (180 <= _angle && _angle < 270) then {
        _x_to_y_ratio = (_angle - 180) / 90;
        _x_offset_direction = -1;
        _y_offset_direction = -1;
    };
    if (270 <= _angle && _angle < 360) then {
        _x_to_y_ratio = 1 - ((_angle - 270) / 90);
        _x_offset_direction = -1;
    };

    // The square of the hypotenuse (distance from origin) equals the sum of the squares
    // of the two legs (x and y offsets)
    _offset_sum_of_squares = _param_distance * _param_distance;
    _x_offset_square = _offset_sum_of_squares * _x_to_y_ratio;
    _y_offset_square = _offset_sum_of_squares - _x_offset_square;

    _x_offset = (sqrt _x_offset_square) * _x_offset_direction;
    _y_offset = (sqrt _y_offset_square) * _y_offset_direction;

    // Apply offset to origin
    _position = [(_param_origin select 0) + _x_offset, (_param_origin select 1) + _y_offset];
    _position;
};

_fnc_initGameMode = {
    missionNamespace setVariable ["mission_ingress_init", false];

    if (isServer) then {
        _location = "";
        _west_ingress_position = [0, 0];
        _resistance_ingress_position = [0, 0];
        _east_ingress_position = [0, 0];

        waitUntil {
            _location = [] call _fnc_selectRandomLocation;

            _west_ingress_angle = random 360;
            _east_ingress_angle = 0;
            _resistance_ingress_angle = 0;
            if (_RESISTANCE_TEAM_PRESENT) then {
                _direction = [-1, 1] call BIS_fnc_selectRandom;
                _east_ingress_angle = _west_ingress_angle + (120 * _direction);
                _resistance_ingress_angle = _east_ingress_angle + (120 * _direction);
            } else {
                _east_ingress_angle = _west_ingress_angle + 180;
            };

            _west_ingress_position = [position _location, _INGRESS_DISTANCE, _west_ingress_angle] call _fnc_computeOffset;
            _resistance_ingress_position = [position _location, _INGRESS_DISTANCE, _resistance_ingress_angle] call _fnc_computeOffset;
            _east_ingress_position = [position _location, _INGRESS_DISTANCE, _east_ingress_angle] call _fnc_computeOffset;
            (
                !([_west_ingress_position] call _fnc_isPositionInWater) &&
                !([_resistance_ingress_position] call _fnc_isPositionInWater) &&
                !([_east_ingress_position] call _fnc_isPositionInWater)
            );
        };

        ["mission_ingress_init", true] call _fnc_exportToPublicMissionNamespace;
        
         // Spawn police MRAP
        _mrap = "B_MRAP_01_F" createVehicle [_resistance_ingress_position select 0, _resistance_ingress_position select 1, 0];    
        {
            _ingress_position = [0, 0];
            
            if (side _x == west) then {
                _ingress_position = _west_ingress_position;
            };
            if (side _x == resistance) then {
                _ingress_position = _resistance_ingress_position;
            };
            if (side _x == east) then {
               _ingress_position = _east_ingress_position;
            };

            if (side _x != resistance) then {
                _atv = "C_Quadbike_01_F" createVehicle [_ingress_position select 0, _ingress_position select 1, 0];
                [[_x, _atv], "scripts\moveInAvailableVehiclePosition.sqf"] call _fnc_remoteExecVm;
            } else {
                [[_x, _mrap], "scripts\moveInAvailableVehiclePosition.sqf"] call _fnc_remoteExecVm;
            };
        } forEach allUnits;
    };

    waitUntil {
        missionNamespace getVariable "mission_ingress_init";
    };
};

_fnc_main = {
    [] call _fnc_applyLoadouts;
    [] call _fnc_initGameMode;
};

[] call _fnc_main;