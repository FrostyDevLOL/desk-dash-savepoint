class_name Stickers
## The sticker album: six stickers per room, each showing a real object from that room.
## Ids are saved, so don't rename them. Each sticker's "art" says how to build its picture:
##   ["obj", Kind name, Vector2 size, fill, accent]  a GiantObject
##   ["spike", Style name, color]                     a Thumbtack
##   ["roller", Style name]                           a Roller
##   ["sprite", texture path]                         an image

const SET_BONUS := 100 # crumbs for finishing a room's page

const SETS := [
	[
		{"id": "desk_book", "name": "big book", "art": ["obj", "BOOK", Vector2(64, 22), "BLUE", "BUTTER"]},
		{"id": "desk_mug", "name": "giant mug", "art": ["obj", "MUG", Vector2(34, 40), "WHITE", "PINK"]},
		{"id": "desk_pencil", "name": "pencil", "art": ["obj", "PENCIL", Vector2(60, 8), "BUTTER", "PEACH"]},
		{"id": "desk_eraser", "name": "eraser", "art": ["obj", "ERASER", Vector2(36, 13), "PINK", "MIST"]},
		{"id": "desk_tack", "name": "thumbtack", "art": ["spike", "TACK", "TEAL"]},
		{"id": "desk_notepad", "name": "sticky notes", "art": ["obj", "NOTEPAD", Vector2(48, 16), "BUTTER", "WHITE"]},
	],
	[
		{"id": "shelf_upright", "name": "tall book", "art": ["obj", "BOOK", Vector2(20, 54), "SAGE", "WHITE"]},
		{"id": "shelf_bookend", "name": "bookend", "art": ["obj", "BOOKEND", Vector2(10, 46), "SLATE", "PERI"]},
		{"id": "shelf_cactus", "name": "cactus", "art": ["spike", "CACTUS", "PINK"]},
		{"id": "shelf_marble", "name": "marble", "art": ["roller", "MARBLE"]},
		{"id": "shelf_novel", "name": "comfy novel", "art": ["obj", "BOOK", Vector2(52, 18), "VIOLET", "BUTTER"]},
		{"id": "shelf_chipitos", "name": "chipitos", "art": ["sprite", "res://sprites/chip_bag.png"]},
	],
	[
		{"id": "kitchen_plate", "name": "plate", "art": ["obj", "PLATE", Vector2(60, 8), "WHITE", "SKY"]},
		{"id": "kitchen_sugar", "name": "sugar cube", "art": ["obj", "SUGAR", Vector2(20, 20), "WHITE", "MIST"]},
		{"id": "kitchen_board", "name": "cutting board", "art": ["obj", "BOARD", Vector2(60, 13), "PEACH", "ROSE"]},
		{"id": "kitchen_fork", "name": "fork", "art": ["spike", "FORK", "PINK"]},
		{"id": "kitchen_pea", "name": "runaway pea", "art": ["roller", "PEA"]},
		{"id": "kitchen_marshmallow", "name": "marshmallow", "art": ["obj", "MARSHMALLOW", Vector2(30, 20), "WHITE", "PINK"]},
	],
	[
		{"id": "bed_pillow", "name": "pillow", "art": ["obj", "PILLOW", Vector2(62, 24), "PERI", "LILAC"]},
		{"id": "bed_phone", "name": "phone", "art": ["obj", "PHONE", Vector2(60, 8), "INK", "SKY"]},
		{"id": "bed_sock", "name": "lost sock", "art": ["obj", "SOCK", Vector2(50, 16), "TEAL", "BUTTER"]},
		{"id": "bed_pin", "name": "sewing pin", "art": ["spike", "PIN", "PINK"]},
		{"id": "bed_button", "name": "button", "art": ["roller", "BUTTON"]},
		{"id": "bed_landing", "name": "landing zone", "art": ["sprite", "res://sprites/landing_sign.png"]},
	],
	[
		{"id": "bath_soap", "name": "soap", "art": ["obj", "SOAP", Vector2(50, 16), "PINK", "WHITE"]},
		{"id": "bath_brush", "name": "toothbrush", "art": ["obj", "TOOTHBRUSH", Vector2(28, 17), "TEAL", "WHITE"]},
		{"id": "bath_bottle", "name": "shampoo", "art": ["obj", "BOTTLE", Vector2(30, 46), "SKY", "PLUM"]},
		{"id": "bath_duck", "name": "rubber duck", "art": ["obj", "DUCK", Vector2(36, 24), "BUTTER", "PEACH"]},
		{"id": "bath_comb", "name": "comb", "art": ["spike", "COMB", "LILAC"]},
		{"id": "bath_bubble", "name": "bubble", "art": ["roller", "BUBBLE"]},
	],
	[
		{"id": "sill_pot", "name": "flower pot", "art": ["obj", "POT", Vector2(40, 30), "ROSE", "PEACH"]},
		{"id": "sill_can", "name": "watering can", "art": ["obj", "CAN", Vector2(44, 34), "TEAL", "BUTTER"]},
		{"id": "sill_mushroom", "name": "toadstool", "art": ["obj", "MUSHROOM", Vector2(30, 24), "SALMON", "WHITE"]},
		{"id": "sill_snail", "name": "snail", "art": ["roller", "SNAIL"]},
		{"id": "sill_thorn", "name": "thorny twig", "art": ["spike", "THORN", "ROSE"]},
		{"id": "sill_leaf", "name": "leaf", "art": ["obj", "LEAF", Vector2(40, 12), "MINT", "SAGE"]},
	],
	[
		{"id": "laundry_basket", "name": "laundry basket", "art": ["obj", "BASKET", Vector2(56, 26), "PEACH", "PINK"]},
		{"id": "laundry_towel", "name": "fluffy towel", "art": ["obj", "TOWEL", Vector2(56, 14), "SKY", "WHITE"]},
		{"id": "laundry_soap", "name": "detergent", "art": ["obj", "BOX", Vector2(34, 40), "TEAL", "WHITE"]},
		{"id": "laundry_pin", "name": "safety pin", "art": ["spike", "SAFETY_PIN", "BUTTER"]},
		{"id": "laundry_lint", "name": "lint ball", "art": ["roller", "LINT"]},
		{"id": "laundry_sponge", "name": "sponge", "art": ["obj", "SPONGE", Vector2(40, 14), "BUTTER", "SAGE"]},
	],
]


static func total() -> int:
	var n := 0
	for s in SETS:
		n += s.size()
	return n


static func find(id: String) -> Dictionary:
	for s in SETS:
		for st in s:
			if st.id == id:
				return st
	return {}


static func zone_of(id: String) -> int:
	for z in SETS.size():
		for st in SETS[z]:
			if st.id == id:
				return z
	return -1


static func _color(name: String) -> Color:
	return Palette.get_script().get_script_constant_map()[name]


## Builds a picture of the sticker's object, centred on (0, 0) and scaled to fit fit_size.
static func make_art(sticker: Dictionary, fit_size: Vector2) -> Node2D:
	var holder := Node2D.new()
	var art: Array = sticker.art
	var node: Node2D
	var bounds := Vector2(20, 20)
	match art[0]:
		"obj":
			var o := GiantObject.new()
			o.kind = GiantObject.Kind[art[1]]
			o.size = art[2]
			o.fill = _color(art[3])
			o.accent = _color(art[4])
			o.solid = false
			o.position = -o.size / 2.0
			bounds = o.size
			node = o
		"spike":
			var t := Thumbtack.new()
			t.style = Thumbtack.Style[art[1]]
			t.color = _color(art[2])
			t.monitoring = false
			var h := 30.0 if t.style == Thumbtack.Style.CACTUS else 13.0
			t.position = Vector2(0, h / 2.0)
			bounds = Vector2(Thumbtack.WIDTHS[t.style], h)
			node = t
		"roller":
			var r := Roller.new()
			r.style = Roller.Style[art[1]]
			r.monitoring = false
			r.process_mode = Node.PROCESS_MODE_DISABLED # it would roll off its sticker otherwise
			bounds = Vector2(RADIUS_PAD, RADIUS_PAD) * 2.0
			node = r
		"sprite":
			var s := Sprite2D.new()
			s.texture = load(art[1])
			bounds = s.texture.get_size()
			node = s
	holder.add_child(node)
	var k := minf(fit_size.x / bounds.x, fit_size.y / bounds.y)
	holder.scale = Vector2.ONE * minf(k, 3.0)
	return holder


const RADIUS_PAD := 11.0
