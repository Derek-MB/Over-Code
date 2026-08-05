extends Node2D

@onready var menu_panel = $Control/MenuPanel
@onready var menu_info = $Control/MenuPanel/InfoLabel
@onready var mapa_animado: AnimatedSprite2D = $Mapa
@onready var mapa_partes_animado: AnimatedSprite2D = $"mapa partes"
@onready var pilares_animado: AnimatedSprite2D = $Pilares/Visual
@onready var objetos_niveles_animado: AnimatedSprite2D = $ObjetosNiveles/Visual
@onready var arbol_animado: AnimatedSprite2D = $Arbol/Visual
@onready var jugador_mapa: CharacterBody2D = $CharacterBody2D
@onready var pilares_capa: Node2D = $Pilares
@onready var objetos_niveles_capa: Node2D = $ObjetosNiveles
@onready var arbol_capa: Node2D = $Arbol

func _ready() -> void:
    menu_panel.hide()

    # El jugador se mantiene entre las capas de fondo (0) y primer plano (2).
    jugador_mapa.z_index = 1

    # Mapa es la animación principal. La segunda capa se actualiza abajo
    # con el mismo frame para evitar que sus tiles se desfasen.
    mapa_animado.play(&"new_animation")
    mapa_animado.frame = 0
    mapa_animado.frame_progress = 0.0

    mapa_partes_animado.play(&"default")
    mapa_partes_animado.pause()
    mapa_partes_animado.frame = 0
    mapa_partes_animado.frame_progress = 0.0

    for capa in [pilares_animado, objetos_niveles_animado, arbol_animado]:
        capa.play(&"default")
        capa.pause()
        capa.frame = 0
        capa.frame_progress = 0.0


func _process(_delta: float) -> void:
    mapa_partes_animado.frame = mapa_animado.frame
    mapa_partes_animado.frame_progress = mapa_animado.frame_progress

    for capa in [pilares_animado, objetos_niveles_animado, arbol_animado]:
        capa.frame = mapa_animado.frame
        capa.frame_progress = mapa_animado.frame_progress

    actualizar_profundidad_capas()


func actualizar_profundidad_capas() -> void:
    # Cada grupo usa la posición de su base. Si el jugador camina por arriba,
    # el objeto se dibuja encima; al caminar por abajo, el jugador se ve delante.
    actualizar_profundidad_capa(pilares_capa)
    actualizar_profundidad_capa(objetos_niveles_capa)
    actualizar_profundidad_capa(arbol_capa)


func actualizar_profundidad_capa(capa: Node2D) -> void:
    capa.z_index = 2 if jugador_mapa.global_position.y < capa.global_position.y else 0

func show_menu_message(text: String) -> void:
    menu_info.text = text
    menu_info.show()

func _on_chatbot_pressed() -> void:
    TransitionManager.cambiar_escena("res://Scenes/ChatBot.tscn")

func _on_menu_hamburguesa_pressed() -> void:
    menu_panel.visible = not menu_panel.visible
    if menu_panel.visible:
        menu_info.hide()

func _on_volver_menu_pressed() -> void:
    Global.opciones_return_scene = "res://Scenes/menu.tscn"
    TransitionManager.cambiar_escena("res://Scenes/menu.tscn")

func _on_logros_pressed() -> void:
    show_menu_message("Logros\n\nMuy pronto podras revisar tus logros desbloqueados.")

func _on_info_jugador_pressed() -> void:
    var progreso = SaveManager.current_slot_data.get("progreso", 0)
    var personaje = Global.player_character
    var slot = SaveManager.current_slot

    show_menu_message(
        "Informacion del jugador\n\nSlot: %s\nPersonaje: %s\nProgreso: %s" % [
            str(slot),
            personaje,
            str(progreso)
        ]
    )

func _on_opciones_pressed() -> void:
    Global.opciones_return_scene = "res://Scenes/mapa.tscn"
    TransitionManager.cambiar_escena("res://Scenes/opciones.tscn")
