extends Control

@onready var preview = $TextureRect
@onready var input_nombre = $LineEdit

var nombre_temporal = ""


func _ready():
    var personaje = SaveManager.current_slot_data["personaje"]
    
    if personaje == "boy":
        preview.texture = preload("res://Assets/Art/Characters/boy.png")
    elif personaje == "girl":
        preview.texture = preload("res://Assets/Art/Characters/girl.png")


func _on_confirmar_pressed():
    var nombre = input_nombre.text.strip_edges()
    
    if nombre == "":
        return
    
    nombre_temporal = nombre
    
    # Cambiar texto del panel
    $PanelConfirmacion/Label.text = nombre + " ¿así esta bien?"
    
    $PanelConfirmacion.show()


func _on_si_pressed():
    SaveManager.current_slot_data["nombre"] = nombre_temporal
    SaveManager.current_slot_data["nuevo"] = false
    
    SaveManager.save_slot(SaveManager.current_slot)
    # Desde la personalización, la introducción retoma el flujo original: mapa.
    Global.cinematic_return_scene = "res://Scenes/mapa.tscn"
    TransitionManager.cambiar_escena("res://Scenes/cinematicas.tscn")


func _on_no_pressed():
    $PanelConfirmacion.hide()
