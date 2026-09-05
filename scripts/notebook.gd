extends Control
## Kelime Defterim: oyuncunun bulduğu tüm kelimeler; resim, Türkçe anlam,
## ustalık yıldızları ve telaffuz dinleme. Buradan Tekrar Testi başlatılır.

const WordBank := preload("res://data/word_bank.gd")
const UIKit := preload("res://scripts/ui_kit.gd")
const WordIllustrationScript := preload("res://scripts/word_illustration.gd")

var grid: GridContainer


func _ready() -> void:
	UIKit.add_backdrop(self)
	_build()
	resized.connect(_update_columns)


func _build() -> void:
	var root := VBoxContainer.new()
	UIKit.full_rect(root)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	root.offset_left = 20
	root.offset_right = -20
	root.offset_top = 16
	root.offset_bottom = -16
	root.add_theme_constant_override("separation", 12)
	add_child(root)

	# Üst şerit
	var bar: Dictionary = UIKit.make_top_bar("<  Menü", func() -> void: Progress.go_menu(), "Kelime Defterim", "%d kelime" % Progress.learned_count())
	root.add_child(bar["bar"])

	var words := Progress.learned_words_sorted()
	if words.is_empty():
		var center := CenterContainer.new()
		center.size_flags_vertical = Control.SIZE_EXPAND_FILL
		root.add_child(center)
		var panel := UIKit.make_panel()
		panel.custom_minimum_size = Vector2(clampf(get_viewport_rect().size.x - 40.0, 280.0, 480.0), 0)
		center.add_child(panel)
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 14)
		panel.add_child(box)
		box.add_child(UIKit.make_label("Defterin henüz boş", 30, UIKit.TEXT_BROWN))
		box.add_child(UIKit.make_label("Oyunda bulduğun her İngilizce kelime buraya resmi ve Türkçe anlamıyla eklenir.", 20, UIKit.TEXT_DARK))
		var play := UIKit.make_button("Hemen Oyna", UIKit.GREEN, 24, 64)
		play.pressed.connect(func() -> void: Progress.start_level_game())
		box.add_child(play)
		return

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	grid = GridContainer.new()
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(grid)
	for w in words:
		grid.add_child(_make_card(w))
	_update_columns()

	var quiz := UIKit.make_button("Tekrar Testi Başlat", UIKit.PURPLE, 24, 64)
	quiz.disabled = words.size() < 4
	if quiz.disabled:
		quiz.text = "Tekrar Testi için en az 4 kelime öğren"
	quiz.pressed.connect(func() -> void: Progress.go_quiz())
	root.add_child(quiz)


func _update_columns() -> void:
	if grid == null:
		return
	grid.columns = maxi(1, int((size.x - 40.0) / 250.0))


func _make_card(word: String) -> Control:
	var panel := UIKit.make_panel(UIKit.CREAM_LIGHT, UIKit.TILE_COLORS[hash(word) % UIKit.TILE_COLORS.size()], 22)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)

	var ill_frame := PanelContainer.new()
	ill_frame.add_theme_stylebox_override("panel", UIKit.panel_style(Color(1, 1, 1, 0.9), Color(0.95, 0.78, 0.42), 18, 3, 6.0))
	var ill := Control.new()
	ill.set_script(WordIllustrationScript)
	ill.custom_minimum_size = Vector2(0, 96)
	ill_frame.add_child(ill)
	box.add_child(ill_frame)
	ill.call("set_word", word)

	box.add_child(UIKit.make_label(word, 30, UIKit.PINK))
	box.add_child(UIKit.make_label(WordBank.get_meaning(word), 19, UIKit.TEXT_BROWN))

	var stars := UIKit.StarRow.new(Progress.mastery(word), 3, 20.0)
	stars.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(stars)

	var e: Dictionary = Progress.learned.get(word, {})
	var info := UIKit.make_label("%d kez bulundu  •  Seviye %d" % [int(e.get("count", 0)), WordBank.get_level_of(word)], 13, UIKit.DARK_PURPLE)
	box.add_child(info)

	var listen := UIKit.make_small_button("Dinle", UIKit.BLUE)
	listen.pressed.connect(func() -> void: _speak(word))
	box.add_child(listen)
	return panel


func _speak(word: String) -> void:
	var voices := DisplayServer.tts_get_voices_for_language("en")
	if voices.is_empty():
		return
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(word, voices[0], 50, 1.0, 0.9)
