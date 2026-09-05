@tool
class_name WordIllustration
extends Control
## Draws a simple colorful icon for a supported vocabulary word.
## Uses only built-in Godot drawing primitives. No external art assets.

const WordBank := preload("res://data/word_bank.gd")

var word_key := ""
## Category key used by the drawing and reported by behavior probes so the
## reveal state can be verified ("cat", "animal", "profession", "color", ...).
var illustration_kind := ""


func set_word(key: String) -> void:
	word_key = key
	illustration_kind = _resolve_kind(key)
	queue_redraw()


func _resolve_kind(word: String) -> String:
	match word:
		"CAT":
			return "cat"
		"DOG":
			return "dog"
		"SUN":
			return "sun"
		"MOON":
			return "moon"
		"STAR":
			return "star"
		"TREE":
			return "tree"
		"FISH":
			return "fish"
		"BOOK":
			return "book"
		"BALL":
			return "ball"
		"HOME", "HOUSE":
			return "home"
		"APPLE":
			return "apple"
		"RED", "BLUE", "GREEN":
			return "color"
		"DUCK":
			return "duck"
		"BIRD", "OWL", "HEN", "CROW", "SWAN", "DOVE":
			return "bird"
		"EGG":
			return "egg"
		"MILK":
			return "milk"
		"CAKE":
			return "cake"
		"CAR":
			return "car"
		"FLOWER":
			return "flower"
		"CLOUD":
			return "cloud"
		"RAIN":
			return "rain"
		"HAT", "CAP":
			return "hat"
		"KEY":
			return "key"
		"CUP", "MUG":
			return "cup"
		_:
			return WordBank.get_illustration_kind(word)


func _color_for(word: String) -> Color:
	match word:
		"RED":
			return Color("#e63946")
		"BLUE":
			return Color("#3a86ff")
		"GREEN":
			return Color("#2a9d4e")
		_:
			return Color("#7f6bd6")


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	if word_key == "":
		_draw_badge("?")
		return
	match illustration_kind:
		"cat":
			_draw_cat()
		"dog":
			_draw_dog()
		"sun":
			_draw_sun()
		"moon":
			_draw_moon()
		"star":
			_draw_star()
		"tree":
			_draw_tree()
		"fish":
			_draw_fish()
		"book":
			_draw_book()
		"ball":
			_draw_ball()
		"home":
			_draw_home()
		"apple":
			_draw_apple()
		"color":
			_draw_color_swatch(_color_for(word_key))
		"animal":
			_draw_animal()
		"profession":
			_draw_profession()
		"body":
			_draw_body()
		"food":
			_draw_food()
		"furniture":
			_draw_furniture()
		"toy":
			_draw_toy()
		"school":
			_draw_school()
		"nature":
			_draw_nature()
		"action":
			_draw_action()
		"clothes":
			_draw_clothes()
		"place":
			_draw_place()
		"vehicle":
			_draw_car()
		"person":
			_draw_person()
		"feeling":
			_draw_feeling()
		"time":
			_draw_time()
		"adjective":
			_draw_adjective()
		"object":
			_draw_object()
		"duck":
			_draw_duck()
		"bird":
			_draw_bird()
		"egg":
			_draw_egg()
		"milk":
			_draw_milk()
		"cake":
			_draw_cake()
		"car":
			_draw_car()
		"flower":
			_draw_flower()
		"cloud":
			_draw_cloud()
		"rain":
			_draw_rain()
		"hat":
			_draw_hat()
		"key":
			_draw_key()
		"cup":
			_draw_cup()
		_:
			_draw_badge(word_key)


func _center() -> Vector2:
	return size * 0.5


func _unit() -> float:
	return minf(size.x, size.y)


func _draw_cat() -> void:
	var c := _center()
	var u := _unit()
	var head := u * 0.26
	var ear_base := u * 0.18
	var ear_tip := u * 0.34
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-ear_base, -head * 0.55),
		c + Vector2(-ear_tip, -head * 1.35),
		c + Vector2(-ear_base * 0.25, -head * 0.85),
	]), Color("#f4a261"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(ear_base, -head * 0.55),
		c + Vector2(ear_tip, -head * 1.35),
		c + Vector2(ear_base * 0.25, -head * 0.85),
	]), Color("#f4a261"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-ear_base * 0.72, -head * 0.6),
		c + Vector2(-ear_tip * 0.72, -head * 1.15),
		c + Vector2(-ear_base * 0.2, -head * 0.82),
	]), Color("#f9c6a4"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(ear_base * 0.72, -head * 0.6),
		c + Vector2(ear_tip * 0.72, -head * 1.15),
		c + Vector2(ear_base * 0.2, -head * 0.82),
	]), Color("#f9c6a4"))
	draw_circle(c, head, Color("#f4a261"))
	draw_circle(c + Vector2(-head * 0.34, -head * 0.12), head * 0.08, Color("#264653"))
	draw_circle(c + Vector2(head * 0.34, -head * 0.12), head * 0.08, Color("#264653"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-head * 0.09, -head * 0.02),
		c + Vector2(head * 0.09, -head * 0.02),
		c + Vector2(0.0, head * 0.1),
	]), Color("#e76f51"))
	var lw := u * 0.012
	draw_line(c + Vector2(0.0, head * 0.1), c + Vector2(-head * 0.12, head * 0.2), Color("#264653"), lw)
	draw_line(c + Vector2(0.0, head * 0.1), c + Vector2(head * 0.12, head * 0.2), Color("#264653"), lw)
	draw_line(c + Vector2(-head * 0.5, 0.0), c + Vector2(-head * 1.0, -head * 0.15), Color("#264653"), lw)
	draw_line(c + Vector2(-head * 0.5, head * 0.1), c + Vector2(-head * 1.0, head * 0.25), Color("#264653"), lw)
	draw_line(c + Vector2(head * 0.5, 0.0), c + Vector2(head * 1.0, -head * 0.15), Color("#264653"), lw)
	draw_line(c + Vector2(head * 0.5, head * 0.1), c + Vector2(head * 1.0, head * 0.25), Color("#264653"), lw)


func _draw_dog() -> void:
	var c := _center()
	var u := _unit()
	var head := u * 0.26
	draw_circle(c + Vector2(-head * 0.85, -head * 0.3), head * 0.3, Color("#8a5a44"))
	draw_circle(c + Vector2(head * 0.85, -head * 0.3), head * 0.3, Color("#8a5a44"))
	draw_circle(c, head, Color("#a47148"))
	draw_circle(c + Vector2(0.0, head * 0.25), head * 0.42, Color("#d9a066"))
	draw_circle(c + Vector2(0.0, head * 0.12), head * 0.11, Color("#264653"))
	draw_circle(c + Vector2(-head * 0.34, -head * 0.25), head * 0.08, Color("#264653"))
	draw_circle(c + Vector2(head * 0.34, -head * 0.25), head * 0.08, Color("#264653"))
	draw_colored_polygon(_ellipse_points(c + Vector2(0.0, head * 0.5), head * 0.16, head * 0.22), Color("#e76f51"))
	draw_line(c + Vector2(0.0, head * 0.35), c + Vector2(0.0, head * 0.55), Color("#8a5a44"), u * 0.012)


func _draw_sun() -> void:
	var c := _center()
	var u := _unit()
	var r := u * 0.22
	var rays := 12
	for i in range(rays):
		var ang := TAU * float(i) / float(rays)
		var p1 := c + Vector2(cos(ang), sin(ang)) * (r * 1.25)
		var p2 := c + Vector2(cos(ang), sin(ang)) * (r * 1.6)
		draw_line(p1, p2, Color("#f4a261"), u * 0.03)
	draw_circle(c, r, Color("#ffd23f"))
	draw_circle(c + Vector2(-r * 0.35, -r * 0.15), r * 0.08, Color("#7f5f00"))
	draw_circle(c + Vector2(r * 0.35, -r * 0.15), r * 0.08, Color("#7f5f00"))
	draw_arc(c + Vector2(0.0, r * 0.1), r * 0.4, PI * 1.15, PI * 1.85, 12, Color("#7f5f00"), u * 0.02)


func _draw_moon() -> void:
	var c := _center()
	var u := _unit()
	var r := u * 0.3
	draw_circle(c, r, Color("#f9e076"))
	draw_circle(c + Vector2(r * 0.45, -r * 0.3), r * 0.82, Color("#ffffff"))
	draw_circle(c + Vector2(-r * 0.4, r * 0.05), r * 0.12, Color("#e9c94f"))
	draw_circle(c + Vector2(-r * 0.15, r * 0.35), r * 0.08, Color("#e9c94f"))


func _draw_star() -> void:
	var c := _center()
	var u := _unit()
	var outer := u * 0.32
	var inner := outer * 0.45
	draw_colored_polygon(_star_points(c, outer, inner), Color("#ffd23f"))
	draw_circle(c + Vector2(-outer * 0.35, -outer * 0.35), outer * 0.1, Color("#fff3b0"))


func _draw_color_swatch(color: Color) -> void:
	var c := _center()
	var u := _unit()
	var r := u * 0.26
	draw_circle(c + Vector2(u * 0.04, u * 0.04), r, color.darkened(0.35))
	draw_circle(c, r, color)
	draw_circle(c + Vector2(-r * 0.35, -r * 0.35), r * 0.18, Color(1, 1, 1, 0.85))


func _draw_tree() -> void:
	var c := _center()
	var u := _unit()
	draw_rect(Rect2(c.x - u * 0.07, c.y + u * 0.05, u * 0.14, u * 0.28), Color("#8a5a44"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(0.0, -u * 0.34),
		c + Vector2(-u * 0.32, u * 0.08),
		c + Vector2(u * 0.32, u * 0.08),
	]), Color("#2a9d4e"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(0.0, -u * 0.12),
		c + Vector2(-u * 0.38, u * 0.22),
		c + Vector2(u * 0.38, u * 0.22),
	]), Color("#34b55c"))
	draw_circle(c + Vector2(-u * 0.1, u * 0.02), u * 0.04, Color("#e63946"))
	draw_circle(c + Vector2(u * 0.12, u * 0.12), u * 0.04, Color("#e63946"))


func _draw_fish() -> void:
	var c := _center()
	var u := _unit()
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(u * 0.2, 0.0),
		c + Vector2(u * 0.34, -u * 0.12),
		c + Vector2(u * 0.34, u * 0.12),
	]), Color("#ff8c42"))
	draw_colored_polygon(_ellipse_points(c, u * 0.24, u * 0.16), Color("#f4a261"))
	draw_line(c + Vector2(-u * 0.06, -u * 0.13), c + Vector2(-u * 0.06, u * 0.13), Color("#e76f51"), u * 0.02)
	draw_line(c + Vector2(u * 0.02, -u * 0.13), c + Vector2(u * 0.02, u * 0.13), Color("#e76f51"), u * 0.02)
	draw_circle(c + Vector2(-u * 0.14, -u * 0.04), u * 0.035, Color("#264653"))


func _draw_book() -> void:
	var c := _center()
	var u := _unit()
	draw_rect(Rect2(c.x - u * 0.28, c.y - u * 0.22, u * 0.56, u * 0.44), Color("#3a86ff"))
	draw_rect(Rect2(c.x - u * 0.22, c.y - u * 0.16, u * 0.18, u * 0.32), Color("#ffffff"))
	draw_rect(Rect2(c.x + u * 0.04, c.y - u * 0.16, u * 0.18, u * 0.32), Color("#ffffff"))
	draw_rect(Rect2(c.x - u * 0.02, c.y - u * 0.22, u * 0.04, u * 0.44), Color("#1f4e9e"))
	for i in range(3):
		var y := c.y - u * 0.1 + float(i) * u * 0.06
		draw_line(Vector2(c.x - u * 0.19, y), Vector2(c.x - u * 0.06, y), Color("#c8d8f0"), u * 0.012)
		draw_line(Vector2(c.x + u * 0.07, y), Vector2(c.x + u * 0.2, y), Color("#c8d8f0"), u * 0.012)


func _draw_ball() -> void:
	var c := _center()
	var u := _unit()
	var r := u * 0.26
	draw_circle(c, r, Color("#e63946"))
	draw_rect(Rect2(c.x - u * 0.03, c.y - r, u * 0.06, r * 2.0), Color("#ffffff"))
	draw_circle(c + Vector2(-r * 0.35, -r * 0.4), r * 0.12, Color(1, 1, 1, 0.7))


func _draw_home() -> void:
	var c := _center()
	var u := _unit()
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(0.0, -u * 0.32),
		c + Vector2(-u * 0.3, -u * 0.02),
		c + Vector2(u * 0.3, -u * 0.02),
	]), Color("#e76f51"))
	draw_rect(Rect2(c.x - u * 0.22, c.y - u * 0.02, u * 0.44, u * 0.28), Color("#f9e076"))
	draw_rect(Rect2(c.x - u * 0.06, c.y + u * 0.08, u * 0.12, u * 0.18), Color("#8a5a44"))
	draw_rect(Rect2(c.x - u * 0.16, c.y + u * 0.02, u * 0.08, u * 0.08), Color("#3a86ff"))
	draw_rect(Rect2(c.x + u * 0.08, c.y + u * 0.02, u * 0.08, u * 0.08), Color("#3a86ff"))


func _draw_apple() -> void:
	var c := _center()
	var u := _unit()
	var r := u * 0.24
	draw_colored_polygon(_ellipse_points(c + Vector2(u * 0.06, -r * 1.05), u * 0.09, u * 0.045), Color("#2a9d4e"))
	draw_line(c + Vector2(0.0, -r * 0.85), c + Vector2(u * 0.03, -r * 1.1), Color("#8a5a44"), u * 0.03)
	draw_circle(c + Vector2(-u * 0.01, u * 0.02), r, Color("#e63946"))
	draw_circle(c + Vector2(u * 0.02, -u * 0.02), r, Color("#f14a3a"))
	draw_circle(c + Vector2(-r * 0.3, -r * 0.35), r * 0.1, Color(1, 1, 1, 0.6))


func _draw_animal() -> void:
	var c := _center()
	var u := _unit()
	var head := u * 0.24
	# Ears.
	draw_circle(c + Vector2(-head * 0.8, -head * 0.75), head * 0.5, Color("#f4a261"))
	draw_circle(c + Vector2(head * 0.8, -head * 0.75), head * 0.5, Color("#f4a261"))
	draw_circle(c + Vector2(-head * 0.8, -head * 0.75), head * 0.28, Color("#f9c6a4"))
	draw_circle(c + Vector2(head * 0.8, -head * 0.75), head * 0.28, Color("#f9c6a4"))
	# Head.
	draw_circle(c, head, Color("#f9c6a4"))
	# Eyes.
	draw_circle(c + Vector2(-head * 0.35, -head * 0.1), head * 0.09, Color("#264653"))
	draw_circle(c + Vector2(head * 0.35, -head * 0.1), head * 0.09, Color("#264653"))
	# Nose and mouth.
	draw_circle(c + Vector2(0.0, head * 0.18), head * 0.12, Color("#e76f51"))
	draw_arc(c + Vector2(0.0, head * 0.12), head * 0.34, 0.2, PI - 0.2, 12, Color("#264653"), u * 0.015)
	# Whiskers.
	var lw := u * 0.012
	draw_line(c + Vector2(-head * 0.5, head * 0.2), c + Vector2(-head * 1.0, head * 0.1), Color("#8a5a44"), lw)
	draw_line(c + Vector2(-head * 0.5, head * 0.3), c + Vector2(-head * 1.0, head * 0.4), Color("#8a5a44"), lw)
	draw_line(c + Vector2(head * 0.5, head * 0.2), c + Vector2(head * 1.0, head * 0.1), Color("#8a5a44"), lw)
	draw_line(c + Vector2(head * 0.5, head * 0.3), c + Vector2(head * 1.0, head * 0.4), Color("#8a5a44"), lw)


func _draw_profession() -> void:
	var c := _center()
	var u := _unit()
	var head := u * 0.22
	# Cap.
	draw_rect(Rect2(c.x - head * 0.9, c.y - head * 1.7, head * 1.8, head * 0.6), Color("#3a86ff"))
	draw_rect(Rect2(c.x - head * 1.15, c.y - head * 1.15, head * 2.3, head * 0.28), Color("#3a86ff"))
	# Face.
	draw_circle(c, head, Color("#f9c6a4"))
	# Eyes and smile.
	draw_circle(c + Vector2(-head * 0.35, -head * 0.05), head * 0.08, Color("#264653"))
	draw_circle(c + Vector2(head * 0.35, -head * 0.05), head * 0.08, Color("#264653"))
	draw_arc(c + Vector2(0.0, head * 0.05), head * 0.4, 0.25, PI - 0.25, 12, Color("#264653"), u * 0.015)
	# Shoulders.
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-head * 1.1, head * 1.4),
		c + Vector2(head * 1.1, head * 1.4),
		c + Vector2(head * 0.7, head * 0.6),
		c + Vector2(-head * 0.7, head * 0.6),
	]), Color("#2a9d4e"))


func _draw_duck() -> void:
	var c := _center()
	var u := _unit()
	draw_colored_polygon(_ellipse_points(c + Vector2(0.0, u * 0.06), u * 0.24, u * 0.18), Color("#ffd23f"))
	draw_circle(c + Vector2(-u * 0.2, -u * 0.16), u * 0.13, Color("#ffd23f"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-u * 0.32, -u * 0.16),
		c + Vector2(-u * 0.14, -u * 0.2),
		c + Vector2(-u * 0.16, -u * 0.1),
	]), Color("#f4a261"))
	draw_circle(c + Vector2(-u * 0.24, -u * 0.2), u * 0.025, Color("#264653"))
	draw_colored_polygon(_ellipse_points(c + Vector2(u * 0.04, u * 0.02), u * 0.1, u * 0.06), Color("#f9e076"))


func _draw_bird() -> void:
	var c := _center()
	var u := _unit()
	draw_colored_polygon(_ellipse_points(c, u * 0.22, u * 0.17), Color("#3a86ff"))
	draw_circle(c + Vector2(-u * 0.19, -u * 0.12), u * 0.1, Color("#3a86ff"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-u * 0.29, -u * 0.12),
		c + Vector2(-u * 0.15, -u * 0.16),
		c + Vector2(-u * 0.15, -u * 0.06),
	]), Color("#f4a261"))
	draw_circle(c + Vector2(-u * 0.22, -u * 0.16), u * 0.02, Color("#264653"))
	draw_colored_polygon(_ellipse_points(c + Vector2(u * 0.06, u * 0.02), u * 0.11, u * 0.06), Color("#1f6fe0"))
	draw_line(c + Vector2(-u * 0.02, u * 0.16), c + Vector2(-u * 0.05, u * 0.24), Color("#e76f51"), u * 0.015)
	draw_line(c + Vector2(u * 0.04, u * 0.16), c + Vector2(u * 0.06, u * 0.24), Color("#e76f51"), u * 0.015)


func _draw_egg() -> void:
	var c := _center()
	var u := _unit()
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(0.0, -u * 0.3), c + Vector2(u * 0.14, -u * 0.2), c + Vector2(u * 0.2, -u * 0.02),
		c + Vector2(u * 0.16, u * 0.18), c + Vector2(0.0, u * 0.28), c + Vector2(-u * 0.16, u * 0.18),
		c + Vector2(-u * 0.2, -u * 0.02), c + Vector2(-u * 0.14, -u * 0.2),
	]), Color("#fff3d6"))
	draw_circle(c + Vector2(-u * 0.06, -u * 0.08), u * 0.04, Color("#ffffff"))


func _draw_milk() -> void:
	var c := _center()
	var u := _unit()
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-u * 0.16, -u * 0.28), c + Vector2(u * 0.16, -u * 0.28),
		c + Vector2(u * 0.12, u * 0.28), c + Vector2(-u * 0.12, u * 0.28),
	]), Color("#eaf2ff"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-u * 0.15, -u * 0.04), c + Vector2(u * 0.15, -u * 0.04),
		c + Vector2(u * 0.12, u * 0.28), c + Vector2(-u * 0.12, u * 0.28),
	]), Color("#ffffff"))
	draw_rect(Rect2(c.x - u * 0.17, c.y - u * 0.33, u * 0.34, u * 0.06), Color("#3a86ff"))


func _draw_cake() -> void:
	var c := _center()
	var u := _unit()
	draw_rect(Rect2(c.x - u * 0.26, c.y + u * 0.02, u * 0.52, u * 0.24), Color("#e76f51"))
	draw_rect(Rect2(c.x - u * 0.2, c.y - u * 0.12, u * 0.4, u * 0.16), Color("#f4a261"))
	draw_colored_polygon(_ellipse_points(c + Vector2(0.0, -u * 0.12), u * 0.2, u * 0.05), Color("#ffffff"))
	draw_rect(Rect2(c.x - u * 0.02, c.y - u * 0.28, u * 0.04, u * 0.18), Color("#f9e076"))
	draw_colored_polygon(_ellipse_points(c + Vector2(0.0, -u * 0.32), u * 0.03, u * 0.05), Color("#ffd23f"))


func _draw_car() -> void:
	var c := _center()
	var u := _unit()
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-u * 0.34, u * 0.1), c + Vector2(-u * 0.2, -u * 0.1), c + Vector2(u * 0.14, -u * 0.1),
		c + Vector2(u * 0.34, u * 0.1),
	]), Color("#e63946"))
	draw_rect(Rect2(c.x - u * 0.34, c.y + u * 0.06, u * 0.68, u * 0.14), Color("#e63946"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-u * 0.15, -u * 0.09), c + Vector2(-u * 0.04, -u * 0.09),
		c + Vector2(-u * 0.04, u * 0.05), c + Vector2(-u * 0.19, u * 0.05),
	]), Color("#cdeaff"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(u * 0.01, -u * 0.09), c + Vector2(u * 0.11, -u * 0.09),
		c + Vector2(u * 0.15, u * 0.05), c + Vector2(u * 0.01, u * 0.05),
	]), Color("#cdeaff"))
	draw_circle(c + Vector2(-u * 0.2, u * 0.22), u * 0.08, Color("#264653"))
	draw_circle(c + Vector2(u * 0.2, u * 0.22), u * 0.08, Color("#264653"))
	draw_circle(c + Vector2(-u * 0.2, u * 0.22), u * 0.03, Color("#c8d8f0"))
	draw_circle(c + Vector2(u * 0.2, u * 0.22), u * 0.03, Color("#c8d8f0"))


func _draw_flower() -> void:
	var c := _center()
	var u := _unit()
	draw_line(c + Vector2(0.0, u * 0.1), c + Vector2(0.0, u * 0.36), Color("#2a9d4e"), u * 0.025)
	var petal := u * 0.13
	for i in range(5):
		var ang := TAU * float(i) / 5.0
		draw_circle(c + Vector2(cos(ang), sin(ang)) * petal * 1.1, petal, Color("#ff8fa3"))
	draw_circle(c, petal * 0.7, Color("#ffd23f"))


func _draw_cloud() -> void:
	var c := _center()
	var u := _unit()
	draw_circle(c + Vector2(-u * 0.14, u * 0.04), u * 0.16, Color("#f2f6ff"))
	draw_circle(c + Vector2(u * 0.12, u * 0.02), u * 0.19, Color("#f2f6ff"))
	draw_circle(c + Vector2(u * 0.32, u * 0.08), u * 0.13, Color("#f2f6ff"))
	draw_rect(Rect2(c.x - u * 0.24, c.y + u * 0.02, u * 0.56, u * 0.14), Color("#f2f6ff"))


func _draw_rain() -> void:
	var c := _center()
	var u := _unit()
	draw_circle(c + Vector2(-u * 0.12, -u * 0.14), u * 0.14, Color("#c8d8f0"))
	draw_circle(c + Vector2(u * 0.1, -u * 0.16), u * 0.17, Color("#c8d8f0"))
	draw_rect(Rect2(c.x - u * 0.2, c.y - u * 0.14, u * 0.46, u * 0.12), Color("#c8d8f0"))
	for dx in [-u * 0.16, 0.0, u * 0.16]:
		draw_line(c + Vector2(dx, u * 0.06), c + Vector2(dx - u * 0.03, u * 0.24), Color("#3a86ff"), u * 0.02)


func _draw_hat() -> void:
	var c := _center()
	var u := _unit()
	draw_colored_polygon(_ellipse_points(c + Vector2(0.0, u * 0.14), u * 0.32, u * 0.08), Color("#e76f51"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-u * 0.16, u * 0.12), c + Vector2(u * 0.16, u * 0.12),
		c + Vector2(u * 0.12, -u * 0.22), c + Vector2(-u * 0.12, -u * 0.22),
	]), Color("#f4a261"))
	draw_rect(Rect2(c.x - u * 0.16, c.y + u * 0.02, u * 0.32, u * 0.06), Color("#264653"))


func _draw_key() -> void:
	var c := _center()
	var u := _unit()
	draw_circle(c + Vector2(-u * 0.18, -u * 0.14), u * 0.14, Color("#ffd23f"))
	draw_circle(c + Vector2(-u * 0.18, -u * 0.14), u * 0.06, Color("#7f6bd6"))
	draw_line(c + Vector2(-u * 0.08, -u * 0.04), c + Vector2(u * 0.26, u * 0.3), Color("#ffd23f"), u * 0.05)
	draw_line(c + Vector2(u * 0.14, u * 0.18), c + Vector2(u * 0.14, u * 0.28), Color("#ffd23f"), u * 0.04)
	draw_line(c + Vector2(u * 0.22, u * 0.26), c + Vector2(u * 0.22, u * 0.34), Color("#ffd23f"), u * 0.04)


func _draw_cup() -> void:
	var c := _center()
	var u := _unit()
	draw_rect(Rect2(c.x - u * 0.18, c.y - u * 0.2, u * 0.36, u * 0.32), Color("#ff8c42"))
	draw_rect(Rect2(c.x - u * 0.18, c.y - u * 0.2, u * 0.36, u * 0.07), Color("#ffffff"))
	draw_arc(c + Vector2(u * 0.24, -u * 0.02), u * 0.11, -PI * 0.5, PI * 0.5, 12, Color("#ff8c42"), u * 0.03)


func _draw_body() -> void:
	var c := _center()
	var u := _unit()
	draw_circle(c + Vector2(0.0, -u * 0.24), u * 0.11, Color("#f9c6a4"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-u * 0.16, u * 0.3), c + Vector2(u * 0.16, u * 0.3),
		c + Vector2(u * 0.12, -u * 0.06), c + Vector2(-u * 0.12, -u * 0.06),
	]), Color("#3a86ff"))
	draw_circle(c + Vector2(-u * 0.03, -u * 0.02), u * 0.045, Color("#ffd23f"))
	draw_circle(c + Vector2(u * 0.06, u * 0.06), u * 0.045, Color("#ffd23f"))


func _draw_food() -> void:
	var c := _center()
	var u := _unit()
	draw_colored_polygon(_ellipse_points(c + Vector2(0.0, u * 0.14), u * 0.3, u * 0.14), Color("#f4a261"))
	draw_colored_polygon(_ellipse_points(c + Vector2(0.0, u * 0.1), u * 0.26, u * 0.11), Color("#ffe0b2"))
	draw_circle(c + Vector2(-u * 0.08, -u * 0.02), u * 0.09, Color("#2a9d4e"))
	draw_circle(c + Vector2(u * 0.08, -u * 0.03), u * 0.08, Color("#e63946"))
	draw_circle(c + Vector2(0.0, -u * 0.1), u * 0.07, Color("#ffd23f"))


func _draw_furniture() -> void:
	var c := _center()
	var u := _unit()
	draw_rect(Rect2(c.x - u * 0.2, c.y - u * 0.06, u * 0.4, u * 0.08), Color("#8a5a44"))
	draw_rect(Rect2(c.x - u * 0.2, c.y - u * 0.32, u * 0.07, u * 0.26), Color("#a47148"))
	draw_rect(Rect2(c.x + u * 0.13, c.y - u * 0.32, u * 0.07, u * 0.26), Color("#a47148"))
	for dx in [-u * 0.16, u * 0.16]:
		draw_rect(Rect2(c.x + dx - u * 0.02, c.y + u * 0.02, u * 0.04, u * 0.26), Color("#5c3a2e"))


func _draw_toy() -> void:
	var c := _center()
	var u := _unit()
	draw_rect(Rect2(c.x - u * 0.26, c.y + u * 0.02, u * 0.2, u * 0.2), Color("#e63946"))
	draw_rect(Rect2(c.x + u * 0.02, c.y + u * 0.02, u * 0.2, u * 0.2), Color("#3a86ff"))
	draw_rect(Rect2(c.x - u * 0.12, c.y - u * 0.2, u * 0.2, u * 0.2), Color("#ffd23f"))


func _draw_school() -> void:
	var c := _center()
	var u := _unit()
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-u * 0.28, u * 0.24), c + Vector2(-u * 0.08, u * 0.28), c + Vector2(u * 0.26, -u * 0.22),
		c + Vector2(u * 0.16, -u * 0.3), c + Vector2(u * 0.02, -u * 0.14),
	]), Color("#ffd23f"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(u * 0.16, -u * 0.3), c + Vector2(u * 0.26, -u * 0.22), c + Vector2(u * 0.22, -u * 0.34),
	]), Color("#264653"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-u * 0.28, u * 0.24), c + Vector2(-u * 0.08, u * 0.28), c + Vector2(-u * 0.16, u * 0.32),
	]), Color("#e76f51"))


func _draw_nature() -> void:
	var c := _center()
	var u := _unit()
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(0.0, -u * 0.3), c + Vector2(u * 0.22, -u * 0.04), c + Vector2(0.0, u * 0.3),
		c + Vector2(-u * 0.22, -u * 0.04),
	]), Color("#2a9d4e"))
	draw_line(c + Vector2(0.0, -u * 0.28), c + Vector2(0.0, u * 0.28), Color("#1f6d3a"), u * 0.018)


func _draw_action() -> void:
	var c := _center()
	var u := _unit()
	var lw := u * 0.035
	draw_circle(c + Vector2(u * 0.06, -u * 0.28), u * 0.08, Color("#f9c6a4"))
	draw_line(c + Vector2(u * 0.02, -u * 0.2), c + Vector2(-u * 0.06, u * 0.04), Color("#3a86ff"), lw)
	draw_line(c + Vector2(-u * 0.06, u * 0.04), c + Vector2(u * 0.1, -u * 0.02), Color("#3a86ff"), lw)
	draw_line(c + Vector2(-u * 0.06, u * 0.04), c + Vector2(-u * 0.24, u * 0.32), Color("#264653"), lw)
	draw_line(c + Vector2(u * 0.1, -u * 0.02), c + Vector2(u * 0.3, u * 0.14), Color("#264653"), lw)
	draw_line(c + Vector2(u * 0.02, -u * 0.2), c + Vector2(-u * 0.2, -u * 0.28), Color("#f4a261"), lw)
	draw_line(c + Vector2(u * 0.02, -u * 0.2), c + Vector2(u * 0.26, -u * 0.3), Color("#f4a261"), lw)


func _draw_clothes() -> void:
	var c := _center()
	var u := _unit()
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-u * 0.24, -u * 0.18), c + Vector2(-u * 0.1, -u * 0.28), c + Vector2(0.0, -u * 0.18),
		c + Vector2(u * 0.1, -u * 0.28), c + Vector2(u * 0.24, -u * 0.18), c + Vector2(u * 0.16, -u * 0.02),
		c + Vector2(u * 0.14, u * 0.28), c + Vector2(-u * 0.14, u * 0.28), c + Vector2(-u * 0.16, -u * 0.02),
	]), Color("#3a86ff"))
	draw_colored_polygon(_ellipse_points(c + Vector2(0.0, -u * 0.18), u * 0.06, u * 0.04), Color("#eaf2ff"))


func _draw_place() -> void:
	var c := _center()
	var u := _unit()
	draw_rect(Rect2(c.x - u * 0.22, c.y - u * 0.3, u * 0.44, u * 0.58), Color("#e76f51"))
	for row in range(2):
		for col in range(2):
			draw_rect(Rect2(c.x - u * 0.15 + col * u * 0.17, c.y - u * 0.2 + row * u * 0.2, u * 0.1, u * 0.1), Color("#fff3d6"))
	draw_rect(Rect2(c.x - u * 0.05, c.y + u * 0.12, u * 0.1, u * 0.16), Color("#8a5a44"))


func _draw_person() -> void:
	var c := _center()
	var u := _unit()
	draw_circle(c + Vector2(0.0, -u * 0.2), u * 0.14, Color("#f9c6a4"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-u * 0.2, u * 0.3), c + Vector2(u * 0.2, u * 0.3),
		c + Vector2(u * 0.14, -u * 0.02), c + Vector2(-u * 0.14, -u * 0.02),
	]), Color("#2a9d4e"))
	draw_circle(c + Vector2(-u * 0.05, -u * 0.22), u * 0.02, Color("#264653"))
	draw_circle(c + Vector2(u * 0.05, -u * 0.22), u * 0.02, Color("#264653"))


func _draw_feeling() -> void:
	var c := _center()
	var u := _unit()
	draw_circle(c, u * 0.28, Color("#ffd23f"))
	draw_circle(c + Vector2(-u * 0.09, -u * 0.06), u * 0.03, Color("#264653"))
	draw_circle(c + Vector2(u * 0.09, -u * 0.06), u * 0.03, Color("#264653"))
	draw_arc(c + Vector2(0.0, u * 0.02), u * 0.14, 0.25, PI - 0.25, 12, Color("#264653"), u * 0.02)


func _draw_time() -> void:
	var c := _center()
	var u := _unit()
	draw_circle(c, u * 0.28, Color("#eaf2ff"))
	draw_circle(c, u * 0.28, Color("#3a86ff"), false, u * 0.02)
	for i in range(12):
		var ang := TAU * float(i) / 12.0
		var p1 := c + Vector2(cos(ang), sin(ang)) * u * 0.24
		var p2 := c + Vector2(cos(ang), sin(ang)) * u * 0.27
		draw_line(p1, p2, Color("#264653"), u * 0.012)
	draw_line(c, c + Vector2(0.0, -u * 0.16), Color("#264653"), u * 0.02)
	draw_line(c, c + Vector2(u * 0.13, u * 0.06), Color("#264653"), u * 0.018)
	draw_circle(c, u * 0.02, Color("#e63946"))


func _draw_adjective() -> void:
	var c := _center()
	var u := _unit()
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-u * 0.24, -u * 0.12), c + Vector2(u * 0.06, -u * 0.24), c + Vector2(u * 0.28, -u * 0.02),
		c + Vector2(-u * 0.02, u * 0.24), c + Vector2(-u * 0.28, u * 0.16),
	]), Color("#7f6bd6"))
	draw_circle(c + Vector2(-u * 0.12, -u * 0.08), u * 0.045, Color("#ffffff"))


func _draw_object() -> void:
	var c := _center()
	var u := _unit()
	draw_rect(Rect2(c.x - u * 0.24, c.y - u * 0.16, u * 0.48, u * 0.4), Color("#ff8c42"))
	draw_rect(Rect2(c.x - u * 0.24, c.y - u * 0.16, u * 0.48, u * 0.1), Color("#ffb787"))
	draw_rect(Rect2(c.x - u * 0.04, c.y - u * 0.16, u * 0.08, u * 0.4), Color("#2a9d4e"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-u * 0.1, -u * 0.16), c + Vector2(u * 0.1, -u * 0.16),
		c + Vector2(u * 0.14, -u * 0.3), c + Vector2(-u * 0.14, -u * 0.3),
	]), Color("#2a9d4e"))


func _draw_badge(word: String) -> void:
	var c := _center()
	var u := _unit()
	var r := u * 0.28
	draw_circle(c, r, Color("#7f6bd6"))
	draw_circle(c, r * 0.8, Color("#9d8ce8"))
	var letter := word.substr(0, 1)
	_draw_letter(c, letter, u * 0.22, Color("#ffffff"))


func _draw_letter(center: Vector2, text: String, size_px: float, color: Color) -> void:
	var font := get_theme_default_font()
	if font == null:
		return
	draw_string(font, center + Vector2(-size_px * 0.5, size_px * 0.35), text, HORIZONTAL_ALIGNMENT_CENTER, size_px, int(size_px), color)


func _star_points(center: Vector2, outer: float, inner: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(10):
		var ang := -PI * 0.5 + float(i) * PI * 0.2
		var r := outer if i % 2 == 0 else inner
		pts.append(center + Vector2(cos(ang) * r, sin(ang) * r))
	return pts


func _ellipse_points(center: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(24):
		var ang := TAU * float(i) / 24.0
		pts.append(center + Vector2(cos(ang) * rx, sin(ang) * ry))
	return pts
