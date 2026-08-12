extends Control

const CINEMATICA_CHICO = preload("res://Assets/Art/Cinematics/player_boy.png")
const CINEMATICA_CHICA = preload("res://Assets/Art/Cinematics/player_girl.png")

var escenas = [
    {
        "imagen": preload("res://Assets/Art/Cinematics/intro_message.png"),
        "texto": "Un día recibes un mensaje urgente del científico, tu maestro, diciendo que debes ir al laboratorio! "
    },
    {
        "imagen": CINEMATICA_CHICO,
        "texto": "Por lo que te preparas y decides salir deprisa para ayudarlo"
    },
    {
        "imagen": preload("res://Assets/Art/Cinematics/Sprite-0001-100tifiko con Bigotes (cinematica).png"),
        "texto": "Al llegar,vez a Migotes, su gato, tocando las teclas de la computadora, lo que ocaciona un error en la maquina"
    }
]

var indice = 0
var escribiendo = false
var escritura_id = 0
var terminando_intro = false

@onready var imagen = $Fondo
@onready var texto = $Label
@onready var prompt: Label = $Prompt


func _ready():
    # La segunda escena muestra el personaje que el jugador eligió.
    if Global.player_character == "girl":
        escenas[1]["imagen"] = CINEMATICA_CHICA
    else:
        escenas[1]["imagen"] = CINEMATICA_CHICO

    actualizar_cinematica()
    crear_parpadeo()


func actualizar_cinematica():
    imagen.texture = escenas[indice]["imagen"]
    mostrar_texto(escenas[indice]["texto"])


func crear_parpadeo() -> void:
    var tween := create_tween().set_loops()
    tween.tween_property(prompt, "modulate:a", 0.28, 1.0)
    tween.tween_property(prompt, "modulate:a", 1.0, 1.0)


func mostrar_texto(nuevo_texto):
    escritura_id += 1
    var escritura_actual = escritura_id
    escribiendo = true
    texto.text = nuevo_texto
    texto.visible_characters = 0

    for i in texto.text.length():
        texto.visible_characters += 1

        if not is_inside_tree() or escritura_actual != escritura_id or not escribiendo:
            return

        var tree = get_tree()
        if tree == null:
            return

        await tree.create_timer(0.03).timeout

        if not is_inside_tree() or escritura_actual != escritura_id:
            return

    escribiendo = false


func _input(event):
    if terminando_intro:
        return

    if event.is_pressed() and event is InputEventKey:
        # Completar el texto instantáneamente.
        if escribiendo:
            texto.visible_characters = texto.text.length()
            escribiendo = false
            escritura_id += 1
            return

        indice += 1
        if indice >= escenas.size():
            terminar_intro()
        else:
            actualizar_cinematica()


func terminar_intro():
    if terminando_intro:
        return

    terminando_intro = true
    escritura_id += 1
    TransitionManager.cambiar_escena("res://Scenes/mapa.tscn")
