_param_position = _this select 0;

_marker =createMarkerLocal  ["meeting_marker", _param_position];
_marker setMarkerShapeLocal "ICON";
_marker setMarkerTypeLocal "mil_pickup";