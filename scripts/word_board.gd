@tool
extends Control
## Word Blast prototype board.
## Drag across adjacent letters to spell a word. Valid words clear their
## tiles, the grid cascades, and new letters fall in from the top.

const GRID_SIZE := 5
const MIN_WORD_LENGTH := 3

## Vocabulary and Turkish meanings load from the dedicated bank so the board
## stays small while the game keeps a large rotating word pool.
const WordBank := preload("res://data/word_bank.gd")

## Fill letters are biased toward simple vocabulary so new letters can keep
## forming familiar child-friendly words.
const FILL_POOL := "AAAABBBBCCCCDDDDEEEEEEEFFGGGGHHHIIIIJJKKLLLMMMNNNNNOOOOOPPQRRRRSSSSTTTTUUUVWWXYYZ"





## How long the meaning reveal stays up before returning to the board.
const REVEAL_SECONDS := 2.0

var letters: Array[String] = []
var dictionary: Dictionary = {}
var path: Array[int] = []
var invalid_tiles: Array[int] = []
var dragging := false
var invalid_flash := 0.0
var score := 0
var combo := 0
var revealing := false
var reveal_tween: Tween
var pulse_tween: Tween

## Words not yet found in the active level. When this empties, the board
## advances to the next free level or shows the prototype paywall after level 3.
var remaining_words: Array[String] = []
var current_hint_word := ""
var used_count := 0
## Current level number (1-based). Levels 1-3 are free; level 4+ is locked.
var current_level := 1
## Active level target pool used to rebuild remaining_words.
var level_words: Array[String] = []
## True while the prototype paywall overlay is visible.
var paywall_visible := false
## Seeded generator for deterministic board placement.
var _board_rng := RandomNumberGenerator.new()

var tile_buttons: Array[Button] = []
var base_styles: Array[StyleBox] = []
var selected_style: StyleBox
var invalid_style: StyleBox

@onready var score_label: Label = $ScoreLabel
@onready var combo_label: Label = $ComboLabel
@onready var word_label: Label = $WordLabel
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
@onready var paywall_overlay: Control = $PaywallOverlay
@onready var paywall_title_label: Label = $PaywallOverlay/PaywallCenter/PaywallPanel/VBox/PaywallTitleLabel
@onready var paywall_price_label: Label = $PaywallOverlay/PaywallCenter/PaywallPanel/VBox/PaywallPriceLabel
@onready var paywall_message_label: Label = $PaywallOverlay/PaywallCenter/PaywallPanel/VBox/PaywallMessageLabel
@onready var buy_button: Button = $PaywallOverlay/PaywallCenter/PaywallPanel/VBox/BuyButton
@onready var paywall_close_button: Button = $PaywallOverlay/PaywallCenter/PaywallPanel/VBox/PaywallCloseButton


func _ready() -> void:
	for word in WordBank.get_all_words():
		dictionary[word] = true
	$ResetButton.pressed.connect(_on_reset_pressed)
	listen_button.pressed.connect(_on_listen_pressed)
	reveal_overlay.gui_input.connect(_on_reveal_overlay_input)
	reveal_overlay.hide()
	paywall_overlay.hide()
	buy_button.pressed.connect(_on_buy_pressed)
	paywall_close_button.pressed.connect(_on_paywall_close_pressed)
	resized.connect(_on_resized)
	for i in range(GRID_SIZE * GRID_SIZE):
		var button := get_node_or_null("Center/BoardBackdrop/Board/Tile%d" % i)
		if button is Button:
			tile_buttons.append(button)
			base_styles.append(button.get_theme_stylebox("normal"))
	selected_style = _make_tile_style(Color("#ffd23f"), Color("#ffffff"))
	invalid_style = _make_tile_style(Color("#e63946"), Color("#ffffff"))
	_on_resized()
	_board_rng.seed = 20240517
	reset_board()


func _process(delta: float) -> void:
	if invalid_flash > 0.0:
		invalid_flash = maxf(0.0, invalid_flash - delta)
		if invalid_flash == 0.0:
			invalid_tiles.clear()
		_refresh_tiles()


func _gui_input(event: InputEvent) -> void:
	if revealing or paywall_visible:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drag(event.position)
		else:
			_end_drag()
	elif event is InputEventMouseMotion and dragging:
		_update_drag(event.position)


func _on_resized() -> void:
	if tile_buttons.is_empty():
		return
	var gap := 8.0
	var horizontal_space := size.x - 48.0
	var vertical_space := size.y - 220.0
	var tile := int(clampf((minf(horizontal_space, vertical_space) - gap * float(GRID_SIZE - 1)) / float(GRID_SIZE), 44.0, 120.0))
	for button in tile_buttons:
		button.custom_minimum_size = Vector2(tile, tile)
		button.add_theme_font_size_override("font_size", int(tile * 0.44))
	_refresh_tiles()


func _on_reset_pressed() -> void:
	reset_board()


func reset_board() -> void:
	path.clear()
	invalid_tiles.clear()
	dragging = false
	invalid_flash = 0.0
	score = 0
	combo = 0
	revealing = false
	paywall_visible = false
	if reveal_tween and reveal_tween.is_valid():
		reveal_tween.kill()
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	reveal_overlay.hide()
	paywall_overlay.hide()
	_load_level(current_level)
	_set_feedback("Harfleri surukleyip kelime yap", Color("#2f5d8a"))
	_refresh_hud()
	_refresh_tiles()


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
	if paywall_visible:
		return
	var word := _current_word()
	if not _path_is_straight():
		_fail_word("Sadece duz cizgi sec!")
		path.clear()
		_refresh_hud()
		_refresh_tiles()
		return
	var found_word := ""
	if word.length() < MIN_WORD_LENGTH:
		_fail_word("Cok kisa! Daha fazla harf sec")
	elif dictionary.has(word):
		combo += 1
		var points := word.length() * 10 * combo
		score += points
		_set_feedback("Harika! %s +%d" % [word, points], Color("#1e8e3e"))
		_clear_tiles(path)
		_cascade_and_fill()
		found_word = word
		_mark_word_used(word)
	else:
		_fail_word("Listede yok: %s" % word)
	path.clear()
	_refresh_hud()
	_refresh_tiles()
	if found_word != "":
		_reveal_word(found_word)


func _fail_word(message: String) -> void:
	combo = 0
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


func _reveal_word(word: String) -> void:
	if paywall_visible:
		return
	revealing = true
	var meaning := WordBank.get_meaning(word)
	reveal_word_label.text = word
	reveal_meaning_label.text = meaning
	illustration.set_word(word)
	pronunciation_label.text = "Okuyus: %s" % _letter_guide(word)
	reveal_hint.text = "Devam etmek icin dokun"
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
	if event is InputEventMouseButton:
		if event.pressed:
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
	_set_feedback("Baska kelime bul!", Color("#2f5d8a"))


## Round and hint helpers.

func _load_level(level: int) -> void:
	current_level = clampi(level, 1, WordBank.LEVEL_COUNT)
	level_words = WordBank.get_level_words(current_level)
	remaining_words = level_words.duplicate()
	remaining_words.shuffle()
	used_count = 0
	_refill_board()
	_refresh_hint_word()
	_refresh_tiles()
	_update_level_hud()


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


func _level_found_count() -> int:
	return WordBank.WORDS_PER_LEVEL - remaining_words.size()


func _update_level_hud() -> void:
	if level_label == null:
		return
	level_label.text = "SEVIYE %d  %d/%d" % [current_level, _level_found_count(), WordBank.WORDS_PER_LEVEL]


func _mark_word_used(word: String) -> void:
	if remaining_words.has(word):
		remaining_words.erase(word)
		used_count += 1
		_update_level_hud()
	if remaining_words.is_empty():
		_auto_refresh_round()
		return
	_refresh_hint_word()


func _auto_refresh_round() -> void:
	# Every target in the active level has been found. Free levels advance;
	# finishing level 3 opens the prototype paywall instead of entering level 4.
	if current_level < WordBank.FREE_LEVELS:
		_load_level(current_level + 1)
		_set_feedback("Seviye %d hazir! Yeni kelimeleri bul!" % current_level, Color("#1e8e3e"))
	else:
		_show_paywall()


func _refill_board() -> void:
	letters = []
	for i in range(GRID_SIZE * GRID_SIZE):
		letters.append(_random_letter())


func _update_hint() -> void:
	if hint_label == null:
		return
	if current_hint_word == "":
		hint_label.text = "IPUCU: Yeni kelimeler geliyor..."
		return
	var meaning := WordBank.get_meaning(current_hint_word)
	var first := current_hint_word.substr(0, 1)
	hint_label.text = "IPUCU: %s = %s ile baslayan kelime" % [meaning, first]


## Prototype paywall (no real billing, no store SDK).
func _show_paywall() -> void:
	paywall_visible = true
	revealing = false
	path.clear()
	if reveal_tween and reveal_tween.is_valid():
		reveal_tween.kill()
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	reveal_overlay.hide()
	paywall_title_label.text = "4. SEVIYE KILITLI"
	paywall_price_label.text = "Prototip fiyat: 19,99 TL"
	paywall_message_label.hide()
	paywall_overlay.show()
	_set_feedback("Seviye 3 tamamlandi! Seviye 4 kilitli.", Color("#c0392b"))


func _on_buy_pressed() -> void:
	paywall_message_label.text = "Demo: Gercek odeme yok"
	paywall_message_label.show()


func _on_paywall_close_pressed() -> void:
	paywall_overlay.hide()
	paywall_visible = false
	# Keep the game playable: replay the current (level 3) target pool.
	_load_level(current_level)
	_set_feedback("Seviye 4 kilitli (demo). Seviye 3 tekrar oynanabilir.", Color("#2f5d8a"))


## Pronunciation helpers.

func _on_listen_pressed() -> void:
	_speak_word(reveal_word_label.text)


func _speak_word(word: String) -> void:
	if word == "":
		return
	var guide := _letter_guide(word)
	var voice := _english_voice_id()
	if voice.is_empty():
		pronunciation_label.text = "Ses yok. Sozcugu harf harf oku: %s" % guide
		return
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(word, voice, 50, 1.0, 0.9)
	pronunciation_label.text = "Dinle: %s (harfler: %s)" % [word, guide]


func _english_voice_id() -> String:
	# Pick the first English voice so the word is spoken in English instead
	# of the OS default voice, which can be a localized voice such as Turkish.
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
