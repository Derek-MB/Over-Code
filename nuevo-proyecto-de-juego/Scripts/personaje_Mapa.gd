extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

@export var speed = 200

var boy_frames = preload("res://Assets/Animations/boy_frames.tres")
var girl_frames = preload("res://Assets/Animations/girl_frames.tres")

var last_direction = Vector2.DOWN


func _ready():

    if Global.player_character == "boy":
        sprite.sprite_frames = boy_frames
    else:
        sprite.sprite_frames = girl_frames


func _physics_process(_delta):

    var direction = Vector2.ZERO

    if Input.is_action_pressed("ui_right"):
        direction.x += 1

    if Input.is_action_pressed("ui_left"):
        direction.x -= 1

    if Input.is_action_pressed("ui_down"):
        direction.y += 1

    if Input.is_action_pressed("ui_up"):
        direction.y -= 1


    velocity = direction.normalized() * speed

    move_and_slide()


    # GUARDAR ÚLTIMA DIRECCIÓN
    if direction != Vector2.ZERO:
        last_direction = direction


    # ANIMACIONES
    if direction == Vector2.ZERO:

        # IDLE DERECHA/IZQUIERDA
        if abs(last_direction.x) > abs(last_direction.y):

            if sprite.animation != "idle_side":
                sprite.play("idle_side")

        # IDLE ABAJO
        elif last_direction.y > 0:

            if sprite.animation != "idle_down":
                sprite.play("idle")

        # IDLE ARRIBA
        elif last_direction.y < 0:

            if sprite.animation != "idle_up":
                sprite.play("idle")

    else:

        # DERECHA
        if direction.x > 0:

            sprite.flip_h = false

            if sprite.animation != "walk_side":
                sprite.play("walk_side")


        # IZQUIERDA
        elif direction.x < 0:

            sprite.flip_h = true

            if sprite.animation != "walk_side":
                sprite.play("walk_side")


        # ABAJO
        elif direction.y > 0:

            sprite.flip_h = false

            if sprite.animation != "walk_down":
                sprite.play("walk_down")


        # ARRIBA
        elif direction.y < 0:

            sprite.flip_h = false

            if sprite.animation != "walk_up":
                sprite.play("walk_up")
