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
## App is fully free for now - no level is paywalled.
const FREE_LEVELS := LEVEL_COUNT + 1

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
		"CAT", "DOG", "COW", "PIG", "HEN", "DUCK", "FISH", "BIRD", "LION", "BEAR",
		"FOX", "WOLF", "DEER", "GOAT", "HORSE", "SHEEP", "FROG", "OWL", "BUNNY", "MOUSE",
		"SNAKE", "TIGER", "ZEBRA", "PANDA", "KOALA", "CAMEL", "WHALE", "SHARK", "SWAN", "GOOSE",
		"EAGLE", "HAWK", "CROW", "PUPPY", "KITTY", "PONY", "LAMB", "CRAB", "SNAIL", "MOOSE",
		"DOVE", "WREN", "ROBIN", "RAVEN", "CRANE", "STORK", "HERON", "QUAIL", "FINCH", "EGRET",
		"LOON", "OWLET", "PUMA", "HYENA", "BISON", "OTTER", "SKUNK", "SLOTH", "MINK", "STOAT",
		"MOLE", "HARE", "TOAD", "NEWT", "GECKO", "COBRA", "VIPER", "SQUID", "WORM", "WASP",
		"MOTH", "FLEA", "BUG", "ANT", "BEE", "FLY", "RAT", "BAT", "APE", "ELK",
		"EMU", "CUB", "PUP", "KID", "MULE", "LLAMA", "TAPIR", "OKAPI", "SEAL", "TUNA",
		"COD", "EEL", "PERCH", "TROUT", "BASS", "CARP", "PIKE", "GUPPY", "TETRA", "CLAM",
	],
	# Level 2 - Colors, shapes and the body
	[
		"RED", "BLUE", "GREEN", "EYE", "EAR", "ARM", "LEG", "HAND", "FOOT", "NOSE",
		"HAIR", "HEAD", "TOOTH", "FACE", "PINK", "BLACK", "WHITE", "BROWN", "YELLOW", "ORANGE",
		"PURPLE", "GRAY", "BALL", "LINE", "RING", "BOX", "HEART", "ROUND", "NECK", "CHIN",
		"CHEEK", "BROW", "SKIN", "BONE", "KNEE", "ELBOW", "WRIST", "ANKLE", "TOE", "THUMB",
		"PALM", "NAIL", "LIP", "JAW", "GUM", "RIB", "HIP", "WAIST", "BACK", "ARC",
		"DOT", "SKY", "TAN", "AQUA", "CALF", "COAL", "COIL", "CONE", "CUBE", "CYAN",
		"DISK", "EDGE", "GOLD", "KNOT", "LASH", "LIME", "LOOP", "LUNG", "MINT", "NAVY",
		"OVAL", "ROSE", "RUST", "SAGE", "SAND", "SHIN", "SOLE", "TEAL", "TUBE", "VEIN",
		"WINE", "AMBER", "ANGLE", "BEIGE", "BELLY", "BLOCK", "BLOOD", "BRAIN", "CORAL", "CREAM",
		"CROSS", "CURVE", "DENIM", "EBONY", "FLINT", "IVORY", "KHAKI", "LILAC", "LIVER", "MAUVE",
		"NERVE", "OLIVE", "PEACH", "PLATE", "PRISM", "PUPIL", "SLATE", "STEEL", "TUMMY", "WHEEL",
	],
	# Level 3 - Food and drink
	[
		"APPLE", "MILK", "EGG", "CAKE", "BREAD", "RICE", "CHEESE", "SOUP", "JUICE", "WATER",
		"PEAR", "PLUM", "GRAPE", "LEMON", "HONEY", "CORN", "PIE", "NUT", "MEAT", "HAM",
		"BUN", "JAM", "FIG", "OAT", "PEA", "TEA", "YAM", "BEAN", "BEEF", "BEET",
		"COLA", "DATE", "DILL", "HERB", "KALE", "KIWI", "LEEK", "LIME", "MINT", "MISO",
		"PORK", "SAGE", "SALT", "SODA", "STEW", "TACO", "TARO", "TART", "TOFU", "VEAL",
		"BACON", "BAGEL", "BASIL", "BERRY", "BROTH", "CANDY", "CHILI", "CHIVE", "CIDER", "CLOVE",
		"COCOA", "CREAM", "CURRY", "DONUT", "FEAST", "FLOUR", "GRAVY", "GRILL", "GRUEL", "ICING",
		"JELLY", "LUNCH", "MAIZE", "MANGO", "MELON", "NACHO", "OLIVE", "ONION", "PASTA", "PEACH",
		"PIZZA", "PRAWN", "PUNCH", "ROAST", "SALAD", "SALSA", "SNACK", "SPICE", "STEAK", "SUGAR",
		"SWEET", "SYRUP", "THYME", "TOAST", "WAFER", "WHEAT", "YEAST", "BARLEY", "DINNER", "LENTIL",
		"MORSEL", "NOODLE", "QUINOA", "RAISIN", "SORBET", "TIDBIT", "APRICOT", "COCONUT", "DUMPLING", "MERINGUE",
	],
	# Level 4 - Home and furniture
	[
		"BED", "BIN", "COT", "CUP", "FAN", "JUG", "KEY", "LID", "MAT", "MOP",
		"MUG", "PAN", "POT", "RUG", "TAP", "TUB", "BEAM", "BOWL", "BULB", "BUNK",
		"COMB", "CORD", "DECK", "DESK", "DISH", "DOOR", "DUST", "FORK", "GATE", "HALL",
		"HOME", "KNOB", "LAMP", "LOCK", "OVEN", "PATH", "PLUG", "RAIL", "ROOF", "ROOM",
		"SILL", "SINK", "SOAP", "SOFA", "STEP", "VASE", "WALL", "WIRE", "YARD", "ATTIC",
		"BENCH", "BLIND", "BROOM", "BRUSH", "CHAIR", "CHEST", "CLOCK", "DRAIN", "FENCE", "FLOOR",
		"FRAME", "HINGE", "HOUSE", "KNIFE", "LEDGE", "PATIO", "PHOTO", "PLATE", "PORCH", "QUILT",
		"SHEET", "SHELF", "SPOON", "STOOL", "STOVE", "TABLE", "TOWEL", "TRASH", "BASKET", "BUCKET",
		"CLOSET", "CORNER", "CRADLE", "DRAWER", "FRIDGE", "GARAGE", "GARDEN", "HANDLE", "HEATER", "MIRROR",
		"MIRROR", "PILLAR", "PILLOW", "ROCKER", "SHOWER", "SPONGE", "STAIRS", "SWITCH", "TOILET", "WINDOW",
		"BLANKET", "CABINET", "CEILING", "CHIMNEY", "CURTAIN", "DRESSER", "FREEZER", "SHUTTER", "BASEMENT", "WARDROBE",
	],
	# Level 5 - Toys, games and play
	[
		"BAT", "BOW", "CAR", "ELF", "HUT", "JOG", "LAP", "NET", "RUN", "TAG",
		"TOP", "TOY", "WIN", "BALL", "BALL", "BOAT", "CAMP", "CAPE", "CARD", "CLAP",
		"CLUB", "DART", "DICE", "DOLL", "DRUM", "DRUM", "FORT", "GAME", "GOAL", "HERO",
		"HIDE", "HOOP", "HORN", "JOIN", "KING", "KITE", "LEAP", "MASK", "PAIL", "PLAY",
		"RACE", "RING", "ROPE", "SAND", "SEEK", "SING", "SKIP", "STAR", "TEAM", "TENT",
		"TURN", "WALK", "WAND", "YOYO", "ARROW", "BADGE", "BANJO", "BLOCK", "BUNNY", "CHEER",
		"CLOWN", "COURT", "CROWN", "DANCE", "DWARF", "FAIRY", "FIELD", "FLUTE", "GIANT", "LAUGH",
		"MEDAL", "PIANO", "PITCH", "PLANE", "PRIZE", "QUEEN", "ROBOT", "SCORE", "SHARE", "SLIDE",
		"SMILE", "SPADE", "STICK", "SWING", "TEDDY", "TRACK", "TRAIN", "TRUCK", "WITCH", "CASTLE",
		"DRAGON", "GIGGLE", "GLIDER", "KNIGHT", "MARBLE", "PADDLE", "PRINCE", "PUPPET", "PUZZLE", "RACKET",
		"RIBBON", "ROCKET", "SEESAW", "SHOVEL", "TARGET", "TROPHY", "WIZARD", "TRUMPET", "WHISTLE", "PRINCESS",
	],
	# Level 6 - School
	[
		"ART", "BAG", "GYM", "MAP", "PEN", "TAG", "TAP", "BEAT", "BELL", "BOOK",
		"CARD", "DESK", "DESK", "DRAW", "EXAM", "GLUE", "GOAL", "HALL", "LINE", "LIST",
		"LOGO", "MARK", "MATH", "MEMO", "NAME", "NOTE", "NOTE", "PAGE", "PAIR", "PLAN",
		"PLAY", "POEM", "QUIZ", "READ", "RING", "ROOM", "SIZE", "SONG", "STAR", "TAPE",
		"TASK", "TEAM", "TEST", "TONE", "TUNE", "WORD", "WORK", "AWARD", "BADGE", "BOARD",
		"BREAK", "CHAIR", "CHALK", "CLASS", "COACH", "COLOR", "COUNT", "COUNT", "DRAMA", "FIELD",
		"GRADE", "GROUP", "LABEL", "LOGIC", "LUNCH", "MUSIC", "PAINT", "PAPER", "PITCH", "POUCH",
		"PRIZE", "PUPIL", "PUPIL", "RHYME", "RULER", "SCORE", "SHAPE", "SNACK", "SOUND", "SPELL",
		"SPORT", "STAMP", "STORY", "STRAP", "TUTOR", "VOWEL", "WRITE", "BINDER", "CRAYON", "ERASER",
		"FOLDER", "FRIEND", "LETTER", "NATURE", "NUMBER", "OFFICE", "PENCIL", "PENCIL", "RECESS", "RHYTHM",
		"SCHOOL", "ZIPPER", "HISTORY", "LIBRARY", "SCIENCE", "STICKER", "TEACHER", "UNIFORM", "ALPHABET", "NOTEBOOK",
	],
	# Level 7 - Nature and weather
	[
		"ASH", "BUD", "ELM", "FIR", "MUD", "OAK", "RAY", "SEA", "SKY", "SUN",
		"BEAM", "BUSH", "CAVE", "CLAY", "COLD", "DARK", "DAWN", "DIRT", "DUNE", "DUST",
		"FARM", "FERN", "FIRE", "GALE", "GLOW", "GUST", "HAIL", "HEAT", "HILL", "LAKE",
		"LEAF", "MELT", "MOON", "MOSS", "PALM", "PINE", "POND", "RAIN", "REED", "ROCK",
		"ROOT", "SAND", "SEED", "SNOW", "SOIL", "STAR", "STEM", "THAW", "TREE", "VINE",
		"WIND", "BEACH", "BLOOM", "BROOK", "CANAL", "CLIFF", "CLOUD", "COAST", "CREEK", "EARTH",
		"FIELD", "FLAME", "FLOOD", "FOGGY", "FROST", "GRASS", "MISTY", "PETAL", "PLANT", "RAINY",
		"RIVER", "SHADE", "SHINE", "SHORE", "SHRUB", "SLEET", "SNOWY", "SPARK", "STEAM", "STONE",
		"STORM", "SUNNY", "VAPOR", "WINDY", "WOODS", "WORLD", "BREEZE", "CANYON", "CLOUDY", "DESERT",
		"FLOWER", "FOREST", "GARDEN", "GRAVEL", "ICICLE", "JUNGLE", "MEADOW", "PEBBLE", "PUDDLE", "STREAM",
		"VALLEY", "BLOSSOM", "BOULDER", "DROPLET", "DROUGHT", "ORCHARD", "PLATEAU", "TEMPEST", "THUNDER", "LIGHTNING",
	],
	# Level 8 - Actions (verbs)
	[
		"ASK", "EAT", "FIX", "FLY", "FRY", "HIT", "HOP", "MIX", "ROW", "RUN",
		"SAY", "SEE", "SIP", "SIT", "TIE", "BAKE", "BITE", "BOIL", "CALL", "CHEW",
		"CHOP", "COOK", "DIVE", "DRAW", "DUST", "FEEL", "FILL", "FOLD", "GIVE", "GLUE",
		"GULP", "HANG", "HEAR", "HELP", "IRON", "JUMP", "KICK", "KNOT", "KNOW", "LICK",
		"LIFT", "LOOK", "MAKE", "OPEN", "PACK", "PEEL", "PLAY", "POUR", "PULL", "PUSH",
		"READ", "RIDE", "ROLL", "SAIL", "SING", "SINK", "SORT", "STIR", "SWIM", "TAKE",
		"TALK", "TAPE", "TELL", "TOSS", "TOSS", "WALK", "WASH", "WIPE", "WRAP", "BREAK",
		"BUILD", "CARRY", "CATCH", "CLEAN", "CLIMB", "CLOSE", "DANCE", "DRINK", "DRIVE", "EMPTY",
		"FLOAT", "GRATE", "GRILL", "LEARN", "PAINT", "SCRUB", "SHARE", "SHINE", "SHOUT", "SKATE",
		"SLEEP", "SLICE", "SLIDE", "SMELL", "SPILL", "STACK", "SWEEP", "TASTE", "TEACH", "THINK",
		"THROW", "TOUCH", "WRITE", "BOUNCE", "PADDLE", "POLISH", "SPLASH", "SPREAD", "WHISPER", "SPRINKLE",
	],
	# Level 9 - Clothes
	[
		"BAG", "BIB", "BOW", "CAP", "FIT", "HAT", "HEM", "PIN", "SEW", "TIE",
		"BAND", "BELT", "CANE", "CASE", "CLIP", "COAT", "CUFF", "FELT", "GOWN", "HOOD",
		"KILT", "KNIT", "LACE", "LACE", "MASK", "MEND", "RING", "ROBE", "SACK", "SEAM",
		"SILK", "TOTE", "VEST", "WEAR", "WOOL", "APRON", "BOOTS", "CLOTH", "CROWN", "DENIM",
		"DRESS", "GLOVE", "JEANS", "LINEN", "MATCH", "PANTS", "PARKA", "PATCH", "PURSE", "SCARF",
		"SHAWL", "SHIRT", "SHOES", "SKIRT", "SOCKS", "STRAP", "TIARA", "TRUNK", "TUNIC", "WATCH",
		"WEAVE", "BLAZER", "BROOCH", "BUCKLE", "BUTTON", "COLLAR", "COTTON", "DIAPER", "FLEECE", "HOODIE",
		"JACKET", "JERSEY", "MITTEN", "POCKET", "PONCHO", "RIBBON", "SANDAL", "SARONG", "SHORTS", "SLEEVE",
		"STITCH", "TAILOR", "TIGHTS", "VELVET", "WALLET", "ZIPPER", "EARRING", "GLASSES", "GOGGLES", "HAIRPIN",
		"LUGGAGE", "NIGHTIE", "OVERALL", "PAJAMAS", "PENDANT", "SATCHEL", "SLIPPER", "SNEAKER", "SWEATER", "UNIFORM",
		"BACKPACK", "BARRETTE", "BRACELET", "CARDIGAN", "HEADBAND", "LEGGINGS", "NECKLACE", "STOCKING", "SUNGLASS", "UMBRELLA",
	],
	# Level 10 - Places
	[
		"BAY", "GYM", "INN", "ZOO", "BANK", "BARN", "CAPE", "CAVE", "CITY", "DOCK",
		"DOOR", "FAIR", "FARM", "GATE", "HALL", "HILL", "HOME", "LAKE", "LANE", "MALL",
		"PARK", "PATH", "PEAK", "PIER", "POND", "POOL", "PORT", "ROAD", "ROOM", "SHOP",
		"TOWN", "WELL", "YARD", "ALLEY", "ARENA", "BEACH", "BLOCK", "BROOK", "CANAL", "CLIFF",
		"COAST", "COURT", "DEPOT", "FIELD", "FIELD", "HOTEL", "HOUSE", "MOTEL", "PLAZA", "RIDGE",
		"RIVER", "SHORE", "SLOPE", "STATE", "STORE", "TOWER", "TRACK", "WOODS", "WORLD", "AVENUE",
		"BAZAAR", "BRIDGE", "CANYON", "CASTLE", "CHURCH", "CINEMA", "CIRCUS", "CLINIC", "CORNER", "DESERT",
		"FOREST", "GARAGE", "GARDEN", "HARBOR", "HOSTEL", "ISLAND", "JUNGLE", "MARKET", "MEADOW", "MOSQUE",
		"MUSEUM", "NATION", "OFFICE", "PALACE", "SCHOOL", "SPRING", "SQUARE", "STABLE", "STREAM", "STREET",
		"SUBURB", "TEMPLE", "VALLEY", "AIRPORT", "COUNTRY", "LIBRARY", "ORCHARD", "PLATEAU", "STADIUM", "STATION",
		"THEATER", "VILLAGE", "CARNIVAL", "FOUNTAIN", "HOSPITAL", "MOUNTAIN", "PHARMACY", "PENINSULA", "WATERFALL", "PLAYGROUND",
	],
	# Level 11 - Transport
	[
		"GO", "BAG", "BUS", "CAB", "CAR", "FLY", "GAS", "JET", "MAP", "OIL",
		"VAN", "AXLE", "BELT", "BIKE", "BOAT", "CART", "DOCK", "DOOR", "FARE", "FAST",
		"FIRE", "FLAG", "FUEL", "HOOD", "HORN", "JEEP", "KITE", "LANE", "LINE", "PARK",
		"PASS", "PATH", "PIER", "RAFT", "RAIL", "RIDE", "ROAD", "SAIL", "SEAT", "SHIP",
		"SLED", "SLOW", "STOP", "TAXI", "TIRE", "TRAM", "WING", "BARGE", "BLIMP", "BRAKE",
		"CANOE", "COACH", "CYCLE", "DRIVE", "DRONE", "FERRY", "KAYAK", "LIGHT", "LIGHT", "LORRY",
		"METRO", "MOPED", "MOTOR", "MOTOR", "PEDAL", "PILOT", "PLANE", "RADIO", "ROUTE", "SIREN",
		"STEER", "TRACK", "TRAIN", "TRUCK", "TRUNK", "WAGON", "WHEEL", "YACHT", "BEACON", "BUMPER",
		"CAMPER", "CHARGE", "DIESEL", "ENGINE", "ENGINE", "GLIDER", "MIRROR", "PETROL", "PICKUP", "POLICE",
		"ROCKET", "SIGNAL", "SLEIGH", "STREET", "TICKET", "WINDOW", "BALLOON", "BATTERY", "BICYCLE", "COMPASS",
		"SCOOTER", "SHUTTLE", "TRACTOR", "TRAILER", "WHISTLE", "CARRIAGE", "AMBULANCE", "LIMOUSINE", "SUBMARINE", "HELICOPTER",
	],
	# Level 12 - Family and people
	[
		"BOY", "BOY", "DAD", "FAN", "HEN", "KID", "MAN", "MOB", "MOM", "MUM",
		"NAN", "PAL", "POP", "SON", "AUNT", "BABY", "BOSS", "CHEF", "CLAN", "COOK",
		"DATE", "FOLK", "GIRL", "GIRL", "HERO", "HERO", "HOST", "IDOL", "KING", "LADY",
		"MATE", "MISS", "STAR", "TEAM", "TEEN", "TEEN", "TWIN", "ADULT", "ADULT", "BRIDE",
		"CHIEF", "CHILD", "CHILD", "COACH", "CROWD", "CROWD", "ELDER", "GROOM", "GROUP", "GUEST",
		"HUMAN", "LOCAL", "LOSER", "MADAM", "MODEL", "NANNY", "NIECE", "NURSE", "PILOT", "PUPIL",
		"QUEEN", "TRIBE", "TUTOR", "UNCLE", "UNCLE", "WIDOW", "WOMAN", "AUNTIE", "COUSIN", "DOCTOR",
		"FAMILY", "FARMER", "FRIEND", "GRAMPY", "GRANNY", "INFANT", "KNIGHT", "LEADER", "MASTER", "MISTER",
		"NATION", "NATIVE", "NEPHEW", "ORPHAN", "PARENT", "PEOPLE", "PERSON", "PLAYER", "PRINCE", "SENIOR",
		"SISTER", "WINNER", "BROTHER", "CAPTAIN", "CITIZEN", "CITIZEN", "GRANDMA", "GRANDPA", "PARTNER", "STUDENT",
		"TEACHER", "TODDLER", "TOURIST", "VISITOR", "NEIGHBOR", "NEIGHBOR", "PRINCESS", "ROOMMATE", "STRANGER", "GENTLEMAN",
	],
	# Level 13 - Feelings
	[
		"AWE", "AWE", "BAD", "CRY", "FUN", "JOY", "MAD", "SAD", "SHY", "SOB",
		"WAR", "ACHE", "CALM", "CALM", "CARE", "CHAT", "COZY", "DOOM", "ENVY", "FEAR",
		"FEEL", "FINE", "FURY", "GASP", "GLAD", "GLEE", "GOOD", "GRIN", "HATE", "HOPE",
		"HURT", "KIND", "LIKE", "LOVE", "MEAN", "MIND", "MOAN", "MOOD", "NICE", "OKAY",
		"PAIN", "RAGE", "RISK", "SAFE", "SICK", "SIGH", "SORE", "SOUL", "SURE", "WEEP",
		"WELL", "WISH", "YELL", "ZEAL", "ANGRY", "BLAME", "BLISS", "BLUES", "BORED", "BRAVE",
		"BRAVE", "CHEER", "DOUBT", "DREAM", "FAITH", "FROWN", "GLOOM", "GREAT", "GUILT", "HAPPY",
		"HEART", "JOLLY", "LAUGH", "LOVED", "MERRY", "MOODY", "PANIC", "PEACE", "PRIDE", "PROUD",
		"PROUD", "SENSE", "SHAME", "SHOCK", "SHOUT", "SMILE", "SORRY", "SPITE", "STORM", "TIRED",
		"TRUST", "WORRY", "AFRAID", "DANGER", "LONELY", "PRAISE", "RELIEF", "SCARED", "SCREAM", "SLEEPY",
		"SPIRIT", "WARMTH", "WONDER", "COMFORT", "COMFORT", "EXCITED", "NERVOUS", "WHISPER", "WORRIED", "SURPRISED",
	],
	# Level 14 - Numbers and time
	[
		"ADD", "AGE", "BIT", "DAY", "END", "ERA", "FEW", "LOT", "NOW", "ONE",
		"SIX", "SUM", "TEN", "TWO", "DATE", "DAWN", "DUSK", "FAST", "FIVE", "FOUR",
		"HALF", "HOUR", "LAST", "LATE", "LESS", "LONG", "MANY", "MORE", "MOST", "NEXT",
		"NINE", "NOON", "ONCE", "PAIR", "PART", "PAST", "RANK", "REST", "SLOW", "SOME",
		"SOON", "STOP", "THEN", "WEEK", "YEAR", "ZERO", "AFTER", "AGAIN", "ALARM", "BEGIN",
		"BREAK", "BRIEF", "CLOCK", "COUNT", "DIGIT", "DOZEN", "EARLY", "EIGHT", "FIRST", "FLASH",
		"LATER", "MONTH", "NEVER", "NIGHT", "OFTEN", "ORDER", "PAUSE", "PIECE", "QUICK", "SCORE",
		"SEVEN", "SHORT", "START", "SWIFT", "TALLY", "THIRD", "THREE", "TIMER", "TODAY", "TOTAL",
		"TOTAL", "TWICE", "WATCH", "WHILE", "WHOLE", "ALWAYS", "AUTUMN", "BEFORE", "DOUBLE", "FINISH",
		"FUTURE", "MINUTE", "MOMENT", "NUMBER", "SEASON", "SECOND", "SELDOM", "SINGLE", "SPRING", "STEADY",
		"SUMMER", "TRIPLE", "WINTER", "EVENING", "INSTANT", "MORNING", "NUMERAL", "PRESENT", "TOMORROW", "YESTERDAY",
	],
	# Level 15 - Describing words (adjectives)
	[
		"BIG", "DIM", "DRY", "FAT", "HOT", "ICY", "LOW", "NEW", "OLD", "RAW",
		"WET", "BENT", "CALM", "COLD", "COOL", "DAMP", "DARK", "DEEP", "DULL", "DULL",
		"FAST", "FIRM", "FLAT", "FREE", "FULL", "HARD", "HIGH", "HUGE", "LONG", "LOUD",
		"MILD", "NEAT", "OPEN", "POOR", "RARE", "RICH", "RIPE", "SLIM", "SLOW", "SOFT",
		"SOFT", "SOUR", "TALL", "THIN", "TIDY", "TINY", "WARM", "WEAK", "WIDE", "WILD",
		"BLUNT", "BROAD", "CHEAP", "CLEAN", "DIRTY", "EMPTY", "FRESH", "GIANT", "HARSH", "HEAVY",
		"LIGHT", "LOOSE", "MESSY", "MOIST", "NOISY", "QUICK", "QUIET", "RAPID", "READY", "ROUGH",
		"ROUND", "SALTY", "SHARP", "SHINY", "SHORT", "SMALL", "SOGGY", "SOLID", "STALE", "STILL",
		"SWEET", "SWIFT", "THICK", "TIGHT", "YOUNG", "BITTER", "BRIGHT", "CHILLY", "CLOSED", "COSTLY",
		"CURVED", "HOLLOW", "LITTLE", "MODERN", "NARROW", "SILENT", "SMOOTH", "SQUARE", "STEADY", "STEAMY",
		"STRONG", "SUDDEN", "ANCIENT", "BURNING", "CROOKED", "FRAGILE", "POINTED", "SHALLOW", "FREEZING", "STRAIGHT",
	],
	# Level 16 - Jobs and helpers
	[
		"NUN", "BOSS", "CHEF", "COOK", "HEAD", "IMAM", "KING", "MAID", "MONK", "POET",
		"ACTOR", "ACTOR", "BAKER", "BOXER", "CHIEF", "CLERK", "CLOWN", "COACH", "GUARD", "JUDGE",
		"MASON", "MAYOR", "MINER", "MODEL", "NURSE", "PILOT", "PILOT", "QUEEN", "RABBI", "RACER",
		"RIDER", "SAINT", "TUTOR", "ARTIST", "AUTHOR", "BARBER", "BUTLER", "DANCER", "DOCTOR", "DRIVER",
		"EDITOR", "FARMER", "FISHER", "HERDER", "HUNTER", "LAWYER", "LEADER", "PASTOR", "PLAYER", "POLICE",
		"POTTER", "PRIEST", "PRINCE", "RUNNER", "SAILOR", "SINGER", "TAILOR", "UMPIRE", "WAITER", "WARDEN",
		"WEAVER", "WINNER", "WRITER", "ACROBAT", "ATHLETE", "BUILDER", "CLEANER", "DRUMMER", "JANITOR", "JEWELER",
		"JUGGLER", "MANAGER", "OFFICER", "PAINTER", "PLUMBER", "PRINTER", "PROPHET", "RANCHER", "REFEREE", "SCHOLAR",
		"SOLDIER", "SWIMMER", "TEACHER", "CHAMPION", "COMPOSER", "DESIGNER", "ENGINEER", "GARDENER", "GOVERNOR", "LYRICIST",
		"MAGICIAN", "MECHANIC", "MINISTER", "MUSICIAN", "PRINCESS", "REPORTER", "SCULPTOR", "SHEPHERD", "WRESTLER", "ARCHITECT",
		"CARPENTER", "CONDUCTOR", "PRESIDENT", "SCIENTIST", "SECRETARY", "SHOEMAKER", "JOURNALIST", "SEAMSTRESS", "ELECTRICIAN", "PHOTOGRAPHER",
	],
	# Level 17 - More actions (verbs)
	[
		"ASK", "BAT", "BOW", "CRY", "DIG", "DRY", "FIX", "FLY", "FRY", "HIT",
		"HUG", "HUM", "LAY", "MIX", "NOD", "PAT", "PUT", "ROW", "RUB", "SAY",
		"SET", "SEW", "SOB", "TIE", "WAX", "BAKE", "BOIL", "CALL", "CHAT", "CHOP",
		"CLAP", "DIVE", "DROP", "FEED", "FILL", "FISH", "FOLD", "HANG", "HUNT", "IRON",
		"JUMP", "KICK", "KISS", "KNIT", "KNOT", "LIFT", "MAKE", "MEND", "MILK", "PACK",
		"PEEL", "PICK", "POUR", "PULL", "PUSH", "RIDE", "ROLL", "SAIL", "SIGH", "SING",
		"SKIP", "SORT", "STIR", "SWIM", "TALK", "TELL", "TOSS", "WAVE", "WEEP", "WIPE",
		"WRAP", "BUILD", "CARRY", "CATCH", "CATCH", "CHEER", "CLIMB", "DRIVE", "EMPTY", "FLOAT",
		"GRILL", "KNEEL", "LAUGH", "PAINT", "PLACE", "PLANT", "POINT", "RINSE", "ROAST", "SCRUB",
		"SCRUB", "SHINE", "SHOUT", "SLICE", "SMILE", "SPEAK", "SPILL", "SQUAT", "STACK", "STAND",
		"THROW", "WATER", "WEAVE", "BOUNCE", "POLISH", "REPAIR", "SPLASH", "HARVEST", "WHISPER", "WHISTLE",
	],
	# Level 18 - More describing words
	[
		"DRY", "FAT", "FIT", "SAD", "SHY", "WET", "BOLD", "BUSY", "CALM", "DAMP",
		"DULL", "FAIR", "GLAD", "HARD", "IDLE", "KIND", "LAZY", "NEAT", "POOR", "PURE",
		"RICH", "RIPE", "RUDE", "SLIM", "SOFT", "SOUR", "TAME", "THIN", "TIDY", "UGLY",
		"WEAK", "WILD", "WISE", "ALERT", "ANGRY", "BLAND", "BRAVE", "BRAVE", "CLEAN", "CRISP",
		"CRUEL", "DIRTY", "EAGER", "FANCY", "FRAIL", "FRESH", "FUNNY", "GRAND", "HAPPY", "HARSH",
		"MERRY", "MESSY", "MOIST", "PLAIN", "PLUMP", "PROUD", "ROUGH", "SALTY", "SILLY", "SMART",
		"SOGGY", "SOLID", "SPICY", "STALE", "SWEET", "TASTY", "THICK", "TIMID", "TIMID", "YUCKY",
		"YUMMY", "ACTIVE", "AFRAID", "BITTER", "BRIGHT", "CLEVER", "DROOPY", "DROWSY", "FIERCE", "FLIMSY",
		"GENTLE", "GENTLE", "GLOOMY", "HOLLOW", "HONEST", "HUMBLE", "LIVELY", "MODEST", "POLITE", "PRETTY",
		"ROTTEN", "SICKLY", "SIMPLE", "SKINNY", "STRONG", "STURDY", "UNFAIR", "CAREFUL", "HEALTHY", "PLAYFUL",
		"SERIOUS", "CARELESS", "CAUTIOUS", "CHEERFUL", "FEARLESS", "PEACEFUL", "RECKLESS", "BEAUTIFUL", "DELICIOUS", "RELUCTANT",
	],
	# Level 19 - Everyday words mix
	[
		"BAG", "BOX", "CAR", "CUP", "DOG", "EGG", "HAT", "ICE", "INK", "JAM",
		"JAR", "JUG", "KEY", "LEG", "MAP", "MUG", "NET", "OAR", "OWL", "PEN",
		"PIE", "RAT", "RUG", "SEA", "VAN", "BALL", "BELL", "BOOK", "COIN", "DICE",
		"DISH", "DOLL", "DRUM", "FISH", "FLAG", "GIFT", "GOAT", "HOOK", "HORN", "KITE",
		"LAMP", "NEST", "NEST", "RING", "STAR", "TENT", "TIRE", "TREE", "VASE", "WALL",
		"WIND", "YARD", "YARN", "APPLE", "APRON", "CROWN", "EASEL", "FAIRY", "GLOBE", "IGLOO",
		"LEMON", "OPERA", "ORBIT", "QUILT", "RIVER", "SHELL", "WAGON", "YACHT", "ZEBRA", "ANCHOR",
		"BRIDGE", "CANDLE", "CASTLE", "ENGINE", "FOSSIL", "GARLIC", "GINGER", "HARBOR", "HARBOR", "ICICLE",
		"ISLAND", "JACKET", "JUNGLE", "KITTEN", "KITTEN", "LADDER", "MAGNET", "MARBLE", "MIRROR", "NEEDLE",
		"NICKEL", "PALACE", "PILLOW", "PIRATE", "QUARTZ", "SADDLE", "TUNNEL", "WINDOW", "YELLOW", "ZIGZAG",
		"ZIPPER", "BALLOON", "DIAMOND", "DOLPHIN", "FURNACE", "LANTERN", "OCTOPUS", "UNICORN", "VILLAGE", "UMBRELLA",
	],
	# Level 20 - Final challenge mix
	[
		"ACORN", "AROMA", "BRAIN", "CORAL", "FABLE", "IGLOO", "IVORY", "KAYAK", "KAYAK", "OASIS",
		"OCEAN", "ORBIT", "UMBRA", "XENON", "XENON", "YIELD", "ALPACA", "ARCTIC", "BAMBOO", "BEACON",
		"CACTUS", "CANYON", "DESERT", "DESERT", "DOMAIN", "DRAGON", "EMBLEM", "EMBLEM", "ENIGMA", "FALCON",
		"FALCON", "FOSSIL", "GADGET", "GALAXY", "GARDEN", "GARNET", "HARBOR", "HIDDEN", "ICICLE", "IGUANA",
		"ISLAND", "JIGSAW", "JUNGLE", "KERNEL", "LAGOON", "LAGOON", "LIZARD", "METEOR", "MIRAGE", "NEBULA",
		"NECTAR", "NECTAR", "NICKEL", "PIRATE", "QUARTZ", "QUARTZ", "QUIVER", "QUIVER", "RADIUS", "RADIUS",
		"REFUGE", "TUNDRA", "TUNDRA", "UNISON", "VACUUM", "VALLEY", "VOYAGE", "WALNUT", "WALNUT", "YELLOW",
		"YOGURT", "ZENITH", "ZEPHYR", "ZIGZAG", "ZODIAC", "BOULDER", "CHIMNEY", "CRYSTAL", "DOLPHIN", "ECLIPSE",
		"EMERALD", "FIREFLY", "GLACIER", "HARMONY", "HARVEST", "HORIZON", "JASMINE", "JOURNEY", "LANTERN", "MAGENTA",
		"MAMMOTH", "OCTAGON", "PRAIRIE", "PRAIRIE", "PYRAMID", "RAINBOW", "SAVANNA", "STADIUM", "TEMPEST", "TORNADO",
		"UNICORN", "UTENSIL", "VOLCANO", "WHISKER", "WHISPER", "BLIZZARD", "KANGAROO", "SAPPHIRE", "SATELLITE", "XYLOPHONE",
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

## Tam Türkçe anlam sözlükleri (2000 kelimenin tamamı, doğru Türkçe karakterlerle).
const _M1 := preload("res://data/meanings_1.gd")
const _M2 := preload("res://data/meanings_2.gd")
const _M3 := preload("res://data/meanings_3.gd")
const _M4 := preload("res://data/meanings_4.gd")


static func _lookup_full(w: String) -> String:
	if _M1.WORDS.has(w):
		return str(_M1.WORDS[w])
	if _M2.WORDS.has(w):
		return str(_M2.WORDS[w])
	if _M3.WORDS.has(w):
		return str(_M3.WORDS[w])
	if _M4.WORDS.has(w):
		return str(_M4.WORDS[w])
	return ""


## Kelimenin gerçek (kategori değil) bir Türkçe anlamı var mı?
static func has_real_meaning(word: String) -> bool:
	var w := word.to_upper()
	return _lookup_full(w) != "" or MEANINGS.has(w) or ANIMAL_MEANINGS.has(w) or PROFESSION_MEANINGS.has(w)


## Kelimenin ait olduğu seviye (1 tabanlı); bilinmiyorsa 0.
static func get_level_of(word: String) -> int:
	_ensure_built()
	return int(_level_of.get(word.to_upper(), 0))


## Seviyenin Türkçe tema adı.
static func get_level_title(level: int) -> String:
	var idx := level - 1
	if idx >= 0 and idx < LEVEL_TITLES.size():
		return LEVEL_TITLES[idx]
	return "Kelimeler"

const LEVEL_TITLES := [
	"Hayvanlar", "Renkler ve Vücut", "Yiyecekler", "Evimiz", "Oyun Zamanı",
	"Okul", "Doğa ve Hava", "Hareketler", "Giysiler", "Yerler",
	"Taşıtlar", "İnsanlar ve Aile", "Duygular", "Sayılar ve Zaman", "Sıfatlar",
	"Meslekler", "Hareketler 2", "Sıfatlar 2", "Nesneler", "Karışık",
]


static func get_meaning(word: String) -> String:
	var w := word.to_upper()
	var full := _lookup_full(w)
	if full != "":
		return full
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


## One representative icon per level theme, so every word gets a picture
## that matches its category instead of a plain letter badge. Professions
## resolve from the shared lookup first since they appear across several
## levels (COOK, PILOT, NURSE, ...), not only the dedicated jobs level.
const LEVEL_ILLUSTRATION_KINDS := [
	"animal", "body", "food", "furniture", "toy",
	"school", "nature", "action", "clothes", "place",
	"vehicle", "person", "feeling", "time", "adjective",
	"profession", "action", "adjective", "object", "object",
]

static func get_illustration_kind(word: String) -> String:
	var w := word.to_upper()
	_ensure_built()
	if PROFESSION_MEANINGS.has(w):
		return "profession"
	if _level_of.has(w):
		var level_index: int = _level_of[w] - 1
		if level_index >= 0 and level_index < LEVEL_ILLUSTRATION_KINDS.size():
			return LEVEL_ILLUSTRATION_KINDS[level_index]
	return "object"
