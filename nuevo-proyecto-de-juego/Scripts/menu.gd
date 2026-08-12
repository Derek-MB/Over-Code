extends Control

const CORREO_CERRADO = preload("res://Assets/Art/Interface/Correo.png")
const CORREO_ABIERTO = preload("res://Assets/Art/Interface/Correo_abierto.png")

@onready var boton_cerrar_sesion: Button = $CerrarSesion
@onready var panel_confirmacion: Control = $PanelConfirmacion
@onready var fade: ColorRect = $Fade


func _ready() -> void:
    reproducir_fade_entrada()


func reproducir_fade_entrada() -> void:
    var tween := create_tween()

    tween.set_trans(Tween.TRANS_CUBIC)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(
        fade,
        "modulate:a",
        0.0,
        1000
    )


func _on_jugar_pressed() -> void:
    if Supabase.is_signed_in():
        TransitionManager.cambiar_escena("res://Scenes/jugar.tscn")
    else:
        TransitionManager.cambiar_escena("res://Scenes/login.tscn")


func _on_opciones_pressed() -> void:
    Global.opciones_return_scene = "res://Scenes/menu.tscn"
    TransitionManager.cambiar_escena("res://Scenes/opciones.tscn")


func _on_salir_pressed() -> void:
    get_tree().quit()


func _on_cerrar_sesion_pressed() -> void:
    panel_confirmacion.show()


func _on_si_pressed() -> void:
    var logout_result := await Supabase.sign_out()

    if not logout_result.get("ok", false):
        push_warning(
            "No se pudo cerrar la sesión remota: "
            + str(logout_result.get("message", ""))
        )

    TransitionManager.cambiar_escena("res://Scenes/login.tscn")


func _on_cerrar_sesion_mouse_entered() -> void:
    boton_cerrar_sesion.icon = CORREO_ABIERTO


func _on_cerrar_sesion_mouse_exited() -> void:
    boton_cerrar_sesion.icon = CORREO_CERRADO


func _on_no_pressed() -> void:
    panel_confirmacion.hide()
