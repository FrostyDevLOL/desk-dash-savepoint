class_name Dripper
extends Node2D
## A leaky tap high up on the bathroom wall. Every so often a water drop falls straight down;
## a growing puddle mark on the shelf shows where it will land. Origin sits on the shelf.

const DROP_START := -160.0 # how high above the shelf the tap is (just below the HUD)
const DROP_SPEED := 260.0
const EVERY := 1.1

var _t := 0.0
var _drop_y := INF # local y of the falling drop, INF when none
var _drop: Area2D


func _ready() -> void:
	_t = randf() * EVERY
	_drop = Area2D.new()
	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 3.5
	col.shape = circle
	_drop.add_child(col)
	_drop.monitoring = false
	add_child(_drop)
	_drop.body_entered.connect(_on_drop_hit)


func _physics_process(delta: float) -> void:
	_t += delta
	if _drop_y == INF and _t >= EVERY:
		_t = 0.0
		_drop_y = DROP_START
		_drop.monitoring = true
	if _drop_y != INF:
		_drop_y += DROP_SPEED * delta
		_drop.position = Vector2(0, _drop_y)
		if _drop_y >= -3.0:
			_drop_y = INF
			_drop.set_deferred("monitoring", false)
			if _on_screen():
				Audio.play("drip", 0.1)
			Fx.burst(get_parent(), global_position + Vector2(0, -2), Palette.SKY, 5, 40.0, 70.0, 200.0, 1.5)
	queue_redraw()


func _on_screen() -> bool:
	var cam := get_viewport().get_camera_2d()
	return cam != null and absf(global_position.x - cam.get_screen_center_position().x) < 260.0


func _draw() -> void:
	var ink := Palette.INK
	# the tap, sticking out of the wall far above
	draw_rect(Rect2(-14, DROP_START - 16, 18, 7), ink)
	draw_rect(Rect2(-13, DROP_START - 15, 16, 5), Palette.MIST)
	draw_rect(Rect2(-3, DROP_START - 11, 7, 9), ink)
	draw_rect(Rect2(-2, DROP_START - 10, 5, 7), Palette.MIST)
	# warning puddle grows as the next drop gets close
	var warn := clampf(_t / EVERY, 0.0, 1.0) if _drop_y == INF else 1.0
	draw_set_transform(Vector2(0, -1), 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, 3.0 + warn * 5.0, Color(Palette.SKY, 0.35 + warn * 0.4))
	draw_set_transform(Vector2.ZERO)
	if _drop_y != INF:
		var p := Vector2(0, _drop_y)
		draw_circle(p, 3.6, ink)
		draw_colored_polygon(PackedVector2Array([p + Vector2(-2.8, -1), p + Vector2(0, -7), p + Vector2(2.8, -1)]), ink)
		draw_circle(p, 2.7, Palette.SKY)
		draw_colored_polygon(PackedVector2Array([p + Vector2(-2, -1), p + Vector2(0, -5.6), p + Vector2(2, -1)]), Palette.SKY)
		draw_circle(p + Vector2(-1, -1), 0.8, Palette.WHITE)


func _on_drop_hit(body: Node2D) -> void:
	if body is Player:
		body.die("splash")
