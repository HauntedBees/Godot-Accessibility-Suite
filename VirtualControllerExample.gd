extends Control

func _on_CheckButton_pressed(): $GASVirtualGamepad.edit_mode = $Buttons/CheckButton.pressed
func _on_SaveButton_pressed(): $GASVirtualGamepad.save_setup()
func _on_LoadButton_pressed(): $GASVirtualGamepad.load_setup()
func _on_DefaultButton_pressed(): $GASVirtualGamepad.restore_defaults()
