@tool
extends EditorImportPlugin

const _REFRESH_RATE := 0.066666667 # 4 frames at 60FPS

func _get_importer_name() -> String:
	return "gas.caption.srt"

func _get_visible_name() -> String:
	return "Subtitle Importer"

func _get_recognized_extensions() -> PackedStringArray:
	return ["srt"]

func _get_save_extension() -> String:
	return "tres"

func _get_resource_type() -> String:
	return "Resource"

func _get_import_order() -> int:
	return 0

func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
	return []

func _get_priority() -> float:
	return 1.0

func _get_preset_count() -> int:
	return 0

func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	var file := FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FAILED
	var res := GASAudioCaption.new()
	if res.audio == null:
		res.audio = _try_get_with_extension(source_file, ".ogg")
	if res.audio == null:
		res.audio = _try_get_with_extension(source_file, ".wav")
	if res.audio == null:
		res.audio = _try_get_with_extension(source_file, ".mp3")
	if res.audio == null:
		printerr("No valid .ogg, .wav, or .mp3 file exists to accompany %s" % source_file)
		return FAILED
	var current_string: PackedStringArray = []
	var lines_in_current_caption := 0
	var current_caption := 0
	while !file.eof_reached():
		var l := file.get_line().strip_edges()
		if l == "":
			continue
		if l.is_valid_int(): # new caption
			if current_string.size():
				res.caption_texts.append("\n".join(current_string))
			current_string = []
			lines_in_current_caption = 0
			current_caption += 1
		elif l.contains("-->"): # new timings
			var split := l.split("-->")
			var last_end_time := -1.0 if res.caption_timings.size() == 0 else res.caption_timings[-1]
			var current_start_time := _time_string_to_seconds(split[0].strip_edges())
			res.caption_timings.append(current_start_time)
			res.caption_timings.append(_time_string_to_seconds(split[1].strip_edges()))
			if (current_start_time - last_end_time) < _REFRESH_RATE:
				printerr("Import Warning (%s): Caption %d should start at least %1.3f seconds after Caption %d." % [source_file, current_caption, _REFRESH_RATE, current_caption - 1])
		else:
			lines_in_current_caption += 1
			current_string.append(l)
			if lines_in_current_caption > 2:
				printerr("Import Warning (%s): Caption %d is longer than the recommended two lines." % [source_file, current_caption])
	res.caption_texts.append("\n".join(current_string))
	return ResourceSaver.save(res, "%s.%s" % [save_path, _get_save_extension()])

func _try_get_with_extension(source_file: String, new_extension: String) -> AudioStream:
	var new_file = source_file.replace(".srt", new_extension)
	return load(new_file) if FileAccess.file_exists(new_file) else null

func _time_string_to_seconds(s: String) -> float:
	var timing := s.split(":")
	var hours := int(timing[0])
	var minutes := int(timing[1])
	var second_split := timing[2].split(",")
	var seconds := int(second_split[0])
	var milliseconds := int(second_split[1])
	return milliseconds + 1000 * seconds + 60000 * minutes + 3600000 * hours
