extends Control
## Tekrar Testi: öğrenilen kelimelerden çoktan seçmeli Türkçe -> İngilizce sorular.
## En zayıf kelimeler önce sorulur; sonuçlar ustalık yıldızlarına işlenir.

const WordBank := preload("res://data/word_bank.gd")
const UIKit := preload("res://scripts/ui_kit.gd")
const WordIllustrationScript := preload("res://scripts/word_illustration.gd")
const QUESTION_COUNT := 10
const OPTION_COUNT := 4

var questions: Array[String] = []
var index := 0
var correct := 0
var answering := false
var rng := RandomNumberGenerator.new()

var progress_label: Label
var meaning_label: Label
var illustration: Control
var option_buttons: Array[Button] = []
var feedback_label: Label
var card: PanelContainer


func _ready() -> void:
	rng.randomize()
	UIKit.add_backdrop(self)
	questions = Progress.quiz_pool(QUESTION_COUNT)
	if questions.size() < 4:
		Progress.go_notebook()
		return
	questions.shuffle()
	_build()
	_show_question()


func _build() -> void:
	var root := VBoxContainer.new()
	UIKit.full_rect(root)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	root.offset_left = 20
	root.offset_right = -20
	root.offset_top = 16
	root.offset_bottom = -16
	root.add_theme_constant_override("separation", 14)
	add_child(root)

	var bar: Dictionary = UIKit.make_top_bar("<  Defter", func() -> void: Progress.go_notebook(), "Tekrar Testi", "1/%d" % questions.size())
	root.add_child(bar["bar"])
	progress_label = bar["right"]

	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(center)
	card = UIKit.make_panel(UIKit.CREAM_LIGHT, UIKit.ORANGE, 28)
	card.custom_minimum_size = Vector2(clampf(size.x - 40.0, 280.0, 540.0), 0)
	center.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	card.add_child(box)

	box.add_child(UIKit.make_label("Bu kelimenin İngilizcesi hangisi?", 20, UIKit.TEXT_DARK))
	var ill_frame := PanelContainer.new()
	ill_frame.add_theme_stylebox_override("panel", UIKit.panel_style(Color(1, 1, 1, 0.9), Color(0.95, 0.78, 0.42), 20, 3, 8.0))
	illustration = Control.new()
	illustration.set_script(WordIllustrationScript)
	illustration.custom_minimum_size = Vector2(0, 130)
	ill_frame.add_child(illustration)
	box.add_child(ill_frame)
	meaning_label = UIKit.make_label("", 40, UIKit.TEXT_BROWN)
	box.add_child(meaning_label)

	var opts := GridContainer.new()
	opts.columns = 2
	opts.add_theme_constant_override("h_separation", 10)
	opts.add_theme_constant_override("v_separation", 10)
	box.add_child(opts)
	for i in range(OPTION_COUNT):
		var b := UIKit.make_button("", UIKit.TILE_COLORS[(i * 2 + 1) % UIKit.TILE_COLORS.size()], 26, 64)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(_on_option.bind(i))
		opts.add_child(b)
		option_buttons.append(b)

	feedback_label = UIKit.make_label(" ", 20, UIKit.GREEN.darkened(0.2))
	box.add_child(feedback_label)


func _show_question() -> void:
	if index >= questions.size():
		_show_result()
		return
	answering = true
	var word := questions[index]
	progress_label.text = "%d/%d" % [index + 1, questions.size()]
	meaning_label.text = WordBank.get_meaning(word)
	illustration.call("set_word", word)
	feedback_label.text = " "
	var options := _make_options(word)
	for i in range(OPTION_COUNT):
		var b := option_buttons[i]
		b.text = options[i]
		b.disabled = false
		b.modulate = Color.WHITE


func _make_options(answer: String) -> Array[String]:
	var options: Array[String] = [answer]
	# Önce öğrenilen diğer kelimelerden, yetmezse bankadan benzer uzunlukta çeldiriciler.
	var pool: Array[String] = []
	for w in Progress.learned_words_sorted():
		if w != answer:
			pool.append(w)
	pool.shuffle()
	for w in pool:
		if options.size() >= OPTION_COUNT:
			break
		if absi(w.length() - answer.length()) <= 2:
			options.append(w)
	if options.size() < OPTION_COUNT:
		var bank := WordBank.get_all_core_words()
		var guard := 0
		while options.size() < OPTION_COUNT and guard < 500:
			guard += 1
			var w := bank[rng.randi() % bank.size()]
			if w != answer and not options.has(w):
				options.append(w)
	options.shuffle()
	return options


func _on_option(i: int) -> void:
	if not answering:
		return
	answering = false
	var word := questions[index]
	var chosen := option_buttons[i].text
	var ok := chosen == word
	Progress.record_quiz(word, ok)
	for b in option_buttons:
		b.disabled = true
		if b.text == word:
			b.modulate = Color(1, 1, 1, 1)
		else:
			b.modulate = Color(1, 1, 1, 0.45)
	if ok:
		correct += 1
		feedback_label.add_theme_color_override("font_color", UIKit.GREEN.darkened(0.2))
		feedback_label.text = "Doğru!  %s = %s" % [word, WordBank.get_meaning(word)]
	else:
		feedback_label.add_theme_color_override("font_color", Color("#c0392b"))
		feedback_label.text = "Doğrusu: %s" % word
	_speak(word)
	get_tree().create_timer(1.1).timeout.connect(func() -> void:
		index += 1
		_show_question())


func _show_result() -> void:
	for child in get_children():
		if child is VBoxContainer:
			child.queue_free()
	var center := CenterContainer.new()
	UIKit.full_rect(center)
	center.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(center)
	var panel := UIKit.make_panel(UIKit.CREAM_LIGHT, UIKit.PURPLE, 30)
	panel.custom_minimum_size = Vector2(clampf(size.x - 60.0, 280.0, 500.0), 0)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	box.add_child(UIKit.make_label("Test bitti!", 40, UIKit.PINK))
	box.add_child(UIKit.make_label("%d / %d doğru" % [correct, questions.size()], 32, UIKit.TEXT_BROWN))
	var ratio := float(correct) / float(maxi(1, questions.size()))
	var stars := 3 if ratio >= 0.9 else (2 if ratio >= 0.6 else (1 if ratio > 0.0 else 0))
	var star_row := UIKit.StarRow.new(stars, 3, 40.0)
	star_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(star_row)
	var msg := "Harika! Kelimeler pekişiyor." if stars == 3 else ("İyi gidiyorsun, tekrar et." if stars == 2 else "Defterine dönüp kelimelere göz at.")
	box.add_child(UIKit.make_label(msg, 20, UIKit.TEXT_DARK))
	var again := UIKit.make_button("Tekrar Test", UIKit.PURPLE, 24, 62)
	again.pressed.connect(func() -> void: Progress.go_quiz())
	box.add_child(again)
	var notebook := UIKit.make_button("Kelime Defterim", UIKit.BLUE, 24, 62)
	notebook.pressed.connect(func() -> void: Progress.go_notebook())
	box.add_child(notebook)
	var menu := UIKit.make_button("Menü", UIKit.DARK_PURPLE, 22, 56)
	menu.pressed.connect(func() -> void: Progress.go_menu())
	box.add_child(menu)


func _speak(word: String) -> void:
	var voices := DisplayServer.tts_get_voices_for_language("en")
	if voices.is_empty():
		return
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(word, voices[0], 50, 1.0, 0.9)
