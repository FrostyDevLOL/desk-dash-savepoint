extends Node2D
## Main menu.

var _t := 0.0
var _rotate_notice: Control
var _colors: Array


func _ready() -> void:
	Audio.duck(false)
	_colors = Game.body_colors()
	var touch := Game.touch
	var ui := Control.new()
	ui.size = Vector2(480, 270)
	add_child(ui)
	ScreenArt.label(ui, "DESK DASH", 44, 18)
	ScreenArt.label(ui, "you're just a little guy. the world is very big. run.", 13, 78, Palette.INK)
	var stats := "crumb jar: %d" % Game.bank
	if Game.best > 0:
		stats = "best %d      " % Game.best + stats
	ScreenArt.label(ui, stats, 13, 96, Palette.INK)
	var entries := [["run!", _start], ["shop", Game.go_to_shop], ["album", Game.go_to_album],
			[Audio.sound_label(), Audio.toggle_mute]]
	if not OS.has_feature("web"):
		entries.append(["quit", get_tree().quit])
	var buttons := ScreenArt.button_row(ui, 226, entries)
	buttons[3].add_to_group("sound_buttons")
	buttons[0].get_parent().add_theme_constant_override("separation", 8)
	buttons[0].grab_focus()
	var hint := "tap to jump    hold to go higher" if touch else "space: jump (hold to go higher)    esc pause    m mute"
	ScreenArt.label(ui, hint, 11, 252, Palette.WHITE)
	_build_challenge_note(ui)

	# phones held upright get a tiny letterboxed game; suggest turning sideways
	_rotate_notice = ColorRect.new()
	_rotate_notice.color = Palette.INK
	_rotate_notice.size = Vector2(480, 270)
	_rotate_notice.visible = false
	ui.add_child(_rotate_notice)
	ScreenArt.label(_rotate_notice, "turn your phone sideways", 30, 105)
	ScreenArt.label(_rotate_notice, "the desk is very wide.", 16, 145, Palette.MIST)


## Today's challenges, pinned on the left like a sticky note.
func _build_challenge_note(parent: Control) -> void:
	Game.ensure_daily()
	var note := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Palette.BUTTER
	style.border_color = Palette.INK
	style.set_border_width_all(2)
	style.set_corner_radius_all(3)
	style.set_content_margin_all(5)
	style.shadow_color = Color(Palette.INK, 0.3)
	style.shadow_offset = Vector2(3, 3)
	note.add_theme_stylebox_override("panel", style)
	note.position = Vector2(8, 116)
	note.rotation_degrees = -2.0
	parent.add_child(note)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	note.add_child(box)
	_note_line(box, "today's challenges", 13, Palette.INK)
	for ch in Game.daily.list:
		var line := Challenges.describe(ch)
		if ch.done:
			_note_line(box, "done!  " + line, 10, Palette.TEAL)
		else:
			var extra := ""
			if Challenges.find(ch.id).stat == "today_crumbs":
				extra = "  (%d/%d)" % [mini(Game.challenge_progress(ch), ch.target), ch.target]
			_note_line(box, "%s%s  +%d" % [line, extra, ch.reward], 10, Palette.INK)


func _note_line(box: VBoxContainer, text: String, size: int, color: Color) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.custom_minimum_size.x = 196
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(l)


func _start() -> void:
	Audio.play("start")
	Game.start_game()


func _process(delta: float) -> void:
	_t += delta
	var win := DisplayServer.window_get_size()
	_rotate_notice.visible = win.y > win.x
	queue_redraw()


func _draw() -> void:
	ScreenArt.draw_room(self)
	var breathe := 1.0 + sin(_t * 2.5) * 0.05
	GuyArt.draw_guy(self, Vector2(240, 214), Vector2(2.0 / breathe, 2.0 * breathe), _colors[0], _colors[1],
			Palette.MINT, sin(_t * 0.7) * 0.6, fmod(_t, 3.2) < 0.12, 0.0, Game.hat)
