@tool
extends Control
## Wordi oyun tahtası.
## Harfleri düz bir çizgide sürükleyerek İngilizce kelimeyi bul; doğru kelimede
## resim + Türkçe anlam + telaffuz gösterilir ve kelime Kelime Defterine eklenir.
## İki mod: SEVİYE (temalı 15 hedef kelime) ve GÜNÜN KELİMELERİ (süreli 8 kelime).

const GRID_SIZE := 5
const MIN_WORD_LENGTH := 3
## Bir seviyeyi tamamlamak için bulunması gereken hedef kelime sayısı.
const WORDS_TO_CLEAR := 15

const WordBank := preload("res://data/word_bank.gd")
const UIKit := preload("res://scripts/ui_kit.gd")

const FILL_POOL := "AAAABBBBCCCCDDDDEEEEEEEFFGGGGHHHIIIIJJKKLLLMMMNNNNNOOOOOPPQRRRRSSSSTTTTUUUVWWXYYZ"
const REVEAL_SECONDS := 2.2

var letters: Array[String] = []
var dictionary: Dictionary = {}
var path: Array[int] = []
var invalid_tiles: Array[int] = []
var dragging := false
var invalid_flash := 0.0
var score := 0
var combo := 0
var mistakes := 0
var revealing := false
var finished := false
var reveal_tween: Tween
var pulse_tween: Tween

var remaining_words: Array[String] = []
var current_hint_word := ""
var current_level := 1
var level_words: Array[String] = []
var target_total := WORDS_TO_CLEAR
var _board_rng := RandomNumberGenerator.new()

## Günün kelimeleri modu
var daily_mode := false
var time_left := 0.0
var timer_label: Label

var tile_buttons: Array[Button] = []
var base_styles: Array[StyleBox] = []
var selected_style: StyleBox
var invalid_style: StyleBox
var result_overlay: Control

@onready var score_label: Label = $ScoreLabel
@onready var combo_label: Label = $ComboLabel
@onready var word_label: Label = $WordLabel
@onready var title_label: Label = $Title
@onready var feedback_label: Label = $FeedbackLabel
@onready var reveal_overlay: Control = $RevealOverlay
@onready var reveal_panel: PanelContainer = $RevealOverlay/RevealCenter/RevealPanel
@onready var reveal_word_label: Label = $RevealOverlay/RevealCenter/RevealPanel/VBox/RevealWordLabel
@onready var reveal_meaning_label: Label = $RevealOverlay/RevealCenter/RevealPanel/VBox/RevealMeaningLabel
@onready var illustration: WordIllustration = $RevealOverlay/RevealCenter/RevealPanel/VBox/IllustrationCard/Illustration
@onready var reveal_hint: Label = $RevealOverlay/RevealCenter/RevealPanel/VBox/RevealHint
@onready var hint_label: Label = $HintPanel/HintLabel
@onready var listen_button: Button = $RevealOverlay/RevealCenter/RevealPanel/VBox/ListenButton
@onready var pronunciation_label: Label = $RevealOverlay/RevealCenter/RevealPanel/VBox/PronunciationLabel
@onready var level_label: Label = $LevelLabel
@onready var menu_button: Button = $ResetButton
@onready var music_player: AudioStreamPlayer = $BackgroundMusic


func _has_progress() -> bool:
	return not Engine.is_editor_hint() and has_node("/root/Progress")


func _ready() -> void:
	for word in WordBank.get_all_words():
		dictionary[word] = true
	menu_button.pressed.connect(_on_menu_pressed)
	listen_button.pressed.connect(_on_listen_pressed)
	reveal_overlay.gui_input.connect(_on_reveal_overlay_input)
	reveal_overlay.hide()
	resized.connect(_on_resized)
	for i in range(GRID_SIZE * GRID_SIZE):
		var button := get_node_or_null("Center/BoardBackdrop/Board/Tile%d" % i)
		if button is Button:
			tile_buttons.append(button)
			base_styles.append(button.get_theme_stylebox("normal"))
	selected_style = _make_tile_style(Color("#ffd23f"), Color("#ffffff"))
	invalid_style = _make_tile_style(Color("#e63946"), Color("#ffffff"))
	_layout_hud()
	_on_resized()
	if _has_progress():
		daily_mode = Progress.mode == Progress.Mode.DAILY
		current_level = Progress.current_level
		music_player.playing = Progress.music_on
		if not Progress.music_on:
			music_player.stop()
	_board_rng.seed = hash(Progress.today_key()) if daily_mode else int(Time.get_unix_time_from_system())
	if daily_mode:
		_build_timer_label()
	reset_board()


func _process(delta: float) -> void:
	if invalid_flash > 0.0:
		invalid_flash = maxf(0.0, invalid_flash - delta)
		if invalid_flash == 0.0:
			invalid_tiles.clear()
		_refresh_tiles()
	if daily_mode and not finished and not Engine.is_editor_hint():
		time_left = maxf(0.0, time_left - delta)
		_update_timer_label()
		if time_left <= 0.0:
			_finish_daily()


func _gui_input(event: InputEvent) -> void:
	if revealing or finished:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drag(event.position)
		else:
			_end_drag()
	elif event is InputEventMouseMotion and dragging:
		_update_drag(event.position)


## HUD yerleşimi (540 px mantıksal genişlik için): 1. satır puan + menü,
## 2. satır seviye başlığı, 3. satır ilerleme (sol) ve kombo (sağ); tahta 190 px'den başlar.
func _layout_hud() -> void:
	title_label.offset_top = 56
	title_label.offset_bottom = 100
	title_label.add_theme_font_size_override("font_size", 30)
	word_label.offset_top = 150
	word_label.offset_bottom = 184
	level_label.offset_top = 104
	level_label.offset_bottom = 136
	combo_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	combo_label.offset_left = -300
	combo_label.offset_right = -24
	combo_label.offset_top = 104
	combo_label.offset_bottom = 136
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	combo_label.add_theme_font_size_override("font_size", 22)
	$Center.offset_top = 190
	var rabbit := get_node_or_null("AnimalBackdrop/Rabbit")
	if rabbit:
		rabbit.offset_top = 196
		rabbit.offset_bottom = 316
	var cat := get_node_or_null("AnimalBackdrop/Cat")
	if cat:
		cat.offset_top = 196
		cat.offset_bottom = 316


func _on_resized() -> void:
	if tile_buttons.is_empty():
		return
	var gap := 8.0
	var horizontal_space := size.x - 48.0
	var vertical_space := size.y - 320.0
	var tile := int(clampf((minf(horizontal_space, vertical_space) - gap * float(GRID_SIZE - 1)) / float(GRID_SIZE), 44.0, 120.0))
	for button in tile_buttons:
		button.custom_minimum_size = Vector2(tile, tile)
		button.add_theme_font_size_override("font_size", int(tile * 0.44))
	_refresh_tiles()


func _on_menu_pressed() -> void:
	if _has_progress():
		Progress.go_menu()


func reset_board() -> void:
	path.clear()
	invalid_tiles.clear()
	dragging = false
	invalid_flash = 0.0
	score = 0
	combo = 0
	mistakes = 0
	revealing = false
	finished = false
	if reveal_tween and reveal_tween.is_valid():
		reveal_tween.kill()
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	reveal_overlay.hide()
	if result_overlay:
		result_overlay.queue_free()
		result_overlay = null
	if daily_mode:
		_load_daily()
	else:
		_load_level(current_level)
	_set_feedback("Harfleri sürükleyip kelime yap", Color("#2f5d8a"))
	_refresh_hud()
	_refresh_tiles()


# --- Sürükleme -------------------------------------------------------------

func _start_drag(pos: Vector2) -> void:
	var idx := _tile_at(pos)
	if idx < 0:
		return
	dragging = true
	path = [idx]
	_refresh_hud()
	_refresh_tiles()


func _update_drag(pos: Vector2) -> void:
	var idx := _tile_at(pos)
	if idx < 0:
		return
	if path.size() > 1 and idx == path[path.size() - 2]:
		path.pop_back()
		_refresh_hud()
		_refresh_tiles()
		return
	if idx == path[path.size() - 1]:
		return
	if _can_extend_straight(idx):
		path.append(idx)
		_refresh_hud()
		_refresh_tiles()


func _end_drag() -> void:
	if not dragging:
		return
	dragging = false
	_submit_word()


func _submit_word() -> void:
	if finished:
		return
	var word := _current_word()
	if not _path_is_straight():
		_fail_word("Sadece düz çizgi seç!")
		path.clear()
		_refresh_hud()
		_refresh_tiles()
		return
	var found_word := ""
	if word.length() < MIN_WORD_LENGTH:
		if path.size() > 1:
			_fail_word("Çok kısa! Daha fazla harf seç")
	elif dictionary.has(word):
		combo += 1
		var points := word.length() * 10 * combo
		score += points
		_set_feedback("Harika! %s +%d" % [word, points], Color("#1e8e3e"))
		_clear_tiles(path)
		_cascade_and_fill()
		found_word = word
		if _has_progress():
			Progress.learn_word(word)
		_mark_word_used(word)
	else:
		_fail_word("Listede yok: %s" % word)
	path.clear()
	_refresh_hud()
	_refresh_tiles()
	if found_word != "" and not finished:
		_reveal_word(found_word)


func _fail_word(message: String) -> void:
	combo = 0
	mistakes += 1
	invalid_tiles = path.duplicate()
	invalid_flash = 0.6
	_set_feedback(message, Color("#c0392b"))
	_refresh_hud()


func _current_word() -> String:
	var word := ""
	for idx in path:
		word += letters[idx]
	return word


func _clear_tiles(ids: Array[int]) -> void:
	for idx in ids:
		letters[idx] = ""


func _cascade_and_fill() -> void:
	for col in range(GRID_SIZE):
		var column: Array[String] = []
		for row in range(GRID_SIZE - 1, -1, -1):
			var ch := letters[row * GRID_SIZE + col]
			if ch != "":
				column.append(ch)
		var write_row := GRID_SIZE - 1
		for ch in column:
			letters[write_row * GRID_SIZE + col] = ch
			write_row -= 1
		while write_row >= 0:
			letters[write_row * GRID_SIZE + col] = _random_letter()
			write_row -= 1


func _random_letter() -> String:
	return FILL_POOL[_board_rng.randi() % FILL_POOL.length()]


func _is_straight_adjacent(a: int, b: int) -> bool:
	@warning_ignore("integer_division")
	var ar := a / GRID_SIZE
	var ac := a % GRID_SIZE
	@warning_ignore("integer_division")
	var br := b / GRID_SIZE
	var bc := b % GRID_SIZE
	return (ar == br and absi(ac - bc) == 1) or (ac == bc and absi(ar - br) == 1)


func _path_is_straight() -> bool:
	if path.size() <= 1:
		return true
	var same_row := true
	var same_col := true
	@warning_ignore("integer_division")
	var r0 := path[0] / GRID_SIZE
	@warning_ignore("integer_division")
	var c0 := path[0] % GRID_SIZE
	for i in range(1, path.size()):
		if not _is_straight_adjacent(path[i - 1], path[i]):
			return false
		@warning_ignore("integer_division")
		var r := path[i] / GRID_SIZE
		@warning_ignore("integer_division")
		var c := path[i] % GRID_SIZE
		if r != r0:
			same_row = false
		if c != c0:
			same_col = false
	return same_row or same_col


func _can_extend_straight(idx: int) -> bool:
	if path.is_empty():
		return true
	if not _is_straight_adjacent(path[path.size() - 1], idx):
		return false
	if path.has(idx):
		return false
	if path.size() < 2:
		return true
	@warning_ignore("integer_division")
	var r0 := path[0] / GRID_SIZE
	@warning_ignore("integer_division")
	var c0 := path[0] % GRID_SIZE
	@warning_ignore("integer_division")
	var r1 := path[1] / GRID_SIZE
	@warning_ignore("integer_division")
	var c1 := path[1] % GRID_SIZE
	@warning_ignore("integer_division")
	var er := idx / GRID_SIZE
	@warning_ignore("integer_division")
	var ec := idx % GRID_SIZE
	if r0 == r1:
		return er == r0 and absi(ec - c0) == path.size()
	if c0 == c1:
		return ec == c0 and absi(er - r0) == path.size()
	return false


func _tile_at(pos: Vector2) -> int:
	var global_point := global_position + pos
	for i in range(tile_buttons.size()):
		if tile_buttons[i].get_global_rect().has_point(global_point):
			return i
	return -1


func _make_tile_style(bg: Color, border: Color) -> StyleBox:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(18)
	sb.set_border_width_all(4)
	sb.border_color = border
	return sb


func _refresh_tiles() -> void:
	for i in range(tile_buttons.size()):
		if i >= letters.size():
			break
		var button := tile_buttons[i]
		button.text = letters[i]
		button.visible = letters[i] != ""
		var style: StyleBox = base_styles[i]
		if invalid_flash > 0.0 and invalid_tiles.has(i):
			style = invalid_style
		elif path.has(i):
			style = selected_style
		button.add_theme_stylebox_override("normal", style)


func _set_feedback(text: String, color: Color) -> void:
	feedback_label.text = text
	feedback_label.add_theme_color_override("font_color", color)


func _refresh_hud() -> void:
	score_label.text = "PUAN  %d" % score
	combo_label.text = ("KOMBO  x%d" % combo) if combo > 1 else ""
	word_label.text = _current_word()
	_update_level_hud()


# --- Kelime kartı ----------------------------------------------------------

func _reveal_word(word: String) -> void:
	revealing = true
	var meaning := WordBank.get_meaning(word)
	reveal_word_label.text = word
	reveal_meaning_label.text = meaning
	illustration.set_word(word)
	pronunciation_label.text = "Harf harf: %s" % _letter_guide(word)
	reveal_hint.text = "Deftere eklendi  •  Devam etmek için dokun"
	reveal_overlay.show()
	_play_reveal_entrance()
	_speak_word(word)
	get_tree().create_timer(REVEAL_SECONDS).timeout.connect(_on_reveal_timeout)


func _play_reveal_entrance() -> void:
	if reveal_tween and reveal_tween.is_valid():
		reveal_tween.kill()
	reveal_panel.pivot_offset = reveal_panel.size * 0.5
	reveal_panel.modulate = Color(1, 1, 1, 0.0)
	reveal_panel.scale = Vector2(0.6, 0.6)
	reveal_tween = create_tween()
	reveal_tween.set_parallel(true)
	reveal_tween.tween_property(reveal_panel, "modulate:a", 1.0, 0.22)
	reveal_tween.tween_property(reveal_panel, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	reveal_tween.set_parallel(false)
	_play_illustration_pulse()


func _play_illustration_pulse() -> void:
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	illustration.pivot_offset = illustration.size * 0.5
	illustration.scale = Vector2(0.8, 0.8)
	pulse_tween = create_tween()
	pulse_tween.tween_property(illustration, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pulse_tween.tween_property(illustration, "scale", Vector2(1.06, 1.06), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(illustration, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_reveal_overlay_input(event: InputEvent) -> void:
	if not revealing:
		return
	if event is InputEventMouseButton and event.pressed:
		_continue_after_reveal()


func _on_reveal_timeout() -> void:
	if revealing:
		_continue_after_reveal()


func _continue_after_reveal() -> void:
	if not revealing:
		return
	revealing = false
	if reveal_tween and reveal_tween.is_valid():
		reveal_tween.kill()
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	reveal_overlay.hide()
	if remaining_words.is_empty():
		_on_round_complete()
	else:
		_set_feedback("Başka kelime bul!", Color("#2f5d8a"))


# --- Tur / seviye ----------------------------------------------------------

func _load_level(level: int) -> void:
	current_level = clampi(level, 1, WordBank.LEVEL_COUNT)
	level_words = WordBank.get_level_words(current_level)
	remaining_words = _pick_targets(_ordered_by_difficulty(level_words), WORDS_TO_CLEAR)
	target_total = remaining_words.size()
	title_label.text = "Seviye %d: %s" % [current_level, WordBank.get_level_title(current_level)]
	_refill_board()
	_refresh_hint_word()
	_refresh_tiles()
	_update_level_hud()


func _load_daily() -> void:
	level_words = Progress.daily_words() if _has_progress() else WordBank.get_level_words(1)
	remaining_words = _ordered_by_difficulty(level_words)
	target_total = remaining_words.size()
	time_left = float(Progress.DAILY_SECONDS) if _has_progress() else 120.0
	title_label.text = "Günün Kelimeleri"
	_refill_board()
	_refresh_hint_word()
	_refresh_tiles()
	_update_level_hud()
	_update_timer_label()


## Seviyedeki 100 kelimelik havuzdan, kolaydan zora yayılmış hedef kelimeler seç.
func _pick_targets(ordered: Array[String], count: int) -> Array[String]:
	if ordered.size() <= count:
		return ordered
	var picked: Array[String] = []
	var step := float(ordered.size()) / float(count)
	for i in range(count):
		var start := int(i * step)
		var end := mini(ordered.size() - 1, int((i + 1) * step) - 1)
		var idx := start + (_board_rng.randi() % maxi(1, end - start + 1))
		picked.append(ordered[idx])
	return picked


func _ordered_by_difficulty(words: Array[String]) -> Array[String]:
	var ordered: Array[String] = words.duplicate()
	ordered.sort_custom(func(a: String, b: String) -> bool: return a.length() < b.length())
	var group_start := 0
	for i in range(1, ordered.size() + 1):
		if i == ordered.size() or ordered[i].length() != ordered[group_start].length():
			var group := ordered.slice(group_start, i)
			_shuffle_with_rng(group)
			for j in range(group.size()):
				ordered[group_start + j] = group[j]
			group_start = i
	return ordered


func _shuffle_with_rng(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := _board_rng.randi() % (i + 1)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


func _refresh_hint_word() -> void:
	current_hint_word = ""
	if remaining_words.is_empty():
		_update_hint()
		return
	var candidate := _find_discoverable_word(remaining_words)
	if candidate == "":
		candidate = remaining_words[0]
		_place_word_on_board(candidate)
	current_hint_word = candidate
	_update_hint()
	_refresh_tiles()


func _find_discoverable_word(pool: Array[String]) -> String:
	for word in pool:
		if _word_can_be_formed(word):
			return word
	return ""


func _word_can_be_formed(word: String) -> bool:
	if word == "" or word.length() > GRID_SIZE:
		return false
	var n := word.length()
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE - n + 1):
			var forward := true
			var backward := true
			for k in range(n):
				var idx := row * GRID_SIZE + col + k
				if letters[idx] != word[k]:
					forward = false
				if letters[idx] != word[n - 1 - k]:
					backward = false
			if forward or backward:
				return true
	for col in range(GRID_SIZE):
		for row in range(GRID_SIZE - n + 1):
			var forward := true
			var backward := true
			for k in range(n):
				var idx := (row + k) * GRID_SIZE + col
				if letters[idx] != word[k]:
					forward = false
				if letters[idx] != word[n - 1 - k]:
					backward = false
			if forward or backward:
				return true
	return false


func _place_word_on_board(word: String) -> void:
	var n := word.length()
	if n < 1 or n > GRID_SIZE:
		return
	var horizontal := _board_rng.randi() % 2 == 0
	var reverse := _board_rng.randi() % 2 == 0
	var line := _board_rng.randi() % GRID_SIZE
	var start := _board_rng.randi() % (GRID_SIZE - n + 1)
	for i in range(n):
		var src := (n - 1 - i) if reverse else i
		var idx: int
		if horizontal:
			idx = line * GRID_SIZE + start + i
		else:
			idx = (start + i) * GRID_SIZE + line
		letters[idx] = word[src]


func _found_count() -> int:
	return target_total - remaining_words.size()


func _update_level_hud() -> void:
	if level_label == null:
		return
	if daily_mode:
		level_label.text = "GÜNÜN KELİMELERİ  %d/%d" % [_found_count(), target_total]
	else:
		level_label.text = "SEVİYE %d  %d/%d" % [current_level, _found_count(), target_total]


func _mark_word_used(word: String) -> void:
	if remaining_words.has(word):
		remaining_words.erase(word)
		_update_level_hud()
	if remaining_words.is_empty():
		return
	_refresh_hint_word()


func _on_round_complete() -> void:
	if daily_mode:
		_finish_daily()
	else:
		_finish_level()


func _refill_board() -> void:
	letters = []
	for i in range(GRID_SIZE * GRID_SIZE):
		letters.append(_random_letter())


func _update_hint() -> void:
	if hint_label == null:
		return
	if current_hint_word == "":
		hint_label.text = "İPUCU: Yeni kelimeler geliyor..."
		return
	var meaning := WordBank.get_meaning(current_hint_word)
	var first := current_hint_word.substr(0, 1)
	hint_label.text = "İPUCU: %s  (%d harf, %s ile başlar)" % [meaning, current_hint_word.length(), first]


# --- Günlük görev zamanlayıcı ---------------------------------------------

func _build_timer_label() -> void:
	timer_label = Label.new()
	timer_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	timer_label.offset_left = 24
	timer_label.offset_top = 136
	timer_label.offset_right = 300
	timer_label.offset_bottom = 166
	timer_label.add_theme_font_size_override("font_size", 24)
	timer_label.add_theme_color_override("font_color", Color("#c0392b"))
	timer_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(timer_label)


func _update_timer_label() -> void:
	if timer_label == null:
		return
	var secs := int(ceil(time_left))
	@warning_ignore("integer_division")
	timer_label.text = "SÜRE  %d:%02d" % [secs / 60, secs % 60]


# --- Sonuç ekranları --------------------------------------------------------

func _compute_stars() -> int:
	if mistakes <= 6:
		return 3
	if mistakes <= 15:
		return 2
	return 1


func _finish_level() -> void:
	if finished:
		return
	finished = true
	var stars := _compute_stars()
	if _has_progress():
		Progress.complete_level(current_level, stars, score)
	var next_level := mini(current_level + 1, WordBank.LEVEL_COUNT)
	var lines: Array[String] = [
		"%d kelime öğrendin, %d puan topladın." % [target_total, score],
		"Kelimeler defterine eklendi.",
	]
	var buttons: Array = []
	if current_level < WordBank.LEVEL_COUNT:
		buttons.append(["Sonraki Seviye: %s" % WordBank.get_level_title(next_level), UIKit.GREEN, func() -> void:
			current_level = next_level
			reset_board()])
	else:
		buttons.append(["Tüm seviyeler tamam! Tekrar oyna", UIKit.GREEN, func() -> void: reset_board()])
	buttons.append(["Kelime Defterim", UIKit.BLUE, _go_notebook])
	buttons.append(["Menü", UIKit.DARK_PURPLE, _go_menu])
	_show_result("Seviye %d tamamlandı!" % current_level, stars, lines, buttons)


func _go_notebook() -> void:
	if _has_progress():
		Progress.go_notebook()


func _go_menu() -> void:
	if _has_progress():
		Progress.go_menu()


func _go_levels() -> void:
	if _has_progress():
		Progress.start_level_game()


func _finish_daily() -> void:
	if finished:
		return
	finished = true
	var found := _found_count()
	if _has_progress():
		Progress.complete_daily(found, score)
	var stars := 3 if found >= target_total else (2 if found >= int(target_total * 0.6) else (1 if found > 0 else 0))
	var title := "Günün görevi tamam!" if found >= target_total else "Süre bitti!"
	var lines: Array[String] = [
		"%d / %d kelime buldun, %d puan." % [found, target_total, score],
		"Serin: %d gün. Yarın yeni kelimelerle görüşürüz!" % (Progress.streak if _has_progress() else 1),
	]
	var buttons: Array = [
		["Kelime Defterim", UIKit.BLUE, _go_notebook],
		["Seviyelere Devam", UIKit.GREEN, _go_levels],
		["Menü", UIKit.DARK_PURPLE, _go_menu],
	]
	_show_result(title, stars, lines, buttons)


func _show_result(title: String, stars: int, lines: Array[String], buttons: Array) -> void:
	reveal_overlay.hide()
	result_overlay = Control.new()
	UIKit.full_rect(result_overlay)
	result_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0.18, 0.08, 0.3, 0.6)
	result_overlay.add_child(UIKit.full_rect(dim))
	var center := CenterContainer.new()
	UIKit.full_rect(center)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_overlay.add_child(center)
	var panel := UIKit.make_panel(UIKit.CREAM_LIGHT, UIKit.ORANGE, 30)
	panel.custom_minimum_size = Vector2(clampf(size.x - 60.0, 280.0, 480.0), 0)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	box.add_child(UIKit.make_label(title, 36, UIKit.PINK))
	var row := UIKit.StarRow.new(stars, 3, 44.0)
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(row)
	for l in lines:
		box.add_child(UIKit.make_label(l, 20, UIKit.TEXT_DARK))
	for b in buttons:
		var btn := UIKit.make_button(b[0], b[1], 22, 60)
		btn.pressed.connect(b[2])
		box.add_child(btn)
	add_child(result_overlay)
	panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2(0.7, 0.7)
	var tw := create_tween()
	tw.tween_property(panel, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# --- Telaffuz ----------------------------------------------------------------

func _on_listen_pressed() -> void:
	_speak_word(reveal_word_label.text)


func _speak_word(word: String) -> void:
	if word == "":
		return
	if _has_progress() and not Progress.sound_on:
		return
	var voice := _english_voice_id()
	if voice.is_empty():
		pronunciation_label.text = "Harf harf: %s" % _letter_guide(word)
		return
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(word, voice, 50, 1.0, 0.9)


func _english_voice_id() -> String:
	var voices := DisplayServer.tts_get_voices_for_language("en")
	if voices.is_empty():
		return ""
	return voices[0]


func _letter_guide(word: String) -> String:
	var guide := ""
	for i in range(word.length()):
		if i > 0:
			guide += " - "
		guide += word[i]
	return guide
