extends Area2D

@export var nivel_id := 1
@export var progreso_al_completar := 1
var jugador_en_rango := false
var completando := false

@onready var aviso: Label = $Label

func _ready() -> void:
    aviso.hide()

func _on_body_entered(body: Node2D) -> void:
    if body.name == "jugador":
        jugador_en_rango = true
        aviso.show()

func _on_body_exited(body: Node2D) -> void:
    if body.name == "jugador":
        jugador_en_rango = false
        aviso.hide()

func _unhandled_input(event: InputEvent) -> void:
    if jugador_en_rango and not completando and event.is_action_pressed("ui_accept"):
        completar_nivel()
        get_viewport().set_input_as_handled()

func completar_nivel() -> void:
    completando = true
    var progreso_actual := int(SaveManager.current_slot_data.get("progreso", 0))
    SaveManager.current_slot_data["progreso"] = max(progreso_actual, progreso_al_completar)
    SaveManager.current_slot_data["nivel_%d_completado" % nivel_id] = true
    if nivel_id < 5:
        SaveManager.current_slot_data["puente_%d_desbloqueado" % nivel_id] = true
    SaveManager.save_slot(SaveManager.current_slot)
    TransitionManager.cambiar_escena("res://Scenes/mapa.tscn")
