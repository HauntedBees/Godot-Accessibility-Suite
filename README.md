# Godot Accessibility Suite
An attempt at making it as easy for you to follow as many of the guidelines from [gameaccessibilityguidelines.com](https://gameaccessibilityguidelines.com/) as possible.

Guidelines not listed below have not been evaluated yet, or are things that cannot be solved with a plugin or script (or at the very least, ***I*** couldn't figure out how to solve with a plugin or script). The only way I can think of to handle something like [providing Simple Control Schemes](https://gameaccessibilityguidelines.com/provide-very-simple-control-schemes-that-are-compatible-with-assistive-technology-devices-such-as-switch-or-eye-tracking/) is for the developer to be conscious of this need and just ***not*** programming in complicated control schemes. This suite is intended to make accessible design decisions as easy as possible for game developers, but "as easy as possible" doesn't always mean "easy." It's usually harder to [allow interfaces to be rearranged](gameaccessibilityguidelines.com/allow-interfaces-to-be-rearranged) than it is to just give the players one static interface. Every game is different and what is trivial to implement in one game may be impossible to implement in another.

You should consult resources like the [Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/advanced/) and the [AbleGamers APX](https://accessible.games/accessible-player-experiences/) to learn what's right for your game, and having people with a variety of accessibility needs playtesting your game and giving you feedback will be even more valuable. I am not associated with any of theese associations or websites and I am not a professional or expert on video game accessibility.

## Status
This suite is a work in progress and will be built upon as I develop my own game projects in Godot. Every accessibility feature I add to my games that can be abstracted into general purpose code will be added here.

## Contributing
If you would like to add to the project, by all means, go for it! All contributions must be made with a permissive open source license to ensure as many game developers as possible have access to this code.

# Usage
This suite is probably not entirely usable yet, even for the features that are already implemented. The intention is that certain functionalities will be grouped together and developers will be able to simply copy those script files into their own projects. It is possible that making this whole thing a plugin might be a better idea in the long run. An example project and usage notes for each feature will be added eventually.

# Features (based on the Game Accessibility Guidelines as they existed on 1FEB2022)

## [Controller Remapping](https://gameaccessibilityguidelines.com/allow-controls-to-be-remapped-reconfigured/)
`GASInput.remap_action(action:String, event:InputEvent)` will update a Godot action (as seen in the **Input Map** in **Project Settings**) to a new value. This supports both keyboard and gamepad inputs concurrently, so if `ui_accept` is configured to the "Start" button on a gamepad as well as the Enter key on a keyboard, calling `GASInput.remap_action("ui_accept", user_pressed_the_spacebar_key)` will replace the Enter key binding with a Spacebar key binding, but leave the "Start" button binding unchanged.

## [Cooldown on Inputs](https://gameaccessibilityguidelines.com/include-a-cool-down-period-post-acceptance-delay-of-0-5-seconds-between-inputs/)
`GASInput.is_action_just_pressed(action:String)` returns `true` when the action is just pressed (based on the native `Input.is_action_just_pressed` method) **unless** it was pressed within the last `COOLDOWN_LENGTH` seconds (default is 0.5), in which case it returns `false`.

# To Be Implemented/Considered

## [Control Sensitivity](https://gameaccessibilityguidelines.com/include-an-option-to-adjust-the-sensitivity-of-controls/)
Will need to handle analog sticks (inverting y, inverting x, dead zones, sensitivity) and mice.

## [Interactive Element Spacing](https://gameaccessibilityguidelines.com/ensure-interactive-elements-virtual-controls-are-large-and-well-spaced-particularly-on-small-or-touch-screens/)
Will probably need to create some sort of "padding" Node that buttons can go in to ensure reasonable spaces around them.

## [Haptics Toggles](https://gameaccessibilityguidelines.com/include-toggle-slider-for-any-haptics/)
An Autoload function to replace `Input.start_joy_vibration` based on user-defined limits.

## [Adjust Game Speed](https://gameaccessibilityguidelines.com/include-an-option-to-adjust-the-game-speed/)
Perhaps an Autoload function like `adjust_speed(delta)` that takes the delta value from `_process` or `_physics_process` and adjusts it based on the specified game speed.

## [Support Windowed Mode](https://gameaccessibilityguidelines.com/if-producing-a-pc-game-support-windowed-mode-for-compatibility-with-overlaid-virtual-keyboards/)
Some sort of plug-and-play node to toggle between windowed and full screen modes.

## [Toggles instead of Holding Buttons](https://gameaccessibilityguidelines.com/avoid-provide-alternatives-to-requiring-buttons-to-be-held-down/)
May be able to write some `is_held_down` function that returns true if the toggle is set OR if the button is actively held down.

## [Support Portrait and Landscape Mode](https://gameaccessibilityguidelines.com/allow-play-in-both-landscape-and-portrait/)
May be able to write some sort of wrapper container to handle this automatically.

## [Provide Gameplay Thumbnails in Saves](https://gameaccessibilityguidelines.com/provide-gameplay-thumbnails-with-game-saves/)
A helper function to generate the thumbnail based on a provided camera and save/load that thumbnail as a texture to be displayed as needed.

## [Separate Volume Controls for Sounds/Music/Voice/etc.](gameaccessibilityguidelines.com/provide-separate-volume-controls-or-mutes-for-effects-speech-and-background-music)
No idea how sound stuff works in Godot yet, so not sure how to implement this as of now.

## [Subtitles](gameaccessibilityguidelines.com/provide-separate-volume-controls-or-mutes-for-effects-speech-and-background-music), [Subtitles](https://gameaccessibilityguidelines.com/provide-subtitles-for-supplementary-speech/), [Subtitles](https://gameaccessibilityguidelines.com/provide-captions-or-visuals-for-significant-background-sounds/), [Subtitles](https://gameaccessibilityguidelines.com/provide-a-visual-indication-of-who-is-currently-speaking/), [Subtitles](https://gameaccessibilityguidelines.com/allow-subtitlecaption-presentation-to-be-customised/).
Related to the sound stuff; create some helper function that accepts both a sound file _and_ a relevant subtitle/caption, then plays the sound and displays the subtitle. Ideally allow for multiple types of subtitle (i.e. spoken word, supplementary speech, environmental noises). For [visual indication of who is currently speaking](https://gameaccessibilityguidelines.com/provide-a-visual-indication-of-who-is-currently-speaking/) allow passing of parameters like font color, speaker name/image, and/or position.

## [Stereo/Mono Audio Toggle](https://gameaccessibilityguidelines.com/provide-a-stereomono-toggle/)
Implementation will depend on other sound functionalities.

## [Saving Settings](https://gameaccessibilityguidelines.com/provide-a-stereomono-toggle/)
Functions to export all custom settings into a dictionary - which can then be saved with other player data in the game's save logic - and then restored.

## [Auto-Aim](https://gameaccessibilityguidelines.com/include-assist-modes-such-as-auto-aim-and-assisted-steering/)
Might be possible to create something like an "auto aim target" node with a certain radius that, when the cursor (controlled by mouse or analog stick) is within that radius, will snap to the center of the node.