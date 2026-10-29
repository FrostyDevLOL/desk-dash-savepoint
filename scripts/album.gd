extends Node2D
## Sticker album: one notebook page per room, six stickers each.

const ROOM_NAMES := ["the desk", "the bookshelf", "the kitchen counter", "the bed", "the bathroom shelf",
		"the windowsill", "the laundry room"]
const PAGE := Rect2(40, 44, 400, 180)
const CELL := Vector2(118, 70)

var _page := 0
var _page_root: Control
var _ui: Control


func _ready() -> void:
	Audio.duck(false)
	_ui = Control.new()
	_ui.size = Vector2(480, 270)
	_ui.theme = ScreenArt.theme()
	add_child(_ui)
	ScreenArt.label(_ui, "sticker album", 28, -2)
	var count := ScreenArt.label(_ui, "%d / %d" % [Game.stickers.size(), Stickers.total()], 15, 8)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count.size.x = 470
	var back := Button.new()
	back.text = "back"
	back.position = Vector2(10, 238)
	back.pressed.connect(func():
		Audio.play("click")
		Game.go_to_title())
	_ui.add_child(back)
	for side in [-1, 1]:
		var b := Button.new()
		b.text = "<" if side < 0 else ">"
		b.position = Vector2(8 if side < 0 else 446, 118)
		b.custom_minimum_size = Vector2(26, 30)
		b.pressed.connect(_flip.bind(side))
		_ui.add_child(b)
	_page_root = Control.new()
	_page_root.size = Vector2(480, 270)
	_page_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_page_root)
	back.grab_focus()
	_show_page()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		_flip(-1)
	elif event.is_action_pressed("ui_right"):
		_flip(1)


func _flip(dir: int) -> void:
	Audio.play("click", 0.0, 1.2)
	_page = posmod(_page + dir, Stickers.SETS.size())
	_show_page()


func _show_page() -> void:
	for c in _page_root.get_children():
		c.queue_free()
	var set: Array = Stickers.SETS[_page]
	var owned := set.filter(func(st): return st.id in Game.stickers).size()
	var done := owned == set.size()
	ScreenArt.label(_page_root, ROOM_NAMES[_page], 18, PAGE.position.y + 2, Palette.TEAL if done else Palette.INK)
	var foot_text := "room %d of %d    %d / %d found" % [_page + 1, Stickers.SETS.size(), owned, set.size()]
	if done:
		foot_text = "room %d of %d    page complete!" % [_page + 1, Stickers.SETS.size()]
	ScreenArt.label(_page_root, foot_text, 12, PAGE.end.y + 4, Palette.WHITE)
	for i in set.size():
		var st: Dictionary = set[i]
		var pos := PAGE.position + Vector2(12 + (i % 3) * (CELL.x + 10), 36 + (i / 3) * (CELL.y + 4))
		_page_root.add_child(_make_cell(st, pos, st.id in Game.stickers))
	queue_redraw()


func _make_cell(st: Dictionary, pos: Vector2, owned: bool) -> Control:
	var cell := Control.new()
	cell.position = pos
	cell.size = CELL
	cell.clip_contents = true
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var art := Stickers.make_art(st, Vector2(CELL.x - 30, CELL.y - 30))
	art.position = Vector2(CELL.x / 2.0, CELL.y / 2.0 - 6)
	if not owned:
		art.modulate = Color(Palette.INK, 0.35) # a mystery silhouette
	var card := _CellCard.new()
	card.owned = owned
	card.size = CELL
	cell.add_child(card)
	cell.add_child(art)
	var name_label := Label.new()
	name_label.text = st.name if owned else "???"
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", Palette.INK if owned else Palette.STONE)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.size = Vector2(CELL.x, 16)
	name_label.position = Vector2(0, CELL.y - 18)
	cell.add_child(name_label)
	return cell


## The sticker's backing: a white card with a coloured edge once found, a dashed outline if not.
class _CellCard extends Control:
	var owned := false

	func _draw() -> void:
		var r := Rect2(Vector2(4, 2), size - Vector2(8, 4))
		if owned:
			draw_rect(r.grow(2.0), Palette.INK)
			draw_rect(r.grow(1.0), Palette.PINK)
			draw_rect(r, Palette.WHITE)
		else:
			var x := r.position.x
			while x < r.end.x:
				draw_line(Vector2(x, r.position.y), Vector2(minf(x + 5, r.end.x), r.position.y), Palette.STONE, 1.0)
				draw_line(Vector2(x, r.end.y), Vector2(minf(x + 5, r.end.x), r.end.y), Palette.STONE, 1.0)
				x += 9.0
			var y := r.position.y
			while y < r.end.y:
				draw_line(Vector2(r.position.x, y), Vector2(r.position.x, minf(y + 5, r.end.y)), Palette.STONE, 1.0)
				draw_line(Vector2(r.end.x, y), Vector2(r.end.x, minf(y + 5, r.end.y)), Palette.STONE, 1.0)
				y += 9.0


func _draw() -> void:
	draw_rect(Rect2(0, 0, 480, 270), Palette.SKY)
	var x := 12.0
	while x < 480.0:
		draw_rect(Rect2(x, 0, 6, 270), Palette.PERI)
		x += 48.0
	draw_rect(Rect2(-2, 228, 484, 50), Palette.INK)
	draw_rect(Rect2(-1, 235, 482, 40), Palette.ROSE)
	draw_rect(Rect2(-1, 229, 482, 5), Palette.PEACH)
	# the notebook page
	draw_rect(PAGE.grow(2.0), Palette.INK)
	draw_rect(PAGE, Palette.WHITE)
	var ly := PAGE.position.y + 30.0
	while ly < PAGE.end.y - 4.0:
		draw_line(Vector2(PAGE.position.x + 4, ly), Vector2(PAGE.end.x - 4, ly), Color(Palette.SKY, 0.5), 1.0)
		ly += 12.0
	draw_line(Vector2(PAGE.position.x + 26, PAGE.position.y), Vector2(PAGE.position.x + 26, PAGE.end.y),
			Color(Palette.PINK, 0.6), 1.0)
