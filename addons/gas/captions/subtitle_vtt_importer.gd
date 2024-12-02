@tool
extends EditorImportPlugin

const _REFRESH_RATE := 0.066666667 # 4 frames at 60FPS

func _get_importer_name() -> String:
	return "gas.caption.vtt"

func _get_visible_name() -> String:
	return "VTT Subtitle Importer"

func _get_recognized_extensions() -> PackedStringArray:
	return ["vtt"]

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
		printerr("Import Error (%s): No valid .ogg, .wav, or .mp3 file exists to accompany this file." % source_file)
		return FAILED
	var current_string: PackedStringArray = []
	var lines_in_current_caption := 0
	var current_caption := 0
	var line_no := 1
	var in_style_or_note := false
	var just_started_new_caption := false
	while !file.eof_reached():
		var l := file.get_line().strip_edges()
		if line_no == 1 && l != "WEBVTT":
			printerr("Import Error (%s): First line in file must be \"WEBVTT.\"" % source_file)
			return FAILED
		line_no += 1
		if l == "":
			if in_style_or_note:
				in_style_or_note = false
			continue
		elif in_style_or_note:
			continue
		elif l == "STYLE":
			in_style_or_note = true
			printerr("Import Warning (%s): VTT styles are not currently supported." % source_file)
		elif l.begins_with("NOTE"):
			in_style_or_note = true
		elif l.is_valid_int(): # new caption (optional)
			if current_string.size():
				res.caption_texts.append("\n".join(current_string))
			current_string = []
			lines_in_current_caption = 0
			current_caption += 1
			just_started_new_caption = true
		elif l.contains("-->"): # new timings, new caption
			if !just_started_new_caption:
				if current_string.size():
					res.caption_texts.append("\n".join(current_string))
				current_string = []
				lines_in_current_caption = 0
				current_caption += 1
			else:
				just_started_new_caption = true
			var split := l.split("-->")
			var last_end_time := -1.0 if res.caption_timings.size() == 0 else res.caption_timings[-1]
			var current_start_time := _time_string_to_seconds(source_file, split[0].strip_edges())
			res.caption_timings.append(current_start_time)
			res.caption_timings.append(_time_string_to_seconds(source_file, split[1].strip_edges()))
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

func _time_string_to_seconds(source_file: String, s: String) -> float:
	if s.contains(" "):
		printerr("Import Warning (%s): Position cues are not currently supported." % source_file)
		s = s.split(" ")[0]
	var timing := s.split(":")
	var has_hours := timing.size() == 2
	var hours := int(timing[0]) if has_hours else 0
	var minutes := int(timing[1 if has_hours else 0])
	var second_split := timing[2 if has_hours else 1].split(".")
	var seconds := int(second_split[0])
	var milliseconds := int(second_split[1])
	return milliseconds + 1000 * seconds + 60000 * minutes + 3600000 * hours
