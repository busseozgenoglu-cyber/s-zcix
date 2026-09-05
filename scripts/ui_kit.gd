extends RefCounted
## Wordi ekranları için ortak renk paleti ve kod ile üretilen arayüz parçaları.
## main.tscn'deki stil ile aynı dil: yuvarlak köşeler, kalın renkli kenarlar, krem zemin.

const PINK := Color("#f43b69")
const ORANGE := Color("#ff9f43")
const YELLOW := Color("#ffd23f")
const GREEN := Color("#2ecc71")
const TEAL := Color("#1abc9c")
const BLUE := Color("#45aaf2")
const PURPLE := Color("#a55eea")
const DARK_PURPLE := Color("#6b459c")
const CREAM := Color("#fff7e0")
const CREAM_LIGHT := Color("#fffcef")
const TEXT_DARK := Color("#2f5d8a")
const TEXT_BROWN := Color("#d9850a")
const TILE_COLORS: Array[Color] = [
	Color(1, 0.42, 0.42), Color(1, 0.624, 0.263), Color(1, 0.824, 0.247), Color(0.18, 0.8, 0.44),
	Color(0.102, 0.737, 0.612), Color(0.271, 0.667, 0.949), Color(0.647, 0.369, 0.918), Color(1, 0.467, 0.663),
]

const PLAYFUL_BACKDROP := preload("res://scripts/playful_backdrop.gd")


static func panel_style(bg: Color, border: Color, radius := 24, border_width := 5, margin := 16.0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	sb.set_border_width_all(border_width)
	sb.border_color = border
	sb.content_margin_left = margin
	sb.content_margin_right = margin
	sb.content_margin_top = margin * 0.75
	sb.content_margin_bottom = margin * 0.75
	sb.shadow_color = Color(0.2, 0.12, 0.05, 0.18)
	sb.shadow_size = 8
	return sb


static func button_style(color: Color, radius := 20) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 20
	sb.content_margin_right = 20
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	sb.shadow_color = Color(0, 0, 0, 0.15)
	sb.shadow_size = 4
	sb.shadow_offset = Vector2(0, 3)
	return sb


## Büyük renkli düğme (menü ve sonuç ekranları için).
static func make_button(text: String, color: Color, font_size := 26, min_height := 68.0) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(0, min_height)
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.7))
	b.add_theme_stylebox_override("normal", button_style(color))
	b.add_theme_stylebox_override("hover", button_style(color.lightened(0.08)))
	b.add_theme_stylebox_override("pressed", button_style(color.darkened(0.15)))
	b.add_theme_stylebox_override("disabled", button_style(color.lerp(Color.GRAY, 0.5)))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return b


## Küçük ikincil düğme (geri, ayar).
static func make_small_button(text: String, color: Color) -> Button:
	return make_button(text, color, 18, 44.0)


static func make_label(text: String, size: int, color: Color, align := HORIZONTAL_ALIGNMENT_CENTER, wrap := true) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


## Üst şerit: [geri düğmesi] [başlık] [sağ bilgi]; tüm öğeler dikeyde ortalanır.
static func make_top_bar(back_text: String, on_back: Callable, title: String, right_text: String) -> Dictionary:
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	var back := make_small_button(back_text, DARK_PURPLE)
	back.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(on_back)
	top.add_child(back)
	var title_label := make_label(title, 34, PINK, HORIZONTAL_ALIGNMENT_CENTER, false)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.clip_text = true
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	top.add_child(title_label)
	var right := make_label(right_text, 20, DARK_PURPLE, HORIZONTAL_ALIGNMENT_RIGHT, false)
	right.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(right)
	return {"bar": top, "title": title_label, "right": right}


static func make_panel(bg := CREAM_LIGHT, border := ORANGE, radius := 24) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", panel_style(bg, border, radius))
	return p


static func full_rect(c: Control) -> Control:
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


## Ana ekranlarla aynı canlı arka planı ekler (krem zemin + hareketli desen).
static func add_backdrop(parent: Control) -> void:
	var bg := ColorRect.new()
	bg.color = Color(1, 0.92, 0.7, 1)
	parent.add_child(full_rect(bg))
	var playful := Control.new()
	playful.set_script(PLAYFUL_BACKDROP)
	parent.add_child(full_rect(playful))


## Yıldız satırı (0-3 dolu yıldız) çizen küçük kontrol.
class StarRow:
	extends Control
	var filled := 0
	var total := 3
	var star_size := 22.0
	var gap := 6.0

	func _init(p_filled := 0, p_total := 3, p_size := 22.0) -> void:
		filled = p_filled
		total = p_total
		star_size = p_size
		custom_minimum_size = Vector2(total * (star_size + gap), star_size + 4)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func set_stars(n: int) -> void:
		filled = clampi(n, 0, total)
		queue_redraw()

	func _draw() -> void:
		var start_x := (size.x - total * (star_size + gap) + gap) * 0.5
		for i in range(total):
			var center := Vector2(start_x + i * (star_size + gap) + star_size * 0.5, size.y * 0.5)
			var color := Color("#ffb703") if i < filled else Color(0.75, 0.72, 0.65, 0.6)
			_draw_star(center, star_size * 0.5, color)

	func _draw_star(center: Vector2, radius: float, color: Color) -> void:
		var pts := PackedVector2Array()
		for i in range(10):
			var r := radius if i % 2 == 0 else radius * 0.45
			var ang := -PI / 2 + i * PI / 5
			pts.append(center + Vector2(cos(ang), sin(ang)) * r)
		draw_colored_polygon(pts, color)
		draw_polyline(pts + PackedVector2Array([pts[0]]), color.darkened(0.25), 2.0, true)
