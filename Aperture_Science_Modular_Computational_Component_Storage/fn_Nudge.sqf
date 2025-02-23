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

/// Description: Handles "nudging" the player towards portals they're falling towards. Meant to be ran via StartRemoteUpdate.
/// Parameters:
///		PARAMETER		|		EXPECTED INPUT TYPE		|		DESCRIPTION
///
///		bPortal			|		Object					|		The blue portal.
///		oPortal			|		Object					|		The orange portal.
///
///	Return value: None.

#ifdef ASHPD_VERBOSE_DEBUG
ASHPD_LOG_FUNC("Nudge");
#endif

params["_bPortal", "_oPortal"];

// Don't perform nudging unless the player is in free-fall outside of a vehicle
if (isTouchingGround player || {vehicle player != player}) exitWith {};

{
	private _portal = _x;
	private _portalDir = vectorDir _portal;
	private _playerPos = getPosWorld player;
	private _portalPos = getPosWorld _portal;
	private _posOffset = _portalPos vectorDiff _playerPos;
	// Do nothing if not within nudge range of the player
	if (vectorMagnitude _posOffset > ASHPD_VAR_NUDGE_RANGE) then { continue };
	// Only check if we need to apply a nudge if the portal isn't vertical and is facing upwards
	if (acos((_portalDir vectorMultiply -1) vectorCos [0, 0, 1]) < ASHPD_VAR_VERTICAL_TOLERANCE) then {
		// Calculate the position correction needed 
		private _posCorrection = [_posOffset, _portalDir vectorMultiply -1] call ASHPD_fnc_ProjectVector;
		// Apply slight position correction
		player setPosWorld (_playerPos vectorAdd (_posCorrection vectorMultiply (ASHPD_VAR_NUDGE_STRENGTH * ASHPD_VAR_UPDATE_INTERVAL * ASHPD_SP_UPDATE_RATE)));
	};
} forEach [_bPortal, _oPortal];