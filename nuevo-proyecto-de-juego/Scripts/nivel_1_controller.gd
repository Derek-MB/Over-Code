extends Node2D


# ================================================================
# REFERENCIAS
# ================================================================

@onready var menu_panel: Control = $CanvasLayer/MenuPanel
@onready var jugador: CharacterBody2D = $jugador

# Indicador visual del acertijo.
# IMPORTANTE: en la escena el nodo se llama "Alerta".
@onready var alerta: AnimatedSprite2D = $Alerta

# Barrera visual.
@onready var glitch: AnimatedSprite2D = $Glitch

# Barrera física del acertijo.
@onready var barrera_puzzle: CollisionShape2D = $BarreraPuzzle/CollisionShape2D


# ================================================================
# VARIABLES
# ================================================================

var acertijo_resuelto := false


# ================================================================
# READY
# ================================================================

func _ready() -> void:

    # Este nodo puede seguir procesando aunque el juego esté pausado.
    process_mode = Node.PROCESS_MODE_ALWAYS


    # ============================================================
    # CONFIGURAR PAUSA
    # ============================================================

    for node in get_children():

        if node != $CanvasLayer:
            node.process_mode = Node.PROCESS_MODE_PAUSABLE


    # ============================================================
    # OCULTAR MENÚ
    # ============================================================

    menu_panel.hide()


    # ============================================================
    # RESTAURAR POSICIÓN DEL JUGADOR
    # ============================================================

    if (
        Global.level_return_scene == scene_file_path
        and Global.level_resume_position != Vector2.INF
    ):

        jugador.global_position = Global.level_resume_position


    Global.level_return_scene = ""
    Global.level_resume_position = Vector2.INF


    # ============================================================
    # CONFIGURAR ESTADO INICIAL
    # ============================================================

    actualizar_estado_puzzle()


# ================================================================
# PROCESS
# ================================================================

func _process(_delta: float) -> void:

    # Comprobamos si PuzzleCodigo ya desactivó
    # la barrera física.

    actualizar_estado_puzzle()


# ================================================================
# ACTUALIZAR ESTADO DEL PUZZLE
# ================================================================

func actualizar_estado_puzzle() -> void:

    # ------------------------------------------------------------
    # COMPROBAR QUE LA BARRERA EXISTE
    # ------------------------------------------------------------

    if not is_instance_valid(barrera_puzzle):

        print("[Nivel1] ERROR: No se encontró BarreraPuzzle/CollisionShape2D.")

        return


    # ------------------------------------------------------------
    # EL PUZZLE TODAVÍA NO ESTÁ RESUELTO
    # ------------------------------------------------------------

    if not barrera_puzzle.disabled:

        # Si ya habíamos detectado que estaba resuelto,
        # no hacemos nada más.

        if acertijo_resuelto:
            return


        # ========================================================
        # ALERTA → INCOMPLETA
        # ========================================================

        if is_instance_valid(alerta):

            if alerta.sprite_frames.has_animation(&"incompleta"):

                if alerta.animation != &"incompleta":

                    alerta.play(&"incompleta")

            else:

                print(
					"[Nivel1] ERROR: Alerta no tiene la animación 'incompleta'."
                )

        else:

            print(
				"[Nivel1] ERROR: No se encontró el nodo Alerta."
            )


        # ========================================================
        # GLITCH → VISIBLE
        # ========================================================

        if is_instance_valid(glitch):

            glitch.visible = true

        else:

            print(
				"[Nivel1] ERROR: No se encontró el nodo Glitch."
            )


        return


    # ================================================================
    # PUZZLE RESUELTO
    # ================================================================

    if acertijo_resuelto:
        return


    acertijo_resuelto = true


    # ============================================================
    # ALERTA → COMPLETA
    # ============================================================

    if is_instance_valid(alerta):

        if alerta.sprite_frames.has_animation(&"completa"):

            alerta.play(&"completa")

        else:

            print(
				"[Nivel1] ERROR: Alerta no tiene la animación 'completa'."
            )


    # ============================================================
    # GLITCH → INVISIBLE
    # ============================================================

    if is_instance_valid(glitch):

        glitch.visible = false


    # ============================================================
    # MENSAJE DE DEPURACIÓN
    # ============================================================

    print(
		"[Nivel1] ¡PUZZLE COMPLETADO! "
        + "Barrera desactivada, Alerta cambiada a completa "
        + "y Glitch ocultado."
    )


# ================================================================
# INPUT
# ================================================================

func _unhandled_input(event: InputEvent) -> void:

    if (
        event is InputEventKey
        and event.pressed
        and not event.echo
        and event.keycode == KEY_BACKSPACE
    ):

        alternar_menu()

        get_viewport().set_input_as_handled()


# ================================================================
# MENÚ
# ================================================================

func alternar_menu() -> void:

    var abierto := not menu_panel.visible

    menu_panel.visible = abierto

    get_tree().paused = abierto


# ================================================================
# CERRAR MENÚ
# ================================================================

func cerrar_menu() -> void:

    menu_panel.hide()

    get_tree().paused = false


# ================================================================
# BOTÓN MENÚ HAMBURGUESA
# ================================================================

func _on_menu_hamburguesa_pressed() -> void:

    alternar_menu()


# ================================================================
# REINICIAR NIVEL
# ================================================================

func _on_reiniciar_nivel_pressed() -> void:

    get_tree().paused = false

    get_tree().reload_current_scene()


# ================================================================
# ASISTENCIA
# ================================================================

func _on_asistencia_pressed() -> void:

    _guardar_retorno()

    get_tree().paused = false

    TransitionManager.cambiar_escena(
		"res://Scenes/ChatBot.tscn"
    )


# ================================================================
# OPCIONES
# ================================================================

func _on_opciones_pressed() -> void:

    _guardar_retorno()

    get_tree().paused = false

    Global.opciones_return_scene = scene_file_path

    TransitionManager.cambiar_escena(
		"res://Scenes/opciones.tscn"
    )


# ================================================================
# SALIR DEL NIVEL
# ================================================================

func _on_salir_del_nivel_pressed() -> void:

    get_tree().paused = false

    TransitionManager.cambiar_escena(
		"res://Scenes/mapa.tscn"
    )


# ================================================================
# GUARDAR RETORNO
# ================================================================

func _guardar_retorno() -> void:

    Global.level_return_scene = scene_file_path

    Global.level_resume_position = jugador.global_position
