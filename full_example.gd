class_name FullExample extends Panel

@onready var _info: AccessibleRichTextLabel = %ContentInfo
@onready var _content: PanelContainer = %ContentContainer

func change_scene(p: PackedScene, label: String, link: String) -> void:
	for c: ExampleSceneRoot in _content.get_children():
		_content.remove_child(c)
		c.clean_up()
		c.queue_free()
	_content.add_child(p.instantiate())
	if link == "":
		_info.text = label
	else:
		_info.text = "%s ([url=%s]More Info[/url])" % [label, link]

func _on_content_info_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
