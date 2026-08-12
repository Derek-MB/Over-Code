extends Control

const DURACION_PRIMER_LOGO := 3.0
const DURACION_TRANSICION := 1.8
const DURACION_SEGUNDO_LOGO := 3.0
const DURACION_FADE_FINAL := 0.8

@onready var logo_inicial: TextureRect = $DoVak
@onready var logo_pixelado: TextureRect = $DoVakPixel
@onready var fade: ColorRect = $Fade


func _ready() -> void:
    reproducir_introduccion()


func reproducir_introduccion() -> void:

    # --------------------------------------------------
    # ESTADO INICIAL
    # --------------------------------------------------

    logo_inicial.visible = true
    logo_pixelado.visible = false

    # El fade está completamente transparente.
    fade.modulate.a = 0.0

    # Obtener el material del shader.
    var shader_material := logo_inicial.material as ShaderMaterial

    if shader_material:
        shader_material.set_shader_parameter("progress", 0.0)


    # --------------------------------------------------
    # MOSTRAR LOGO ORIGINAL
    # --------------------------------------------------

    await get_tree().create_timer(DURACION_PRIMER_LOGO).timeout


    # --------------------------------------------------
    # TRANSICIÓN PIXELADA
    # --------------------------------------------------

    var transicion := create_tween()

    transicion.set_trans(Tween.TRANS_QUAD)
    transicion.set_ease(Tween.EASE_IN_OUT)

    transicion.tween_method(
        func(valor: float):
            if shader_material:
                shader_material.set_shader_parameter("progress", valor),
        0.0,
        1.0,
        DURACION_TRANSICION
    )

    await transicion.finished


    # --------------------------------------------------
    # MOSTRAR LOGO PIXELADO FINAL
    # --------------------------------------------------

    logo_inicial.visible = false
    logo_pixelado.visible = true
    
    fade.modulate.a = 0.0
    logo_pixelado.modulate.a = 1.0
    logo_pixelado.self_modulate.a = 1.0


    # --------------------------------------------------
    # MANTENER LOGO PIXELADO
    # --------------------------------------------------

    await get_tree().create_timer(DURACION_SEGUNDO_LOGO).timeout


    # --------------------------------------------------
    # FADE A NEGRO
    # --------------------------------------------------

    var fade_final := create_tween()

    fade_final.set_trans(Tween.TRANS_QUAD)
    fade_final.set_ease(Tween.EASE_IN_OUT)

    fade_final.tween_property(
        fade,
        "modulate:a",
        1.0,
        DURACION_FADE_FINAL
    )

    await fade_final.finished


    # --------------------------------------------------
    # CAMBIAR AL MENÚ
    # --------------------------------------------------

    get_tree().change_scene_to_file("res://Scenes/menu.tscn")
