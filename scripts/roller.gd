class_name Roller
extends Area2D
## Something round rolling toward the little guy (marble, pea, button, soap bubble). Jump over it.
## It starts rolling once it's on screen and pops when it reaches stop_x.

enum Style { MARBLE, PEA, BUTTON, BUBBLE, SNAIL, LINT }

const RADIUS := {Style.MARBLE: 6.0, Style.PEA: 5.0, Style.BUTTON: 6.5, Style.BUBBLE: 8.0, Style.SNAIL: 7.0,
		Style.LINT: 7.0}

@export var style := Style.MARBLE
@export var roll_speed := 70.0
var stop_x := -INF

var _rolling := false
var _angle := 0.0
var _done := false


func _ready() -> void:
	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = RADIUS[style] - 1.0
	col.shape = circle
	add_child(col)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if _done:
		return
	if not _rolling:
		var cam := get_viewport().get_camera_2d()
		if cam and position.x < cam.get_screen_center_position().x + 250.0:
			_rolling = true
		return
	position.x -= roll_speed * delta
	_angle -= roll_speed * delta / RADIUS[style]
	queue_redraw()
	if position.x <= stop_x:
		_done = true
		set_deferred("monitoring", false)
		var tw := create_tween().set_parallel()
		tw.tween_property(self, "scale", Vector2(1.6, 1.6), 0.15)
		tw.tween_property(self, "modulate:a", 0.0, 0.15)
		tw.chain().tween_callback(queue_free)


func _draw() -> void:
	var r: float = RADIUS[style]
	var ink := Palette.INK
	draw_circle(Vector2.ZERO, r, ink)
	match style:
		Style.MARBLE:
			draw_circle(Vector2.ZERO, r - 1.0, Palette.SKY)
			var swirl := Vector2(cos(_angle), sin(_angle)) * (r - 2.5)
			draw_line(-swirl, swirl, Palette.BLUE, 1.5)
			draw_circle(Vector2(-r * 0.35, -r * 0.35), 1.2, Palette.WHITE)
		Style.PEA:
			draw_circle(Vector2.ZERO, r - 1.0, Palette.MINT)
			var spot := Vector2(cos(_angle), sin(_angle)) * (r - 2.5)
			draw_circle(spot, 1.0, Palette.SAGE)
			draw_circle(Vector2(-r * 0.3, -r * 0.35), 0.9, Palette.WHITE)
		Style.BUTTON:
			draw_circle(Vector2.ZERO, r - 1.0, Palette.PINK)
			draw_arc(Vector2.ZERO, r - 2.2, 0, TAU, 16, Palette.PLUM, 1.0)
			for i in 4:
				var a := _angle + TAU * i / 4.0 + PI / 4.0
				draw_circle(Vector2(cos(a), sin(a)) * 1.6, 0.8, ink)
		Style.SNAIL:
			# a snail doesn't roll: it slides along, its shell bobbing a little
			draw_circle(Vector2.ZERO, r - 1.0, Palette.PEACH)
			var bob := sin(_angle * 0.6) * 0.6
			var body := Rect2(-r - 6, r - 4 + bob, r * 2 + 10, 4)
			draw_rect(body.grow(1.0), ink)
			draw_rect(body, Palette.BUTTER)
			draw_circle(Vector2(-r - 5, r - 6 + bob), 3.0, ink)
			draw_circle(Vector2(-r - 5, r - 6 + bob), 2.2, Palette.BUTTER)
			draw_line(Vector2(-r - 6, r - 8 + bob), Vector2(-r - 8, r - 13), ink, 1.0)
			draw_line(Vector2(-r - 4, r - 8 + bob), Vector2(-r - 3, r - 13), ink, 1.0)
			var spiral := PackedVector2Array()
			for i in 16:
				var t := i / 15.0
				spiral.append(Vector2(cos(t * 9.0), sin(t * 9.0)) * (r - 1.5) * (1.0 - t * 0.8))
			draw_polyline(spiral, Palette.ROSE, 1.2)
		Style.LINT:
			# a fuzzy ball of dryer lint
			draw_circle(Vector2.ZERO, r - 1.0, Palette.MIST)
			for i in 10:
				var a := _angle + TAU * i / 10.0
				draw_line(Vector2(cos(a), sin(a)) * (r - 2.0), Vector2(cos(a + 0.4), sin(a + 0.4)) * (r + 1.5),
						Palette.STONE, 1.0)
			draw_circle(Vector2(1, -1), 2.0, Palette.WHITE)
		Style.BUBBLE:
			draw_circle(Vector2.ZERO, r - 1.0, Palette.WHITE)
			draw_circle(Vector2.ZERO, r - 1.6, Palette.SKY)
			draw_arc(Vector2.ZERO, r - 2.5, _angle, _angle + 2.0, 10, Palette.LILAC, 1.2)
			draw_arc(Vector2.ZERO, r - 2.5, _angle + PI, _angle + PI + 1.6, 10, Palette.MINT, 1.2)
			draw_circle(Vector2(-r * 0.35, -r * 0.4), 1.6, Palette.WHITE)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()
