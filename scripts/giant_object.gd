@tool
class_name GiantObject
extends StaticBody2D
## A big everyday object the little guy can stand on. Origin is the top-left corner.

enum Kind { BOOK, MUG, PENCIL, BOX, POT, SHELF, DESK, NOTE, LEAF,
		NOTEPAD, ERASER, PLATE, BOARD, SUGAR, MARSHMALLOW, PILLOW, PHONE, SOCK, BOOKEND, CLOUDS,
		SOAP, TOOTHBRUSH, BOTTLE, DUCK, CAN, MUSHROOM, BASKET, TOWEL, SPONGE }
## Floor styles for Kind.DESK, one per zone.
enum Floor { DESK, SHELF, COUNTER, BED, BATH, SILL, WASHER }

@export var kind := Kind.BOOK:
	set(v):
		kind = v
		_refresh()
@export var size := Vector2(64, 24):
	set(v):
		size = v
		_refresh()
@export var fill := Color("4c64a8"):
	set(v):
		fill = v
		_refresh()
@export var accent := Color("e0dc9c"):
	set(v):
		accent = v
		_refresh()
@export var one_way := false:
	set(v):
		one_way = v
		_refresh()
@export var floor_style := Floor.DESK:
	set(v):
		floor_style = v
		_refresh()
## Landing on top launches the little guy high (see Player).
@export var bouncy := false
## False for pure decoration (clouds) he passes through.
@export var solid := true:
	set(v):
		solid = v
		_refresh()

var _shape: CollisionShape2D
var _squish := 0.0


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return
	if _shape == null:
		_shape = CollisionShape2D.new()
		add_child(_shape)
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape.shape = rect
	_shape.position = size / 2.0
	_shape.one_way_collision = one_way
	_shape.disabled = not solid
	queue_redraw()


## Visual squash when bounced on.
func squish() -> void:
	var tw := create_tween()
	tw.tween_method(func(v: float):
		_squish = v
		queue_redraw(), 0.45, 0.0, 0.35).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _box(rect: Rect2, color: Color) -> void:
	draw_rect(rect, Palette.INK)
	draw_rect(rect.grow(-1.0), color)


func _outlined_poly(points: PackedVector2Array, color: Color) -> void:
	draw_colored_polygon(points, color)
	var closed := points.duplicate()
	closed.append(points[0])
	draw_polyline(closed, Palette.INK, 1.0)


func _rounded(rect: Rect2, color: Color, radius: float) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.border_color = Palette.INK
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(int(radius))
	sb.anti_aliasing = false
	draw_style_box(sb, rect)


func _draw() -> void:
	var full := Rect2(Vector2.ZERO, size)
	# bouncy things squash down from the top when bounced on
	if _squish > 0.0:
		var h := size.y * (1.0 - _squish * 0.5)
		full = Rect2(0, size.y - h, size.x, h)
	match kind:
		Kind.BOOK:
			_draw_book(full)
		Kind.MUG:
			_draw_mug(full)
		Kind.PENCIL:
			_draw_pencil(full)
		Kind.BOX:
			_box(full, fill)
			draw_rect(Rect2(size.x / 2.0 - 3.0, 1.0, 6.0, size.y - 2.0), accent)
			draw_line(Vector2(1, 5), Vector2(size.x - 1, 5), Palette.ROSE, 1.0)
		Kind.POT:
			_draw_pot()
		Kind.SHELF:
			for bx in [6.0, size.x - 12.0]:
				_outlined_poly(PackedVector2Array([Vector2(bx, size.y), Vector2(bx + 6.0, size.y),
						Vector2(bx + 1.0, size.y + 9.0)]), Palette.STONE)
			_box(full, fill)
			draw_line(Vector2(1, 1.5), Vector2(size.x - 1, 1.5), accent, 1.0)
		Kind.DESK:
			_draw_floor()
		Kind.NOTE:
			_box(full, fill)
			_outlined_poly(PackedVector2Array([Vector2(size.x - 8, size.y), Vector2(size.x, size.y - 8),
					Vector2(size.x - 8, size.y - 8)]), accent)
			for i in 3:
				var y := 8.0 + i * 5.0
				draw_line(Vector2(5, y), Vector2(size.x - 7 - i * 4, y), accent, 1.0)
			draw_circle(Vector2(size.x / 2.0, 2.0), 2.0, Palette.INK)
			draw_circle(Vector2(size.x / 2.0, 2.0), 1.2, Palette.PINK)
		Kind.LEAF:
			_draw_leaf()
		Kind.NOTEPAD:
			# a pad of sticky notes, seen from the side: lots of thin sheets
			_box(full, fill)
			var y := 3.0
			while y < size.y - 1.0:
				draw_line(Vector2(1, y), Vector2(size.x - 1, y), accent, 1.0)
				y += 2.0
			draw_rect(Rect2(1, 1, size.x - 2, 1.5), Palette.WHITE)
		Kind.ERASER:
			_rounded(full, fill, 3)
			var sleeve := Rect2(full.position.x + size.x * 0.35, full.position.y, size.x * 0.65, full.size.y)
			_box(sleeve, accent)
			draw_line(sleeve.position + Vector2(4, sleeve.size.y / 2.0),
					sleeve.position + Vector2(sleeve.size.x - 4, sleeve.size.y / 2.0), Palette.BLUE, 1.0)
		Kind.PLATE:
			_rounded(full, Palette.WHITE, int(minf(size.y / 2.0, 4.0)))
			draw_line(Vector2(4, full.position.y + 2), Vector2(size.x - 4, full.position.y + 2), accent, 1.0)
		Kind.BOARD:
			_rounded(full, fill, 3)
			for i in 3:
				var gy := full.position.y + 3.0 + i * 3.5
				draw_line(Vector2(6 + i * 9, gy), Vector2(size.x - 30 + i * 6, gy), accent, 1.0)
			draw_circle(Vector2(size.x - 10, full.get_center().y), 2.4, Palette.INK)
			draw_circle(Vector2(size.x - 10, full.get_center().y), 1.6, Palette.STONE)
		Kind.SUGAR:
			_box(full, Palette.WHITE)
			for p in [Vector2(0.3, 0.3), Vector2(0.7, 0.45), Vector2(0.4, 0.75), Vector2(0.75, 0.8)]:
				draw_rect(Rect2(full.position + p * full.size, Vector2(1, 1)), Palette.MIST)
		Kind.MARSHMALLOW:
			_rounded(full, Palette.WHITE, 6)
			draw_rect(Rect2(full.position.x + 2, full.end.y - 4, full.size.x - 4, 2), Palette.PINK)
		Kind.PILLOW:
			_rounded(full, fill, 8)
			draw_line(Vector2(6, full.get_center().y), Vector2(size.x - 6, full.get_center().y), accent, 1.0)
			for cx in [5.0, size.x - 5.0]:
				draw_circle(Vector2(cx, full.position.y + 4), 1.5, accent)
				draw_circle(Vector2(cx, full.end.y - 4), 1.5, accent)
		Kind.PHONE:
			_rounded(full, Palette.INK, 2)
			draw_rect(Rect2(3, full.position.y + 1, size.x - 6, 1.5), Palette.SKY)
			draw_rect(Rect2(size.x - 14, full.end.y - 3, 6, 1), Palette.STONE)
		Kind.SOCK:
			_rounded(full, fill, 5)
			var sx := 8.0
			while sx < size.x - 6.0:
				draw_rect(Rect2(sx, full.position.y + 1, 4, full.size.y - 2), accent)
				sx += 12.0
		Kind.CLOUDS:
			# fluffy clouds drifting far below the cliff
			var cx := 30.0
			var i := 0
			while cx < size.x - 30.0:
				var cy := 18.0 + fmod(i * 23.0, 30.0)
				for p in [Vector2(-14, 4), Vector2(0, -3), Vector2(14, 4), Vector2(4, 6)]:
					draw_circle(Vector2(cx, cy) + p, 11.0, Palette.MIST)
				for p in [Vector2(-14, 2), Vector2(0, -5), Vector2(14, 2)]:
					draw_circle(Vector2(cx, cy) + p, 9.0, Palette.WHITE)
				cx += 70.0 + fmod(i * 37.0, 40.0)
				i += 1
		Kind.SOAP:
			_rounded(full, fill, 6)
			draw_line(Vector2(6, full.position.y + 3), Vector2(size.x - 6, full.position.y + 3), Palette.WHITE, 1.0)
			for p in [Vector2(0.2, -0.4), Vector2(0.55, -0.7), Vector2(0.8, -0.3)]:
				draw_arc(Vector2(size.x * p.x, full.position.y + size.y * p.y), 2.5, 0, TAU, 10,
						Color(Palette.WHITE, 0.8), 1.0)
		Kind.TOOTHBRUSH:
			# spawned as two pieces: a flat handle (short) and the bristle head (taller)
			if size.y <= 8.0:
				_rounded(full, fill, 3)
				draw_line(Vector2(6, 2), Vector2(size.x - 6, 2), Color(Palette.WHITE, 0.7), 1.0)
			else:
				_box(Rect2(0, size.y - 7, size.x, 7), fill)
				var bx := 2.0
				while bx < size.x - 2.0:
					draw_rect(Rect2(bx, 0, 3, size.y - 7), Palette.INK)
					draw_rect(Rect2(bx + 0.5, 0.5, 2, size.y - 8), accent)
					bx += 4.0
		Kind.BOTTLE:
			# shampoo bottle: body, shoulder, cap
			_rounded(Rect2(0, 14, size.x, size.y - 14), fill, 5)
			_box(Rect2(size.x * 0.25, 4, size.x * 0.5, 11), fill)
			_box(Rect2(size.x * 0.32, 0, size.x * 0.36, 6), accent)
			_box(Rect2(5, 24, size.x - 10, size.y * 0.32), Palette.WHITE)
			draw_line(Vector2(9, 32), Vector2(size.x - 9, 32), accent, 1.0)
			draw_line(Vector2(9, 37), Vector2(size.x - 14, 37), accent, 1.0)
		Kind.DUCK:
			# rubber duck, squishes like the other bounce pads
			var body := Rect2(full.position.x, full.position.y + full.size.y * 0.35, size.x, full.size.y * 0.65)
			_rounded(body, Palette.BUTTER, 8)
			var head_c := Vector2(size.x * 0.68, full.position.y + full.size.y * 0.32)
			draw_circle(head_c, full.size.y * 0.32 + 1.0, Palette.INK)
			draw_circle(head_c, full.size.y * 0.32, Palette.BUTTER)
			draw_circle(head_c + Vector2(2, -1), 1.3, Palette.INK)
			_outlined_poly(PackedVector2Array([head_c + Vector2(full.size.y * 0.28, -1),
					head_c + Vector2(full.size.y * 0.28 + 7, 1), head_c + Vector2(full.size.y * 0.28, 4)]), Palette.PEACH)
			draw_arc(Vector2(size.x * 0.35, body.position.y + body.size.y * 0.45), 6.0, 0.3, 2.6, 8, Palette.PEACH, 1.5)
		Kind.CAN:
			# watering can: body, a spout reaching right, a handle arching over the top
			draw_line(Vector2(size.x - 2, size.y * 0.55), Vector2(size.x + 16, size.y * 0.15), Palette.INK, 5.0)
			draw_line(Vector2(size.x - 2, size.y * 0.55), Vector2(size.x + 16, size.y * 0.15), fill, 3.0)
			_box(Rect2(size.x + 12, size.y * 0.08, 8, 6), accent)
			draw_arc(Vector2(size.x * 0.4, 0), size.x * 0.32, PI, TAU, 14, Palette.INK, 4.0)
			draw_arc(Vector2(size.x * 0.4, 0), size.x * 0.32, PI, TAU, 14, fill, 2.0)
			_rounded(full, fill, 4)
			draw_rect(Rect2(3, size.y * 0.3, size.x - 6, 4), accent)
		Kind.MUSHROOM:
			# a little toadstool: squishy red cap with white dots (bouncy)
			var stem := Rect2(size.x * 0.32, full.position.y + full.size.y * 0.5, size.x * 0.36, full.size.y * 0.5)
			_rounded(stem, Palette.WHITE, 3)
			var cap := PackedVector2Array()
			for i in 13:
				var a := PI + PI * i / 12.0
				cap.append(Vector2(size.x / 2.0 + cos(a) * size.x / 2.0, full.position.y + full.size.y * 0.55 + sin(a) * full.size.y * 0.55))
			_outlined_poly(cap, fill)
			for p in [Vector2(0.3, 0.3), Vector2(0.55, 0.15), Vector2(0.72, 0.36)]:
				draw_circle(Vector2(size.x * p.x, full.position.y + full.size.y * p.y), 2.0, Palette.WHITE)
		Kind.BASKET:
			# woven laundry basket with a towel peeking out
			_rounded(Rect2(4, -5, size.x - 8, 8), accent, 3)
			_rounded(full, fill, 5)
			var wy := 5.0
			while wy < size.y - 3.0:
				draw_line(Vector2(3, wy), Vector2(size.x - 3, wy), Palette.ROSE, 1.0)
				wy += 5.0
			var wx := 8.0
			while wx < size.x - 4.0:
				draw_line(Vector2(wx, 2), Vector2(wx, size.y - 2), Color(Palette.ROSE, 0.6), 1.0)
				wx += 9.0
		Kind.TOWEL:
			# a folded towel, seen from the side
			_rounded(full, fill, 4)
			draw_line(Vector2(3, full.position.y + full.size.y * 0.5), Vector2(size.x - 3, full.position.y + full.size.y * 0.5),
					Color(Palette.WHITE, 0.6), 1.0)
			draw_rect(Rect2(size.x - 12, full.position.y + 2, 3, full.size.y - 4), accent)
			draw_rect(Rect2(size.x - 7, full.position.y + 2, 3, full.size.y - 4), accent)
		Kind.SPONGE:
			_rounded(full, fill, 3)
			draw_rect(Rect2(1, full.end.y - 5, size.x - 2, 4), accent)
			for p in [Vector2(0.2, 0.35), Vector2(0.45, 0.25), Vector2(0.7, 0.4), Vector2(0.85, 0.2), Vector2(0.35, 0.55)]:
				draw_circle(Vector2(size.x * p.x, full.position.y + full.size.y * p.y), 1.4, Palette.PEACH)
		Kind.BOOKEND:
			_box(Rect2(0, 0, size.x, size.y), Palette.SLATE)
			_box(Rect2(0, size.y - 4, size.x + 18, 4), Palette.SLATE)
			draw_line(Vector2(2, 3), Vector2(2, size.y - 6), Palette.PERI, 1.0)


func _draw_book(full: Rect2) -> void:
	_box(full, fill)
	if size.x >= size.y:
		# lying down: pages on the right, spine bands on the left
		draw_rect(Rect2(size.x - 6, 2, 4, size.y - 4), Palette.WHITE)
		for y in range(4, int(size.y) - 3, 3):
			draw_line(Vector2(size.x - 6, y), Vector2(size.x - 2, y), Palette.MIST, 1.0)
		draw_rect(Rect2(5, 1, 3, size.y - 2), accent)
		draw_rect(Rect2(12, 1, 3, size.y - 2), accent)
		var title := Rect2(size.x * 0.35, size.y * 0.3, minf(size.x * 0.3, 60), size.y * 0.4)
		draw_rect(title, accent)
	else:
		# standing up: bands near top and bottom, a title block
		draw_rect(Rect2(1, 5, size.x - 2, 2), accent)
		draw_rect(Rect2(1, size.y - 9, size.x - 2, 2), accent)
		draw_rect(Rect2(size.x * 0.25, size.y * 0.3, size.x * 0.5, size.y * 0.22), accent)


func _draw_mug(full: Rect2) -> void:
	var hc := Vector2(size.x, size.y * 0.45)
	var hr := size.y * 0.22
	draw_arc(hc, hr, -PI / 2.0, PI / 2.0, 16, Palette.INK, 6.0)
	draw_arc(hc, hr, -PI / 2.0, PI / 2.0, 16, fill, 4.0)
	_box(full, fill)
	draw_rect(Rect2(1, 1, size.x - 2, 4), Palette.ROSE)
	GuyArt.draw_heart(self, Vector2(size.x / 2.0, size.y * 0.5), minf(size.x * 0.25, 14.0), accent)
	for i in 3:
		var x := size.x * (0.3 + i * 0.2)
		var pts := PackedVector2Array()
		for s in 6:
			pts.append(Vector2(x + sin(s * 1.3 + i) * 2.0, -4.0 - s * 3.0))
		draw_polyline(pts, Palette.WHITE, 1.0)


func _draw_pencil(full: Rect2) -> void:
	var h := size.y
	_outlined_poly(PackedVector2Array([Vector2(size.x - 1, 0), Vector2(size.x + h * 1.8, h / 2.0),
			Vector2(size.x - 1, h)]), Palette.PEACH)
	draw_colored_polygon(PackedVector2Array([Vector2(size.x + h * 1.2, h / 2.0 - h * 0.25),
			Vector2(size.x + h * 1.8, h / 2.0), Vector2(size.x + h * 1.2, h / 2.0 + h * 0.25)]), Palette.INK)
	_box(full, fill)
	draw_line(Vector2(14, h / 2.0), Vector2(size.x - 2, h / 2.0), Palette.PEACH, 1.0)
	_box(Rect2(0, 0, 9, h), Palette.PINK)
	_box(Rect2(8, 0, 5, h), Palette.MIST)


func _draw_pot() -> void:
	var stem := PackedVector2Array()
	for i in 13:
		var t := i / 12.0
		stem.append(Vector2(size.x / 2.0 + sin(t * 5.0) * 6.0, -t * 125.0))
	draw_polyline(stem, Palette.INK, 4.0)
	draw_polyline(stem, Palette.SAGE, 2.0)
	_outlined_poly(PackedVector2Array([Vector2(3, 7), Vector2(size.x - 3, 7),
			Vector2(size.x - 7, size.y), Vector2(7, size.y)]), fill)
	_box(Rect2(0, 0, size.x, 8), accent)
	draw_rect(Rect2(size.x * 0.3, size.y * 0.5, size.x * 0.4, 3), accent)


func _draw_floor() -> void:
	match floor_style:
		Floor.DESK:
			_box(Rect2(0, 7, size.x, size.y - 7), Palette.ROSE)
			var x := 20.0
			while x + 110.0 < size.x - 10.0:
				draw_rect(Rect2(x, 22, 110, 40), Palette.INK, false, 1.0)
				draw_circle(Vector2(x + 55, 42), 3.0, Palette.INK)
				draw_circle(Vector2(x + 55, 42), 2.0, Palette.BUTTER)
				x += 140.0
			_box(Rect2(0, 0, size.x, 8), Palette.PEACH)
		Floor.SHELF:
			_box(Rect2(0, 9, size.x, size.y - 9), Palette.ROSE)
			for i in 4:
				var gy := 16.0 + i * 7.0
				draw_line(Vector2(4 + i * 13, gy), Vector2(size.x - 8 - i * 21, gy), Palette.PLUM, 1.0)
			_box(Rect2(0, 0, size.x, 10), Palette.PEACH)
			draw_line(Vector2(1, 2), Vector2(size.x - 1, 2), Palette.PEACH, 1.0)
		Floor.COUNTER:
			_box(Rect2(0, 8, size.x, size.y - 8), Palette.MINT)
			var x := 14.0
			while x + 90.0 < size.x - 8.0:
				draw_rect(Rect2(x, 18, 90, 60), Palette.SAGE, false, 1.0)
				draw_rect(Rect2(x + 40, 24, 10, 3), Palette.WHITE)
				x += 104.0
			_box(Rect2(0, 0, size.x, 9), Palette.STONE)
			draw_line(Vector2(1, 2), Vector2(size.x - 1, 2), Palette.MIST, 1.0)
		Floor.BED:
			_box(Rect2(0, 6, size.x, size.y - 6), Palette.NAVY)
			var x := 0.0
			while x < size.x - 2.0:
				var qw := minf(28.0, size.x - x - 2.0)
				draw_rect(Rect2(x + 1, 7, qw, 28), Palette.BLUE)
				draw_rect(Rect2(x + 1, 37, qw, 28), Palette.BLUE)
				x += 30.0
			_rounded(Rect2(0, 0, size.x, 8), Palette.PERI, 3)
		Floor.BATH:
			# glass shelf on top, tiled vanity below
			_box(Rect2(0, 8, size.x, size.y - 8), Palette.SKY)
			var x := 0.0
			while x < size.x - 2.0:
				var tw := minf(22.0, size.x - x - 2.0)
				for ty in [10.0, 34.0, 58.0]:
					draw_rect(Rect2(x + 1, ty, tw, 22), Palette.WHITE)
				x += 24.0
			_box(Rect2(0, 0, size.x, 8), Palette.MIST)
			draw_line(Vector2(1, 2), Vector2(size.x - 1, 2), Palette.WHITE, 1.0)
			draw_line(Vector2(1, 6), Vector2(size.x - 1, 6), Palette.SKY, 1.0)
		Floor.SILL:
			# a painted wooden windowsill with the wall below
			_box(Rect2(0, 10, size.x, size.y - 10), Palette.SAGE)
			var x := 30.0
			while x < size.x - 20.0:
				draw_line(Vector2(x, 14), Vector2(x, size.y), Color(Palette.INK, 0.25), 1.0)
				x += 60.0
			_box(Rect2(0, 0, size.x, 11), Palette.WHITE)
			draw_line(Vector2(1, 8), Vector2(size.x - 1, 8), Palette.MIST, 1.0)
		Floor.WASHER:
			# the top of a washing machine: control strip, then the round door
			_box(Rect2(0, 6, size.x, size.y - 6), Palette.WHITE)
			draw_rect(Rect2(1, 7, size.x - 2, 12), Palette.MIST)
			var x := 50.0
			while x < size.x - 50.0:
				draw_circle(Vector2(x, 13), 3.5, Palette.INK)
				draw_circle(Vector2(x, 13), 2.5, Palette.SLATE)
				var c := Vector2(x + 50.0, 62)
				draw_circle(c, 32.0, Palette.INK)
				draw_circle(c, 30.0, Palette.MIST)
				draw_circle(c, 24.0, Palette.INK)
				draw_circle(c, 23.0, Palette.SKY)
				draw_arc(c, 15.0, 0.4, 2.4, 10, Palette.WHITE, 2.0)
				x += 180.0
			_box(Rect2(0, 0, size.x, 7), Palette.MIST)
			draw_line(Vector2(1, 2), Vector2(size.x - 1, 2), Palette.WHITE, 1.0)


func _draw_leaf() -> void:
	var pts := PackedVector2Array()
	var n := 12
	for i in n + 1:
		var t := float(i) / n
		pts.append(Vector2(t * size.x, size.y / 2.0 - sin(t * PI) * size.y * 0.9))
	for i in range(n - 1, 0, -1):
		var t := float(i) / n
		pts.append(Vector2(t * size.x, size.y / 2.0 + sin(t * PI) * size.y * 0.6))
	_outlined_poly(pts, fill)
	draw_line(Vector2(2, size.y / 2.0), Vector2(size.x - 4, size.y / 2.0 - 1.0), accent, 1.0)
