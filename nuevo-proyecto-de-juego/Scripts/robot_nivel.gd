extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var label = $SpeechBubble/Label
@onready var bubble = $SpeechBubble

var activated = false

const NORMAL_SPRITE_SCALE = Vector2(1.0, 1.075)
const FLY_SPRITE_SCALE = Vector2(1.5, 1.6125)

func _ready():

    bubble.visible = false
    sprite.scale = NORMAL_SPRITE_SCALE


func reproducir_animacion(nombre: String):

    sprite.scale = FLY_SPRITE_SCALE if nombre == "fly" else NORMAL_SPRITE_SCALE
    sprite.play(nombre)


func _on_area_2d_body_entered(body):

    if body.name == "jugador" and not activated:

        activated = true

        iniciar_tutorial()


func iniciar_tutorial():

    bubble.visible = true

    reproducir_animacion("talk")

    await escribir_texto("Usa A y D para moverte")

    await get_tree().create_timer(2.0).timeout

    await escribir_texto("Presiona SPACE para saltar")

    mover_robot()

    await get_tree().create_timer(2.0).timeout

    await escribir_texto("¡Sigue adelante!")

    await get_tree().create_timer(2.0).timeout

    bubble.visible = false

    reproducir_animacion("idle")


func escribir_texto(texto):

    label.text = ""

    for letra in texto:

        label.text += letra

        await get_tree().create_timer(0.03).timeout


func mover_robot():

    # CAMBIAR A SPRITE VOLANDO
    reproducir_animacion("fly")

    var tween = create_tween()

    tween.tween_property(
        self,
        "position:x",
        position.x + 150,
        2.0
    )

    tween.parallel().tween_property(
        self,
        "position:y",
        position.y - 50,
        2.0
    )

    await tween.finished

    reproducir_animacion("talk")
