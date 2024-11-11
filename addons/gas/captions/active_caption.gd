class_name GASActiveCaption extends RefCounted

var _l: RichTextLabel
var _d: GASAudioCaption

func _init(label: RichTextLabel, data: GASAudioCaption) -> void:
	_l = label
	_d = data

func update(time_in_seconds: float) -> void:
	var time := time_in_seconds * 1000.0
	print(time)
	for i in range(0, floori(_d.caption_timings.size() / 2.0)):
		var lower_bound := _d.caption_timings[i * 2]
		var upper_bound := _d.caption_timings[i * 2 + 1]
		if lower_bound <= time && time <= upper_bound:
			set_text(_d.caption_texts[i])
			return
	set_text()

func set_text(t := "") -> void:
	print(t)
	if t == "":
		_l.visible = false
	else:
		_l.visible = true
		_l.text = "[center]%s[/center]" % t
