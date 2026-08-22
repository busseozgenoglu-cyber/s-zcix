extends Control
## Gentle idle motion for the background animal decorations.
## Each direct child TextureRect gets a soft bob, a slight side-to-side
## sway, and an occasional blink. Motion is kept subtle so the 5x5 word
## board and its letters stay fully readable.

const BOB_AMPLITUDE := 7.0
const BOB_SPEED := 1.3
const SWAY_AMPLITUDE := 0.04
const SWAY_SPEED := 0.8
const BLINK_SPEED := 0.55
const BREATHE_AMPLITUDE := 0.035
const BREATHE_SPEED := 1.1
const HOP_AMPLITUDE := 14.0
const HOP_SPEED := 0.4
const DRIFT_AMPLITUDE := 10.0
const DRIFT_SPEED := 0.35

var _animals: Array[TextureRect] = []
var _base_positions: Array[Vector2] = []

func _ready() -> void:
	for child in get_children():
		if child is TextureRect:
			_animals.append(child)
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Wait one frame so anchored controls have resolved their layout,
	# then record each animal's resting position as the animation baseline.
	await get_tree().process_frame
	for animal in _animals:
		_base_positions.append(animal.position)

func _process(_delta: float) -> void:
	if _animals.is_empty() or _base_positions.size() != _animals.size():
		return
	var t := Time.get_ticks_msec() / 1000.0
	for i in _animals.size():
		var animal := _animals[i]
		var phase := float(i) * 1.9
		animal.pivot_offset = animal.size * 0.5
		# Gentle side drift plus the soft up/down bob for a more lively idle.
		animal.position.x = _base_positions[i].x + sin((t + phase) * DRIFT_SPEED) * DRIFT_AMPLITUDE
		animal.position.y = _base_positions[i].y + sin((t + phase) * BOB_SPEED) * BOB_AMPLITUDE
		animal.rotation = sin((t + phase) * SWAY_SPEED) * SWAY_AMPLITUDE
		# Occasional quick blink: briefly squash the sprite vertically.
		var blink := pow(0.5 + 0.5 * cos((t + phase) * BLINK_SPEED), 60.0)
		# Slow breathing scale plus an occasional playful hop.
		var breathe := 1.0 + sin((t + phase) * BREATHE_SPEED) * BREATHE_AMPLITUDE
		var hop := pow(0.5 + 0.5 * cos((t + phase) * HOP_SPEED), 24.0)
		animal.position.y -= hop * HOP_AMPLITUDE
		animal.scale = Vector2(breathe, breathe * (1.0 - 0.16 * blink))
