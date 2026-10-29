class_name Thumbtack
extends Area2D
## Something pointy. Origin sits on the surface. Each zone has its own style.

enum Style { TACK, FORK, PIN, CACTUS, COMB, THORN, SAFETY_PIN }

## Width each style takes up, used when laying out obstacles.
const WIDTHS := {Style.TACK: 12.0, Style.FORK: 16.0, Style.PIN: 9.0, Style.CACTUS: 18.0, Style.COMB: 30.0,
		Style.THORN: 22.0, Style.SAFETY_PIN: 14.0}

@export var style := Style.TACK
@export var color := Color("dc94d4")


func _ready() -> void:
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	match style:
		Style.FORK:
			rect.size = Vector2(12, 12)
		Style.PIN:
			rect.size = Vector2(6, 13)
		Style.CACTUS:
			rect.size = Vector2(14, 30)
		Style.COMB:
			rect.size = Vector2(26, 10)
		Style.THORN:
			rect.size = Vector2(18, 9)
		Style.SAFETY_PIN:
			rect.size = Vector2(9, 13)
		_:
			rect.size = Vector2(8, 7)
	col.shape = rect
	col.position = Vector2(0, -rect.size.y / 2.0)
	add_child(col)
	body_entered.connect(_on_body_entered)


func _draw() -> void:
	var ink := Palette.INK
	match style:
		Style.TACK:
			draw_line(Vector2(0, -3), Vector2(0, -11), ink, 2.0)
			draw_line(Vector2(0, -3), Vector2(0, -10.5), Palette.MIST, 1.0)
			draw_rect(Rect2(-5, -4, 10, 4), ink)
			draw_rect(Rect2(-4, -3, 8, 2), color)
			draw_rect(Rect2(-2, -6, 4, 3), ink)
			draw_rect(Rect2(-1, -5, 2, 2), color)
		Style.FORK:
			# an upturned fork: four silver tines
			draw_rect(Rect2(-7, -4, 14, 4), ink)
			draw_rect(Rect2(-6, -3, 12, 2), Palette.MIST)
			for i in 4:
				var x := -5.5 + i * 3.6
				draw_line(Vector2(x, -3), Vector2(x, -13), ink, 2.0)
				draw_line(Vector2(x, -3), Vector2(x, -12.5), Palette.WHITE, 1.0)
		Style.PIN:
			# a sewing pin sticking up out of the blanket
			draw_line(Vector2(0, 0), Vector2(0, -13), ink, 2.0)
			draw_line(Vector2(0, -1), Vector2(0, -12.5), Palette.MIST, 1.0)
			draw_circle(Vector2(0, -2), 3.0, ink)
			draw_circle(Vector2(0, -2), 2.2, color)
		Style.THORN:
			# a thorny twig lying on the sill
			draw_line(Vector2(-11, -2), Vector2(11, -3), ink, 3.0)
			draw_line(Vector2(-11, -2), Vector2(11, -3), Palette.ROSE, 1.5)
			for tx in [-8.0, -2.0, 4.0, 9.0]:
				var up := 1.0 if int(tx) % 2 == 0 else -1.0
				_thorn(Vector2(tx, -2.5), Vector2(2.0 * up, -7.0))
		Style.SAFETY_PIN:
			# an open safety pin standing point-up
			draw_arc(Vector2(0, -2.5), 2.5, 0, PI, 8, ink, 1.5)
			draw_line(Vector2(-2.5, -2.5), Vector2(-2.5, -11), ink, 1.5)
			draw_line(Vector2(2.5, -2.5), Vector2(4.5, -13), ink, 1.5)
			draw_line(Vector2(2.5, -2.5), Vector2(4.5, -13), Palette.MIST, 0.8)
			draw_rect(Rect2(-4.5, -13, 4, 3), ink)
			draw_rect(Rect2(-4, -12.5, 3, 2), color)
		Style.COMB:
			# a comb lying on its back, teeth pointing up
			draw_rect(Rect2(-15, -4, 30, 4), ink)
			draw_rect(Rect2(-14, -3, 28, 2), color)
			var tx := -13.0
			while tx < 13.5:
				draw_rect(Rect2(tx - 0.5, -11, 2, 8), ink)
				draw_rect(Rect2(tx, -10.5, 1, 7), color)
				tx += 3.0
		Style.CACTUS:
			draw_rect(Rect2(-8, -8, 16, 8), ink)
			draw_rect(Rect2(-7, -7, 14, 7), Palette.ROSE)
			draw_rect(Rect2(-8, -9, 16, 2), ink)
			var body := StyleBoxFlat.new()
			body.bg_color = Palette.SAGE
			body.border_color = ink
			body.set_border_width_all(1)
			body.set_corner_radius_all(4)
			draw_style_box(body, Rect2(-4, -30, 8, 22))
			draw_style_box(body, Rect2(-9, -24, 5, 9))
			draw_style_box(body, Rect2(4, -27, 5, 9))
			for p in [Vector2(-1, -26), Vector2(1, -20), Vector2(-1, -14), Vector2(-7, -21), Vector2(6, -24)]:
				draw_rect(Rect2(p, Vector2(1, 1)), Palette.WHITE)


func _thorn(base: Vector2, tip: Vector2) -> void:
	draw_colored_polygon(PackedVector2Array([base + Vector2(-1.8, 0), base + Vector2(1.8, 0), base + tip]),
			Palette.INK)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()
