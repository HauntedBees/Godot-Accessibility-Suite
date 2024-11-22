# Godot Accessibility Suite
An attempt at making it as easy for you to follow as many of the guidelines from [gameaccessibilityguidelines.com](https://gameaccessibilityguidelines.com/) as possible in your Godot 4.4 games.

## Installation
Download it from GitHub, place the `addons/gas` folder in your project's `addons` folder, then in Project Settings enable the plugin. If you're on Godot 4.3, just find the typed `Dictionary` properties in the addon and make them regular dictionaries.

## Usage
Run `full_example.tscn` (the default scene if you press `F5` to run the project) to see all of the Suite's features. You can also view the source of each example page to see more usage details.

## Current Status
This was originally written for Godot 3.5, and while certain parts of it have been maintained over the past year as I've worked on my main Godot 4.x project, most of the rest of this suite has fallen behind. My hope is to have it in a presentable state by the end of November 2024.

### Implemented Features
 - Three different ways to adjust game speed.
 - Vibration/haptics intensity scaling.
 - Default theme with spacing added to several container nodes.
 - Control remapping utility methods (example page in progress).
 - Support for providing alternatives to holding down buttons.
 - Support for input cooldowns.
 - Support for adjusting mouse and joystick sensitivity.
 - Scalable font size for `Label` and `RichTextLabel` nodes.
 - Helpers for highlighting important words.
 - Utility for saving the game screen to a file.
 - Saving/loading of accessibility settings.
 - Accessibility Audit Tool that programatically scans scenes and scripts for some accessibility issues (still in progress).
 - Configurable virtual gamepad and keyboards.
 - `.srt` resource importing and a `CaptionedAudioStreamPlayer` node that syncs captions and audio.

### Remaining Features

See the [Issues list](https://github.com/HauntedBees/Godot-Accessibility-Suite/issues), but the main things are:
 - Resizable/rearrangeable Control nodes.
 - Dark, light, and high-contrast themes.
 - Separate volume controls.
 - Full subtitle/caption support.
 - Improve the Accessibility Audit Tool.

## Contributing
If there's a feature you want included in this suite, whether you're a game developer or a game player, create an [issue](https://github.com/HauntedBees/Godot-Accessibility-Suite/issues) for it! My goal is to make a tool helpful for everyone, so the most important thing you can do is let me know how!

And if you would like to contribute to the project with code, please do! All contributions must be made with a permissive MIT-compatible open source license to ensure as many game developers as possible have access to this code.
