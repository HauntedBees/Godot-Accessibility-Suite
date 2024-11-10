@tool
class_name GASSubtitleImporter extends EditorImportPlugin

func _get_importer_name() -> String:
	return "gas.caption.srt"

func _get_visible_name() -> String:
	return "Subtitle Importer"

func _get_recognized_extensions() -> PackedStringArray:
	return ["srt"]

func _get_save_extension() -> String:
	return "res"

func _get_resource_type() -> String:
	return "StandardMaterial3D"

func _get_priority() -> float:
	return 1.0

func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	var file := FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FAILED
	var res := StandardMaterial3D.new()
	#var res := GASAudioCaption.new()
	#if res.audio == null:
		#res.audio = _try_get_with_extension(source_file, ".ogg")
	#if res.audio == null:
		#printerr("No valid .ogg, .wav, or .mp3 file exists to accompany %s" % source_file)
		#return FAILED
	return ResourceSaver.save(res, save_path, ResourceSaver.FLAG_COMPRESS)

func _try_get_with_extension(source_file: String, new_extension: String) -> AudioStream:
	var new_file = source_file.replace(".srt", new_extension)
	return load(new_file) if FileAccess.file_exists(new_file) else null
