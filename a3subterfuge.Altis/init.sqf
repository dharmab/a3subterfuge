_RESISTANCE_TEAM_PRESENT = ((resistance countSide allUnits) > 0);
_INGRESS_DISTANCE = 1000;

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

    // use the quadrant and angle to determine x and y offsets
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

    _x_offset = _param_distance * _x_to_y_ratio;
    _y_offset = _param_distance - _x_offset;
    _x_offset = _x_offset * _x_offset_direction;
    _y_offset = _y_offset * _y_offset_direction;

    // Apply offset to origin
    _position = [(_param_origin select 0) + _x_offset, (_param_origin select 1) + _y_offset];
    _position;
};

_fnc_initGameMode = {
    _location = "";
    _west_ingress_position = [0, 0];
    _resistance_ingress_position = [0, 0];
    _east_ingress_position = [0, 0];
    waitUntil {
        _location = [] call _fnc_selectRandomLocation;

        _west_ingress_angle = random 360;
        _east_ingress_angle = 0;
        _resistance_ingress_angle = 0;
        hint format ["RTP:%1", _RESISTANCE_TEAM_PRESENT];
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

    // Spawn police MRAP
    "B_MRAP_01_F" createVehicle [_resistance_ingress_position select 0, _resistance_ingress_position select 1, 0];

    {
        _ingress_position = [0, 0];
        _vehicle = "";
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
            _vehicle = "C_Quadbike_01_F" createVehicle [_ingress_position select 0, _ingress_position select 1, 0];
            _x moveInDriver _vehicle;
        } else {
            _x setPos [_ingress_position select 0, _ingress_position select 1, 0];
        };
    } forEach allUnits;

    _location;
};

_fnc_main = {
    [] call _fnc_applyLoadouts;
    [] call _fnc_initGameMode;
};

[] call _fnc_main;