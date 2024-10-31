class_name ExampleSceneRoot extends Control

signal change_scene(p: PackedScene, label: String, link: String)

func clean_up() -> void: pass

func _change_scene(b: CategoryButton):
	change_scene.emit(b.scene, b.heading_name, b.link)
