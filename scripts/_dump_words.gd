extends SceneTree
func _init() -> void:
	var Bank := load("res://data/word_bank.gd")
	var out := {}
	var missing := 0
	for level in range(1, Bank.LEVEL_COUNT + 1):
		var arr := []
		for w in Bank.get_level_words(level):
			var m: String = Bank.get_meaning(w)
			var real: bool = Bank.MEANINGS.has(w) or Bank.ANIMAL_MEANINGS.has(w) or Bank.PROFESSION_MEANINGS.has(w)
			if not real:
				missing += 1
			arr.append([w, m if real else ""])
		out[str(level)] = arr
	var f := FileAccess.open("/private/tmp/claude-501/-Users-alen/3253d666-cdda-4b68-8482-76a3ab626cc5/scratchpad/wordi/words.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out))
	f.close()
	print("total unique: ", Bank.get_total_unique_words(), " missing meanings: ", missing)
	quit()
