class_name FullExample extends Panel

const _PLACEHOLDER := preload("res://example_scenes/placeholder.tscn")

@onready var _info: AccessibleRichTextLabel = %ContentInfo
@onready var _content: PanelContainer = %ContentContainer
@onready var _btn_home: TextureButton = %Home
@onready var _btn_motor: TextureButton = %Motor
@onready var _btn_cognitive: TextureButton = %Cognitive
@onready var _btn_vision: TextureButton = %Vision
@onready var _btn_hearing: TextureButton = %Hearing
@onready var _btn_speech: TextureButton = %Speech
@onready var _btn_general: TextureButton = %General
@onready var _back_button: Button = %BackButton
@onready var _scene_path: AccessibleLabel = %ScenePath

var _current_back: CategoryTextureButton

func _ready() -> void:
	var buttons := [_btn_home, _btn_motor, _btn_cognitive, _btn_vision, _btn_hearing, _btn_speech, _btn_general]
	for btn: CategoryTextureButton in buttons:
		btn.pressed.connect(func() -> void:
			btn.button_pressed = true
			_current_back = btn
			change_scene(btn.scene, btn.heading_name, btn.link)
			for b: CategoryTextureButton in buttons:
				if b != btn:
					b.button_pressed = false
		)

func change_scene(p: PackedScene, label: String, link: String) -> void:
	for c: ExampleSceneRoot in _content.get_children():
		_content.remove_child(c)
		c.clean_up()
		c.queue_free()
	var c: ExampleSceneRoot = _PLACEHOLDER.instantiate() if p == null else p.instantiate()
	c.change_scene.connect(change_scene)
	_content.add_child(c)
	_scene_path.text = "" if p == null else p.resource_path
	if link == "":
		_info.text = label
		_back_button.visible = false
	else:
		_info.text = "%s ([url=%s]More Info[/url])" % [label, link]
		_back_button.visible = true

func _on_content_info_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func _on_back_button_pressed() -> void:
	if _current_back:
		_current_back.pressed.emit()
