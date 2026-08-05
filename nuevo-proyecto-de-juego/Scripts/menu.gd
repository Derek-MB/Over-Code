extends Control



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
