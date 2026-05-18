extends Control



func _on_jugar_pressed() -> void:
    TransitionManager.cambiar_escena("res://Scenes/jugar.tscn")

func _on_opciones_pressed() -> void:
    TransitionManager.cambiar_escena("res://Scenes/opciones.tscn")


func _on_salir_pressed() -> void:
    get_tree().quit()
