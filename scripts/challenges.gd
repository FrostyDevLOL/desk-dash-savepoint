class_name Challenges
## Daily challenge templates. Three are picked each day (the same three all day), each with a
## target and a crumb reward from one of three tiers. Ids are saved, so don't rename them.

const TEMPLATES := [
	{"id": "crumbs", "stat": "crumbs", "one": "grab %d crumbs in one run", "many": "grab %d crumbs in one run",
			"targets": [25, 40, 60], "rewards": [25, 40, 60]},
	{"id": "cm", "stat": "cm", "one": "run %d cm in one run", "many": "run %d cm in one run",
			"targets": [300, 550, 900], "rewards": [25, 45, 70]},
	{"id": "landings", "stat": "landings", "one": "nail %d landing zone", "many": "nail %d landing zones in one run",
			"targets": [1, 2, 3], "rewards": [30, 50, 80]},
	{"id": "bounces", "stat": "bounces", "one": "bounce %d time", "many": "bounce %d times in one run",
			"targets": [3, 5, 8], "rewards": [25, 40, 60]},
	{"id": "powerups", "stat": "powerups", "one": "grab %d power-up", "many": "grab %d power-ups in one run",
			"targets": [1, 2, 3], "rewards": [25, 40, 60]},
	{"id": "doors", "stat": "doors", "one": "go through %d doorway", "many": "go through %d doorways in one run",
			"targets": [1, 2, 4], "rewards": [25, 45, 80]},
	{"id": "escapes", "stat": "escapes", "one": "escape the vacuum", "many": "escape the vacuum %d times",
			"targets": [1, 1, 2], "rewards": [40, 40, 80]},
	{"id": "stickers", "stat": "stickers", "one": "find a sticker", "many": "find %d stickers in one run",
			"targets": [1, 1, 2], "rewards": [30, 30, 60]},
	{"id": "today", "stat": "today_crumbs", "one": "collect %d crumbs today", "many": "collect %d crumbs today",
			"targets": [80, 130, 200], "rewards": [30, 50, 75]},
]


static func find(id: String) -> Dictionary:
	for t in TEMPLATES:
		if t.id == id:
			return t
	return TEMPLATES[0]


static func describe(ch: Dictionary) -> String:
	var t := find(ch.id)
	var fmt: String = t.one if ch.target == 1 else t.many
	return fmt % ch.target if "%d" in fmt else fmt


## Picks today's three challenges. The same date always gives the same three.
static func generate(date: String) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(date)
	var pool := TEMPLATES.duplicate()
	var picked := []
	for i in 3:
		var t: Dictionary = pool.pop_at(rng.randi_range(0, pool.size() - 1))
		var tier := rng.randi_range(0, 2)
		picked.append({"id": t.id, "target": t.targets[tier], "reward": t.rewards[tier], "done": false})
	return picked
