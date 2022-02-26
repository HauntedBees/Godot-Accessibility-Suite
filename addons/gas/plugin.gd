tool
extends EditorPlugin

const FONT_MSG := "https://gameaccessibilityguidelines.com/use-an-easily-readable-default-font-size/"
const SPACING_MSG := "https://gameaccessibilityguidelines.com/ensure-interactive-elements-virtual-controls-are-large-and-well-spaced-particularly-on-small-or-touch-screens/"

var profiler:VBoxContainer
var result_text:RichTextLabel
var errors := []
var goods := []
var nodes_scanned := 0

func _enter_tree():
	add_autoload_singleton("GASConfig", "res://addons/gas/GASConfig.gd")
	add_autoload_singleton("GASInput", "res://addons/gas/GASInput.gd")
	add_custom_type("GASContainer", "Control", preload("res://addons/gas/GASContainer.gd"), get_editor_interface().get_base_control().get_icon("GridContainer", "EditorIcons"))
	add_custom_type("GASVirtualGamepad", "Control", preload("res://addons/gas/GASVirtualGamepad/GASVirtualGamepad.gd"), get_editor_interface().get_base_control().get_icon("Button", "EditorIcons"))
	add_custom_type("GASVirtualButton", "Control", preload("res://addons/gas/GASVirtualGamepad/GASVirtualButton.gd"), get_editor_interface().get_base_control().get_icon("Button", "EditorIcons"))
	add_custom_type("GASVirtualAnalogStick", "Control", preload("res://addons/gas/GASVirtualGamepad/GASVirtualAnalogStick.gd"), get_editor_interface().get_base_control().get_icon("Button", "EditorIcons"))
	add_custom_type("GASVirtualDPad", "Control", preload("res://addons/gas/GASVirtualGamepad/GASVirtualDPad.gd"), get_editor_interface().get_base_control().get_icon("Button", "EditorIcons"))
	profiler = VBoxContainer.new()
	
	var buttons := HBoxContainer.new()
	buttons.size_flags_horizontal = 3
	profiler.add_child(buttons)
	
	var profile_button = Button.new()
	profile_button.size_flags_horizontal = 3
	profile_button.text = "Audit Scene"
	profile_button.connect("pressed", self, "_audit_scene")
	buttons.add_child(profile_button)
	
	var profile_resources = Button.new()
	profile_resources.size_flags_horizontal = 3
	profile_resources.text = "Audit Project Resources"
	profile_resources.connect("pressed", self, "_audit_resources")
	buttons.add_child(profile_resources)
	
	result_text = RichTextLabel.new()
	result_text.size_flags_horizontal = 3
	result_text.size_flags_vertical = 3
	result_text.rect_min_size = Vector2(10, 100)
	result_text.selection_enabled = true
	result_text.bbcode_enabled = true
	result_text.bbcode_text = "This Accessibility Profiler will scan through all nodes in the current Scene to check for some common accessibility issues. Note that this [u]will not[/u] identify issues with Nodes created via code."
	result_text.connect("meta_clicked", self, "_on_link_click")
	profiler.add_child(result_text)
	
	add_control_to_bottom_panel(profiler, "Accessibility")

func _exit_tree():
	remove_autoload_singleton("GASInput")
	remove_autoload_singleton("GASConfig")
	remove_custom_type("GASContainer")
	remove_custom_type("GASVirtualGamepad")
	remove_custom_type("GASVirtualButton")
	remove_custom_type("GASVirtualAnalogStick")
	remove_custom_type("GASVirtualDPad")
	remove_control_from_bottom_panel(profiler) # TODO: why doesn't this work?? :(
	profiler.queue_free() # TODO: this throws an error :'(

func _on_link_click(meta): OS.shell_open(str(meta))

func _audit_scene():
	var ei := get_editor_interface()
	if ei == null:
		result_text.bbcode_text = "[color=red]Could not find Editor Interface.[/color]"
		return
	var cs := ei.get_edited_scene_root()
	if cs == null:
		result_text.bbcode_text = "[color=red]Please select a Scene with at least one Node to begin.[/color]"
		return
	errors = []
	goods = []
	nodes_scanned = 0
	result_text.bbcode_text = "Beginning Audit."
	process_node(cs, cs)
	_display_audit_results("Node")
func _audit_resources(path := "res://", is_first := true):
	var d:Directory = Directory.new()
	if d.open(path) != OK:
		errors.append("Unable to open %s directory." % path)
		if is_first: result_text.bbcode_text = "[color=red]Unable to open %s directory.[/color]" % path
		return
	if is_first:
		result_text.bbcode_text = "Beginning Audit."
		errors = []
		goods = []
		nodes_scanned = 0
	print("Stepping through %s" % path)
	d.list_dir_begin(true, true)
	var i := d.get_next()
	while i != "":
		if d.current_is_dir(): _audit_resources("%s%s/" % [path, i], false)
		else:
			if i.ends_with(".tres"):
				nodes_scanned += 1
				print("Checking %s%s" % [path, i])
				var r:Resource = load("%s%s" % [path, i])
				process_resource("%s%s" % [path, i], r)
			#else: print("Skipping %s; not a recognized resource file." % i)
		i = d.get_next()
	if is_first: _display_audit_results("Resource")

func _display_audit_results(noun:String):
	var response := ""
	for e in errors: response += "\n[color=red]%s[/color]" % e
	if response == "": response = "None! :)"
	var good_response := ""
	for g in goods: good_response += "\n%s" % g
	if good_response == "": good_response = "N/A"
	var noun_suffixed = noun if nodes_scanned == 1 else "%ss" % noun
	result_text.bbcode_text = "Audit Complete (%s %s Audited)\n Issues Found: %s\n Passed Checks: %s" % [nodes_scanned, noun_suffixed, response, good_response]

func process_resource(name:String, r:Resource):
	if r is Font:
		var fh := get_font_size(r)
		if fh < 28: errors.append("%s: [url=%s]Font Size should be at least 28px[/url] (current value is %spx)." % [name, FONT_MSG, fh])
		else: goods.append("%s: [url=%s]Font Size is %spx[/url]."% [name, FONT_MSG, fh])

func process_node(root:Node, n:Node):
	var name := root.get_path_to(n)
	result_text.bbcode_text = "Processing %s" % name
	nodes_scanned += 1
	if n is BaseButton || n is Label:
		var fh := get_font_size((n as Control).get_font("font"))
		if fh < 28: errors.append("%s: [url=%s]Font Size should be at least 28px[/url] (current value is %spx)." % [name, FONT_MSG, fh])
		else: goods.append("%s: [url=%s]Font Size is %spx[/url]."% [name, FONT_MSG, fh])
	elif n is RichTextLabel:
		var t := (n as RichTextLabel).theme
		if t.normal_font != null:
			var fh := get_font_size(t.normal_font)
			if fh < 28: errors.append("%s: [url=%s]Normal Font Size should be at least 28px[/url] (current value is %spx)." % [name, FONT_MSG, fh])
			else: goods.append("%s: [url=%s]Normal Font Size is %spx[/url]."% [name, FONT_MSG, fh])
		if t.bold_font != null:
			var fh := get_font_size(t.bold_font)
			if fh < 28: errors.append("%s: [url=%s]Bold Font Size should be at least 28px[/url] (current value is %spx)." % [name, FONT_MSG, fh])
			else: goods.append("%s: [url=%s]Bold Font Size is %spx[/url]."% [name, FONT_MSG, fh])
		if t.bold_italics_font != null:
			var fh := get_font_size(t.bold_italics_font)
			if fh < 28: errors.append("%s: [url=%s]Bold Italics Font Size should be at least 28px[/url] (current value is %spx)." % [name, FONT_MSG, fh])
			else: goods.append("%s: [url=%s]Bold Italics Font Size is %spx[/url]."% [name, FONT_MSG, fh])
		if t.italics_font != null:
			var fh := get_font_size(t.italics_font)
			if fh < 28: errors.append("%s: [url=%s]Italics Font Size should be at least 28px[/url] (current value is %spx)." % [name, FONT_MSG, fh])
			else: goods.append("%s: [url=%s]Italics Font Size is %spx[/url]."% [name, FONT_MSG, fh])
		if t.mono_font != null:
			var fh := get_font_size(t.mono_font)
			if fh < 28: errors.append("%s: [url=%s]Mono Font Size should be at least 28px[/url] (current value is %spx)." % [name, FONT_MSG, fh])
			else: goods.append("%s: [url=%s]Mono Font Size is %spx[/url]."% [name, FONT_MSG, fh])
	elif n is HBoxContainer || n is VBoxContainer:
		var b := 0
		for c in n.get_children():
			if c is BaseButton: b += 1
		if b > 0:
			var sp:int = 0
			if n.theme == null:
				var custom_val = n.get("custom_constants/separation")
				if custom_val == null: sp = 4 # default
				else: sp = custom_val
			else: sp = n.theme.separation
			if sp < 15: errors.append("%s [url=%s]Interactive Elements like buttons should be well spaced[/url]; at least 15 pixels apart (current separation is %s)." % [name, SPACING_MSG, sp])
			else: goods.append("%s: [url=%s]Buttons are at least 15 pixels apart[/url]." % [name, SPACING_MSG])
		else: goods.append("%s: [url=%s]No Button Nodes present[/url]." % [name, SPACING_MSG])
	for c in n.get_children(): process_node(root, c)

func get_font_size(f:Font) -> int:
	if f is DynamicFont: return f.size
	else: return int(f.get_height())
