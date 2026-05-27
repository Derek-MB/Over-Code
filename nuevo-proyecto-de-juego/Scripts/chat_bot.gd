extends Control

@onready var robot = $Robot
@onready var output = $RichTextLabel
@onready var input = $LineEdit
@onready var timer = $Timer

var knowledge = {}

var talking = false

var idle_texture = preload("res://Sprites/Cabeza robot1.png")
var talk_texture = preload("res://Sprites/Cabeza robot2.png")

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
	"dime"
]

func _ready():

    load_knowledge()

    robot.texture = idle_texture

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

    if question == "":
        return

    var cleaned_words = clean_text(question)

    var cleaned_question = ""

    for word in cleaned_words:
        cleaned_question += word + " "

    cleaned_question = cleaned_question.strip_edges()

    var found = false

    # búsqueda más inteligente
    for key in knowledge.keys():

        if key in cleaned_question:

            found = true

            var info = knowledge[key]

            var response = ""

            response += info["description"] + "\n\n"

            response += "Ejemplo:\n"
            response += info["example"] + "\n\n"

            response += "Consejo:\n"
            response += info["tips"]

            await type_text(response)

            break

    if not found:

        await type_text(
			"Lo siento.\n\nSolo puedo responder preguntas relacionadas con programación, HTML, CSS, JavaScript y Python."
        )

    input.text = ""

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
