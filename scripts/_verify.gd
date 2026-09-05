extends SceneTree
## Geliştirme aracı: tüm script ve sahneleri yükleyip derleme hatalarını raporlar.

func _init() -> void:
	var ok := true
	for p in ["res://scripts/progress.gd", "res://scripts/ui_kit.gd", "res://scripts/menu.gd",
			"res://scripts/notebook.gd", "res://scripts/quiz.gd", "res://scripts/word_board.gd",
			"res://data/word_bank.gd", "res://data/meanings_1.gd", "res://data/meanings_2.gd",
			"res://data/meanings_3.gd", "res://data/meanings_4.gd"]:
		var s = load(p)
		if s == null or not (s as Script).can_instantiate():
			print("HATA: yüklenemedi ", p)
			ok = false
		else:
			print("ok ", p)
	for p in ["res://menu.tscn", "res://notebook.tscn", "res://quiz.tscn", "res://main.tscn"]:
		var sc = load(p)
		if sc == null:
			print("HATA: sahne yüklenemedi ", p)
			ok = false
		else:
			print("ok ", p)
	var Bank = load("res://data/word_bank.gd")
	var missing := 0
	for w in Bank.get_all_words():
		if not Bank.has_real_meaning(w):
			missing += 1
			print("anlam yok: ", w)
	print("anlamsiz kelime sayisi: ", missing, " / ", Bank.get_total_unique_words())
	print("ornek: CAT=", Bank.get_meaning("CAT"), " | ZOO=", Bank.get_meaning("ZOO"), " | seviye 7=", Bank.get_level_title(7))
	var Core = load("res://data/core_words.gd")
	for level in range(1, Bank.LEVEL_COUNT + 1):
		var core: Array = Bank.get_core_words(level)
		var src: Array = Core.CORE.get(level, [])
		if core.size() != src.size():
			ok = false
			var missing_words := []
			for w in src:
				if not core.has(w):
					missing_words.append(w)
			print("HATA: seviye ", level, " cekirdek kelime sozlukte yok: ", missing_words)
		else:
			print("cekirdek L", level, " ok (", core.size(), "): ", " ".join(core.slice(0, 8)), " ...")
	print("SONUC: ", "TAMAM" if ok and missing == 0 else "HATA")
	quit()
