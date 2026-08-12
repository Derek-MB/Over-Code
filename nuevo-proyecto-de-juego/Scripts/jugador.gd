extends CharacterBody2D


var current_level = null

@export var speed = 200
@export var jump_force = -450
@export var gravity = 1200

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var punto_bloque: Marker2D = $PuntoBloque

var bloque_agarrado: BloqueCodigo


func _ready() -> void:

    # ============================================================
    # CREAR ACCIÓN PARA AGARRAR BLOQUE
    # ============================================================

    if not InputMap.has_action("agarrar_bloque"):
        InputMap.add_action("agarrar_bloque")

        var tecla_e := InputEventKey.new()
        tecla_e.physical_keycode = KEY_E

        InputMap.action_add_event(
            "agarrar_bloque",
            tecla_e
        )


    # ============================================================
    # CAMBIAR PERSONAJE SEGÚN LA SELECCIÓN
    # ============================================================

    if PlayerData.selected_character == "boy":

        sprite.sprite_frames = preload(
			"res://Assets/Animations/boy_frames.tres"
        )

    else:

        sprite.sprite_frames = preload(
			"res://Assets/Animations/girl_frames.tres"
        )


    # ============================================================
    # ANIMACIÓN INICIAL
    # ============================================================

    if sprite.sprite_frames.has_animation(&"idle_level"):

        sprite.play(&"idle_level")

    elif sprite.sprite_frames.has_animation(&"idle"):

        sprite.play(&"idle")


# ================================================================
# FÍSICA Y MOVIMIENTO
# ================================================================

func _physics_process(delta: float) -> void:

    # ============================================================
    # AGARRAR / SOLTAR BLOQUE
    # ============================================================

    if Input.is_action_just_pressed("agarrar_bloque"):

        if bloque_agarrado:

            soltar_bloque()

        else:

            recoger_bloque_cercano()


    # ============================================================
    # GRAVEDAD
    # ============================================================

    if not is_on_floor():

        velocity.y += gravity * delta


    # ============================================================
    # MOVIMIENTO HORIZONTAL
    # ============================================================

    var dir := 0.0


    if Input.is_action_pressed("ui_right"):

        dir = 1.0


    if Input.is_action_pressed("ui_left"):

        dir = -1.0


    velocity.x = dir * speed


    # ============================================================
    # SALTO
    # ============================================================

    if Input.is_action_just_pressed("ui_accept") and is_on_floor():

        velocity.y = jump_force


    # ============================================================
    # VOLTEAR PERSONAJE
    # ============================================================

    if dir != 0:

        sprite.flip_h = dir < 0


    # ============================================================
    # ANIMACIONES
    # ============================================================

    actualizar_animacion(dir)


    # ============================================================
    # MANTENER BLOQUE EN LAS MANOS
    # ============================================================

    if bloque_agarrado:

        bloque_agarrado.global_position = (
            punto_bloque.global_position
        )


    # ============================================================
    # MOVER PERSONAJE
    # ============================================================

    move_and_slide()


    # ============================================================
    # LIMITAR MAPA
    # ============================================================

    global_position.x = clamp(
        global_position.x,
        0,
        6800
    )


# ================================================================
# ACTUALIZAR ANIMACIÓN
# ================================================================

func actualizar_animacion(dir: float) -> void:

    # ------------------------------------------------------------
    # TIENE UN BLOQUE EN LAS MANOS
    # ------------------------------------------------------------

    if bloque_agarrado:

        # Se está moviendo.
        if dir != 0:

            if sprite.sprite_frames.has_animation(
                &"agarrar_bloque"
            ):

                sprite.play(&"agarrar_bloque")


        # Está quieto.
        else:

            if sprite.sprite_frames.has_animation(
                &"agarrar_bloque_idle"
            ):

                sprite.play(&"agarrar_bloque_idle")


        return


    # ------------------------------------------------------------
    # NO TIENE BLOQUE
    # ------------------------------------------------------------

    if dir != 0:

        if sprite.sprite_frames.has_animation(
            &"walking"
        ):

            sprite.play(&"walking")

    else:

        if sprite.sprite_frames.has_animation(
            &"idle_level"
        ):

            sprite.play(&"idle_level")

        elif sprite.sprite_frames.has_animation(
            &"idle"
        ):

            sprite.play(&"idle")


# ================================================================
# BUSCAR BLOQUE CERCANO
# ================================================================

func recoger_bloque_cercano() -> void:

    var mas_cercano: BloqueCodigo
    var distancia := 64.0


    for bloque in get_tree().get_nodes_in_group(
		"bloques_codigo"
    ):

        var nueva_distancia: float = (
            global_position.distance_to(
                bloque.global_position
            )
        )


        if (
            nueva_distancia < distancia
            and not bloque.agarrado
        ):

            mas_cercano = bloque
            distancia = nueva_distancia


    # ============================================================
    # AGARRAR BLOQUE
    # ============================================================

    if mas_cercano:

        bloque_agarrado = mas_cercano

        bloque_agarrado.tomar()


        # Actualizamos inmediatamente la animación.
        # Así no tenemos que esperar al siguiente frame.
        if velocity.x != 0:

            if sprite.sprite_frames.has_animation(
                &"agarrar_bloque"
            ):

                sprite.play(&"agarrar_bloque")

        else:

            if sprite.sprite_frames.has_animation(
                &"agarrar_bloque_idle"
            ):

                sprite.play(&"agarrar_bloque_idle")


# ================================================================
# SOLTAR BLOQUE
# ================================================================

func soltar_bloque() -> void:

    if not bloque_agarrado:
        return


    var direccion := -1.0 if sprite.flip_h else 1.0


    bloque_agarrado.soltar(
        Vector2(
            direccion * 180.0,
            -35.0
        )
    )


    bloque_agarrado = null


    # ============================================================
    # VOLVER A LA ANIMACIÓN NORMAL
    # ============================================================

    if velocity.x != 0:

        if sprite.sprite_frames.has_animation(
            &"walking"
        ):

            sprite.play(&"walking")

    else:

        if sprite.sprite_frames.has_animation(
            &"idle_level"
        ):

            sprite.play(&"idle_level")

        elif sprite.sprite_frames.has_animation(
            &"idle"
        ):

            sprite.play(&"idle")
