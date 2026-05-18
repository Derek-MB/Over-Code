extends Control

var escenas = [
    {
        "imagen": preload("res://Sprites/Cinematica1.png"),
        "texto": "Un dia recibes un mensaje urgente del cientifico"
    },
    
    {
        "imagen": preload("res://Sprites/Sprite-000montañas2.png"),
        "texto": "Por lo que decides salir deprisa para ayudarlo"
    },
    
    {
        "imagen": preload("res://Sprites/Sprite-0002- Titulo 2 OVER CODE-Recovered-2.png"),
        "texto": "Al llegar, lo ves junto a una computadora"
    }
]

var indice = 0
var escribiendo = false

@onready var imagen = $Fondo
@onready var texto = $Label

func _ready():
    actualizar_cinematica()

func actualizar_cinematica():

    imagen.texture = escenas[indice]["imagen"]

    mostrar_texto(escenas[indice]["texto"])

func mostrar_texto(nuevo_texto):

    escribiendo = true

    texto.text = nuevo_texto
    texto.visible_characters = 0

    for i in texto.text.length():

        texto.visible_characters += 1

        await get_tree().create_timer(0.03).timeout

    escribiendo = false

func _input(event):

    if event.is_pressed() and event is InputEventKey:

        # completar instantaneamente
        if escribiendo:

            texto.visible_characters = texto.text.length()
            escribiendo = false
            return

        # siguiente escena
        indice += 1

        if indice >= escenas.size():

            terminar_intro()

        else:

            actualizar_cinematica()

func terminar_intro():
    TransitionManager.cambiar_escena("res://Scenes/mapa.tscn")
