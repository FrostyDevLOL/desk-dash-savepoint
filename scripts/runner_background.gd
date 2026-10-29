extends Node2D
## Endless wall behind the run, scrolling at half speed. Each zone has its own wall; where two
## zones meet, each is drawn on its own layer clipped to its part of the screen.

const PARALLAX := 0.5
const DECOR_SPACING := 420.0
const LAYERS := 3

@export var camera: Camera2D

var _layers: Array[ZoneLayer] = []
var _clips: Array[Control] = []


class ZoneLayer extends Node2D:
	var zone := 0
	var scroll := 0.0

	func _box(rect: Rect2, color: Color) -> void:
		draw_rect(rect, Palette.INK)
		draw_rect(rect.grow(-2.0), color)

	## Cheap repeatable "random" for decor, so it doesn't change frame to frame.
	func _hash(i: int, salt := 0) -> float:
		return fposmod(sin(i * 12.9898 + salt * 78.233) * 43758.5453, 1.0)

	func _draw() -> void:
		match zone:
			0: _draw_desk_wall()
			1: _draw_shelf_wall()
			2: _draw_kitchen_wall()
			3: _draw_bed_wall()
			4: _draw_bath_wall()
			5: _draw_window_wall()
			6: _draw_laundry_wall()

	func _draw_window_wall() -> void:
		# one long window: sky, hills and flowers outside, rain sliding down the glass
		draw_rect(Rect2(0, 0, 480, 270), Palette.SKY)
		var far := scroll * 0.4 # the garden outside moves slower still
		for i in range(floori(far / 160.0) - 1, floori(far / 160.0) + 5):
			var hx := i * 160.0 - far
			draw_circle(Vector2(hx + 80, 250), 120.0, Palette.MINT)
		for i in range(floori(far / 90.0) - 1, floori(far / 90.0) + 8):
			var bx := i * 90.0 - far
			draw_circle(Vector2(bx + 30, 168), 22.0, Palette.SAGE)
			draw_circle(Vector2(bx + 48, 160), 18.0, Palette.SAGE)
			if _hash(i, 9) > 0.4:
				var fc: Color = [Palette.PINK, Palette.BUTTER, Palette.WHITE][int(_hash(i, 10) * 3.0)]
				draw_circle(Vector2(bx + 64, 176), 3.0, fc)
		for i in range(floori(scroll / 80.0) - 1, floori(scroll / 80.0) + 8):
			var cx := i * 80.0 - scroll
			if _hash(i, 11) > 0.6:
				var cy := 30.0 + _hash(i, 12) * 40.0
				for o in [Vector2(0, 0), Vector2(14, -6), Vector2(28, 0)]:
					draw_circle(Vector2(cx, cy) + o, 12.0, Palette.WHITE)
		# raindrops on the glass
		for i in range(floori(scroll / 26.0) - 1, floori(scroll / 26.0) + 20):
			if _hash(i, 13) > 0.45:
				var rp := Vector2(i * 26.0 - scroll, 10.0 + _hash(i, 14) * 180.0)
				draw_line(rp, rp + Vector2(-2, 9), Color(Palette.WHITE, 0.7), 1.5)
				draw_circle(rp + Vector2(-2, 10), 1.6, Color(Palette.WHITE, 0.8))
		# window frame: mullions and a crossbar
		var x := -fposmod(scroll, 160.0)
		while x < 480.0:
			draw_rect(Rect2(x - 5, 0, 10, 270), Palette.INK)
			draw_rect(Rect2(x - 4, 0, 8, 270), Palette.WHITE)
			x += 160.0
		draw_rect(Rect2(0, 96, 480, 9), Palette.INK)
		draw_rect(Rect2(0, 97, 480, 7), Palette.WHITE)

	func _draw_laundry_wall() -> void:
		# lavender wall with a clothesline of washing hung out to dry
		draw_rect(Rect2(0, 0, 480, 270), Palette.PERI)
		var x := -fposmod(scroll, 30.0)
		while x < 480.0:
			draw_line(Vector2(x, 0), Vector2(x, 270), Color(Palette.LILAC, 0.6), 1.0)
			x += 30.0
		var line_pts := PackedVector2Array()
		for i in range(floori(scroll / 120.0) - 1, floori(scroll / 120.0) + 6):
			var lx := i * 120.0 - scroll
			line_pts.append(Vector2(lx, 52))
			line_pts.append(Vector2(lx + 60, 60))
		draw_polyline(line_pts, Palette.INK, 1.5)
		for i in range(floori(scroll / 60.0) - 1, floori(scroll / 60.0) + 10):
			var cx := i * 60.0 - scroll + 30.0
			var cy := 56.0 + (4.0 if posmod(i, 2) == 0 else 0.0)
			var cloth: Color = [Palette.PINK, Palette.BUTTER, Palette.MINT, Palette.WHITE, Palette.SALMON][posmod(i, 5)]
			match posmod(i * 7, 3):
				0:
					# a sock
					_box(Rect2(cx - 5, cy, 10, 26), cloth)
					_box(Rect2(cx - 5, cy + 20, 18, 9), cloth)
				1:
					# a little shirt
					_box(Rect2(cx - 14, cy, 28, 34), cloth)
					_box(Rect2(cx - 22, cy, 10, 12), cloth)
					_box(Rect2(cx + 12, cy, 10, 12), cloth)
				2:
					# a towel
					_box(Rect2(cx - 16, cy, 32, 44), cloth)
					draw_rect(Rect2(cx - 14, cy + 36, 28, 3), Palette.WHITE)
			draw_rect(Rect2(cx - 2, cy - 5, 4, 8), Palette.ROSE)

	func _draw_bath_wall() -> void:
		# mint tiles with a round mirror and a towel on a rail
		draw_rect(Rect2(0, 0, 480, 270), Palette.MINT)
		var x := -fposmod(scroll, 20.0)
		while x < 480.0:
			draw_line(Vector2(x, 0), Vector2(x, 270), Palette.WHITE, 1.0)
			x += 20.0
		for y in range(0, 270, 20):
			draw_line(Vector2(0, y), Vector2(480, y), Palette.WHITE, 1.0)
		draw_rect(Rect2(0, 150, 480, 6), Palette.TEAL)
		for slot in _decor_slots():
			var sx: float = slot[1]
			if posmod(slot[0], 2) == 0:
				var c := Vector2(sx + 70, 82)
				draw_circle(c, 52.0, Palette.INK)
				draw_circle(c, 49.0, Palette.MIST)
				draw_circle(c, 44.0, Palette.SKY)
				draw_line(c + Vector2(-22, -14), c + Vector2(-6, -30), Palette.WHITE, 3.0)
				draw_line(c + Vector2(-14, -2), c + Vector2(4, -20), Palette.WHITE, 2.0)
			else:
				var rail := Rect2(sx + 20, 60, 110, 5)
				_box(rail.grow(1.0), Palette.MIST)
				var towel := Rect2(sx + 32, 64, 86, 74)
				_box(towel, Palette.PINK)
				for i in 3:
					draw_rect(Rect2(towel.position.x + 3, towel.end.y - 14 + i * 4, towel.size.x - 6, 2), Palette.WHITE)
		# a few soap bubbles drifting up the wall
		var base := floori(scroll / 70.0) - 1
		for i in range(base, base + 9):
			if _hash(i, 5) > 0.5:
				var bp := Vector2(i * 70.0 - scroll + _hash(i, 6) * 40.0, 40.0 + _hash(i, 7) * 150.0)
				var br := 3.0 + _hash(i, 8) * 5.0
				draw_arc(bp, br, 0, TAU, 14, Palette.WHITE, 1.0)
				draw_circle(bp + Vector2(-br * 0.35, -br * 0.35), 0.9, Palette.WHITE)

	func _decor_slots() -> Array:
		var first := floori(scroll / DECOR_SPACING)
		var out := []
		for i in range(first, first + 3):
			out.append([i, i * DECOR_SPACING - scroll + 60.0])
		return out

	func _draw_desk_wall() -> void:
		draw_rect(Rect2(0, 0, 480, 270), Palette.SKY)
		var x := -fposmod(scroll, 48.0)
		while x < 480.0:
			draw_rect(Rect2(x, 0, 6, 270), Palette.PERI)
			x += 48.0
		for slot in _decor_slots():
			var sx: float = slot[1]
			match posmod(slot[0], 3):
				0:
					var win := Rect2(sx, 40, 140, 110)
					_box(win.grow(6.0), Palette.WHITE)
					draw_rect(win, Palette.BUTTER)
					draw_circle(win.position + Vector2(100, 35), 18.0, Palette.WHITE)
					for c in [Vector2(30, 80), Vector2(48, 72), Vector2(66, 82)]:
						draw_circle(win.position + c, 12.0, Palette.WHITE)
					draw_rect(Rect2(win.position.x + 67, win.position.y, 6, win.size.y), Palette.WHITE)
					draw_rect(Rect2(win.position.x, win.position.y + 52, win.size.x, 6), Palette.WHITE)
				1:
					var pic := Rect2(sx + 20, 60, 80, 64)
					_box(pic.grow(5.0), Palette.ROSE)
					draw_rect(pic, Palette.MINT)
					draw_rect(Rect2(pic.position.x, pic.end.y - 16, pic.size.x, 16), Palette.SAGE)
					GuyArt.draw_guy(self, pic.position + Vector2(40, 52), Vector2(1.6, 1.6), Palette.SALMON,
							Palette.PEACH, Palette.MINT)
				2:
					var poster := Rect2(sx + 30, 30, 70, 90)
					_box(poster, Palette.LILAC)
					GuyArt.draw_heart(self, poster.get_center() + Vector2(0, -8), 18.0, Palette.PINK)

	func _draw_shelf_wall() -> void:
		draw_rect(Rect2(0, 0, 480, 270), Palette.PLUM)
		var x := -fposmod(scroll, 64.0)
		while x < 480.0:
			draw_line(Vector2(x, 0), Vector2(x, 270), Palette.ROSE, 1.0)
			x += 64.0
		# the shelf above, with a row of books on it
		var spine_x := -fposmod(scroll, 22.0) - 22.0
		var idx := floori(scroll / 22.0) - 1
		while spine_x < 480.0:
			var h := 34.0 + _hash(idx) * 22.0
			var colors := [Palette.BLUE, Palette.SAGE, Palette.BUTTER, Palette.SALMON, Palette.TEAL, Palette.LILAC]
			var c: Color = colors[int(_hash(idx, 1) * colors.size())]
			if _hash(idx, 2) > 0.12:
				draw_rect(Rect2(spine_x, 92 - h, 20, h), Palette.INK)
				draw_rect(Rect2(spine_x + 1, 93 - h, 18, h - 2), c)
				draw_rect(Rect2(spine_x + 1, 98 - h, 18, 2), Palette.PEACH)
			spine_x += 22.0
			idx += 1
		draw_rect(Rect2(0, 92, 480, 12), Palette.INK)
		draw_rect(Rect2(0, 93, 480, 9), Palette.ROSE)
		draw_line(Vector2(0, 95), Vector2(480, 95), Palette.PEACH, 1.0)

	func _draw_kitchen_wall() -> void:
		draw_rect(Rect2(0, 0, 480, 270), Palette.WHITE)
		var x := -fposmod(scroll, 24.0)
		while x < 480.0:
			draw_line(Vector2(x, 0), Vector2(x, 270), Palette.MIST, 1.0)
			x += 24.0
		for y in range(0, 270, 24):
			draw_line(Vector2(0, y), Vector2(480, y), Palette.MIST, 1.0)
		draw_rect(Rect2(0, 132, 480, 8), Palette.TEAL)
		for slot in _decor_slots():
			var sx: float = slot[1]
			if posmod(slot[0], 2) == 0:
				var win := Rect2(sx, 26, 120, 86)
				_box(win.grow(6.0), Palette.SAGE)
				draw_rect(win, Palette.SKY)
				draw_circle(win.position + Vector2(30, 28), 12.0, Palette.WHITE)
				draw_circle(win.position + Vector2(44, 32), 10.0, Palette.WHITE)
				draw_rect(Rect2(win.position.x + 57, win.position.y, 6, win.size.y), Palette.SAGE)
			else:
				var c := Vector2(sx + 70, 70)
				draw_circle(c, 30.0, Palette.INK)
				draw_circle(c, 27.0, Palette.BUTTER)
				for h in 12:
					var a := TAU * h / 12.0
					draw_rect(Rect2(c + Vector2(cos(a), sin(a)) * 22.0 - Vector2(1, 1), Vector2(2, 2)), Palette.INK)
				draw_line(c, c + Vector2(0, -17), Palette.INK, 2.0)
				draw_line(c, c + Vector2(12, 4), Palette.INK, 2.0)

	func _draw_bed_wall() -> void:
		draw_rect(Rect2(0, 0, 480, 270), Palette.VIOLET)
		var base := floori(scroll / 30.0) - 1
		for i in range(base, base + 19):
			var sx := i * 30.0 - scroll
			if _hash(i) > 0.45:
				var sy := 10.0 + _hash(i, 3) * 150.0
				draw_rect(Rect2(sx, sy, 2, 2), Palette.BUTTER)
		# fairy lights strung along the top
		var pts := PackedVector2Array()
		var lx := -fposmod(scroll, 40.0) - 40.0
		var li := floori(scroll / 40.0) - 1
		while lx < 520.0:
			pts.append(Vector2(lx, 24.0 + (8.0 if li % 2 == 0 else 0.0)))
			lx += 40.0
			li += 1
		draw_polyline(pts, Palette.INK, 1.0)
		var bulbs := [Palette.PINK, Palette.BUTTER, Palette.MINT, Palette.SKY]
		for j in pts.size():
			draw_circle(pts[j] + Vector2(0, 3), 2.5, Palette.INK)
			draw_circle(pts[j] + Vector2(0, 3), 1.8, bulbs[posmod(li - pts.size() + j, bulbs.size())])
		for slot in _decor_slots():
			if posmod(slot[0], 2) == 0:
				var win := Rect2(slot[1], 46, 110, 90)
				_box(win.grow(6.0), Palette.PERI)
				draw_rect(win, Palette.NAVY)
				draw_circle(win.position + Vector2(72, 32), 14.0, Palette.BUTTER)
				draw_circle(win.position + Vector2(79, 27), 12.0, Palette.NAVY)
				for p in [Vector2(20, 20), Vector2(40, 60), Vector2(90, 70), Vector2(25, 75)]:
					draw_rect(Rect2(win.position + p, Vector2(2, 2)), Palette.WHITE)


func _ready() -> void:
	# each zone's wall sits in a clipping box covering its part of the screen
	for i in LAYERS:
		var clip := Control.new()
		clip.clip_contents = true
		clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(clip)
		var l := ZoneLayer.new()
		clip.add_child(l)
		_clips.append(clip)
		_layers.append(l)


func _process(_delta: float) -> void:
	position = camera.get_screen_center_position() - Vector2(240, 135)
	var starts: Array = get_parent().zone_starts
	var scroll := position.x * PARALLAX
	var used := 0
	for i in starts.size():
		var x0: float = clampf(starts[i][0] - position.x, 0.0, 480.0)
		var x1: float = 480.0 if i + 1 >= starts.size() else clampf(starts[i + 1][0] - position.x, 0.0, 480.0)
		if x1 <= x0 or used >= LAYERS:
			continue
		var layer := _layers[used]
		var clip := _clips[used]
		layer.zone = starts[i][1]
		layer.scroll = scroll
		clip.visible = true
		clip.position = Vector2(x0, 0)
		clip.size = Vector2(x1 - x0, 270)
		layer.position = Vector2(-x0, 0) # keep drawing in screen space
		layer.queue_redraw()
		used += 1
	for j in range(used, LAYERS):
		_clips[j].visible = false
