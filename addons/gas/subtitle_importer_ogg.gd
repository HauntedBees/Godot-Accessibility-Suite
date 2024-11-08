@tool
extends EditorImportPlugin

func _get_importer_name():
	return "gas.caption.ogg"

func _get_visible_name():
	return "OGG Importer"

func _get_recognized_extensions():
	return ["ogg"]

func _get_resource_type():
	return "AudioStreamOggVorbis"

func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	# TODO: all of this
	return OK
