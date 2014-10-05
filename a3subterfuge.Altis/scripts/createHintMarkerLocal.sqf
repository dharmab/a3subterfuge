_param_hint_position = _this select 0;
_param_hint_radius = _this select 1;

_diameter = _param_hint_radius * 2;
_marker = createMarkerLocal ["hint_marker", _param_hint_position];
_marker setMarkerShapeLocal "ELLIPSE";
_marker setMarkerSizeLocal [_diameter, _diameter];
_marker setMarkerColorLocal "ColorRed";