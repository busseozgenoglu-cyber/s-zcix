extends Control
## Wordi ana menü: ilerleme özeti, oyun modları, kelime defteri ve ayarlar.

const WordBank := preload("res://data/word_bank.gd")
const UIKit := preload("res://scripts/ui_kit.gd")
const CAT_TEX := preload("res://assets/images/img-69715444-5126-4ee3-bc65-b090abf1b32e-1787003493078-0_1787003493078_an695b00.png")
const RABBIT_TEX := preload("res://assets/images/img-69715444-5126-4ee3-bc65-b090abf1b32e-1787003493226-0_1787003493226_2bxuf32l.png")

var music_button: Button


func _ready() -> void:
	UIKit.add_backdrop(self)
	_add_mascots()
	_build_layout()


func _add_mascots() -> void:
	var cat := TextureRect.new()
	cat.texture = CAT_TEX
	cat.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cat.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cat.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	cat.offset_left = -170
	cat.offset_top = 40
	cat.offset_right = -30
	cat.offset_bottom = 180
	add_child(cat)
	var rabbit := TextureRect.new()
	rabbit.texture = RABBIT_TEX
	rabbit.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rabbit.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rabbit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rabbit.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	rabbit.offset_left = 30
	rabbit.offset_top = -190
	rabbit.offset_right = 170
	rabbit.offset_bottom = -50
	add_child(rabbit)


func _build_layout() -> void:
	var margin := MarginContainer.new()
	UIKit.full_rect(margin)
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_child(center)

	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(0, 0)
	column.add_theme_constant_override("separation", 16)
	column.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	center.add_child(column)

	# Sütun genişliği: ekrana göre en fazla 560 px.
	var width := clampf(get_viewport_rect().size.x - 56.0, 280.0, 560.0)
	column.custom_minimum_size = Vector2(width, 0)

	var title := UIKit.make_label("Wordi", 84, UIKit.PINK)
	title.add_theme_constant_override("outline_size", 10)
	title.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.9))
	column.add_child(title)
	var subtitle := UIKit.make_label("Harfleri sürükle, İngilizce kelimeyi bul,\nanlamını öğren ve kelime defterine yaz!", 22, UIKit.DARK_PURPLE)
	column.add_child(subtitle)

	column.add_child(_build_stats_card())

	var level := Progress.current_level
	var play := UIKit.make_button("OYNA  -  Seviye %d: %s" % [level, WordBank.get_level_title(level)], UIKit.GREEN, 26, 76)
	play.pressed.connect(func() -> void: Progress.start_level_game())
	column.add_child(play)

	var daily_text := "GÜNÜN KELİMELERİ"
	var daily_color := UIKit.ORANGE
	var daily_done := Progress.daily_done_today()
	if daily_done:
		var r := Progress.daily_result_today()
		daily_text = "GÜNÜN KELİMELERİ  -  Bugün %d/%d, yarın yenisi!" % [int(r.get("found", 0)), Progress.DAILY_WORD_COUNT]
		daily_color = UIKit.TEAL
	var daily := UIKit.make_button(daily_text, daily_color, 20 if daily_done else 22, 68)
	daily.disabled = daily_done
	daily.pressed.connect(func() -> void: Progress.start_daily_game())
	column.add_child(daily)

	var notebook := UIKit.make_button("KELİME DEFTERİM  (%d kelime)" % Progress.learned_count(), UIKit.BLUE, 22, 68)
	notebook.pressed.connect(func() -> void: Progress.go_notebook())
	column.add_child(notebook)

	var quiz := UIKit.make_button("TEKRAR TESTİ", UIKit.PURPLE, 22, 68)
	quiz.disabled = Progress.learned_count() < 4
	if quiz.disabled:
		quiz.text = "TEKRAR TESTİ  (en az 4 kelime öğren)"
	quiz.pressed.connect(func() -> void: Progress.go_quiz())
	column.add_child(quiz)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	music_button = UIKit.make_small_button(_music_text(), UIKit.DARK_PURPLE)
	music_button.pressed.connect(_on_music_toggle)
	row.add_child(music_button)
	var howto := UIKit.make_small_button("Nasıl oynanır?", UIKit.TEXT_DARK)
	howto.pressed.connect(_show_howto)
	row.add_child(howto)
	column.add_child(row)

	var footer := UIKit.make_label("Reklamsız  •  Çocuklara uygun  •  İnternetsiz çalışır", 16, UIKit.DARK_PURPLE)
	column.add_child(footer)


func _build_stats_card() -> PanelContainer:
	var panel := UIKit.make_panel(UIKit.CREAM_LIGHT, UIKit.ORANGE, 24)
	var grid := HBoxContainer.new()
	grid.add_theme_constant_override("separation", 8)
	panel.add_child(grid)
	grid.add_child(_stat("%d" % Progress.learned_count(), "öğrenilen\nkelime", UIKit.BLUE))
	grid.add_child(_stat("%d" % Progress.total_stars(), "yıldız", UIKit.YELLOW.darkened(0.15)))
	grid.add_child(_stat("%d gün" % Progress.current_streak(), "seri", UIKit.PINK))
	grid.add_child(_stat("%d" % Progress.total_score, "toplam\npuan", UIKit.GREEN.darkened(0.1)))
	return panel


func _stat(value: String, caption: String, color: Color) -> Control:
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 0)
	var v := UIKit.make_label(value, 30, color)
	var c := UIKit.make_label(caption, 14, UIKit.DARK_PURPLE)
	box.add_child(v)
	box.add_child(c)
	return box


func _music_text() -> String:
	return "Müzik: Açık" if Progress.music_on else "Müzik: Kapalı"


func _on_music_toggle() -> void:
	Progress.set_music(not Progress.music_on)
	music_button.text = _music_text()


func _show_howto() -> void:
	var overlay := Control.new()
	UIKit.full_rect(overlay)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0.18, 0.08, 0.3, 0.55)
	overlay.add_child(UIKit.full_rect(dim))
	var center := CenterContainer.new()
	UIKit.full_rect(center)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)
	var panel := UIKit.make_panel(UIKit.CREAM_LIGHT, UIKit.ORANGE, 28)
	panel.custom_minimum_size = Vector2(minf(get_viewport_rect().size.x - 60.0, 520.0), 0)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	box.add_child(UIKit.make_label("Nasıl oynanır?", 34, UIKit.PINK))
	var steps := [
		"1. İpucuna bak: Türkçe anlam ve baş harf verilir.",
		"2. Tahtada harfleri düz bir çizgide sürükleyerek İngilizce kelimeyi oluştur.",
		"3. Her doğru kelimede resim, Türkçe anlam ve İngilizce okunuş gösterilir; 'Dinle' ile telaffuzu duy.",
		"4. Bulduğun her kelime Kelime Defterine eklenir. Tekrar Testi ile pekiştir.",
		"5. Her gün Günün Kelimeleri görevini bitir, serini koru ve yıldız topla!",
	]
	for s in steps:
		box.add_child(UIKit.make_label(s, 19, UIKit.TEXT_DARK, HORIZONTAL_ALIGNMENT_LEFT))
	var close := UIKit.make_button("Anladım", UIKit.GREEN, 22, 56)
	close.pressed.connect(func() -> void: overlay.queue_free())
	box.add_child(close)
	add_child(overlay)
