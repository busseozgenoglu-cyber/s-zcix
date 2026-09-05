extends Node
## Wordi ilerleme ve kayıt sistemi (autoload: Progress).
##
## Oyuncunun seviyesi, öğrendiği kelimeler (kelime defteri), günlük görev
## sonuçları, seri (streak) ve ayarlar user:// altında ConfigFile ile saklanır.
## Ayrıca sahneler arası geçiş için oyun modunu taşır.

const SAVE_PATH := "user://wordi_save.cfg"
const WordBank := preload("res://data/word_bank.gd")

## Oyun modları
enum Mode { LEVEL, DAILY }

## Günlük görevde aranacak kelime sayısı ve süre (saniye).
const DAILY_WORD_COUNT := 8
const DAILY_SECONDS := 120

var mode: int = Mode.LEVEL

var current_level := 1
var total_score := 0
## word -> {"count": int, "first": unix, "last": unix, "correct": int, "wrong": int}
var learned: Dictionary = {}
## level(String) -> stars(int)
var level_stars: Dictionary = {}
## "YYYY-MM-DD" -> {"found": int, "stars": int, "score": int}
var daily_results: Dictionary = {}
var streak := 0
var last_play_day := ""
var music_on := true
var sound_on := true

var _cfg := ConfigFile.new()


func _ready() -> void:
	load_game()
	_touch_streak()
	_maybe_setup_screenshot_harness()


# --- Kayıt ---------------------------------------------------------------

func load_game() -> void:
	var err := _cfg.load(SAVE_PATH)
	if err != OK:
		return
	current_level = int(_cfg.get_value("game", "current_level", 1))
	total_score = int(_cfg.get_value("game", "total_score", 0))
	learned = _cfg.get_value("game", "learned", {})
	level_stars = _cfg.get_value("game", "level_stars", {})
	daily_results = _cfg.get_value("game", "daily_results", {})
	streak = int(_cfg.get_value("game", "streak", 0))
	last_play_day = str(_cfg.get_value("game", "last_play_day", ""))
	music_on = bool(_cfg.get_value("settings", "music_on", true))
	sound_on = bool(_cfg.get_value("settings", "sound_on", true))


func save_game() -> void:
	_cfg.set_value("game", "current_level", current_level)
	_cfg.set_value("game", "total_score", total_score)
	_cfg.set_value("game", "learned", learned)
	_cfg.set_value("game", "level_stars", level_stars)
	_cfg.set_value("game", "daily_results", daily_results)
	_cfg.set_value("game", "streak", streak)
	_cfg.set_value("game", "last_play_day", last_play_day)
	_cfg.set_value("settings", "music_on", music_on)
	_cfg.set_value("settings", "sound_on", sound_on)
	_cfg.save(SAVE_PATH)


func reset_all() -> void:
	current_level = 1
	total_score = 0
	learned = {}
	level_stars = {}
	daily_results = {}
	streak = 0
	last_play_day = ""
	save_game()


# --- Kelime defteri -------------------------------------------------------

func learn_word(word: String) -> void:
	var w := word.to_upper()
	var now := int(Time.get_unix_time_from_system())
	if learned.has(w):
		var entry: Dictionary = learned[w]
		entry["count"] = int(entry.get("count", 0)) + 1
		entry["last"] = now
		learned[w] = entry
	else:
		learned[w] = {"count": 1, "first": now, "last": now, "correct": 0, "wrong": 0}
	save_game()


func record_quiz(word: String, correct: bool) -> void:
	var w := word.to_upper()
	if not learned.has(w):
		learned[w] = {"count": 0, "first": 0, "last": 0, "correct": 0, "wrong": 0}
	var entry: Dictionary = learned[w]
	var key := "correct" if correct else "wrong"
	entry[key] = int(entry.get(key, 0)) + 1
	learned[w] = entry
	save_game()


func learned_words_sorted() -> Array[String]:
	var words: Array[String] = []
	for k in learned.keys():
		words.append(str(k))
	words.sort_custom(func(a: String, b: String) -> bool:
		var la: int = int(learned[a].get("last", 0))
		var lb: int = int(learned[b].get("last", 0))
		return la > lb)
	return words


func learned_count() -> int:
	return learned.size()


## Ustalık: 0 (yeni) .. 3 (pekişmiş). Doğru quiz cevapları ve tekrar bulma sayısıyla artar.
func mastery(word: String) -> int:
	var w := word.to_upper()
	if not learned.has(w):
		return 0
	var e: Dictionary = learned[w]
	var pts := int(e.get("count", 0)) + int(e.get("correct", 0)) * 2 - int(e.get("wrong", 0))
	return clampi(int(pts / 2), 0, 3)


## Quiz için en zayıf kelimeler önce gelir.
func quiz_pool(limit: int) -> Array[String]:
	var words := learned_words_sorted()
	words.sort_custom(func(a: String, b: String) -> bool:
		return mastery(a) < mastery(b))
	if words.size() > limit:
		words = words.slice(0, limit)
	return words


# --- Seviye ---------------------------------------------------------------

func complete_level(level: int, stars: int, score: int) -> void:
	var key := str(level)
	var prev := int(level_stars.get(key, 0))
	level_stars[key] = maxi(prev, stars)
	total_score += score
	if level >= current_level and level < WordBank.LEVEL_COUNT:
		current_level = level + 1
	save_game()


func stars_for(level: int) -> int:
	return int(level_stars.get(str(level), 0))


func total_stars() -> int:
	var s := 0
	for k in level_stars.keys():
		s += int(level_stars[k])
	return s


# --- Günlük görev ---------------------------------------------------------

static func today_key() -> String:
	var d := Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [d.year, d.month, d.day]


func daily_done_today() -> bool:
	return daily_results.has(today_key())


func daily_result_today() -> Dictionary:
	return daily_results.get(today_key(), {})


## Günün kelimeleri: tarih tohumlu, tüm bankadan seçilen, gerçek Türkçe anlamı olan kelimeler.
func daily_words() -> Array[String]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(today_key())
	var pool: Array[String] = WordBank.get_all_core_words()
	var chosen: Array[String] = []
	while chosen.size() < DAILY_WORD_COUNT and pool.size() > 0:
		var idx := rng.randi() % pool.size()
		chosen.append(pool[idx])
		pool.remove_at(idx)
	return chosen


func complete_daily(found: int, score: int) -> void:
	var stars := 0
	if found >= DAILY_WORD_COUNT:
		stars = 3
	elif found >= int(DAILY_WORD_COUNT * 0.6):
		stars = 2
	elif found > 0:
		stars = 1
	daily_results[today_key()] = {"found": found, "stars": stars, "score": score}
	total_score += score
	save_game()


func _touch_streak() -> void:
	var today := today_key()
	if last_play_day == today:
		return
	if last_play_day != "":
		var yesterday := _day_offset(today, -1)
		streak = streak + 1 if last_play_day == yesterday else 1
	else:
		streak = 1
	last_play_day = today
	save_game()


static func _day_offset(day: String, offset_days: int) -> String:
	var parts := day.split("-")
	if parts.size() != 3:
		return ""
	var dict := {"year": int(parts[0]), "month": int(parts[1]), "day": int(parts[2]), "hour": 12, "minute": 0, "second": 0}
	var unix := Time.get_unix_time_from_datetime_dict(dict) + offset_days * 86400
	var d := Time.get_datetime_dict_from_unix_time(unix)
	return "%04d-%02d-%02d" % [d.year, d.month, d.day]


# --- Sahne geçişleri ------------------------------------------------------

func go_menu() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")


func start_level_game() -> void:
	mode = Mode.LEVEL
	get_tree().change_scene_to_file("res://main.tscn")


func start_daily_game() -> void:
	mode = Mode.DAILY
	get_tree().change_scene_to_file("res://main.tscn")


func go_notebook() -> void:
	get_tree().change_scene_to_file("res://notebook.tscn")


func go_quiz() -> void:
	get_tree().change_scene_to_file("res://quiz.tscn")


# --- Ekran görüntüsü yardımcısı (yalnızca geliştirme; WORDI_SHOT env) ------

func _maybe_setup_screenshot_harness() -> void:
	var path := OS.get_environment("WORDI_SHOT")
	if path == "":
		return
	if OS.get_environment("WORDI_DEMO") != "":
		_seed_demo_progress()
	var delay := float(OS.get_environment("WORDI_DELAY")) if OS.get_environment("WORDI_DELAY") != "" else 1.5
	_run_shot.call_deferred(OS.get_environment("WORDI_SCENE"), path, delay, OS.get_environment("WORDI_SHOT_SIZE"))


## Ekranı istenen mağaza çözünürlüğünde (ör. 1284x2778) bir SubViewport içinde,
## projenin canvas_items/expand ölçekleme mantığını taklit ederek çizer ve PNG kaydeder.
func _run_shot(scene: String, path: String, delay: float, size_str: String) -> void:
	await get_tree().process_frame
	match scene:
		"game":
			mode = Mode.LEVEL
			get_tree().change_scene_to_file("res://main.tscn")
		"daily":
			mode = Mode.DAILY
			get_tree().change_scene_to_file("res://main.tscn")
		"notebook":
			get_tree().change_scene_to_file("res://notebook.tscn")
		"quiz":
			get_tree().change_scene_to_file("res://quiz.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	var target := get_tree().current_scene as Control
	var vp: SubViewport = null
	if size_str != "" and target != null:
		var parts := size_str.split("x")
		var w := int(parts[0])
		var h := int(parts[1])
		var base := Vector2(
			float(ProjectSettings.get_setting("display/window/size/viewport_width", 540)),
			float(ProjectSettings.get_setting("display/window/size/viewport_height", 1170)))
		var scale := minf(float(w) / base.x, float(h) / base.y)
		var logical := Vector2(w, h) / scale
		vp = SubViewport.new()
		vp.size = Vector2i(w, h)
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		vp.transparent_bg = false
		get_tree().root.add_child(vp)
		target.reparent(vp)
		target.set_anchors_preset(Control.PRESET_TOP_LEFT)
		target.position = Vector2.ZERO
		target.size = logical
		vp.canvas_transform = Transform2D().scaled(Vector2(scale, scale))
	var reveal := OS.get_environment("WORDI_REVEAL")
	if reveal != "" and target != null and target.has_method("_reveal_word"):
		await get_tree().create_timer(0.3).timeout
		target.call("_reveal_word", reveal)
	await get_tree().create_timer(delay).timeout
	await RenderingServer.frame_post_draw
	var img := (vp.get_texture() if vp else get_viewport().get_texture()).get_image()
	img.save_png(path)
	print("WORDI_SHOT saved: ", path, " ", img.get_size())
	get_tree().quit()


func _seed_demo_progress() -> void:
	var demo_words := ["CAT", "DOG", "SUN", "MOON", "STAR", "TREE", "FISH", "BOOK", "BALL", "APPLE",
		"DUCK", "LION", "BEAR", "FROG", "BIRD", "EGG", "MILK", "CAKE", "CAR", "HAT", "KEY", "CUP",
		"RED", "BLUE", "GREEN", "HOME", "OWL", "COW", "PIG", "BEE"]
	var now := int(Time.get_unix_time_from_system())
	learned = {}
	for i in range(demo_words.size()):
		learned[demo_words[i]] = {"count": 1 + (i % 3), "first": now - i * 3600, "last": now - i * 600, "correct": i % 4, "wrong": 0}
	current_level = 4
	level_stars = {"1": 3, "2": 3, "3": 2}
	total_score = 4820
	streak = 5
	daily_results = {}
