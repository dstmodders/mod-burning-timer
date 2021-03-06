name = "Burning Timer"
forumthread = ""
description = [[Displays a timer above burning objects or any campfire telling you the time until the fire goes out.]]
author = "Viktor"
version = "1.1.4"
api_version = 10
dont_starve_compatible = false
reign_of_giants_compatible = false
dst_compatible = true
all_clients_require_mod = false
client_only_mod = true
server_filter_tags = {}
icon_atlas = "modicon.xml"
icon = "modicon.tex"

local Keys = {
	{description = "None --", data = -1}, -- If players can't find the None option
	{description = "Numpad Zero", data = 256},
	{description = "Numpad One", data = 257},
	{description = "Numpad Two", data = 258},
	{description = "Numpad Three", data = 259},
	{description = "Numpad Four", data = 260},
	{description = "Numpad Five", data = 261},
	{description = "Numpad Six", data = 262},
	{description = "Numpad Seven", data = 263},
	{description = "Numpad Eight", data = 264},
	{description = "Numpad Nine", data = 265},
	{description = "Numpad Period", data = 266},
	{description = "Numpad Divide", data = 267},
	{description = "Numpad Multiply", data = 268},
	{description = "Numpad Minus", data = 269},
	{description = "Numpad Plus", data = 270},
--	{description = "Numpad Enter", data = 271},
--	{description = "Numpad Equals", data = 272},
	{description = "Up", data = 273},
	{description = "Down", data = 274},
	{description = "Left", data = 276},
	{description = "Right", data = 275},
	{description = "Minus", data = 45},
	{description = "Plus", data = 43},
	{description = "LeftBracket", data = 91},
	{description = "RightBracket", data = 93},
	{description = "Semicolon", data = 59},
	{description = "Quote", data = 39},
	{description = "Comma", data = 44},
	{description = "Period", data = 46},
	{description = "Slash", data = 47},
	{description = "PageUp", data = 280},
	{description = "PageDown", data = 281},
	{description = "Home", data = 278},
	{description = "End", data = 279},
	{description = "Insert", data = 277},
	{description = "Delete", data = 127},
	{description = "-- None --", data = 0}, -- Placing none here could help others to set up their keys
	{description = "A", data = 97},
	{description = "B", data = 98},
	{description = "C", data = 99},
	{description = "D", data = 100},
	{description = "E", data = 101},
	{description = "F", data = 102},
	{description = "G", data = 103},
	{description = "H", data = 104},
	{description = "I", data = 105},
	{description = "J", data = 106},
	{description = "K", data = 107},
	{description = "L", data = 108},
	{description = "M", data = 109},
	{description = "N", data = 110},
	{description = "O", data = 111},
	{description = "P", data = 112},
	{description = "Q", data = 113},
	{description = "R", data = 114},
	{description = "S", data = 115},
	{description = "T", data = 116},
	{description = "U", data = 117},
	{description = "V", data = 118},
	{description = "W", data = 119},
	{description = "X", data = 120},
	{description = "Y", data = 121},
	{description = "Z", data = 122},
	{description = "F1", data = 282},
	{description = "F2", data = 283},
	{description = "F3", data = 284},
	{description = "F4", data = 285},
	{description = "F5", data = 286},
	{description = "F6", data = 287},
	{description = "F7", data = 288},
	{description = "F8", data = 289},
	{description = "F9", data = 290},
	{description = "F10", data = 291},
	{description = "F11", data = 292},
	{description = "F12", data = 293},
	{description = "-- None", data = -1}, -- To avoid forcing players to click all the way back to the beginning
}
local Boolean = {
	{description = "Disabled", data = false},
	{description = "Enabled", data = true},
}
local BooleanHidden = {
	{description = "Disabled", data = false},
	{description = "Hidden", data = "hidden", hover = "Timer will only show up if you hover above it with your cursor."},
	{description = "Enabled", data = true},
}

configuration_options = {
{
	name = "hideButton",
	label = "Show/Hide Burning Timer",
	hover = "Toggles the visibility of the burning timers if pressed.",
	options = Keys,
	default = 0,
},
{
	name = "enabledByDefault",
	label = "Enabled by default",
	hover = "Enables/Disables the visibility of the burning timers at the start of your game.",
	options = Boolean,
	default = true,
},
{
	name = "",
	label = "",
	hover = "",
	options = {{description = "", data = 0}},
	default = 0,
},
{
	name = "showBurningTimer",
	label = "Show Burning Timer",
	hover = "Burning objects will show the remaining time until they burn down to ashes.",
	options = Boolean,
	default = true,
},
{
	name = "showCampfireTimer",
	label = "Show Campfire Timer",
	hover = "Fire Pits, Campfires, Night Lights, etc.\nwill show their fuel and the remaining time until the fire goes out.",
	options = BooleanHidden,
	default = true,
},
{
	name = "showLanternTimer",
	label = "Show Lantern Timer",
	hover = "Lanterns will show their fuel and the remaining time until they turn off.",
	options = BooleanHidden,
	default = true,
},
{
	name = "showStarTimer",
	label = "Show Star Caller Timer",
	hover = "Dwarf Stars and Polar Lights will show their remaining time in days and in minutes until they disappear.",
	options = BooleanHidden,
	default = true,
},
{
	name = "showHiddenDuration",
	label = "Unhide Duration",
	hover = "How long the timers will be shown if set to 'Hidden'.",
	options = {
		{description = "0.5s", data = 0.5},
		{description =  "1s", data = 1.0},
		{description =  "2s", data = 2.0},
		{description =  "3s", data = 3.0},
		{description =  "4s", data = 4.0},
		{description =  "5s", data = 5.0},
		{description =  "6s", data = 6.0},
		{description =  "7s", data = 7.0},
		{description =  "8s", data = 8.0},
		{description =  "9s", data = 9.0},
		{description = "10s", data = 10.0},
		{description = "15s", data = 15.0},
		{description = "20s", data = 20.0},
		{description = "25s", data = 25.0},
		{description = "30s", data = 30.0},
		{description = "45s", data = 45.0},
		{description =  "1m", data = 60.0},
		{description =  "2m", data = 120.0},
		{description =  "5m", data = 300.0},
		{description = "10m", data = 600.0},
		{description = "15m", data = 900.0},
		{description = "20m", data = 1200.0},
		{description = "30m", data = 1800.0},
		{description =  "1h", data = 3600.0},
		{description = "3.14h", data = 11309.74, hover = "I doubt you can keep a fire that long without hovering above it."},
	},
	default = 5.0,
},
} -- The End