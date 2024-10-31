extends ExampleSceneRoot

func _on_accessible_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
