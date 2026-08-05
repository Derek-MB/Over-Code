extends Control

@onready var robot = $Robot
@onready var output = $RichTextLabel
@onready var input = $LineEdit
@onready var timer = $Timer

var knowledge = {}

var talking = false

var idle_texture = preload("res://Assets/Art/Characters/Robot/robot_head_idle.png")
var talk_texture = preload("res://Assets/Art/Characters/Robot/robot_head_talk.png")

var stopwords = [
    "que",
    "como",
    "el",
    "la",
    "de",
    "por",
    "para",
    "un",
    "una",
    "es",
    "y",
    "o",
    "me",
    "puedes",
    "explicar",
    "decir",
    "sobre",
    "cual",
    "cuál",
    "son",
    "las",
    "los",
    "del",
    "al",
    "se",
    "usa",
    "usar",
    "sirve",
    "hacer",
    "con",
    "en",
    "quiero",
    "necesito",
    "ayuda",
    "dime",
    "explicame",
    "dame",
    "informacion",
    "info",
    "tema",
    "temas"
]

func get_topic_aliases(key, info):

    var aliases = [key]

    if typeof(info) == TYPE_DICTIONARY and info.has("aliases"):

        for alias in info["aliases"]:
            aliases.append(str(alias))

    return aliases

func question_matches_topic(cleaned_question, cleaned_words, key, info):

    for alias in get_topic_aliases(key, info):

        var alias_words = clean_text(alias)

        if alias_words.is_empty():
            continue

        if alias_words.size() == 1:

            if alias_words[0] in cleaned_words:
                return true

        else:

            var alias_phrase = " ".join(alias_words)

            if alias_phrase in cleaned_question:
                return true

    return false

func get_topic_match_score(cleaned_question, cleaned_words, key, info):

    var best_score = -1

    for alias in get_topic_aliases(key, info):

        var alias_words = clean_text(alias)

        if alias_words.is_empty():
            continue

        if alias_words.size() == 1:

            var word_position = cleaned_words.find(alias_words[0])

            if word_position != -1:
                var word_score = 10 - min(word_position, 9)
                best_score = max(best_score, word_score)

        else:

            var alias_phrase = " ".join(alias_words)
            var phrase_position = cleaned_question.find(alias_phrase)

            if phrase_position != -1:
                var phrase_score = alias_words.size() * 10
                best_score = max(best_score, phrase_score)

    return best_score

func _ready():

    load_knowledge()

    robot.texture = idle_texture

    input.text_submitted.connect(_on_line_edit_text_submitted)

func load_knowledge():

    var file = FileAccess.open("res://Data/Knowledge.json", FileAccess.READ)

    if file:

        var text = file.get_as_text()

        knowledge = JSON.parse_string(text)

    else:

        print("No se pudo cargar Knowledge.json")

func clean_text(text):

    text = text.to_lower()

    # quitar acentos
    text = text.replace("á", "a")
    text = text.replace("é", "e")
    text = text.replace("í", "i")
    text = text.replace("ó", "o")
    text = text.replace("ú", "u")

    # quitar caracteres especiales
    var specials = [
        ".", ",", ";", ":", "¿", "?", "¡", "!",
        "(", ")", "[", "]", "{", "}",
        "\"", "'", "-", "_", "/", "\\",
        "*", "+", "="
    ]

    for special_char in specials:
        text = text.replace(special_char, "")

    var words = text.split(" ")

    var filtered = []

    for word in words:

        word = word.strip_edges()

        if word != "" and word not in stopwords:
            filtered.append(word)

    return filtered

func _on_button_pressed():

    var question = input.text

    if question == "" or talking:
        return

    var cleaned_words = clean_text(question)

    var cleaned_question = ""

    for word in cleaned_words:
        cleaned_question += word + " "

    cleaned_question = cleaned_question.strip_edges()

    var best_info = {}
    var best_score = -1

    # búsqueda más inteligente
    for key in knowledge.keys():

        var info = knowledge[key]

        var score = get_topic_match_score(cleaned_question, cleaned_words, key, info)

        if score > best_score:
            best_score = score
            best_info = info

    if best_score != -1:

        var response = ""

        response += best_info["description"] + "\n\n"

        response += "Ejemplo:\n"
        response += best_info["example"] + "\n\n"

        response += "Consejo:\n"
        response += best_info["tips"]

        await type_text(response)

    else:

        await type_text(
			"Lo siento.\n\nSolo puedo responder preguntas relacionadas con programación, HTML, CSS, JavaScript y Python."
        )

    input.text = ""

func _on_line_edit_text_submitted(_new_text):

    await _on_button_pressed()

func type_text(text):

    output.text = ""

    start_talking()

    for letter in text:

        output.text += letter

        await get_tree().create_timer(0.02).timeout

    stop_talking()

func start_talking():

    talking = true

    timer.start()

func stop_talking():

    talking = false

    timer.stop()

    robot.texture = idle_texture

func _on_timer_timeout():

    if talking:

        if robot.texture == idle_texture:
            robot.texture = talk_texture
        else:
            robot.texture = idle_texture


func _on_button_2_pressed() -> void:
    TransitionManager.cambiar_escena("res://Scenes/mapa.tscn")
