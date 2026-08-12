extends Control

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
        TransitionManager.cambiar_escena("res://Scenes/menu.tscn")
        get_viewport().set_input_as_handled()


func _on_regresar_pressed() -> void:
    TransitionManager.cambiar_escena("res://Scenes/menu.tscn")
