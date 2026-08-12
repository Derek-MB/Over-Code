extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var label = $SpeechBubble/Label
@onready var bubble = $SpeechBubble
@onready var animation_player = $AnimationPlayer

# =========================================================
# ETAPA ACTUAL DEL ROBOT
# =========================================================
# 0 = punto inicial
# 1 = llegó al punto 1
# 2 = llegó al punto 2
# 3 = llegó al punto 3
# 4 = llegó al punto 4

var etapa := 0

# Evita que el diálogo se active varias veces
var hablando := false

# Permite cancelar correctamente los diálogos
# cuando el nivel está siendo cerrado.
var cancelado := false

const NORMAL_SPRITE_SCALE = Vector2(1.0, 1.075)
const FLY_SPRITE_SCALE = Vector2(1.5, 1.6125)


func _ready() -> void:
    bubble.visible = false
    sprite.scale = NORMAL_SPRITE_SCALE

    # Si la escena empieza a salir del árbol,
    # cancelamos cualquier diálogo pendiente.
    tree_exiting.connect(_al_salir_de_escena)


# =========================================================
# CUANDO EL ROBOT SALE DE LA ESCENA
# =========================================================

func _al_salir_de_escena() -> void:
    cancelado = true
    hablando = false


# =========================================================
# COMPROBAR SI EL ROBOT PUEDE CONTINUAR
# =========================================================

func puede_continuar() -> bool:
    return is_inside_tree() and not cancelado


# =========================================================
# ESPERAR DE FORMA SEGURA
# =========================================================

func esperar(segundos: float) -> bool:

    if not puede_continuar():
        return false

    await get_tree().create_timer(segundos).timeout

    if not puede_continuar():
        return false

    return true


# =========================================================
# ANIMACIONES DEL ROBOT
# =========================================================

func reproducir_animacion(nombre: String) -> void:

    if not puede_continuar():
        return

    if nombre == "fly":
        sprite.scale = FLY_SPRITE_SCALE
    else:
        sprite.scale = NORMAL_SPRITE_SCALE

    if sprite.sprite_frames != null:
        if sprite.sprite_frames.has_animation(nombre):
            sprite.play(nombre)


# =========================================================
# CUANDO EL JUGADOR ENTRA EN EL AREA DEL ROBOT
# =========================================================

func _on_area_2d_body_entered(body) -> void:

    if not puede_continuar():
        return

    if body.name != "jugador":
        return

    if hablando:
        return

    match etapa:

        0:
            iniciar_tutorial_1()

        1:
            iniciar_tutorial_2()

        2:
            iniciar_tutorial_3()

        3:
            iniciar_tutorial_4()

        4:
            iniciar_tutorial_final()


# =========================================================
# PRIMER ENCUENTRO
# =========================================================

func iniciar_tutorial_1() -> void:

    hablando = true
    bubble.visible = true

    reproducir_animacion("talk")

    await escribir_texto("Hola! vine para ayudarte!")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Usa A y D para moverte")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Presiona SPACE para saltar")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("¡Ven Sigue adelante!")

    if not puede_continuar():
        return

    if not await esperar(1.5):
        return

    bubble.visible = false

    etapa = 1

    await volar_a_punto("volar_punto_1")

    hablando = false


# =========================================================
# SEGUNDO ENCUENTRO
# =========================================================

func iniciar_tutorial_2() -> void:

    hablando = true
    bubble.visible = true

    reproducir_animacion("talk")

    await escribir_texto("Vez esos bloques?")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Tomalos con la tecla E")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Reunelos todos y sigueme!")

    if not puede_continuar():
        return

    if not await esperar(1.5):
        return

    bubble.visible = false

    etapa = 2

    await volar_a_punto("volar_punto_2")

    hablando = false


# =========================================================
# TERCER ENCUENTRO
# =========================================================

func iniciar_tutorial_3() -> void:

    hablando = true
    bubble.visible = true

    reproducir_animacion("talk")

    await escribir_texto("Vez eso grande de alli?")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Eso es CODIGO DAÑADO")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Debemos restaurarlo")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Y para eso son los bloques!")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    bubble.visible = false

    etapa = 3

    await volar_a_punto("volar_punto_3")

    hablando = false


# =========================================================
# CUARTO ENCUENTRO
# =========================================================

func iniciar_tutorial_4() -> void:

    hablando = true
    bubble.visible = true

    reproducir_animacion("talk")

    await escribir_texto("Colocalos en ese espacio")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Eso es una hoja de codigo!")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Ordenarlos bien!")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Los bloques son...")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Archivos dañados!")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Ordenalo bien para restaurarlo!")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Cuando lo logres...")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("La barrera se esfumara!")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Te voy a esperar del otro lado!")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto(" :D")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    bubble.visible = false

    etapa = 4

    await volar_a_punto("volar_punto_4")

    hablando = false


# =========================================================
# ÚLTIMO ENCUENTRO
# =========================================================

func iniciar_tutorial_final() -> void:

    hablando = true
    bubble.visible = true

    reproducir_animacion("talk")

    await escribir_texto("¡FELICIDADES LO LOGRASTE!!!")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Ahora ve a la cueva, al final")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Y sal al escritorio!")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Recuerda, estamos en la PC")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Por culpa de Migotes USSH")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    await escribir_texto("Vamos a restaurar todos los archivos!!")

    if not puede_continuar():
        return

    if not await esperar(2.0):
        return

    bubble.visible = false

    reproducir_animacion("idle")

    hablando = false


# =========================================================
# ESCRIBIR TEXTO LETRA POR LETRA
# =========================================================

func escribir_texto(texto: String) -> bool:

    if not puede_continuar():
        return false

    label.text = ""

    for letra in texto:

        if not puede_continuar():
            return false

        label.text += letra

        if not await esperar(0.03):
            return false

    return true


# =========================================================
# MOVIMIENTO CON ANIMATIONPLAYER
# =========================================================

func volar_a_punto(nombre_animacion: String) -> void:

    if not puede_continuar():
        return

    # Cambiamos al sprite de vuelo
    reproducir_animacion("fly")

    # Comprobamos que AnimationPlayer exista
    if animation_player == null:
        reproducir_animacion("idle")
        return

    # Comprobamos que exista la animación
    if not animation_player.has_animation(nombre_animacion):
        reproducir_animacion("idle")
        return

    # Reproducimos la animación creada manualmente
    animation_player.play(nombre_animacion)

    # Esperamos a que termine
    await animation_player.animation_finished

    if not puede_continuar():
        return

    # Cuando llega al destino, vuelve a estar quieto
    reproducir_animacion("idle")
