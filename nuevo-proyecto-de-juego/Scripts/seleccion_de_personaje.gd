extends Control

func _ready():
    # Conectar clicks
    $CenterContainer/HBoxContainer/Boy.gui_input.connect(_on_boy_clicked)
    $CenterContainer/HBoxContainer/Girl.gui_input.connect(_on_girl_clicked)


func _on_boy_clicked(event):
    if event is InputEventMouseButton and event.pressed:
        seleccionar_personaje("boy")
    Global.player_character = "boy"



func _on_girl_clicked(event):
    if event is InputEventMouseButton and event.pressed:
        seleccionar_personaje("girl")
    Global.player_character = "girl"
    get_tree().change_scene_to_file("res://mapa.tscn")


func seleccionar_personaje(tipo):

    # GUARDAR PERSONAJE EN PLAYERDATA
    PlayerData.selected_character = tipo

    # Guardar elección
    SaveManager.current_slot_data["personaje"] = tipo
    SaveManager.current_slot_data["nuevo"] = false

    SaveManager.save_slot(SaveManager.current_slot)

    # Cambiar escena
    TransitionManager.cambiar_escena("res://Scenes/customizacion.tscn")
    #wasaaaabiii
