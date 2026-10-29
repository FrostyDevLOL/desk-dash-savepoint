class_name PowerUp
extends Area2D
## A floating power-up. Origin is the middle of it.
##   shield: a pink gumball that survives one hit
##   magnet: a little horseshoe magnet that pulls crumbs in
##   double: a golden sugar cube that makes crumbs count double

signal picked(kind: String)

const KINDS := ["shield", "magnet", "double"]
const NAMES := {"shield": "gumball shield!", "magnet": "crumb magnet!", "double": "double crumbs!"}

@export var kind := "shield"

var _t := 0.0
var _taken := false


func _ready() -> void:
	_t = randf() * TAU
	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 10.0
	col.shape = circle
	add_child(col)
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var off := Vector2(0, sin(_t * 3.0) * 2.5)
	# soft glow ring so it reads as special
	draw_circle(off, 11.0 + sin(_t * 6.0), Color(Palette.WHITE, 0.35))
	var ink := Palette.INK
	match kind:
		"shield":
			draw_circle(off, 7.0, ink)
			draw_circle(off, 6.0, Palette.PINK)
			draw_circle(off + Vector2(-2, -2), 1.8, Palette.WHITE)
		"magnet":
			draw_arc(off + Vector2(0, -1), 5.0, 0, PI, 12, ink, 5.0)
			draw_arc(off + Vector2(0, -1), 5.0, 0, PI, 12, Palette.SALMON, 3.0)
			draw_rect(Rect2(off + Vector2(-7.5, -6), Vector2(5, 5)), ink)
			draw_rect(Rect2(off + Vector2(2.5, -6), Vector2(5, 5)), ink)
			draw_rect(Rect2(off + Vector2(-6.5, -5), Vector2(3, 3)), Palette.MIST)
			draw_rect(Rect2(off + Vector2(3.5, -5), Vector2(3, 3)), Palette.MIST)
		"double":
			draw_rect(Rect2(off + Vector2(-6, -6), Vector2(12, 12)), ink)
			draw_rect(Rect2(off + Vector2(-5, -5), Vector2(10, 10)), Palette.BUTTER)
			draw_rect(Rect2(off + Vector2(-3, -3), Vector2(2, 2)), Palette.WHITE)
			draw_rect(Rect2(off + Vector2(1, 1), Vector2(2, 2)), Palette.PEACH)


func _on_body_entered(body: Node2D) -> void:
	if _taken or not body is Player:
		return
	_taken = true
	body.give_powerup(kind)
	Audio.play("powerup")
	Fx.burst(get_parent(), global_position, Palette.WHITE, 14, 90.0, 180.0, 60.0, 2.0)
	picked.emit(kind)
	set_deferred("monitoring", false)
	var tw := create_tween().set_parallel()
	tw.tween_property(self, "scale", Vector2(2.2, 2.2), 0.2)
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	tw.chain().tween_callback(queue_free)
