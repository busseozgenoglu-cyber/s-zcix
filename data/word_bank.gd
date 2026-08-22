extends RefCounted
## Word Blast vocabulary bank.
## Holds 20 ordered levels with 100 usable 3-5 letter target words each,
## plus a Turkish meaning fallback for the reveal UI.
##
## The literal LEVEL_SOURCES entries are friendly everyday English words.
## _ensure_built() deduplicates globally and backfills from BACKUP_POOL so
## every level ends up with exactly WORDS_PER_LEVEL unique words and the bank
## always exposes at least 2000 unique words across all levels.

const WORDS_PER_LEVEL := 100
const LEVEL_COUNT := 20
const FREE_LEVELS := 3

## Exact English-to-Turkish meanings preserved from the original board.
const MEANINGS := {
	"CAT": "Kedi",
	"DOG": "Kopek",
	"SUN": "Gunes",
	"MOON": "Ay",
	"STAR": "Yildiz",
	"RED": "Kirmizi",
	"BLUE": "Mavi",
	"GREEN": "Yesil",
	"TREE": "Agac",
	"FISH": "Balik",
	"BOOK": "Kitap",
	"BALL": "Top",
	"HOME": "Ev",
	"APPLE": "Elma",
	"MOM": "Anne",
	"DAD": "Baba",
	"BABY": "Bebek",
	"TOY": "Oyuncak",
	"KITE": "Ucurtma",
	"DRUM": "Davul",
	"COW": "Inek",
	"PIG": "Domuz",
	"BEE": "Ari",
	"ANT": "Karinca",
	"OWL": "Baykus",
	"BIRD": "Kus",
	"DUCK": "Ordek",
	"HEN": "Tavuk",
	"EGG": "Yumurta",
	"FROG": "Kurbaga",
	"LION": "Aslan",
	"BEAR": "Ayi",
	"GOAT": "Keci",
	"SHEEP": "Koyun",
	"DEER": "Geyik",
	"MOUSE": "Fare",
	"WHALE": "Balina",
	"PINK": "Pembe",
	"BLACK": "Siyah",
	"WHITE": "Beyaz",
	"BROWN": "Kahverengi",
	"GRAY": "Gri",
	"YELLOW": "Sari",
	"ORANGE": "Turuncu",
	"PURPLE": "Mor",
	"MILK": "Sut",
	"BREAD": "Ekmek",
	"CHEESE": "Peynir",
	"RICE": "Pirinc",
	"SOUP": "Corba",
	"CORN": "Misir",
	"PIE": "Turta",
	"CAKE": "Kek",
	"GRAPE": "Uzum",
	"PEAR": "Armut",
	"PLUM": "Erik",
	"NUT": "Findik",
	"HONEY": "Bal",
	"WATER": "Su",
	"JUICE": "Meyve suyu",
	"LEMON": "Limon",
	"ROOM": "Oda",
	"DOOR": "Kapi",
	"WALL": "Duvar",
	"BED": "Yatak",
	"LAMP": "Lamba",
	"CHAIR": "Sandalye",
	"TABLE": "Masa",
	"HOUSE": "Ev",
	"SKY": "Gokyuzu",
	"CLOUD": "Bulut",
	"RAIN": "Yagmur",
	"SNOW": "Kar",
	"WIND": "Ruzgar",
	"SEA": "Deniz",
	"LAKE": "Gol",
	"RIVER": "Nehir",
	"ROCK": "Kaya",
	"SAND": "Kum",
	"HILL": "Tepe",
	"GRASS": "Cimen",
	"FLOWER": "Cicek",
	"LEAF": "Yaprak",
	"RUN": "Kosmak",
	"JUMP": "Ziplamak",
	"SIT": "Oturmak",
	"SWIM": "Yuzmek",
	"WALK": "Yurumek",
	"EAT": "Yemek",
	"PLAY": "Oynamak",
	"READ": "Okumak",
	"SLEEP": "Uyumak",
	"SING": "Sarki soylemek",
	"DANCE": "Dans etmek",
	"FLY": "Ucmak",
	"HOP": "Hoplamak",
	"COOK": "Yemek pisirmek",
	"DRAW": "Resim cizmek",
	"PEN": "Kalem",
	"BAG": "Canta",
	"DESK": "Sira",
	"MAP": "Harita",
	"SCHOOL": "Okul",
	"CLASS": "Sinif",
	"WRITE": "Yazmak",
	"MATH": "Matematik",
	"ART": "Resim",
	"NAME": "Isim",
	"TEST": "Sinav",
}

## Explicit Turkish meanings for representative animals in the large pool.
## Level 1 is the animal level by design, so this keeps the whole animal
## category resolving to a real translation instead of the generic fallback.
const ANIMAL_MEANINGS := {
	"BAT": "Yarasa",
	"FOX": "Tilki",
	"RAT": "Sican",
	"BUG": "Bocek",
	"FLY": "Sinek",
	"APE": "Maymun",
	"ELK": "Geyik",
	"EMU": "Emu",
	"CUB": "Yavru",
	"PUP": "Yavru",
	"KID": "Oglak",
	"LAMB": "Kuzu",
	"PONY": "Midilli",
	"MULE": "Katir",
	"WOLF": "Kurt",
	"SEAL": "Fok",
	"TOAD": "Kara kurbaga",
	"NEWT": "Semender",
	"CRAB": "Yengec",
	"CLAM": "Istiridye",
	"SNAIL": "Salyangoz",
	"WORM": "Solucan",
	"MOTH": "Guve",
	"WASP": "Yaban arisi",
	"FLEA": "Pire",
	"MOLE": "Kostebek",
	"HARE": "Tavsan",
	"SKUNK": "Kokarca",
	"OTTER": "Su samuru",
	"PANDA": "Panda",
	"LLAMA": "Lama",
	"ZEBRA": "Zebra",
	"TIGER": "Kaplan",
	"CAMEL": "Deve",
	"KOALA": "Koala",
	"SLOTH": "Tembel hayvan",
	"SHARK": "Kopek baligi",
	"TUNA": "Ton baligi",
	"COD": "Morina",
	"EEL": "Yilan baligi",
	"PERCH": "Levrek",
	"TROUT": "Alabalik",
	"BASS": "Levrek",
	"CARP": "Sazan",
	"PIKE": "Turna baligi",
	"GUPPY": "Lepistes",
	"TETRA": "Tetra",
	"SNAKE": "Yilan",
	"VIPER": "Engerek",
	"COBRA": "Kobra",
	"GECKO": "Kertenkele",
	"EAGLE": "Kartal",
	"HAWK": "Sahin",
	"CROW": "Karga",
	"RAVEN": "Kuzgun",
	"ROBIN": "Kizil gerdan",
	"WREN": "Calikusu",
	"DOVE": "Guvercin",
	"SWAN": "Kugu",
	"GOOSE": "Kaz",
	"QUAIL": "Bildircin",
	"HERON": "Balikcil",
	"CRANE": "Turna",
	"STORK": "Leylek",
	"FINCH": "Ispinoz",
	"OWLET": "Baykus yavrusu",
	"PUPPY": "Kopek yavrusu",
	"KITTY": "Kedi yavrusu",
	"BUNNY": "Tavsan",
	"HORSE": "At",
	"MOOSE": "Sigin",
	"MINK": "Vizon",
	"STOAT": "Kakim",
	"BISON": "Bizon",
	"HYENA": "Sirtlan",
	"SQUID": "Kalamar",
	"EGRET": "Balikcil kus",
	"LOON": "Dalgic kusu",
	"PUMA": "Puma",
	"OKAPI": "Okapi",
	"TAPIR": "Tapir",
}

## Explicit Turkish meanings for representative professions. Jobs are spread
## across several levels (COOK in actions, PILOT in transport, NURSE in family,
## and the dedicated jobs level), so they live in one shared lookup here.
const PROFESSION_MEANINGS := {
	"ACTOR": "Oyuncu",
	"ARTIST": "Sanatci",
	"BAKER": "Firinci",
	"BOSS": "Patron",
	"BOXER": "Boksor",
	"CHEF": "Asci",
	"CLERK": "Memur",
	"CLOWN": "Palyanco",
	"COACH": "Antrenor",
	"DANCER": "Dansci",
	"DOCTOR": "Doktor",
	"DRIVER": "Sofor",
	"ENGINEER": "Muhendis",
	"FARMER": "Ciftci",
	"GUARD": "Bekci",
	"JUDGE": "Hakim",
	"LAWYER": "Avukat",
	"MAID": "Hizmetci",
	"MAYOR": "Belediye baskani",
	"MECHANIC": "Tamirci",
	"MINER": "Madenci",
	"MODEL": "Manken",
	"NURSE": "Hemsire",
	"PAINTER": "Ressam",
	"PILOT": "Pilot",
	"PLUMBER": "Tesisatci",
	"POET": "Sair",
	"POLICE": "Polis",
	"RACER": "Yarisci",
	"RIDER": "Binici",
	"SAILOR": "Denizci",
	"SCIENTIST": "Bilim insani",
	"SINGER": "Sarkici",
	"SOLDIER": "Asker",
	"TEACHER": "Ogretmen",
	"TUTOR": "Ozel ogretmen",
	"VET": "Veteriner",
	"WRITER": "Yazar",
}

## Turkish category fallbacks, one per level, used when a word has no exact
## meaning. Kept short and child-friendly; never exposes an internal ID.
const LEVEL_FALLBACKS := [
	"Bir hayvan",
	"Bir renk veya sekil",
	"Vucudun bir parcasi",
	"Bir yiyecek veya icecek",
	"Bir ev esyasi",
	"Bir oyuncak veya oyun",
	"Bir okul kelimesi",
	"Doga veya hava durumu",
	"Bir eylem",
	"Bir giysi",
	"Bir yer",
	"Bir tasit",
	"Bir insan veya aile",
	"Bir duygu",
	"Bir sayi veya zaman",
	"Bir sifat",
	"Bir meslek",
	"Bir eylem",
	"Bir sifat",
	"Gunluk bir kelime",
]

## Ordered level sources. Each array is at least 100 words; the builder keeps
## the first 100 unique words and fills any gap from BACKUP_POOL.
const LEVEL_SOURCES: Array[Array] = [
	# Level 1 - Animals (easiest and most familiar)
	[
		"CAT", "DOG", "PIG", "COW", "HEN", "ANT", "BEE", "OWL", "BAT", "FOX",
		"RAT", "BUG", "FLY", "APE", "ELK", "EMU", "CUB", "PUP", "KID", "LAMB",
		"PONY", "MULE", "DEER", "GOAT", "LION", "BEAR", "WOLF", "SEAL", "DUCK", "BIRD",
		"FISH", "FROG", "TOAD", "NEWT", "CRAB", "CLAM", "SNAIL", "WORM", "MOTH", "WASP",
		"FLEA", "MOLE", "HARE", "MOUSE", "SKUNK", "OTTER", "PANDA", "LLAMA", "ZEBRA", "TIGER",
		"CAMEL", "KOALA", "SLOTH", "WHALE", "SHARK", "TUNA", "COD", "EEL", "PERCH", "TROUT",
		"BASS", "CARP", "PIKE", "GUPPY", "TETRA", "SNAKE", "VIPER", "COBRA", "GECKO", "EAGLE",
		"HAWK", "CROW", "RAVEN", "ROBIN", "WREN", "DOVE", "SWAN", "GOOSE", "QUAIL", "HERON",
		"CRANE", "STORK", "FINCH", "OWLET", "PUPPY", "KITTY", "BUNNY", "HORSE", "SHEEP", "MOOSE",
		"MINK", "STOAT", "BISON", "HYENA", "SQUID", "EGRET", "LOON", "PUMA", "OKAPI", "TAPIR",
	],
	# Level 2 - Colors, shapes and the body
	[
		"RED", "BLUE", "GREEN", "PINK", "BLACK", "WHITE", "BROWN", "GRAY", "YELLOW", "ORANGE",
		"PURPLE", "GOLD", "TEAL", "CYAN", "NAVY", "TAN", "LIME", "AQUA", "BEIGE", "CORAL",
		"IVORY", "KHAKI", "LILAC", "MAUVE", "OLIVE", "PEACH", "RUST", "SAGE", "WINE", "MINT",
		"ROSE", "SKY", "COAL", "SAND", "SLATE", "STEEL", "AMBER", "CREAM", "DENIM", "EBONY",
		"FLINT", "ROUND", "OVAL", "CUBE", "CONE", "RING", "LINE", "DOT", "ARC", "BOX",
		"DISK", "TUBE", "KNOT", "LOOP", "COIL", "EDGE", "CURVE", "ANGLE", "PLATE", "BLOCK",
		"BALL", "WHEEL", "CROSS", "HEART", "PRISM", "HEAD", "NECK", "ARM", "LEG", "HAND",
		"FOOT", "EYE", "EAR", "NOSE", "LIP", "TOOTH", "CHIN", "CHEEK", "BROW", "HAIR",
		"SKIN", "BONE", "BLOOD", "VEIN", "BRAIN", "LUNG", "LIVER", "TUMMY", "BELLY", "KNEE",
		"ELBOW", "WRIST", "ANKLE", "TOE", "THUMB", "PALM", "NAIL", "FACE", "JAW", "GUM",
		"RIB", "HIP", "CALF", "SHIN", "SOLE", "NERVE", "PUPIL", "LASH", "WAIST", "BACK",
	],
	# Level 3 - Food and drink
	[
		"MILK", "BREAD", "CHEESE", "RICE", "SOUP", "CORN", "PIE", "CAKE", "GRAPE", "PEAR",
		"PLUM", "NUT", "HONEY", "WATER", "JUICE", "LEMON", "APPLE", "EGG", "MEAT", "HAM",
		"BUN", "JAM", "BEAN", "PEA", "OAT", "YAM", "TARO", "KALE", "LEEK", "BEET",
		"ONION", "CHILI", "SPICE", "SALT", "SUGAR", "FLOUR", "YEAST", "CREAM", "COCOA", "TEA",
		"SODA", "COLA", "CIDER", "PUNCH", "MELON", "MANGO", "PEACH", "BERRY", "OLIVE", "SALAD",
		"PASTA", "PIZZA", "TACO", "NACHO", "SALSA", "DONUT", "BAGEL", "TOAST", "CANDY", "SWEET",
		"SYRUP", "JELLY", "ICING", "BACON", "STEAK", "ROAST", "GRILL", "PORK", "BEEF", "VEAL",
		"PRAWN", "CLOVE", "MINT", "BASIL", "THYME", "CHIVE", "DILL", "HERB", "SAGE", "LENTIL",
		"BARLEY", "WHEAT", "MAIZE", "QUINOA", "FIG", "DATE", "KIWI", "LIME", "COCONUT", "APRICOT",
		"RAISIN", "CURRY", "STEW", "BROTH", "GRUEL", "MISO", "TOFU", "WAFER", "SORBET", "GRAVY",
		"DUMPLING", "NOODLE", "TART", "MERINGUE", "MORSEL", "TIDBIT", "FEAST", "SNACK", "LUNCH", "DINNER",
	],
	# Level 4 - Home and furniture
	[
		"ROOM", "DOOR", "WALL", "BED", "LAMP", "CHAIR", "TABLE", "HOUSE", "HOME", "SOFA",
		"DESK", "SHELF", "CUP", "BOWL", "DISH", "SPOON", "FORK", "KNIFE", "PLATE", "PAN",
		"POT", "LID", "MUG", "JUG", "VASE", "MAT", "RUG", "CURTAIN", "BLIND", "SHUTTER",
		"CLOCK", "MIRROR", "PHOTO", "FRAME", "PILLOW", "BLANKET", "QUILT", "SHEET", "TOWEL", "SOAP",
		"BRUSH", "COMB", "SPONGE", "BROOM", "MOP", "DUST", "BUCKET", "BASKET", "BIN", "TRASH",
		"KEY", "LOCK", "HINGE", "HANDLE", "KNOB", "SWITCH", "PLUG", "CORD", "WIRE", "BULB",
		"HEATER", "FAN", "STOVE", "OVEN", "FRIDGE", "FREEZER", "SINK", "TAP", "DRAIN", "TUB",
		"SHOWER", "TOILET", "MIRROR", "CABINET", "DRAWER", "CHEST", "CLOSET", "WARDROBE", "DRESSER", "STOOL",
		"BENCH", "ROCKER", "CRADLE", "COT", "BUNK", "HALL", "PORCH", "PATIO", "GARAGE", "ATTIC",
		"BASEMENT", "GARDEN", "YARD", "FENCE", "GATE", "PATH", "DECK", "ROOF", "CHIMNEY", "WINDOW",
		"STAIRS", "STEP", "RAIL", "FLOOR", "CEILING", "CORNER", "LEDGE", "SILL", "BEAM", "PILLAR",
	],
	# Level 5 - Toys, games and play
	[
		"TOY", "BALL", "KITE", "DRUM", "DOLL", "BLOCK", "PUZZLE", "GAME", "CARD", "DICE",
		"RING", "ROPE", "SWING", "SLIDE", "SEESAW", "SAND", "PAIL", "SHOVEL", "SPADE", "HOOP",
		"BAT", "RACKET", "GLIDER", "ROCKET", "ROBOT", "TRAIN", "TRUCK", "CAR", "PLANE", "BOAT",
		"MARBLE", "YOYO", "TOP", "WHISTLE", "HORN", "TRUMPET", "FLUTE", "BANJO", "PIANO", "DRUM",
		"STICK", "CLUB", "WAND", "CROWN", "MASK", "CAPE", "TENT", "CAMP", "HUT", "FORT",
		"CASTLE", "KING", "QUEEN", "PRINCE", "PRINCESS", "KNIGHT", "DRAGON", "GIANT", "DWARF", "ELF",
		"FAIRY", "WITCH", "WIZARD", "HERO", "CLOWN", "PUPPET", "TEDDY", "BUNNY", "BALL", "PADDLE",
		"NET", "GOAL", "SCORE", "TEAM", "RACE", "LAP", "TRACK", "FIELD", "COURT", "PITCH",
		"DART", "ARROW", "BOW", "TARGET", "PRIZE", "TROPHY", "MEDAL", "RIBBON", "BADGE", "STAR",
		"TAG", "HIDE", "SEEK", "LEAP", "SKIP", "JOG", "RUN", "WALK", "DANCE", "SING",
		"CLAP", "CHEER", "SMILE", "LAUGH", "GIGGLE", "PLAY", "JOIN", "SHARE", "TURN", "WIN",
	],
	# Level 6 - School
	[
		"BOOK", "PEN", "BAG", "DESK", "MAP", "SCHOOL", "CLASS", "WRITE", "MATH", "ART",
		"NAME", "TEST", "READ", "PAGE", "WORD", "LETTER", "ALPHABET", "NUMBER", "COUNT", "SPELL",
		"STORY", "POEM", "SONG", "LINE", "DRAW", "PAINT", "COLOR", "PAPER", "CARD", "GLUE",
		"TAPE", "RULER", "ERASER", "PENCIL", "CRAYON", "CHALK", "BOARD", "DESK", "CHAIR", "BELL",
		"RING", "LUNCH", "SNACK", "PUPIL", "PUPIL", "TEACHER", "TUTOR", "COACH", "FRIEND", "TEAM",
		"GROUP", "PAIR", "QUIZ", "EXAM", "GRADE", "SCORE", "MARK", "STAR", "AWARD", "PRIZE",
		"STICKER", "STAMP", "LABEL", "TAG", "NOTE", "MEMO", "LIST", "PLAN", "GOAL", "TASK",
		"WORK", "PLAY", "BREAK", "RECESS", "FIELD", "GYM", "HALL", "LIBRARY", "OFFICE", "ROOM",
		"SCIENCE", "NATURE", "HISTORY", "MUSIC", "DRAMA", "SPORT", "LOGIC", "SHAPE", "SIZE", "COUNT",
		"VOWEL", "SOUND", "RHYME", "RHYTHM", "PITCH", "TONE", "TUNE", "NOTE", "BEAT", "TAP",
		"PENCIL", "NOTEBOOK", "FOLDER", "BINDER", "POUCH", "ZIPPER", "STRAP", "BADGE", "UNIFORM", "LOGO",
	],
	# Level 7 - Nature and weather
	[
		"SKY", "CLOUD", "RAIN", "SNOW", "WIND", "SEA", "LAKE", "RIVER", "ROCK", "SAND",
		"HILL", "GRASS", "FLOWER", "LEAF", "TREE", "STAR", "MOON", "SUN", "EARTH", "WORLD",
		"STORM", "THUNDER", "LIGHTNING", "CLOUDY", "SUNNY", "WINDY", "RAINY", "SNOWY", "FOGGY", "MISTY",
		"HAIL", "SLEET", "BREEZE", "GUST", "GALE", "TEMPEST", "FLOOD", "DROUGHT", "HEAT", "COLD",
		"ICICLE", "FROST", "MELT", "THAW", "STEAM", "VAPOR", "DROPLET", "PUDDLE", "POND", "STREAM",
		"BROOK", "CREEK", "CANAL", "COAST", "SHORE", "BEACH", "DUNE", "CLIFF", "CAVE", "VALLEY",
		"CANYON", "PLATEAU", "DESERT", "JUNGLE", "FOREST", "WOODS", "MEADOW", "FIELD", "ORCHARD", "FARM",
		"GARDEN", "PLANT", "ROOT", "STEM", "BUD", "BLOOM", "BLOSSOM", "PETAL", "SEED", "PINE",
		"OAK", "ELM", "PALM", "FIR", "VINE", "MOSS", "FERN", "REED", "BUSH", "SHRUB",
		"PEBBLE", "STONE", "BOULDER", "GRAVEL", "SOIL", "MUD", "CLAY", "DIRT", "DUST", "ASH",
		"SPARK", "FLAME", "FIRE", "GLOW", "BEAM", "RAY", "SHINE", "SHADE", "DARK", "DAWN",
	],
	# Level 8 - Actions (verbs)
	[
		"RUN", "JUMP", "SIT", "SWIM", "WALK", "EAT", "PLAY", "READ", "SLEEP", "SING",
		"DANCE", "FLY", "HOP", "COOK", "DRAW", "WRITE", "TALK", "LOOK", "SEE", "HEAR",
		"SMELL", "TASTE", "TOUCH", "FEEL", "THINK", "KNOW", "LEARN", "TEACH", "MAKE", "BUILD",
		"FIX", "BREAK", "OPEN", "CLOSE", "PUSH", "PULL", "LIFT", "CARRY", "THROW", "CATCH",
		"KICK", "HIT", "TOSS", "ROLL", "BOUNCE", "SLIDE", "SKATE", "CLIMB", "RIDE", "DRIVE",
		"SAIL", "ROW", "PADDLE", "FLOAT", "SINK", "DIVE", "SPLASH", "POUR", "SPILL", "DRINK",
		"CHEW", "BITE", "LICK", "SIP", "GULP", "MIX", "STIR", "BAKE", "BOIL", "FRY",
		"GRILL", "CHOP", "SLICE", "PEEL", "GRATE", "TOSS", "SPRINKLE", "SPREAD", "FILL", "EMPTY",
		"CLEAN", "WASH", "WIPE", "SCRUB", "SWEEP", "DUST", "POLISH", "SHINE", "IRON", "FOLD",
		"HANG", "SORT", "STACK", "PACK", "TIE", "KNOT", "WRAP", "TAPE", "GLUE", "PAINT",
		"SAY", "SHOUT", "WHISPER", "CALL", "ASK", "TELL", "GIVE", "TAKE", "HELP", "SHARE",
	],
	# Level 9 - Clothes
	[
		"HAT", "CAP", "COAT", "DRESS", "SHIRT", "SKIRT", "PANTS", "JEANS", "SHORTS", "SOCKS",
		"SHOES", "BOOTS", "SANDAL", "SNEAKER", "SLIPPER", "GLOVE", "MITTEN", "SCARF", "SHAWL", "BELT",
		"TIE", "BOW", "CLIP", "PIN", "BUTTON", "ZIPPER", "LACE", "STRAP", "BUCKLE", "POCKET",
		"COLLAR", "SLEEVE", "CUFF", "HEM", "SEAM", "HOOD", "HOODIE", "JACKET", "VEST", "SWEATER",
		"CARDIGAN", "PONCHO", "PARKA", "BLAZER", "GOWN", "ROBE", "PAJAMAS", "NIGHTIE", "APRON", "OVERALL",
		"UNIFORM", "JERSEY", "TUNIC", "KILT", "SARONG", "TIGHTS", "LEGGINGS", "STOCKING", "BIB", "DIAPER",
		"WATCH", "RING", "BRACELET", "NECKLACE", "EARRING", "PENDANT", "BROOCH", "CROWN", "TIARA", "BAND",
		"RIBBON", "HEADBAND", "BARRETTE", "HAIRPIN", "MASK", "GLASSES", "GOGGLES", "SUNGLASS", "UMBRELLA", "CANE",
		"BAG", "PURSE", "WALLET", "SATCHEL", "BACKPACK", "TOTE", "LUGGAGE", "TRUNK", "CASE", "SACK",
		"CLOTH", "COTTON", "WOOL", "SILK", "LINEN", "DENIM", "VELVET", "LACE", "FELT", "FLEECE",
		"TAILOR", "SEW", "KNIT", "WEAVE", "STITCH", "PATCH", "MEND", "FIT", "WEAR", "MATCH",
	],
	# Level 10 - Places
	[
		"HOME", "HOUSE", "ROOM", "HALL", "DOOR", "GATE", "YARD", "GARDEN", "PARK", "ZOO",
		"FARM", "BARN", "STABLE", "FIELD", "ORCHARD", "MEADOW", "WOODS", "FOREST", "JUNGLE", "DESERT",
		"BEACH", "COAST", "SHORE", "BAY", "PORT", "HARBOR", "PIER", "DOCK", "BRIDGE", "ROAD",
		"STREET", "PATH", "LANE", "ALLEY", "AVENUE", "PLAZA", "SQUARE", "CORNER", "BLOCK", "TOWN",
		"CITY", "VILLAGE", "SUBURB", "STATE", "NATION", "COUNTRY", "WORLD", "ISLAND", "PENINSULA", "CAPE",
		"MOUNTAIN", "VALLEY", "CANYON", "PLATEAU", "HILL", "PEAK", "RIDGE", "SLOPE", "CAVE", "CLIFF",
		"LAKE", "POND", "STREAM", "BROOK", "RIVER", "CANAL", "WATERFALL", "SPRING", "WELL", "FOUNTAIN",
		"CASTLE", "PALACE", "TOWER", "CHURCH", "TEMPLE", "MOSQUE", "MUSEUM", "LIBRARY", "SCHOOL", "OFFICE",
		"STORE", "SHOP", "MARKET", "BAZAAR", "MALL", "BANK", "HOTEL", "MOTEL", "INN", "HOSTEL",
		"HOSPITAL", "CLINIC", "PHARMACY", "STATION", "AIRPORT", "DEPOT", "GARAGE", "STADIUM", "ARENA", "THEATER",
		"CINEMA", "CIRCUS", "FAIR", "CARNIVAL", "PLAYGROUND", "POOL", "GYM", "TRACK", "COURT", "FIELD",
	],
	# Level 11 - Transport
	[
		"CAR", "BUS", "VAN", "TAXI", "TRUCK", "LORRY", "TRAIN", "TRAM", "METRO", "BIKE",
		"BICYCLE", "CYCLE", "MOTOR", "SCOOTER", "MOPED", "TRACTOR", "TRAILER", "CART", "WAGON", "SLED",
		"SLEIGH", "CARRIAGE", "COACH", "CAB", "LIMOUSINE", "JEEP", "PICKUP", "CAMPER", "AMBULANCE", "POLICE",
		"FIRE", "ENGINE", "BOAT", "SHIP", "FERRY", "YACHT", "CANOE", "KAYAK", "RAFT", "BARGE",
		"SUBMARINE", "PLANE", "JET", "HELICOPTER", "ROCKET", "SHUTTLE", "GLIDER", "BLIMP", "BALLOON", "KITE",
		"DRONE", "WING", "WHEEL", "AXLE", "TIRE", "ENGINE", "MOTOR", "BRAKE", "PEDAL", "SEAT",
		"DOOR", "WINDOW", "MIRROR", "LIGHT", "HORN", "BELT", "BAG", "TRUNK", "HOOD", "BUMPER",
		"STEER", "DRIVE", "RIDE", "SAIL", "FLY", "PARK", "STOP", "GO", "FAST", "SLOW",
		"LANE", "ROAD", "STREET", "ROUTE", "PATH", "TRACK", "RAIL", "LINE", "PIER", "DOCK",
		"FUEL", "GAS", "OIL", "PETROL", "DIESEL", "CHARGE", "BATTERY", "TICKET", "FARE", "PASS",
		"MAP", "COMPASS", "RADIO", "SIGNAL", "SIREN", "WHISTLE", "FLAG", "LIGHT", "BEACON", "PILOT",
	],
	# Level 12 - Family and people
	[
		"MOM", "DAD", "MUM", "BABY", "KID", "BOY", "GIRL", "SON", "HEN", "PAL",
		"AUNT", "UNCLE", "COUSIN", "SISTER", "BROTHER", "GRANDMA", "GRANDPA", "NANNY", "NAN", "POP",
		"FAMILY", "PARENT", "CHILD", "TWIN", "FRIEND", "NEIGHBOR", "GUEST", "HOST", "TEAM", "GROUP",
		"PEOPLE", "PERSON", "HUMAN", "WOMAN", "MAN", "LADY", "GENTLEMAN", "MISTER", "MISS", "MADAM",
		"QUEEN", "KING", "PRINCE", "PRINCESS", "KNIGHT", "HERO", "WINNER", "LOSER", "LEADER", "BOSS",
		"CHIEF", "MASTER", "PUPIL", "STUDENT", "TEACHER", "TUTOR", "COACH", "CAPTAIN", "PLAYER", "FAN",
		"CROWD", "CROWD", "MOB", "FOLK", "CLAN", "TRIBE", "NATION", "CITIZEN", "VISITOR", "TOURIST",
		"NEIGHBOR", "ROOMMATE", "PARTNER", "MATE", "DATE", "BRIDE", "GROOM", "WIDOW", "ORPHAN", "INFANT",
		"TODDLER", "TEEN", "ADULT", "ELDER", "GRANNY", "GRAMPY", "UNCLE", "AUNTIE", "NIECE", "NEPHEW",
		"HERO", "IDOL", "STAR", "MODEL", "DOCTOR", "NURSE", "PILOT", "COOK", "CHEF", "FARMER",
		"BOY", "GIRL", "CHILD", "TEEN", "ADULT", "SENIOR", "CITIZEN", "NATIVE", "LOCAL", "STRANGER",
	],
	# Level 13 - Feelings
	[
		"HAPPY", "SAD", "MAD", "GLAD", "ANGRY", "SCARED", "BRAVE", "CALM", "SHY", "PROUD",
		"SORRY", "LONELY", "TIRED", "SLEEPY", "BORED", "EXCITED", "SURPRISED", "NERVOUS", "WORRIED", "AFRAID",
		"LOVED", "KIND", "MEAN", "NICE", "GOOD", "BAD", "GREAT", "FINE", "OKAY", "SURE",
		"SICK", "WELL", "HURT", "SORE", "PAIN", "ACHE", "FEAR", "JOY", "FUN", "LOVE",
		"LIKE", "HATE", "HOPE", "WISH", "DREAM", "CARE", "WORRY", "DOUBT", "TRUST", "FAITH",
		"PEACE", "WAR", "CALM", "STORM", "COMFORT", "COZY", "SAFE", "RISK", "DANGER", "BRAVE",
		"PROUD", "SHAME", "GUILT", "BLAME", "PRAISE", "SMILE", "FROWN", "GRIN", "LAUGH", "CRY",
		"SOB", "WEEP", "MOAN", "SIGH", "GASP", "YELL", "SHOUT", "SCREAM", "WHISPER", "CHAT",
		"MOOD", "SPIRIT", "HEART", "SOUL", "MIND", "FEEL", "SENSE", "MOODY", "MERRY", "JOLLY",
		"CHEER", "GLOOM", "DOOM", "BLISS", "GLEE", "BLUES", "RAGE", "FURY", "ZEAL", "WARMTH",
		"COMFORT", "RELIEF", "PANIC", "SHOCK", "AWE", "WONDER", "AWE", "PRIDE", "ENVY", "SPITE",
	],
	# Level 14 - Numbers and time
	[
		"ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "TEN",
		"ZERO", "DOUBLE", "TRIPLE", "SINGLE", "PAIR", "DOZEN", "SCORE", "TOTAL", "WHOLE", "HALF",
		"PART", "PIECE", "BIT", "LOT", "FEW", "MANY", "MORE", "LESS", "MOST", "SOME",
		"FIRST", "SECOND", "THIRD", "NEXT", "LAST", "EARLY", "LATE", "SOON", "NEVER", "ALWAYS",
		"OFTEN", "SELDOM", "NOW", "THEN", "AFTER", "BEFORE", "LATER", "AGAIN", "ONCE", "TWICE",
		"DAY", "WEEK", "MONTH", "YEAR", "HOUR", "MINUTE", "MORNING", "NOON", "NIGHT", "DAWN",
		"DUSK", "EVENING", "TODAY", "TOMORROW", "YESTERDAY", "DATE", "CLOCK", "WATCH", "TIMER", "ALARM",
		"SPRING", "SUMMER", "AUTUMN", "WINTER", "SEASON", "AGE", "ERA", "PAST", "PRESENT", "FUTURE",
		"START", "BEGIN", "END", "STOP", "FINISH", "PAUSE", "REST", "BREAK", "MOMENT", "WHILE",
		"QUICK", "FAST", "SLOW", "STEADY", "SWIFT", "LONG", "SHORT", "BRIEF", "INSTANT", "FLASH",
		"COUNT", "TALLY", "SUM", "ADD", "TOTAL", "NUMBER", "DIGIT", "NUMERAL", "ORDER", "RANK",
	],
	# Level 15 - Describing words (adjectives)
	[
		"BIG", "SMALL", "LITTLE", "TINY", "HUGE", "GIANT", "TALL", "SHORT", "LONG", "WIDE",
		"NARROW", "THICK", "THIN", "DEEP", "SHALLOW", "HIGH", "LOW", "FAT", "SLIM", "BROAD",
		"HOT", "COLD", "WARM", "COOL", "ICY", "BURNING", "CHILLY", "FREEZING", "STEAMY", "MILD",
		"DRY", "WET", "DAMP", "MOIST", "SOGGY", "HARD", "SOFT", "ROUGH", "SMOOTH", "SHARP",
		"DULL", "BLUNT", "POINTED", "FLAT", "ROUND", "SQUARE", "CURVED", "STRAIGHT", "BENT", "CROOKED",
		"CLEAN", "DIRTY", "TIDY", "MESSY", "NEAT", "SHINY", "DULL", "BRIGHT", "DIM", "DARK",
		"LIGHT", "HEAVY", "STRONG", "WEAK", "FIRM", "LOOSE", "TIGHT", "SOLID", "HOLLOW", "FRAGILE",
		"NEW", "OLD", "YOUNG", "ANCIENT", "MODERN", "FRESH", "STALE", "RIPE", "RAW", "RARE",
		"FAST", "SLOW", "QUICK", "RAPID", "SWIFT", "SUDDEN", "STEADY", "STILL", "CALM", "WILD",
		"LOUD", "QUIET", "SILENT", "NOISY", "SOFT", "HARSH", "SWEET", "SOUR", "BITTER", "SALTY",
		"RICH", "POOR", "CHEAP", "COSTLY", "FREE", "FULL", "EMPTY", "OPEN", "CLOSED", "READY",
	],
	# Level 16 - Jobs and helpers
	[
		"DOCTOR", "NURSE", "CHEF", "COOK", "BAKER", "FARMER", "TEACHER", "TUTOR", "PILOT", "ACTOR",
		"SINGER", "DANCER", "WRITER", "ARTIST", "PAINTER", "SCULPTOR", "ACTOR", "MODEL", "MUSICIAN", "DRUMMER",
		"SOLDIER", "SAILOR", "PILOT", "DRIVER", "RIDER", "RACER", "PLAYER", "COACH", "REFEREE", "UMPIRE",
		"POLICE", "OFFICER", "GUARD", "WARDEN", "JUDGE", "LAWYER", "CLERK", "SECRETARY", "BOSS", "MANAGER",
		"LEADER", "CHIEF", "HEAD", "KING", "QUEEN", "PRINCE", "PRINCESS", "MAYOR", "GOVERNOR", "PRESIDENT",
		"MINISTER", "PRIEST", "MONK", "NUN", "RABBI", "IMAM", "PASTOR", "SAINT", "PROPHET", "SCHOLAR",
		"SCIENTIST", "ENGINEER", "MECHANIC", "PLUMBER", "ELECTRICIAN", "CARPENTER", "BUILDER", "MASON", "MINER", "RANCHER",
		"SHEPHERD", "HERDER", "HUNTER", "FISHER", "GARDENER", "JANITOR", "CLEANER", "MAID", "BUTLER", "WAITER",
		"BARBER", "TAILOR", "SEAMSTRESS", "SHOEMAKER", "JEWELER", "POTTER", "WEAVER", "PRINTER", "EDITOR", "REPORTER",
		"JOURNALIST", "PHOTOGRAPHER", "DESIGNER", "ARCHITECT", "AUTHOR", "POET", "LYRICIST", "COMPOSER", "CONDUCTOR", "MAGICIAN",
		"CLOWN", "ACROBAT", "JUGGLER", "ATHLETE", "SWIMMER", "RUNNER", "BOXER", "WRESTLER", "CHAMPION", "WINNER",
	],
	# Level 17 - More actions (verbs)
	[
		"BAKE", "BOIL", "FRY", "GRILL", "ROAST", "STIR", "MIX", "CHOP", "SLICE", "PEEL",
		"POUR", "FILL", "EMPTY", "SPILL", "WIPE", "SCRUB", "RINSE", "DRY", "IRON", "FOLD",
		"HANG", "SORT", "STACK", "PACK", "WRAP", "TIE", "KNOT", "SEW", "KNIT", "WEAVE",
		"BUILD", "MAKE", "FIX", "REPAIR", "MEND", "PAINT", "POLISH", "SHINE", "WAX", "SCRUB",
		"DIG", "PLANT", "WATER", "PICK", "HARVEST", "FEED", "MILK", "HUNT", "FISH", "CATCH",
		"THROW", "CATCH", "KICK", "HIT", "BAT", "ROLL", "TOSS", "BOUNCE", "SKIP", "JUMP",
		"CLIMB", "RIDE", "DRIVE", "SAIL", "ROW", "FLY", "FLOAT", "DIVE", "SWIM", "SPLASH",
		"SHOUT", "CALL", "ASK", "TELL", "SAY", "SPEAK", "TALK", "CHAT", "WHISPER", "SING",
		"HUM", "WHISTLE", "CLAP", "CHEER", "LAUGH", "SMILE", "CRY", "WEEP", "SOB", "SIGH",
		"POINT", "WAVE", "NOD", "BOW", "HUG", "KISS", "PAT", "RUB", "PUSH", "PULL",
		"LIFT", "CARRY", "DROP", "PLACE", "PUT", "SET", "LAY", "STAND", "KNEEL", "SQUAT",
	],
	# Level 18 - More describing words
	[
		"BRAVE", "BOLD", "SHY", "TIMID", "PROUD", "HUMBLE", "KIND", "CRUEL", "GENTLE", "HARSH",
		"POLITE", "RUDE", "FAIR", "UNFAIR", "HONEST", "WISE", "SMART", "CLEVER", "BRIGHT", "DULL",
		"FUNNY", "SILLY", "SERIOUS", "PLAYFUL", "CHEERFUL", "GLOOMY", "MERRY", "SAD", "HAPPY", "GLAD",
		"BUSY", "LAZY", "ACTIVE", "IDLE", "EAGER", "RELUCTANT", "BRAVE", "AFRAID", "FEARLESS", "TIMID",
		"CAREFUL", "CARELESS", "CAUTIOUS", "RECKLESS", "NEAT", "MESSY", "TIDY", "DIRTY", "CLEAN", "PURE",
		"SWEET", "SOUR", "BITTER", "SALTY", "SPICY", "BLAND", "TASTY", "YUCKY", "YUMMY", "DELICIOUS",
		"PRETTY", "UGLY", "BEAUTIFUL", "PLAIN", "FANCY", "SIMPLE", "GRAND", "MODEST", "RICH", "POOR",
		"HEALTHY", "SICKLY", "STRONG", "WEAK", "FIT", "FRAIL", "LIVELY", "DROOPY", "ALERT", "DROWSY",
		"ANGRY", "CALM", "PEACEFUL", "FIERCE", "WILD", "TAME", "GENTLE", "ROUGH", "SOFT", "HARD",
		"DRY", "WET", "DAMP", "MOIST", "SOGGY", "CRISP", "STALE", "FRESH", "RIPE", "ROTTEN",
		"THICK", "THIN", "SLIM", "FAT", "PLUMP", "SKINNY", "STURDY", "FLIMSY", "SOLID", "HOLLOW",
	],
	# Level 19 - Everyday words mix
	[
		"APPLE", "BALL", "BOOK", "CAR", "DOG", "EGG", "FISH", "GOAT", "HAT", "ICE",
		"JAM", "KEY", "LEG", "MAP", "NEST", "OWL", "PEN", "QUILT", "RAT", "SEA",
		"TREE", "UMBRELLA", "VAN", "WIND", "BOX", "YARD", "ZEBRA", "BAG", "CUP", "DISH",
		"DOLL", "DRUM", "FLAG", "GIFT", "HORN", "INK", "JAR", "LAMP", "MUG", "NET",
		"OAR", "PIE", "RUG", "STAR", "TENT", "VASE", "WALL", "YARN", "BELL", "COIN",
		"CROWN", "DICE", "FAIRY", "GLOBE", "HOOK", "ICICLE", "JUG", "KITE", "LADDER", "MIRROR",
		"NEEDLE", "ORBIT", "PILLOW", "RING", "SHELL", "TIRE", "UNICORN", "WAGON", "YACHT", "ZIGZAG",
		"ANCHOR", "BALLOON", "CANDLE", "DIAMOND", "EASEL", "FOSSIL", "GARLIC", "HARBOR", "ISLAND", "JUNGLE",
		"KITTEN", "LEMON", "MAGNET", "NICKEL", "OCTOPUS", "PALACE", "QUARTZ", "RIVER", "SADDLE", "TUNNEL",
		"VILLAGE", "WINDOW", "YELLOW", "ZIPPER", "APRON", "BRIDGE", "CASTLE", "DOLPHIN", "ENGINE", "FURNACE",
		"GINGER", "HARBOR", "IGLOO", "JACKET", "KITTEN", "LANTERN", "MARBLE", "NEST", "OPERA", "PIRATE",
	],
	# Level 20 - Final challenge mix
	[
		"BRAIN", "CACTUS", "DESERT", "ECLIPSE", "FALCON", "GADGET", "HARVEST", "ICICLE", "JOURNEY", "KAYAK",
		"LIZARD", "MAMMOTH", "NECTAR", "OCEAN", "PIRATE", "QUARTZ", "RADIUS", "SATELLITE", "TEMPEST", "UTENSIL",
		"VACUUM", "WALNUT", "XYLOPHONE", "YOGURT", "ZIGZAG", "AROMA", "BLIZZARD", "CRYSTAL", "DRAGON", "EMBLEM",
		"FOSSIL", "GALAXY", "HARMONY", "IGUANA", "JIGSAW", "KERNEL", "LAGOON", "METEOR", "NEBULA", "ORBIT",
		"PYRAMID", "QUIVER", "RAINBOW", "SAPPHIRE", "TORNADO", "UNISON", "VOLCANO", "WHISKER", "XENON", "YIELD",
		"ZEPHYR", "ALPACA", "BOULDER", "CHIMNEY", "DOLPHIN", "EMERALD", "FIREFLY", "GLACIER", "HARBOR", "IVORY",
		"JASMINE", "KANGAROO", "LANTERN", "MAGENTA", "NICKEL", "OASIS", "PRAIRIE", "QUARTZ", "REFUGE", "SAVANNA",
		"TUNDRA", "UNICORN", "VOYAGE", "WHISPER", "XENON", "YELLOW", "ZODIAC", "ARCTIC", "BAMBOO", "CORAL",
		"DESERT", "EMBLEM", "FALCON", "GARNET", "HORIZON", "ISLAND", "JUNGLE", "KAYAK", "LAGOON", "MIRAGE",
		"NECTAR", "OCTAGON", "PRAIRIE", "QUIVER", "RADIUS", "STADIUM", "TUNDRA", "UMBRA", "VALLEY", "WALNUT",
		"ZENITH", "ACORN", "BEACON", "CANYON", "DOMAIN", "ENIGMA", "FABLE", "GARDEN", "HIDDEN", "IGLOO",
	],
]

## Extra unique 3-5 letter words used to backfill any level that runs short
## after global deduplication. Kept child-friendly and everyday.
const BACKUP_POOL: Array[String] = [
	"AXE", "AID", "AIM", "AIR", "ALE", "ALP", "APE", "ARK", "ARM", "ASH",
	"AWE", "AXIS", "BACK", "BAIL", "BAIT", "BALD", "BALE", "BAND", "BANG", "BANK",
	"BARE", "BARK", "BARN", "BASE", "BATH", "BEAD", "BEAK", "BEAM", "BEAN", "BEAT",
	"BEEP", "BELL", "BELT", "BEND", "BENT", "BILL", "BITE", "BLADE", "BLAST", "BLEAK",
	"BLEED", "BLEND", "BLESS", "BLINK", "BLISS", "BLOOM", "BLUR", "BOAST", "BOG", "BOIL",
	"BOLD", "BOLT", "BOND", "BOOM", "BOOT", "BORE", "BORN", "BOSS", "BOTH", "BOUNCE",
	"BOUND", "BOWL", "BRAID", "BRAKE", "BRAND", "BRASS", "BRAVE", "BREAD", "BREAK", "BREED",
	"BRICK", "BRIDE", "BRIDGE", "BRIEF", "BRIM", "BRINE", "BRING", "BRINK", "BROAD", "BROIL",
	"BROOD", "BROOK", "BROOM", "BRUSH", "BUDGE", "BUGLE", "BUILD", "BULB", "BULK", "BULL",
	"BUMP", "BUNCH", "BURST", "BURY", "BUZZ", "CABIN", "CABLE", "CAGE", "CANE", "CAPE",
	"CASE", "CASH", "CAST", "CAVE", "CELL", "CHAIN", "CHALK", "CHAMP", "CHANT", "CHARM",
	"CHART", "CHASE", "CHEAT", "CHECK", "CHEER", "CHESS", "CHEST", "CHIME", "CHIP", "CHIRP",
	"CHUNK", "CHURN", "CLAIM", "CLAMP", "CLANG", "CLASH", "CLASP", "CLAW", "CLAY", "CLEAN",
	"CLEAR", "CLERK", "CLICK", "CLIFF", "CLIMB", "CLING", "CLIP", "CLOAK", "CLOSE", "CLOTH",
	"CLOUD", "CLOWN", "CLUE", "COAST", "COAT", "COIL", "COIN", "COLD", "COMB", "COME",
	"COOK", "COOL", "COPE", "COPY", "CORD", "CORE", "CORK", "COST", "COUCH", "COUNT",
	"COURT", "COVER", "CRACK", "CRAFT", "CRANE", "CRASH", "CRATE", "CRAWL", "CRAZE", "CREEP",
	"CREW", "CRISP", "CROSS", "CROWD", "CROWN", "CRUDE", "CRUMB", "CRUSH", "CRUST", "CURVE",
	"DAISY", "DANCE", "DART", "DASH", "DAWN", "DEAL", "DEBT", "DECAY", "DECK", "DEED",
	"DEEP", "DEER", "DELAY", "DENSE", "DENT", "DEPTH", "DIAL", "DIET", "DIME", "DINE",
	"DIRT", "DISC", "DISH", "DIVE", "DOCK", "DOME", "DOSE", "DOVE", "DOWN", "DRAG",
	"DRAIN", "DRAKE", "DRAMA", "DRAPE", "DREAM", "DRESS", "DRIFT", "DRILL", "DRINK", "DRIP",
	"DRIVE", "DROOP", "DROP", "DROWN", "DRUM", "DRY", "DUCK", "DULL", "DUNE", "DUSK",
	"DUST", "DUTY", "EAGER", "EARL", "EARN", "EARTH", "EASE", "EAST", "ECHO", "EDGE",
	"EERIE", "ELECT", "ELITE", "EMPTY", "END", "ENEMY", "ENJOY", "ENTER", "EQUAL", "ERASE",
	"ERUPT", "ESCAPE", "EVENT", "EVER", "EVICT", "EXACT", "EXALT", "EXAM", "EXCEL", "EXIT",
	"EXPEL", "EXPLORE", "EXTRA", "FABLE", "FACE", "FACT", "FADE", "FAIL", "FAIR", "FAITH",
	"FALL", "FAME", "FANCY", "FAR", "FARM", "FAST", "FATE", "FAULT", "FAVOR", "FEAR",
	"FEAST", "FEET", "FELL", "FENCE", "FERN", "FERRY", "FETCH", "FEVER", "FIBER", "FIELD",
	"FIERCE", "FIGHT", "FILE", "FILL", "FILM", "FINAL", "FIND", "FINE", "FIRM", "FIRST",
	"FIVE", "FIX", "FLAG", "FLAKE", "FLAME", "FLAP", "FLARE", "FLASH", "FLAT", "FLEE",
	"FLESH", "FLICK", "FLIGHT", "FLING", "FLINT", "FLIP", "FLOAT", "FLOCK", "FLOOD", "FLOOR",
	"FLORA", "FLOUR", "FLOW", "FLUFF", "FLUID", "FLUSH", "FLUTE", "FOAM", "FOCUS", "FOG",
	"FOIL", "FOLD", "FOLK", "FOLLOW", "FOND", "FOOD", "FOOL", "FOOT", "FORCE", "FORD",
	"FOREST", "FORGE", "FORK", "FORM", "FORT", "FORTH", "FOUND", "FOX", "FRAME", "FRESH",
	"FRONT", "FROST", "FROTH", "FROWN", "FROZE", "FRUIT", "FULL", "FUME", "FUND", "FUN",
	"FUR", "FURY", "FUSE", "FUSS", "GAIN", "GALA", "GALE", "GAME", "GAP", "GASP",
	"GATE", "GAUGE", "GAZE", "GEAR", "GEM", "GENTLE", "GHOST", "GIANT", "GIFT", "GIVE",
	"GLAD", "GLARE", "GLASS", "GLEAM", "GLIDE", "GLINT", "GLOBE", "GLOOM", "GLORY", "GLOSS",
	"GLOW", "GLUE", "GNAW", "GOAL", "GOLD", "GOOD", "GRAB", "GRACE", "GRADE", "GRAIN",
	"GRAND", "GRANT", "GRAPE", "GRASP", "GRASS", "GRAVE", "GRAZE", "GREAT", "GREED", "GREEN",
	"GREET", "GRID", "GRIEF", "GRILL", "GRIM", "GRIN", "GRIND", "GRIP", "GROAN", "GROOM",
	"GROOVE", "GROPE", "GROSS", "GROUP", "GROVE", "GROW", "GROWL", "GRUMBLE", "GRUNT", "GUARD",
	"GUESS", "GUEST", "GUIDE", "GUILT", "GULF", "GULP", "GUM", "GUST", "GUT", "HABIT",
	"HAIL", "HAIR", "HALE", "HALF", "HALL", "HALT", "HAND", "HANG", "HARD", "HARE",
	"HARM", "HARP", "HARSH", "HASTE", "HATCH", "HATE", "HAUL", "HAUNT", "HAVE", "HAWK",
	"HAY", "HAZE", "HEAD", "HEAL", "HEAP", "HEAR", "HEAT", "HEEL", "HEIR", "HELD",
	"HELL", "HELM", "HELP", "HERD", "HERE", "HERO", "HIDE", "HIGH", "HIKE", "HILL",
	"HINT", "HIRE", "HISS", "HIVE", "HOARD", "HOIST", "HOLD", "HOLE", "HOLLOW", "HOLY",
	"HOOD", "HOOF", "HOOK", "HOOT", "HOPE", "HORN", "HOST", "HOT", "HOUR", "HOVER",
	"HOWL", "HUG", "HUGE", "HULL", "HUM", "HUNT", "HURL", "HUSH", "HUT", "ICE",
	"ICY", "IDEA", "IDLE", "IDOL", "ILL", "IMAGE", "IMP", "INCH", "INCOME", "INDEX",
	"INNER", "INPUT", "IRON", "ISLE", "ISSUE", "ITEM", "IVORY", "JACK", "JADE", "JAIL",
	"JAW", "JAZZ", "JEANS", "JEEP", "JEST", "JET", "JEWEL", "JIG", "JOB", "JOG",
	"JOIN", "JOINT", "JOKE", "JOLLY", "JOLT", "JOT", "JOURNEY", "JOY", "JUDGE", "JUG",
	"JUICE", "JUMBO", "JUMP", "JUNGLE", "JUST", "KEEN", "KEEP", "KELP", "KEY", "KICK",
	"KID", "KIND", "KING", "KISS", "KIT", "KITE", "KNACK", "KNEE", "KNEEL", "KNELL",
	"KNEW", "KNIFE", "KNIGHT", "KNIT", "KNOB", "KNOCK", "KNOT", "KNOW", "LABEL", "LABOR",
	"LACE", "LACK", "LAD", "LADDER", "LADY", "LAG", "LAID", "LAKE", "LAMB", "LAMP",
	"LAND", "LANE", "LAP", "LARGE", "LARK", "LASH", "LASS", "LAST", "LATCH", "LATE",
	"LAUGH", "LAUNCH", "LAW", "LAWN", "LAY", "LAYER", "LEAD", "LEAF", "LEAK", "LEAN",
	"LEAP", "LEARN", "LEASE", "LEASH", "LEAST", "LEAVE", "LEG", "LEND", "LENGTH", "LENS",
	"LENT", "LESS", "LETTER", "LEVEL", "LIAR", "LICK", "LID", "LIE", "LIFE", "LIFT",
	"LIGHT", "LIKE", "LIMB", "LIME", "LIMIT", "LIMP", "LINE", "LINEN", "LINK", "LIP",
	"LIST", "LIT", "LIVE", "LOAD", "LOAF", "LOAN", "LOCK", "LODGE", "LOFT", "LOG",
	"LONE", "LONG", "LOOK", "LOOM", "LOOP", "LOOSE", "LORD", "LOSE", "LOSS", "LOST",
	"LOT", "LOUD", "LOVE", "LOW", "LOYAL", "LUCK", "LUMP", "LUNAR", "LUNCH", "LUNG",
	"LURE", "LUSH", "LUTE", "LYNX", "MAD", "MAID", "MAIL", "MAIN", "MAKE", "MALE",
	"MALL", "MAN", "MANE", "MANOR", "MAP", "MARCH", "MARE", "MARK", "MARKET", "MARSH",
	"MASK", "MASS", "MAST", "MATCH", "MATE", "MAY", "MAZE", "MEAL", "MEAN", "MEAT",
	"MEDAL", "MEDIUM", "MEET", "MELT", "MEND", "MENU", "MERGE", "MERRY", "MESH", "MESS",
	"METAL", "METER", "MIGHT", "MILE", "MILK", "MILL", "MIND", "MINE", "MINOR", "MINT",
	"MIRROR", "MISS", "MIST", "MIX", "MOAN", "MOAT", "MOCK", "MODE", "MODEL", "MOIST",
	"MOLD", "MOLE", "MOM", "MONTH", "MOOD", "MOON", "MOOR", "MOP", "MORAL", "MORE",
	"MOSS", "MOST", "MOTH", "MOTOR", "MOTTO", "MOUNT", "MOURN", "MOUSE", "MOUTH", "MOVE",
	"MOVIE", "MOW", "MUCH", "MUD", "MUG", "MULE", "MUM", "MUSIC", "MUST", "MUTE",
	"MYTH", "NAIL", "NAME", "NAP", "NARROW", "NAVY", "NEAR", "NEAT", "NECK", "NEED",
	"NEEDLE", "NERVE", "NEST", "NET", "NEVER", "NEW", "NEWS", "NEXT", "NICE", "NICK",
	"NIECE", "NIGHT", "NINE", "NOBLE", "NOD", "NOISE", "NOISY", "NONE", "NOOK", "NOON",
	"NORTH", "NOSE", "NOTE", "NOTHING", "NOUN", "NOW", "NUMBER", "NURSE", "NUT", "OAK",
	"OAR", "OATH", "OBEY", "OCEAN", "ODD", "ODOR", "OFFER", "OFFICE", "OFTEN", "OIL",
	"OLD", "OLIVE", "OMEN", "ONCE", "ONE", "ONION", "ONLY", "ONTO", "OPEN", "OPERA",
	"ORAL", "ORBIT", "ORCHARD", "ORDER", "ORGAN", "OTHER", "OUNCE", "OUTER", "OVAL", "OVEN",
	"OVER", "OWE", "OWN", "OXEN", "PACE", "PACK", "PAD", "PAGE", "PAIL", "PAIN",
	"PAINT", "PAIR", "PAL", "PALE", "PALM", "PAN", "PANDA", "PANEL", "PAPER", "PARK",
	"PART", "PARTY", "PASS", "PAST", "PASTE", "PAT", "PATCH", "PATH", "PAUSE", "PAW",
	"PAY", "PEACE", "PEACH", "PEAK", "PEARL", "PECK", "PEEL", "PEEP", "PEN", "PERCH",
	"PERFECT", "PERIL", "PERK", "PEST", "PET", "PHASE", "PHONE", "PHOTO", "PICK", "PICTURE",
	"PIE", "PIECE", "PIG", "PILE", "PILOT", "PIN", "PINCH", "PINE", "PINK", "PINT",
	"PIPE", "PITCH", "PLACE", "PLAIN", "PLAN", "PLANE", "PLANK", "PLANT", "PLATE", "PLAY",
	"PLEAD", "PLEASANT", "PLOT", "PLOW", "PLUCK", "PLUG", "PLUM", "PLUNGE", "PLUS", "POCKET",
	"POEM", "POET", "POINT", "POLE", "POLICE", "POND", "POOL", "POOR", "POPE", "POP",
	"PORK", "PORT", "POSE", "POSH", "POST", "POT", "POUCH", "POUND", "POUR", "POWER",
	"PRAISE", "PRAY", "PRESS", "PRICE", "PRIDE", "PRIME", "PRINT", "PRIOR", "PRISM", "PRIZE",
	"PROBE", "PROMPT", "PROOF", "PROUD", "PROVE", "PRUNE", "PUCK", "PUDDLE", "PUFF", "PULL",
	"PULSE", "PUMP", "PUNCH", "PUPIL", "PUPPY", "PURE", "PURSE", "PUSH", "PUT", "QUAIL",
	"QUAKE", "QUALITY", "QUART", "QUEEN", "QUERY", "QUEST", "QUEUE", "QUICK", "QUIET", "QUILL",
	"QUILT", "QUIT", "QUIZ", "QUOTE", "RABBIT", "RACE", "RACK", "RADIO", "RAFT", "RAGE",
	"RAIL", "RAIN", "RAISE", "RAKE", "RALLY", "RAMP", "RANCH", "RANGE", "RANK", "RAPID",
	"RARE", "RASH", "RAT", "RATE", "RAVE", "RAY", "REACH", "REACT", "READ", "READY",
	"REAL", "REALM", "REAP", "REAR", "REASON", "REBEL", "RED", "REEF", "REEL", "REIGN",
	"RELAX", "RELAY", "RENT", "REST", "RHYME", "RHYTHM", "RICE", "RICH", "RIDE", "RIDGE",
	"RIFLE", "RIGHT", "RIGID", "RIM", "RING", "RINSE", "RIPE", "RISE", "RISK", "RITE",
	"RIVAL", "RIVER", "ROAD", "ROAM", "ROAR", "ROAST", "ROB", "ROBE", "ROBIN", "ROBOT",
	"ROCK", "ROCKET", "ROD", "RODE", "ROLE", "ROLL", "ROOF", "ROOK", "ROOM", "ROOT",
	"ROPE", "ROSE", "ROT", "ROUND", "ROUTE", "ROVE", "ROW", "ROYAL", "RUB", "RUBY",
	"RUG", "RULE", "RUN", "RUNG", "RUSH", "RUST", "RUT", "SACK", "SAD", "SAFE",
	"SAGE", "SAIL", "SAINT", "SAKE", "SALE", "SALT", "SAME", "SAND", "SANE", "SASH",
	"SAT", "SAVE", "SAW", "SAY", "SCALE", "SCAN", "SCAR", "SCARE", "SCARF", "SCENE",
	"SCENT", "SCHOOL", "SCOLD", "SCOOP", "SCOPE", "SCORE", "SCOUT", "SCRAP", "SCREAM", "SCREEN",
	"SCRIPT", "SCROLL", "SCRUB", "SEA", "SEAL", "SEARCH", "SEAT", "SEED", "SEEK", "SEEM",
	"SEEN", "SEIZE", "SELF", "SELL", "SEND", "SENSE", "SENT", "SERVE", "SET", "SEVEN",
	"SEW", "SHADE", "SHAFT", "SHAKE", "SHALL", "SHAME", "SHAPE", "SHARE", "SHARK", "SHARP",
	"SHAVE", "SHAWL", "SHED", "SHEEP", "SHEER", "SHEET", "SHELF", "SHELL", "SHIELD", "SHIFT",
	"SHINE", "SHIP", "SHIRT", "SHOCK", "SHOE", "SHOOT", "SHOP", "SHORE", "SHORT", "SHOT",
	"SHOUT", "SHOVE", "SHOW", "SHRIMP", "SHRINK", "SHRUG", "SHUT", "SHY", "SICK", "SIDE",
	"SIFT", "SIGH", "SIGHT", "SIGN", "SILK", "SILLY", "SILVER", "SIMPLE", "SINCE", "SING",
	"SINK", "SIP", "SIR", "SISTER", "SIT", "SITE", "SIX", "SIZE", "SKATE", "SKETCH",
	"SKI", "SKILL", "SKIM", "SKIN", "SKIP", "SKIRT", "SKULL", "SKUNK", "SKY", "SLAB",
	"SLAM", "SLATE", "SLAVE", "SLED", "SLEEP", "SLEET", "SLICE", "SLICK", "SLIDE", "SLIM",
	"SLIME", "SLING", "SLIP", "SLIT", "SLOPE", "SLOT", "SLOW", "SLUG", "SLUM", "SLUMP",
	"SMACK", "SMALL", "SMART", "SMELL", "SMILE", "SMITH", "SMOKE", "SMOOTH", "SMUG", "SNAIL",
	"SNAKE", "SNAP", "SNARE", "SNARL", "SNEAK", "SNEEZE", "SNIFF", "SNIP", "SNORE", "SNORT",
	"SNOW", "SNUG", "SOAK", "SOAP", "SOAR", "SOB", "SOCK", "SOFT", "SOIL", "SOLAR",
	"SOLD", "SOLE", "SOLID", "SOLVE", "SOME", "SON", "SONG", "SOON", "SOOT", "SORE",
	"SORRY", "SORT", "SOUL", "SOUND", "SOUP", "SOUR", "SOUTH", "SOW", "SPACE", "SPADE",
	"SPAN", "SPARE", "SPARK", "SPEAK", "SPEAR", "SPECIAL", "SPEED", "SPELL", "SPEND", "SPENT",
	"SPHERE", "SPICE", "SPICY", "SPIDER", "SPIKE", "SPILL", "SPIN", "SPINE", "SPIRE", "SPIRIT",
	"SPIT", "SPITE", "SPLASH", "SPLIT", "SPOIL", "SPOKE", "SPONGE", "SPOON", "SPORT", "SPOT",
	"SPOUT", "SPRAY", "SPREAD", "SPRING", "SPROUT", "SPUN", "SPUR", "SPY", "SQUAD", "SQUARE",
	"SQUAT", "SQUAWK", "SQUEAK", "SQUEEZE", "SQUID", "STABLE", "STACK", "STAFF", "STAGE", "STAIN",
	"STAIR", "STAKE", "STALE", "STALK", "STALL", "STAMP", "STAND", "STAPLE", "STAR", "STARE",
	"START", "STATE", "STAY", "STEADY", "STEAK", "STEAL", "STEAM", "STEEL", "STEEP", "STEER",
	"STEM", "STEP", "STERN", "STICK", "STIFF", "STILL", "STING", "STIR", "STOCK", "STOLE",
	"STONE", "STOOD", "STOOL", "STOOP", "STOP", "STORE", "STORK", "STORM", "STORY", "STOUT",
	"STOVE", "STRAP", "STRAW", "STRAY", "STREAM", "STREET", "STRESS", "STREW", "STRICT", "STRIDE",
	"STRIP", "STRONG", "STRUCK", "STRUM", "STRUT", "STUB", "STUCK", "STUDY", "STUFF", "STUMP",
	"STUN", "STUNT", "STURDY", "STYLE", "SUCH", "SUCK", "SUD", "SUDS", "SUGAR", "SUIT",
	"SULKY", "SUM", "SUMMER", "SUN", "SUNG", "SUNK", "SUNNY", "SUPER", "SURE", "SURF",
	"SURGE", "SWAMP", "SWAN", "SWAP", "SWARM", "SWAY", "SWEAR", "SWEAT", "SWEEP", "SWEET",
	"SWELL", "SWEPT", "SWIFT", "SWIM", "SWINE", "SWING", "SWIRL", "SWOOP", "SWORD", "SWORE",
	"SWORN", "SWUNG", "SYRUP", "TABLE", "TACK", "TAG", "TAIL", "TAKE", "TALE", "TALENT",
	"TALK", "TALL", "TAME", "TAN", "TANGLE", "TANK", "TAP", "TAPE", "TAR", "TARGET",
	"TASK", "TASTE", "TAUGHT", "TAX", "TEA", "TEACH", "TEAL", "TEAM", "TEAR", "TEASE",
	"TEETH", "TELL", "TEMPLE", "TEN", "TEND", "TENSE", "TENT", "TERM", "TERN", "TEST",
	"TEXT", "THAN", "THANK", "THAW", "THE", "THEIR", "THEM", "THEME", "THEN", "THERE",
	"THESE", "THICK", "THIEF", "THIGH", "THIN", "THING", "THINK", "THIRD", "THORN", "THOSE",
	"THOUGHT", "THREAD", "THREE", "THREW", "THROAT", "THRONE", "THROW", "THUMB", "THUMP", "THUS",
	"TICK", "TICKET", "TIDAL", "TIDE", "TIDY", "TIE", "TIGER", "TIGHT", "TILE", "TILL",
	"TILT", "TIMBER", "TIME", "TIMID", "TIN", "TINT", "TINY", "TIP", "TIRE", "TITLE",
	"TOAD", "TOAST", "TODAY", "TOE", "TOIL", "TOKEN", "TOLD", "TOLL", "TOMB", "TONE",
	"TONGUE", "TONIGHT", "TON", "TOO", "TOOK", "TOOL", "TOOTH", "TOP", "TOPIC", "TORCH",
	"TORE", "TORN", "TOSS", "TOTAL", "TOUCH", "TOUGH", "TOUR", "TOW", "TOWEL", "TOWER",
	"TOWN", "TOY", "TRACE", "TRACK", "TRACT", "TRADE", "TRAIL", "TRAIN", "TRAIT", "TRAMP",
	"TRAP", "TRASH", "TRAVEL", "TRAY", "TREAD", "TREAT", "TREE", "TREND", "TRIAL", "TRIBE",
	"TRICK", "TRIED", "TRIM", "TRIP", "TROOP", "TROT", "TROUT", "TRUCK", "TRUE", "TRULY",
	"TRUNK", "TRUST", "TRUTH", "TUB", "TUBA", "TUBE", "TUCK", "TUG", "TULIP", "TUMBLE",
	"TUNA", "TUNE", "TUNNEL", "TURF", "TURN", "TURTLE", "TUSK", "TUTOR", "TWANG", "TWICE",
	"TWIG", "TWIN", "TWINE", "TWIRL", "TWIST", "TWO", "TYING", "TYPE", "UGLY", "UMPIRE",
	"UNCLES", "UNDER", "UNFAIR", "UNION", "UNIQUE", "UNIT", "UNITE", "UNITY", "UNTIL", "UNTO",
	"UP", "UPPER", "UPSET", "URBAN", "URGE", "URN", "US", "USE", "USED", "USEFUL",
	"USUAL", "UTTER", "VACANT", "VAGUE", "VAIN", "VALE", "VALID", "VALLEY", "VALUE", "VALVE",
	"VAN", "VANE", "VAPOR", "VARY", "VASE", "VAST", "VAT", "VAULT", "VEIL", "VEIN",
	"VELVET", "VEND", "VENT", "VERB", "VERGE", "VERSE", "VERY", "VEST", "VET", "VIEW",
	"VIGOR", "VILLAGE", "VINE", "VIOLIN", "VIPER", "VIRUS", "VISIT", "VISOR", "VISTA", "VITAL",
	"VIVID", "VOCAL", "VOICE", "VOID", "VOLT", "VOTE", "VOW", "VOWEL", "VOYAGE", "WAD",
	"WADE", "WAG", "WAGE", "WAGON", "WAIL", "WAIST", "WAIT", "WAIVE", "WAKE", "WALK",
	"WALL", "WAND", "WANE", "WANT", "WARD", "WARE", "WARM", "WARN", "WARP", "WASH",
	"WASP", "WASTE", "WATCH", "WATER", "WAVE", "WAVY", "WAX", "WAY", "WEAK", "WEALTH",
	"WEAN", "WEAR", "WEAVE", "WEB", "WED", "WEDGE", "WEED", "WEEK", "WEEP", "WEIGH",
	"WEIRD", "WELCOME", "WELL", "WENT", "WEPT", "WERE", "WEST", "WET", "WHALE", "WHARF",
	"WHAT", "WHEAT", "WHEEL", "WHEN", "WHERE", "WHICH", "WHIFF", "WHILE", "WHIM", "WHINE",
	"WHIP", "WHIRL", "WHISK", "WHISPER", "WHISTLE", "WHITE", "WHO", "WHOLE", "WHOM", "WHOSE",
	"WHY", "WICK", "WIDE", "WIDEN", "WIDOW", "WIDTH", "WIFE", "WIG", "WILD", "WILL",
	"WILLOW", "WIN", "WINCE", "WIND", "WINDOW", "WINE", "WING", "WINK", "WINTER", "WIPE",
	"WIRE", "WISE", "WISH", "WISP", "WIT", "WITCH", "WITH", "WITTY", "WOKE", "WOLF",
	"WOMAN", "WON", "WONDER", "WOOD", "WOODEN", "WOOL", "WORD", "WORE", "WORK", "WORLD",
	"WORM", "WORN", "WORRY", "WORSE", "WORST", "WORTH", "WOULD", "WOUND", "WOVE", "WOW",
	"WRAP", "WRATH", "WREATH", "WRECK", "WREN", "WRENCH", "WREST", "WRING", "WRIST", "WRITE",
	"WRONG", "WROTE", "WRUNG", "WRY", "YACHT", "YAM", "YARD", "YARN", "YAWN", "YEAR",
	"YEARN", "YELL", "YELLOW", "YES", "YET", "YIELD", "YOGA", "YOKE", "YOLK", "YOU",
	"YOUNG", "YOUR", "YOUTH", "YUM", "ZEBRA", "ZENITH", "ZERO", "ZEST", "ZIG", "ZIGZAG",
	"ZINC", "ZIP", "ZIPPER", "ZONE", "ZOO", "ZOOM",
]

static var _built := false
static var _levels: Array = []
static var _level_of: Dictionary = {}

static func _clean(raw: String) -> String:
	var w := raw.strip_edges().to_upper()
	if w.length() < 3 or w.length() > 5:
		return ""
	for ch in w:
		if ch < "A" or ch > "Z":
			return ""
	return w

static func _ensure_built() -> void:
	if _built:
		return
	var seen := {}
	for source in LEVEL_SOURCES:
		var level: Array[String] = []
		for raw in source:
			var w := _clean(raw)
			if w == "":
				continue
			if seen.has(w):
				continue
			seen[w] = true
			level.append(w)
			if level.size() >= WORDS_PER_LEVEL:
				break
		_levels.append(level)
	for i in range(_levels.size()):
		var level: Array[String] = _levels[i]
		var backup_index := 0
		while level.size() < WORDS_PER_LEVEL and backup_index < BACKUP_POOL.size():
			var w := _clean(BACKUP_POOL[backup_index])
			backup_index += 1
			if w == "":
				continue
			if seen.has(w):
				continue
			seen[w] = true
			level.append(w)
		_levels[i] = level
	for level_index in range(_levels.size()):
		for w in _levels[level_index]:
			if not _level_of.has(w):
				_level_of[w] = level_index + 1
	_built = true

static func get_level_words(level: int) -> Array[String]:
	_ensure_built()
	if level < 1 or level > _levels.size():
		return []
	return (_levels[level - 1] as Array[String]).duplicate()

static func get_all_words() -> Array[String]:
	_ensure_built()
	var all: Array[String] = []
	for level in _levels:
		for w in level:
			all.append(w)
	return all

static func get_total_unique_words() -> int:
	_ensure_built()
	return _level_of.size()

static func get_meaning(word: String) -> String:
	var w := word.to_upper()
	if MEANINGS.has(w):
		return str(MEANINGS[w])
	if ANIMAL_MEANINGS.has(w):
		return str(ANIMAL_MEANINGS[w])
	if PROFESSION_MEANINGS.has(w):
		return str(PROFESSION_MEANINGS[w])
	_ensure_built()
	if _level_of.has(w):
		var level_index: int = _level_of[w] - 1
		if level_index >= 0 and level_index < LEVEL_FALLBACKS.size():
			return str(LEVEL_FALLBACKS[level_index])
	# Never echo the English word as the meaning. A generic child-friendly
	# Turkish phrase is always available as the last resort.
	return "Gunluk bir kelime"


static func get_illustration_kind(word: String) -> String:
	# Central illustration category. Level 1 is the animal level by design;
	# professions are resolved from the shared PROFESSION_MEANINGS lookup so
	# the drawing and the meaning stay in agreement.
	var w := word.to_upper()
	_ensure_built()
	if _level_of.has(w) and int(_level_of[w]) == 1:
		return "animal"
	if PROFESSION_MEANINGS.has(w):
		return "profession"
	return "default"
