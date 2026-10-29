class_name StickerPickup
extends Area2D
## A shiny sticker floating somewhere in a room. Grab it to add it to the album.
## Origin is the middle of the sticker.

signal picked(sticker_id: String)

var sticker_id := ""

var _t := 0.0
var _taken := false
var _art: Node2D


func _ready() -> void:
	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 11.0
	col.shape = circle
	add_child(col)
	body_entered.connect(_on_body_entered)
	_art = Stickers.make_art(Stickers.find(sticker_id), Vector2(14, 14))
	_art.z_index = 1
	add_child(_art)


func _process(delta: float) -> void:
	_t += delta
	# a slow flip and a bob, like a foil sticker catching the light
	var flip := cos(_t * 2.5)
	scale.x = maxf(0.15, absf(flip))
	position.y += sin(_t * 3.0) * 0.15
	queue_redraw()


func _draw() -> void:
	var ink := Palette.INK
	var rainbow := [Palette.PINK, Palette.BUTTER, Palette.MINT, Palette.SKY, Palette.LILAC]
	draw_circle(Vector2.ZERO, 13.0 + sin(_t * 5.0), Color(Palette.WHITE, 0.4))
	draw_rect(Rect2(-11, -11, 22, 22), ink)
	draw_rect(Rect2(-10, -10, 20, 20), rainbow[int(_t * 4.0) % rainbow.size()])
	draw_rect(Rect2(-8, -8, 16, 16), Palette.WHITE)
	# a corner peeling up
	draw_colored_polygon(PackedVector2Array([Vector2(4, -10), Vector2(10, -10), Vector2(10, -4)]), Palette.MIST)


func _on_body_entered(body: Node2D) -> void:
	if _taken or not body is Player:
		return
	_taken = true
	Audio.play("challenge", 0.0, 1.2)
	Fx.burst(get_parent(), global_position, Palette.BUTTER, 12, 90.0, 180.0, 60.0, 2.0)
	Fx.burst(get_parent(), global_position, Palette.PINK, 10, 90.0, 180.0, 60.0, 2.0)
	picked.emit(sticker_id)
	set_deferred("monitoring", false)
	var tw := create_tween().set_parallel()
	tw.tween_property(self, "scale", Vector2(2.4, 2.4), 0.25)
	tw.tween_property(self, "modulate:a", 0.0, 0.25)
	tw.chain().tween_callback(queue_free)
