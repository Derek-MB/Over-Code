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

    # Actualizar las colisiones y puentes según el progreso.
    actualizar_progresion_mapa()

    # El jugador se mantiene entre las capas de fondo (0)
    # y primer plano (2).
    jugador_mapa.z_index = 1

    # ============================================================
    # ANIMACIONES DEL MAPA
    # ============================================================

    # Mapa principal.
    mapa_animado.play(&"new_animation")
    mapa_animado.frame = 0
    mapa_animado.frame_progress = 0.0

    # Segunda capa del mapa.
    # Se mantiene sincronizada con el mapa principal.
    if mapa_partes_animado.sprite_frames != null:
        if mapa_partes_animado.sprite_frames.has_animation(&"default"):
            mapa_partes_animado.play(&"default")
            mapa_partes_animado.pause()
            mapa_partes_animado.frame = 0
            mapa_partes_animado.frame_progress = 0.0

    # Capas visuales.
    for capa in [
        pilares_animado,
        objetos_niveles_animado,
        arbol_animado
    ]:
        if capa.sprite_frames != null:
            if capa.sprite_frames.has_animation(&"default"):
                capa.play(&"default")
                capa.pause()
                capa.frame = 0
                capa.frame_progress = 0.0


func _process(_delta: float) -> void:

    # ============================================================
    # SINCRONIZAR ANIMACIONES
    # ============================================================

    if mapa_partes_animado.sprite_frames != null:
        mapa_partes_animado.frame = mapa_animado.frame
        mapa_partes_animado.frame_progress = mapa_animado.frame_progress

    for capa in [
        pilares_animado,
        objetos_niveles_animado,
        arbol_animado
    ]:
        if capa.sprite_frames != null:
            capa.frame = mapa_animado.frame
            capa.frame_progress = mapa_animado.frame_progress

    # Actualizar profundidad de las capas.
    actualizar_profundidad_capas()


# ================================================================
# PROFUNDIDAD DE LOS OBJETOS
# ================================================================

func actualizar_profundidad_capas() -> void:

    # Cada grupo utiliza la posición de su base.
    #
    # Si el jugador está por arriba del objeto,
    # el objeto se dibuja encima.
    #
    # Si el jugador está por debajo,
    # el jugador se dibuja delante.

    actualizar_profundidad_capa(pilares_capa)
    actualizar_profundidad_capa(objetos_niveles_capa)
    actualizar_profundidad_capa(arbol_capa)


func actualizar_profundidad_capa(capa: Node2D) -> void:

    if jugador_mapa.global_position.y < capa.global_position.y:
        capa.z_index = 2
    else:
        capa.z_index = 0


# ================================================================
# PROGRESIÓN DEL MAPA
# ================================================================

func actualizar_progresion_mapa() -> void:

    # ------------------------------------------------------------
    # NIVEL 1 COMPLETADO
    #
    # Desbloquea:
    #   Montaña1 / CollisionPolygon2D2
    #   Montaña2 / CollisionPolygon2D2
    # ------------------------------------------------------------

    var progresiones := [
        [
            1,
            [
                $Montaña1/CollisionPolygon2D2,
                $Montaña2/CollisionPolygon2D2
            ],
            $Puentes/"puente1-2"
        ],

        # --------------------------------------------------------
        # NIVEL 2 COMPLETADO
        #
        # Desbloquea:
        #   Montaña2 / CollisionPolygon2D3
        #   Montaña3 / CollisionPolygon2D2
        # --------------------------------------------------------

        [
            2,
            [
                $Montaña2/CollisionPolygon2D3,
                $Montaña3/CollisionPolygon2D2
            ],
            $Puentes/"puente2-3"
        ],

        # --------------------------------------------------------
        # NIVEL 3 COMPLETADO
        #
        # Desbloquea:
        #   Montaña3 / CollisionPolygon2D3
        # --------------------------------------------------------

        [
            3,
            [
                $Montaña3/CollisionPolygon2D3
            ],
            $Puentes/"puente3-4"
        ],

        # --------------------------------------------------------
        # NIVEL 4 COMPLETADO
        #
        # Desbloquea:
        #   Montaña4 / CollisionPolygon2D2
        #   Montaña5 / CollisionPolygon2D2
        # --------------------------------------------------------

        [
            4,
            [
                $Montaña4/CollisionPolygon2D2,
                $Montaña5/CollisionPolygon2D2
            ],
            $Puentes/"puente4-5"
        ]
    ]

    # Aplicar cada progresión.
    for progresion in progresiones:

        var nivel: int = int(progresion[0])
        var barreras: Array = progresion[1]
        var puente: Node2D = progresion[2]

        var desbloqueado: bool = nivel_completado(nivel)

        configurar_puente(
            barreras,
            puente,
            desbloqueado
        )


# ================================================================
# COMPROBAR SI UN NIVEL ESTÁ COMPLETADO
# ================================================================

func nivel_completado(nivel: int) -> bool:

    var clave: String = "nivel_%d_completado" % nivel

    var completado_por_clave: bool = bool(
        SaveManager.current_slot_data.get(
            clave,
            false
        )
    )

    var progreso: int = int(
        SaveManager.current_slot_data.get(
            "progreso",
            0
        )
    )

    var resultado: bool = (
        completado_por_clave
        or progreso >= nivel
    )

    print(
		"[Mapa] Comprobando nivel %d | clave=%s | progreso=%d | resultado=%s"
        % [
            nivel,
            str(completado_por_clave),
            progreso,
            resultado
        ]
    )

    return resultado


# ================================================================
# CONFIGURAR PUENTE Y COLISIONES
# ================================================================

func configurar_puente(
    barreras: Array,
    puente: Node2D,
    desbloqueado: bool
) -> void:

    # ------------------------------------------------------------
    # Desactivar/activar las barreras de salida.
    #
    # Cuando desbloqueado == true:
    #   CollisionPolygon2D queda desactivado.
    #
    # Cuando desbloqueado == false:
    #   CollisionPolygon2D permanece activo.
    # ------------------------------------------------------------

    for barrera in barreras:

        if is_instance_valid(barrera):

            barrera.set_deferred(
                "disabled",
                desbloqueado
            )

    # ------------------------------------------------------------
    # Mostrar u ocultar el puente.
    # ------------------------------------------------------------

    if is_instance_valid(puente):

        puente.visible = desbloqueado

        # --------------------------------------------------------
        # Activar/desactivar las colisiones del puente.
        # --------------------------------------------------------

        var colisiones := puente.find_children(
            "*",
            "CollisionPolygon2D",
            true,
            false
        )

        for colision in colisiones:

            if is_instance_valid(colision):

                colision.set_deferred(
                    "disabled",
                    not desbloqueado
                )


# ================================================================
# MENSAJE DEL MENÚ
# ================================================================

func show_menu_message(text: String) -> void:

    menu_info.text = text
    menu_info.show()


# ================================================================
# CHATBOT
# ================================================================

func _on_chatbot_pressed() -> void:

    TransitionManager.cambiar_escena(
		"res://Scenes/ChatBot.tscn"
    )


# ================================================================
# MENÚ HAMBURGUESA
# ================================================================

func _on_menu_hamburguesa_pressed() -> void:

    menu_panel.visible = not menu_panel.visible

    if menu_panel.visible:
        menu_info.hide()


# ================================================================
# VOLVER AL MENÚ PRINCIPAL
# ================================================================

func _on_volver_menu_pressed() -> void:

    Global.opciones_return_scene = "res://Scenes/menu.tscn"

    TransitionManager.cambiar_escena(
		"res://Scenes/menu.tscn"
    )


# ================================================================
# LOGROS
# ================================================================

func _on_logros_pressed() -> void:

    show_menu_message(
		"Logros\n\nMuy pronto podras revisar tus logros desbloqueados."
    )


# ================================================================
# INFORMACIÓN DEL JUGADOR
# ================================================================

func _on_info_jugador_pressed() -> void:

    var progreso: int = int(
        SaveManager.current_slot_data.get(
            "progreso",
            0
        )
    )

    var personaje = Global.player_character
    var slot = SaveManager.current_slot

    show_menu_message(
		"Informacion del jugador\n\nSlot: %s\nPersonaje: %s\nProgreso: %s"
        % [
            str(slot),
            personaje,
            str(progreso)
        ]
    )


# ================================================================
# OPCIONES
# ================================================================

func _on_opciones_pressed() -> void:

    Global.opciones_return_scene = "res://Scenes/mapa.tscn"

    TransitionManager.cambiar_escena(
		"res://Scenes/opciones.tscn"
    )
