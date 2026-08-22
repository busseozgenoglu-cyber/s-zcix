@tool
extends Control
## Playful animated background for the Word Blast word game.
##
## Paints a soft sky-to-cream gradient plus procedural bubbles, twinkling
## stars, falling confetti, drifting clouds, and gently pulsing color glows.
## Every element is drawn with built-in Godot primitives each frame, so no
## nodes are created at runtime and the animation stays lightweight and
## bounded. The layer is a full-rect Control whose mouse_filter is IGNORE, so
## it can never block the board tiles, HUD, hint panel, reveal overlay, or
## paywall overlay. With @tool the editor preview shows the same rich art.

const BUBBLE_COUNT := 16
const STAR_COUNT := 14
const CONFETTI_COUNT := 26
const CLOUD_COUNT := 5
const PULSE_COUNT := 6
const GLOW_STEPS := 5

const _BUBBLE_COLORS: Array[Color] = [
	Color(0.62, 0.85, 1.0, 0.6),
	Color(1.0, 0.75, 0.86, 0.55),
	Color(0.7, 0.92, 0.98, 0.6),
	Color(1.0, 0.9, 0.75, 0.55),
	Color(0.82, 0.78, 1.0, 0.55),
]

const _STAR_COLORS: Array[Color] = [
	Color(1.0, 0.84, 0.3, 0.95),
	Color(1.0, 0.95, 0.7, 0.95),
	Color(1.0, 0.72, 0.36, 0.95),
]

const _CONFETTI_COLORS: Array[Color] = [
	Color(1.0, 0.42, 0.42, 0.9),
	Color(1.0, 0.65, 0.25, 0.9),
	Color(1.0, 0.85, 0.3, 0.9),
	Color(0.35, 0.8, 0.5, 0.9),
	Color(0.35, 0.72, 1.0, 0.9),
	Color(0.7, 0.45, 0.95, 0.9),
	Color(1.0, 0.55, 0.75, 0.9),
]

const _PULSE_COLORS: Array[Color] = [
	Color(1.0, 0.55, 0.75, 0.3),
	Color(0.5, 0.9, 0.72, 0.28),
	Color(0.55, 0.78, 1.0, 0.28),
	Color(0.85, 0.7, 1.0, 0.28),
	Color(1.0, 0.85, 0.5, 0.28),
	Color(0.95, 0.65, 0.4, 0.26),
]

class Bubble:
	var x: float
	var y: float
	var r: float
	var speed: float
	var phase: float
	var color: Color

	func _init(px: float, py: float, pr: float, ps: float, pph: float, pcol: Color) -> void:
		x = px
		y = py
		r = pr
		speed = ps
		phase = pph
		color = pcol

class Star:
	var x: float
	var y: float
	var r: float
	var twinkle: float
	var phase: float
	var color: Color

	func _init(px: float, py: float, pr: float, pt: float, pph: float, pcol: Color) -> void:
		x = px
		y = py
		r = pr
		twinkle = pt
		phase = pph
		color = pcol

class Confetti:
	var x: float
	var y: float
	var r: float
	var fall: float
	var sway: float
	var spin: float
	var phase: float
	var kind: int
	var color: Color

	func _init(px: float, py: float, pr: float, pf: float, ps: float, psp: float, pph: float, pk: int, pcol: Color) -> void:
		x = px
		y = py
		r = pr
		fall = pf
		sway = ps
		spin = psp
		phase = pph
		kind = pk
		color = pcol

class Cloud:
	var x: float
	var y: float
	var r: float
	var speed: float

	func _init(px: float, py: float, pr: float, ps: float) -> void:
		x = px
		y = py
		r = pr
		speed = ps

class Pulse:
	var x: float
	var y: float
	var r: float
	var speed: float
	var phase: float
	var color: Color

	func _init(px: float, py: float, pr: float, ps: float, pph: float, pcol: Color) -> void:
		x = px
		y = py
		r = pr
		speed = ps
		phase = pph
		color = pcol

var _gradient: GradientTexture2D
var _bubbles: Array[Bubble] = []
var _stars: Array[Star] = []
var _confetti: Array[Confetti] = []
var _clouds: Array[Cloud] = []
var _pulses: Array[Pulse] = []
var _time := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_gradient()
	_build_elements()
	resized.connect(_on_resized)
	queue_redraw()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_time += delta
	queue_redraw()

func _on_resized() -> void:
	queue_redraw()

func _build_gradient() -> void:
	var g := Gradient.new()
	g.set_color(0, Color("#8ecdf0"))
	g.set_color(1, Color("#fff3d1"))
	_gradient = GradientTexture2D.new()
	_gradient.gradient = g
	_gradient.fill_from = Vector2(0.5, 0.0)
	_gradient.fill_to = Vector2(0.5, 1.0)

func _build_elements() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20240613
	for i in range(BUBBLE_COUNT):
		_bubbles.append(Bubble.new(
			rng.randf(),
			rng.randf(),
			rng.randf_range(0.014, 0.042),
			rng.randf_range(0.03, 0.09),
			rng.randf_range(0.0, TAU),
			_BUBBLE_COLORS[i % _BUBBLE_COLORS.size()],
		))
	for i in range(STAR_COUNT):
		_stars.append(Star.new(
			rng.randf(),
			rng.randf_range(0.0, 0.6),
			rng.randf_range(0.01, 0.024),
			rng.randf_range(1.5, 3.5),
			rng.randf_range(0.0, TAU),
			_STAR_COLORS[i % _STAR_COLORS.size()],
		))
	for i in range(CONFETTI_COUNT):
		_confetti.append(Confetti.new(
			rng.randf(),
			rng.randf(),
			rng.randf_range(0.005, 0.012),
			rng.randf_range(0.05, 0.16),
			rng.randf_range(0.8, 2.2),
			rng.randf_range(-3.0, 3.0),
			rng.randf_range(0.0, TAU),
			rng.randi_range(0, 2),
			_CONFETTI_COLORS[i % _CONFETTI_COLORS.size()],
		))
	for _i in range(CLOUD_COUNT):
		_clouds.append(Cloud.new(
			rng.randf(),
			rng.randf_range(0.04, 0.34),
			rng.randf_range(0.05, 0.085),
			rng.randf_range(0.008, 0.025),
		))
	for i in range(PULSE_COUNT):
		_pulses.append(Pulse.new(
			rng.randf(),
			rng.randf_range(0.1, 0.9),
			rng.randf_range(0.16, 0.36),
			rng.randf_range(0.25, 0.6),
			rng.randf_range(0.0, TAU),
			_PULSE_COLORS[i % _PULSE_COLORS.size()],
		))

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var ref := minf(size.x, size.y)
	if _gradient != null:
		draw_texture_rect(_gradient, Rect2(Vector2.ZERO, size), false)
	_draw_pulses(ref)
	_draw_clouds(ref)
	_draw_confetti(ref)
	_draw_bubbles(ref)
	_draw_stars(ref)

func _draw_pulses(ref: float) -> void:
	for p in _pulses:
		var pulse := 0.5 + 0.5 * sin(_time * p.speed + p.phase)
		var radius := p.r * ref * (1.0 + 0.22 * pulse)
		var alpha := p.color.a * (0.7 + 0.3 * pulse)
		_draw_glow(Vector2(p.x * size.x, p.y * size.y), radius, Color(p.color.r, p.color.g, p.color.b, alpha))

func _draw_clouds(ref: float) -> void:
	var white := Color(1.0, 1.0, 1.0, 0.92)
	for c in _clouds:
		var x := fposmod(c.x + _time * c.speed, 1.2) - 0.1
		_draw_cloud(Vector2(x * size.x, c.y * size.y), c.r * ref, white)

func _draw_confetti(ref: float) -> void:
	for k in _confetti:
		var y := fposmod(k.y + _time * k.fall, 1.0)
		var x := fposmod(k.x + sin(_time * k.sway + k.phase) * 0.04, 1.0)
		var ang := _time * k.spin + k.phase
		_draw_confetti_piece(Vector2(x * size.x, y * size.y), k.r * ref, k.color, ang, k.kind)

func _draw_bubbles(ref: float) -> void:
	for b in _bubbles:
		var y := fposmod(b.y - _time * b.speed, 1.0)
		var c := Vector2(b.x * size.x, y * size.y)
		var r := b.r * ref
		var col := b.color
		draw_circle(c, r, Color(col.r, col.g, col.b, col.a * 0.2))
		draw_arc(c, r, 0.0, TAU, 28, col, 1.6, true)
		draw_circle(c + Vector2(-r * 0.35, -r * 0.4), r * 0.2, Color(1.0, 1.0, 1.0, 0.75))

func _draw_stars(ref: float) -> void:
	for s in _stars:
		var tw := 0.55 + 0.45 * sin(_time * s.twinkle + s.phase)
		var c := Vector2(s.x * size.x, s.y * size.y)
		_draw_star(c, s.r * ref, Color(s.color.r, s.color.g, s.color.b, s.color.a * tw))

func _draw_glow(center: Vector2, radius: float, color: Color) -> void:
	for i in range(GLOW_STEPS):
		var t := float(i) / float(GLOW_STEPS - 1)
		var r := radius * (1.0 - 0.82 * t)
		var a := color.a * (0.12 + 0.88 * t)
		draw_circle(center, r, Color(color.r, color.g, color.b, a))

func _draw_star(center: Vector2, radius: float, color: Color) -> void:
	var pts := PackedVector2Array()
	var inner := radius * 0.45
	for k in range(10):
		var ang := -PI * 0.5 + float(k) * PI / 5.0
		var rr := radius if k % 2 == 0 else inner
		pts.append(center + Vector2(cos(ang), sin(ang)) * rr)
	draw_colored_polygon(pts, color)

func _draw_confetti_piece(center: Vector2, half_size: float, color: Color, ang: float, kind: int) -> void:
	var h := half_size
	if kind == 0:
		draw_colored_polygon(PackedVector2Array([
			center + Vector2(-h, -h).rotated(ang),
			center + Vector2(h, -h).rotated(ang),
			center + Vector2(h, h).rotated(ang),
			center + Vector2(-h, h).rotated(ang),
		]), color)
	elif kind == 1:
		draw_colored_polygon(PackedVector2Array([
			center + Vector2(0.0, -h * 1.4).rotated(ang),
			center + Vector2(h, h).rotated(ang),
			center + Vector2(-h, h).rotated(ang),
		]), color)
	else:
		draw_circle(center, h, color)

func _draw_cloud(center: Vector2, s: float, color: Color) -> void:
	draw_circle(center, s * 0.5, color)
	draw_circle(center + Vector2(s * 0.45, 0.0), s * 0.4, color)
	draw_circle(center + Vector2(-s * 0.45, 0.0), s * 0.4, color)
	draw_circle(center + Vector2(s * 0.2, -s * 0.32), s * 0.42, color)
	draw_circle(center + Vector2(s * 0.28, s * 0.16), s * 0.46, color)
