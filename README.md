# Godot Accessibility Suite
An attempt at making it as easy for you to follow as many of the guidelines from [gameaccessibilityguidelines.com](https://gameaccessibilityguidelines.com/) as possible in your Godot 4.x games.

Guidelines not listed below have not been evaluated yet, or are things that cannot be solved with a plugin or script (or at the very least, ***I*** couldn't figure out how to solve with a plugin or script). The only way I can think of to handle something like [providing Simple Control Schemes](https://gameaccessibilityguidelines.com/provide-very-simple-control-schemes-that-are-compatible-with-assistive-technology-devices-such-as-switch-or-eye-tracking/) is for the developer to be conscious of this need and just ***not*** program in complicated control schemes. This suite is intended to make accessible design decisions as easy as possible for game developers, but "as easy as possible" doesn't always mean easy. It's usually harder to [allow interfaces to be rearranged](gameaccessibilityguidelines.com/allow-interfaces-to-be-rearranged) than it is to just give the player one static interface, for example. Every game is different and what is trivial to implement in one game may be impossible to implement in another.

You should consult resources like the [Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/advanced/) and the [AbleGamers APX](https://accessible.games/accessible-player-experiences/) to learn what's right for your game, and having people with a variety of accessibility needs playtesting your game and giving you feedback will be even more valuable. I am not associated with any of theese associations or websites and I am not a professional or expert on video game accessibility.

## Status
This suite is a work in progress and will be built upon as I develop my own game projects in Godot. Every accessibility feature I add to my games that can be abstracted into general purpose code will be added here.

## Contributing
If you would like to add to the project, by all means, go for it! All contributions must be made with a permissive open source license to ensure as many game developers as possible have access to this code.

# Table of Contents

 - [Usage](#usage)
 - [Accessibility Audit](#accessibility-audit)
 - [Custom Nodes](#custom-nodes)
   - [GASRichTextLabel](#gasrichtextlabel)
   - [GASContainer](#gascontainer)
 - [Virtual Gamepad](#virtual-gamepad)
 - [Other Features](#other-features)
   - [Controller Remapping](#controller-remapping)
   - [Action Config](#action-config)
   - [Game Thumbnails with Game Saves](#game-thumbnails-with-game-saves)
   - [Cooldown on Inputs](#cooldown-on-inputs)
   - [Toggles instead of Holding Buttons](#toggles-instead-of-holding-buttons)
   - [Adjust Game Speed](#adjust-game-speed)
 - [To Be Implemented/Considered](#to-be-implementedconsidered)

# Usage
Create the folder `res://addons/gas/` in your project and copy the contents of this repository's `addons/gas` folder into there. Then in Godot go to **Project Settings** > **Plugins** and enable **Godot Accessibility Suite**. Usage information for each feature is described in that feature's summary below. An example project will be added eventually.

# Accessibility Audit
An "Accessibility" tab is added to the Bottom Panel with two buttons:
 - **Audit Scene**: Scans through all Nodes in the current scene for accessibility issues.
 - **Audit Resources**: Scans through all Resources in the project for accessibility issues.
These audits will certainly miss things if you're doing custom/creative/weird stuff, so as with everything else in this Suite, this should be used as just one of many tools in your mission to make your game accessible. These audits will currently find:
 - [Easily Readable Font Size](https://gameaccessibilityguidelines.com/use-an-easily-readable-default-font-size/) in `Button`, `Label`, and `RichTextLabel` Nodes (Audit Scene) and `DynamicFont` and `BitmapFont` Resources (Audit Resources).
 - [Well Spaced Interactive Elements](https://gameaccessibilityguidelines.com/ensure-interactive-elements-virtual-controls-are-large-and-well-spaced-particularly-on-small-or-touch-screens/) on `Button` Nodes inside `HBoxContainer` and `VBoxContainer` Nodes (Audit Scene).

# Custom Nodes

## GASRichTextLabel
A **RichTextLabel** built for easy font size readjusting. In a regular **RichTextLabel**, if your text takes up more space than the control itself, it will either add a scrollbar (when `scroll_active` is true) or the overflowing text will be cut off, possibly with some percentage of the overflow still visible at the bottom of the control. When overflowing text is present in a **GASRichTextLabel** control, no scroll bar will appear, and the text will be cleanly cut (with no partial text visible); the control's `advance()` function can be called to move to the next part of the overflowed text. For example, if the control only allowed around a dozen characters, and the text is set to "Hey everybody, I'm going to the store for some milk!" the player would first see "Hey everybody," after `advance()` is called, they would then see "I'm going to" followed by "the store for" and then "some milk!" `advance()` will return `true` as long as more overflowing text is available to be displayed, and will return `false` at the last chunk of text and when called after that.

The **GASRichTextLabel** also has a `font_size` property that will automamatically adjust the label's font's size. This will not affect any other controls, even ones using the same `DynamicFont`. The `vision_minimum_font_size` config option will force the control to start at at least that font size, even if the control has a different font size specified in code or in its scene, but it can be resized to a smaller font by changing the `font_size` property. However, [a minimum font size of 28 is recommended, and is the default value for this config setting](https://gameaccessibilityguidelines.com/use-an-easily-readable-default-font-size/), so while you can allow the player to manually set a lower font size, your controls should always be at least this size.

Finally, a `translation_key` property exists, and writing `control.translation_key = "x"` is equivalent to writing `control.text = tr("x")`.

### Limitations
This plays nice with some bbcode, with the same caveats as regular **RichTextLabel** controls:
 - Tags must be closed in first-in-first-out order.
   - Bad: `[right][s][b]hey[/right][/b][/s]`
   - Good: `[right][s][b]hey[/b][/s][/right]`
 - Certain combinations don't work together, like `[u][s]strikethrough and underline[/s][/u]`.

Additionally, not all bbcode tags are supported:
 - Currently Supported: `underline`, `strikethrough`, `url`, `url (ref)`, `color`
 - Probably Can't Support (due to Godot limitations): `bold`, `italics`, `code`, `font`
 - Almost Definitely Can't Support: `center`, `right`, `fill`, `indent`, `image`, `resized image`, `table`, `cell`

## GASContainer
Does not *resize* or *scale* child nodes to fit the container, but does enforce alignment rules and [a minimum separation between the nodes](https://gameaccessibilityguidelines.com/ensure-interactive-elements-virtual-controls-are-large-and-well-spaced-particularly-on-small-or-touch-screens/). **Known Issue**: The actual container size and position have no relation to the contents.

# Virtual Gamepad
For touch-screen based games, adding a virtual gamepad to the screen is common. The Virtual Gamepad in this Suite is designed to be easily configurable by the developer, and just as easily configurable by players to accommodate accessibility needs, by allowing the player to:

* resize and reposition all gamepad elements
* choose whether to have analog sticks/directional pads be dynamic (when the player presses down anywhere on the screen, the center of the movement control appears there) or fixed (stays at a specified position)
* set buttons and movement controls that might be pressed rapidly or held down to be *toggle-based* so that they can just press the button once to simulate the button being held or rapidly pressed, then press again to stop the action

## Usage
Add a *GASVirtualGamepad* node to your scene, size it as appropriate, then add the relevant *GASVirtualButton*, *GASVirtualDPad*, and *GASVirtualAnalogStick* nodes and size/position them as your intended default positions. Players will be able to reposition and resize these buttons in **Edit Mode** but they will not be able to add or remove buttons. If different parts of your game need different virtual gamepads, create a different *GASVirtualGamepad* for each one. Configuration is stored in a `gas_virtualgamepad_NODE_NAME.cfg` file in the `user://` directory, so use different names for different gamepad configurations, and use the same name for a given gamepad across multiple scenes.

## Limitations
To scale the gamepad controls, you must use the `rect_scale` property (modified in `Control > Rect > Scale` in the **Inspector** tab, or by using **Scale Mode** in the main 2D view); resizing the `rect_size` property will not work as expected.

## Nodes

### GASVirtualGamepad
The container node for your virtual gamepad. All children of a *GASVirtualGamepad* node should be virtual inputs as described below. The position and scale of these nodes will be the default values when a new player begins the game. It is recommended that you take advantage of the customization features by adding an "edit gamepad configuration" option to your options menu (and having an options menu in your game) so that players can reposition and resize the gamepad as needed. 

#### mobile_only
Set this in the Godot Editor; when `true`, the gamepad will default to being invisible if `OS.has_feature("mobile")` returns false. Otherwise, the gamepad will default to being visible regardless of OS. Useful if you're making mobile and desktop OS builds from the same Godot project. If you're building for the web (with the `HTML5` export), the mobile check will likely fail, so this `mobile_only` being `true` will hide the gamepad in web builds, even if accessed from a mobile device.
#### translation_prefix
When in edit mode, some controls might have options above them, like to set a button's toggle state or make an analog stick placed dynamically (described in more detail below). These options will have plain text like "Toggle?" to label them. If your game is using Godot's built-in translation functionality, these labels will be automatically translated for you. The three option labels are:
 * Toggle
 * Dynamic Position
 * Deadzone
If you set the `translation_prefix` to an empty string, these values will be shown to the player - unless your translation CSV file has an entry with those labels as keys in them. If you choose a prefix (like `GAMEPADEDIT_`), then the keys will be prefixed (like `GAMEPADEDIT_Toggle`), so you can have in your CSV, for example:

| keys                         |  en-us  |   en-es  |
| GAMEPADEDIT_Dynamic Position | Dynamic | Dinámico |

#### edit_mode
Set `edit_mode` to true to allow players to resize and reposition game inputs. In your game's options menu or equivalent, you'll be able to toggle this variable as needed.
#### save_setup()
This will save the player's custom configuration to `gas_virtualgamepad_NODE_NAME.cfg`. You should call this when the player wants to save their changes in your game's options menu.
#### load_setup()
This will load the player's custom configuration, or do nothing if one has not been defined. This is called in the `_ready` function so it does not need to be called manually, but can be if needed - i.e. if the player is editing their configuration and clicks a cancel button instead of a save button.
#### restore_defaults()
This will set the configuration back to the default values: what you specified in the scene. This change will not be saved unless `save_setup` is also called. It is recommended to have a button in your options menu/control edit screen for this in case the player accidentally moves a button off-screen or makes some other hard-to-undo mistake.

### GASVirtualControl
All buttons, analog sticks, and d-pads inherit from *GASVirtualControl* which has the following export variables:

#### can_be_toggled
This should be set by the developer; when true, players can make this input toggle-able, which is desirable for movement controls and buttons that are likely to be held down or pressed repeatedly. It is not recommended for actions that should not be executed repeatedly, like a Pause button or a "talk to the character in front of you or advance the dialog" button.
#### is_toggle
A default value can be set by the developer but this will be configurable by players in Edit Mode if `can_be_toggled` is true.

### GASVirtualButton
It's a button you can press. By default, this will emit its specified `action` when pressed down. It can be configured to repeat the action emission every `repeat_frequency` seconds when held or when toggled.

#### texture
The texture the button should have. Set it to whatever you want your button to look like.
#### action
The action to be executed when pressing the button.
#### is_circle
When `true`, the radius of the button will be used to ensure that the player's finger is actually in the button and not pressing the corner of the square. **TODO: actually implement this, remove it if it doesn't matter, or use an actual click mask.**
#### repeat_frequency
If non-zero, every `repeat_frequency` seconds the action will be released and pressed again. If you have calls to `Input.is_action_just_pressed` in your code, this will ensure that that they return `true` regularly as the button is held down. If you only ever use `Input.is_action_pressed`, this is not needed, as the action will be pressed as long as the button is held down regardless.
#### pressed_tint
The color the button should be tinted when it's pressed. **TODO: have a separate `pressed_texture` maybe.**

### GASVirtualAnalogStick
It's an analog stick. It will emit up to two actions based on the direction it is tilted in.

#### front_texture, back_texture
The textures for the analog stick and the back of the analog stick.

#### action_left, action_right, action_up, action_down
The actions to be emitted when the stick is moved in the respective directions.
#### dead_zone
Movements below this percentage of the control's radius won't trigger actions.
#### max_zone
Movements above this percentage of the control's radius will be clamped to this.
#### fixed_position
When false, the control will be invisible until the player presses somewhere on the screen not occupied by another button. After pressing down, this control will immediately appear under their finger and then can be moved from that position. It will disappear again when the player lifts their finger. **Only one control can be set to `fixed_position = false` at a time.**

### GASVirtualDPad
It's a directional pad. It will emit up to two actions based on the direction it is pressed.
#### left_texture, right_texture, up_texture, down_texture
The textures for the four directions.
#### button_distance
How far apart the direction buttons should be from each other. Set this to 0 if you want this to look like one connected pad.
#### action_left, action_right, action_up, action_down, dead_zone, max_zone, fixed_position
Same as the variables for *GASVirtualAnalogStick*.
#### pressed_tint
The color a direction button should be tinted when it's pressed. **TODO: have separate `pressed_texture`s maybe.**
#### diagonals_enabled:
Do you want this d-pad going in eight directions or four?


# Other Features

## [Controller Remapping](https://gameaccessibilityguidelines.com/allow-controls-to-be-remapped-reconfigured/)
`GASInput.remap_action(action:String, event:InputEvent)` will update a Godot action (as seen in the **Input Map** in **Project Settings**) to a new value. This supports both keyboard and gamepad inputs concurrently, so if `ui_accept` is configured to the "Start" button on a gamepad as well as the Enter key on a keyboard, calling `GASInput.remap_action("ui_accept", user_pressed_the_spacebar_key)` will replace the Enter key binding with a Spacebar key binding, but leave the "Start" button binding unchanged. If you want to save controller mappings, use `GASInput.get_actions_as_json()` to get a JSON string containing a dictionary of every action and its mappings. Save this however you like with the rest of your save data (this is not included in `GASConfig.save()`). After loading the JSON string, use `GASInput.restore_actions_from_json()` to set the controls up again.

## [Action Config](https://gameaccessibilityguidelines.com/allow-controls-to-be-remapped-reconfigured/)
The `GASActionConfig` scene can be dropped anywhere in your project and will function as an out-of-the-box pre-made controller/input remapping screen. Use a `theme` to style it, slap it in your existing options menu if you have one, and players will be able to remap their controls without you having to write any code or design anything. This control automatically reads from the `InputMap` to get available actions, but unless you want users to edit things like `ui_up` and `ui_focus_prev`, you should use the **Action Names** export (described below) to make things more presentable.
**NOTE:** This is currently broken in Godot 4.0 beta and is in the process of being fixed.

### Exports / Script Variables

 - **Number of Columns**: How many columns your control remapping screen should be. This control doesn't have scrolling, so if you don't want to add your own scroller around this and you have a lot of controls, set this to 3.
 - **Action Names**: A dictionary of all of your game's actions as keys; the values are the names that will be displayed to the player. So if you have `ui_up: Move Forward` then the user will see **Move Forward** to describe the `ui_up` action. As you add new actions to your project, this will automatically update with them (although you may need to close and reopen the scene the `GASActionConfig` is instanced in). **Note:** If you *remove* actions from your project, they will not be automatically removed here, so this must be done manually.
 - **Sort Order**: An array of all of your game's actions. Rearrange them to show how they'll be sorted. If you have multiple columns, this fills out rows first, *then* columns.
 - **Hide Default UI Actions**: If you don't want to show the default actions Godot adds and doesn't let you delete - like `ui_home` and `ui_page_down`, check this.

### Additional Notes

 - This control is a **scene**, not a **node**, so you'll need to add it to your scene with **Instance Child Scene**, not **Add Child Node**.
 - This control uses `GASInput` behind the scenes to remap actions (described above). User configuration will last for the rest of the game; if you wish to have these settings retained after reopening the game, use `GASInput.get_actions_as_json()` and `GASInput.restore_actions_from_json()` with your own saving logic.
 - There are icons for keyboard, mouse, and gamepad input. As soon as the user presses a gamepad button or keyboard/mouse button, the controls will switch to the appropriate icons; a player can have both a keyboard/mouse input and a gamepad input for the same action.
 - Gamepad icons will try to update to Xbox, Playstation, or Switch controls based on the current controller.
 - If you wish to use different images for inputs, you can replace `res://addons/gas/ControlConfig/Inputs.png` with another file. Individual inputs should be `128x128`. Current images are sourced from [Free Controller Prompts - Xbox, Playstation, Switch, PC](https://opengameart.org/content/free-controller-prompts-xbox-playstation-switch-pc) by [Terazilla](https://opengameart.org/users/terazilla), licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/), so they may be used freely for any reason without permission, payment, or attribution.

## [Game Thumbnails with Game Saves](https://gameaccessibilityguidelines.com/provide-gameplay-thumbnails-with-game-saves/)
`GASUtils.save_screen(name:String)` will save the current viewport texture to `user://save_{name}.png`, overwriting any existing file with that name. This can then be accessed with `GASUtils.load_screen_as_texture_rect(name:string)`, which returns a `TextureRect` node to be easily dropped into your game scene. `GASUtils.load_screen_as_texture` and `GASUtils.load_screen_as_image` also exist if you want the raw `ImageTexture` or `Image` instead. Alternatively, `GAS_Utils.get_screen()` will return the current viewport image as an `Image`.

Both `load_screen_as_texture_rect` and `load_screen_as_texture` take additional optional arguments, `width:float`, `height:float`, and `keep_aspect_ratio:bool`, that allow you to resize the texture (by default the saved image is half the size of the viewport). Calling `GASUtils.load_screen_as_texture("test", 320, 0, true)` will ensure the image keeps its original aspect ratio, with a maximum width of 320px. Likewise, `GASUtils.load_screen_as_texture("test", 0, 320, true)` will keep the aspect ratio with a maximum height of 320px. `GASUtils.load_screen_as_texture("test", 320, 320, false)` will resize the image to 320x320, regardless of its original aspect ratio. `GASUtils.load_screen_as_texture("test", 320, 320, true)` will maintain the aspect ratio while ensuring that neither the width nor height exceed 320px.

## [Cooldown on Inputs](https://gameaccessibilityguidelines.com/include-a-cool-down-period-post-acceptance-delay-of-0-5-seconds-between-inputs/)
`GASInput.is_action_just_pressed(action:String)` returns `true` when the action is just pressed (based on the native `Input.is_action_just_pressed` method) **unless** it was pressed within the last `COOLDOWN_LENGTH` seconds (default is 0.5), in which case it returns `false`.

## [Toggles instead of Holding Buttons](https://gameaccessibilityguidelines.com/avoid-provide-alternatives-to-requiring-buttons-to-be-held-down/)
Add an action to the `GASConfig.input_toggle_actions` array and it will be handled by `GASInput._process` and `GASInput._input`, ensuring that a player triggering the action will trigger one `Input.is_action_just_pressed` on the first press, then the action will remain pressed until the player triggers it next. 

## [Adjust Game Speed](https://gameaccessibilityguidelines.com/include-an-option-to-adjust-the-game-speed/)
Setting `GASConfig.core_game_speed` will adjust `Engine.time_scale` automatically. As that is a built-in Engine variable, the main benefit of using `GASConfig.core_game_speed` instead is that the value will be saved with other accessibility settings and automatically loaded when the game begins. Default value is **1.0**; to run the game at half speed, set it to **0.5**, to run at double speed, set it to **2.0**, etc.

# To Be Implemented/Considered

## [Control Sensitivity](https://gameaccessibilityguidelines.com/include-an-option-to-adjust-the-sensitivity-of-controls/)
Will need to handle analog sticks (inverting y, inverting x, dead zones, sensitivity) and mice.

## [Interactive Element Spacing](https://gameaccessibilityguidelines.com/ensure-interactive-elements-virtual-controls-are-large-and-well-spaced-particularly-on-small-or-touch-screens/)
Will probably need to create some sort of "padding" Node that buttons can go in to ensure reasonable spaces around them.

## [Haptics Toggles](https://gameaccessibilityguidelines.com/include-toggle-slider-for-any-haptics/)
An Autoload function to replace `Input.start_joy_vibration` based on user-defined limits.

## [Support Windowed Mode](https://gameaccessibilityguidelines.com/if-producing-a-pc-game-support-windowed-mode-for-compatibility-with-overlaid-virtual-keyboards/)
Some sort of plug-and-play node to toggle between windowed and full screen modes.

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

## Some sort of in-editor checklist
Show all items (even the ones not included in this plugin) in a checklist or kanban board with room to leave comments and such.
