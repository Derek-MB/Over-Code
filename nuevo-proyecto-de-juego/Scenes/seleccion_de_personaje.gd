extends Control

func _ready():
	# Conectar clicks (por si no usas señales desde el editor)
	$CenterContainer/HBoxContainer/Boy.gui_input.connect(_on_boy_clicked)
	$CenterContainer/HBoxContainer/Girl.gui_input.connect(_on_girl_clicked)


func _on_boy_clicked(event):
	if event is InputEventMouseButton and event.pressed:
		seleccionar_personaje("boy")


func _on_girl_clicked(event):
	if event is InputEventMouseButton and event.pressed:
		seleccionar_personaje("girl")


func seleccionar_personaje(tipo):
	# Guardar elección
	SaveManager.current_slot_data["personaje"] = tipo
	SaveManager.current_slot_data["nuevo"] = false
	SaveManager.save_slot(SaveManager.current_slot)

	# Cambiar a siguiente escena
	TransitionManager.cambiar_escena("res://Scenes/customizacion.tscn")
#wasabiiiii
