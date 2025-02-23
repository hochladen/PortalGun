// Copyright 2021/2022 Sysroot/Eisenhorn

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

    // http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "macros.hpp"

/// Description: Creates the illusion of depth in the portals' PiP views. Meant to be ran via StartRemoteUpdate.
/// Parameters:
///		PARAMETER		|		EXPECTED INPUT TYPE		|		DESCRIPTION
///
///		bPortal			|		Object					|		The blue portal.
///		oPortal			|		Object					|		The orange portal.
///
///	Return value: None.

#ifdef ASHPD_VERBOSE_DEBUG
ASHPD_LOG_FUNC("CamIllusion");
#endif

params["_bPortal", "_oPortal"];

private _blueCam = ASHPD_REMOTE_BLUE_CAM;
private _orangeCam = ASHPD_REMOTE_ORANGE_CAM;

// Position of player should remain constant so long as they're standing in the same spot
private _playerPos = (getPosWorld player vectorAdd [0,0,1.5]);

// Get the player's position relative to both portals
private _relPosBlue = _playerPos vectorDiff (getPosWorld _bPortal);
private _relPosOrange = _playerPos vectorDiff (getPosWorld _oPortal);

// Get the magnitudes of the relative positions
private _relPosBMag = vectorMagnitude _relPosBlue;
private _relPosOMag = vectorMagnitude _relPosOrange;

// Constrain the relative positions to a minimum magnitude
// (this prevents the portal view from going crazy when the player's too close)
if (_relPosBMag < 3) then {
	_relPosBlue = _relPosBlue vectorMultiply (3/_relPosBMag);
};
if (_relPosOMag < 3) then {
	_relPosOrange = _relPosOrange vectorMultiply (3/_relPosOMag);
};

private _blueDir = vectorDir _bPortal;
private _blueUp = vectorUp _bPortal;
private _orangeDir = vectorDir _oPortal;
private _orangeUp = vectorUp _oPortal;

private _blueX = _blueDir vectorCrossProduct _blueUp;
private _orangeX = _orangeDir vectorCrossProduct _orangeUp;

// Find the angular offsets for the relative positions
private _dirOffsetBlue = acos(_relPosBlue vectorCos _blueX);
private _upOffsetBlue = acos(_relPosBlue vectorCos _blueUp);

// Set camera direction as mirrored offsets of the relative position
private _bCamDir = [_orangeDir, _orangeUp, 270 + _dirOffsetBlue] call CBA_fnc_vectRotate3D;
_bCamDir = [_bCamDir, _orangeX, 270 - _upOffsetBlue] call CBA_fnc_vectRotate3D;

// Find the angular offsets for the relative positions
private _dirOffsetOrange = acos(_relPosOrange vectorCos _orangeX);
private _upOffsetOrange = acos(_relPosOrange vectorCos _orangeUp);

// Set camera direction as mirrored offsets of the relative position
private _oCamDir = [_blueDir, _blueUp, 270 + _dirOffsetOrange] call CBA_fnc_vectRotate3D;
_oCamDir = [_oCamDir, _blueX, 270 - _upOffsetOrange] call CBA_fnc_vectRotate3D;

// Constrain camera direction
if (acos(_bCamDir vectorCos (_orangeDir vectorMultiply -1)) < 50) then {
	_blueCam setVectorDirAndUp [_bCamDir, _orangeUp];
};
if (acos(_oCamDir vectorCos (_blueDir vectorMultiply -1)) < 50) then {
	_orangeCam setVectorDirAndUp [_oCamDir, _blueUp];
};