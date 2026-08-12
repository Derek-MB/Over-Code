extends Node2D

@onready var menu_panel: Control = $CanvasLayer/MenuPanel
@onready var jugador: CharacterBody2D = $jugador

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    for node in get_children():
        if node != $CanvasLayer:
            node.process_mode = Node.PROCESS_MODE_PAUSABLE
    menu_panel.hide()
    if Global.level_return_scene == scene_file_path and Global.level_resume_position != Vector2.INF:
        jugador.global_position = Global.level_resume_position
    Global.level_return_scene = ""
    Global.level_resume_position = Vector2.INF

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_BACKSPACE:
        alternar_menu()
        get_viewport().set_input_as_handled()

func alternar_menu() -> void:
    var abierto := not menu_panel.visible
    menu_panel.visible = abierto
    get_tree().paused = abierto

func cerrar_menu() -> void:
    menu_panel.hide()
    get_tree().paused = false

func _on_menu_hamburguesa_pressed() -> void:
    alternar_menu()

func _on_reiniciar_nivel_pressed() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()

func _on_asistencia_pressed() -> void:
    _guardar_retorno()
    get_tree().paused = false
    TransitionManager.cambiar_escena("res://Scenes/ChatBot.tscn")

func _on_opciones_pressed() -> void:
    _guardar_retorno()
    get_tree().paused = false
    Global.opciones_return_scene = scene_file_path
    TransitionManager.cambiar_escena("res://Scenes/opciones.tscn")

func _on_salir_del_nivel_pressed() -> void:
    get_tree().paused = false
    TransitionManager.cambiar_escena("res://Scenes/mapa.tscn")

func _guardar_retorno() -> void:
    Global.level_return_scene = scene_file_path
    Global.level_resume_position = jugador.global_position
