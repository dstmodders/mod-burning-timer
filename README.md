# mod-burning-timer

Mod for the game Don't Starve Together to display fire durations to clients.

## Overview

Mod for the game [Don't Starve Together][] which is available through the
[Steam Workshop][]. This mod displays a timer above burning objects or any
campfire telling you the exact time until the fire goes out.

_No Lag:_ This mod will not affect your in-game FPS.

_Clear Display:_ Timers will not stack on top of each other and only the
shortest timer will be shown, giving you a clear display of when e.g. a stack
with multiple items will start turning into ashes.

_Compatibility:_ It is compatible with other mods introducing new objects since
timers are not hardcoded.

Burning objects will be marked with a seconds timer which displays the remaining
time until the object turns into its burned state or simply into ashes. Not
every object has a constant burning timer (e.g. Gunpowder) or can be specified
exactly without hardcoding (e.g. Lune Tree), if the timer is marked with
**(brackets)** then the object may burn down during any time while that timer is
counting down. Explosives will additionally be marked with **!!exclamation
marks!!**, they tend to blow up and to deal damage once the timer ends so watch
out for them.

Campfire, Fire Pit, Endothermic Fire, Endothermic Fire Pit, and Night Light do
all show the amount of available fuel and their remaining burning duration
depending on rain.

## Configuration

| Configuration               | Default      | Description                                                                                              |
| --------------------------- | ------------ | -------------------------------------------------------------------------------------------------------- |
| **Show/Hide Burning Timer** | _-- None --_ | Toggles the visibility of the burning timers if pressed.                                                 |
| **Enabled by default**      | _Enabled_    | Enables/Disables the visibility of the burning timers at the start of your game.                         |
| **Show Burning Timer**      | _Enabled_    | Burning objects will show the remaining time until they burn down to ashes.                              |
| **Show Campfire Timer**     | _Enabled_    | Fire Pits, Campfires, Night Lights, etc.                                                                 |
| **Show Lantern Timer**      | _Enabled_    | Lanterns will show their fuel and the remaining time until they turn off.                                |
| **Show Star Caller Timer**  | _Enabled_    | Dwarf Stars and Polar Lights will show their remaining time in days and in minutes until they disappear. |
| **Unhide Duration**         | _5s_         | How long the timers will be shown if set to 'Hidden'.                                                    |

## License

Released under the [MIT License](https://opensource.org/licenses/MIT).

[don't starve together]: https://www.klei.com/games/dont-starve-together
[steam workshop]: https://steamcommunity.com/sharedfiles/filedetails/?id=2525856394
