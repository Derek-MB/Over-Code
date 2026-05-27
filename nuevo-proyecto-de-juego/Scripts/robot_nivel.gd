extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var label = $SpeechBubble/Label
@onready var bubble = $SpeechBubble

var activated = false


func _ready():

    bubble.visible = false


func _on_area_2d_body_entered(body):

    if body.name == "jugador" and not activated:

        activated = true

        iniciar_tutorial()


func iniciar_tutorial():

    bubble.visible = true

    sprite.play("talk")

    await escribir_texto("Usa A y D para moverte")

    await get_tree().create_timer(2.0).timeout

    await escribir_texto("Presiona SPACE para saltar")

    mover_robot()

    await get_tree().create_timer(2.0).timeout

    await escribir_texto("¡Sigue adelante!")

    await get_tree().create_timer(2.0).timeout

    bubble.visible = false

    sprite.play("idle")


func escribir_texto(texto):

    label.text = ""

    for letra in texto:

        label.text += letra

        await get_tree().create_timer(0.03).timeout


func mover_robot():

    # CAMBIAR A SPRITE VOLANDO
    sprite.play("fly")

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

    sprite.play("talk")
