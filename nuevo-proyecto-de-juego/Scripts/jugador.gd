extends CharacterBody2D

var current_level = null

@export var speed = 200
@export var jump_force = -450
@export var gravity = 1200

@onready var sprite = $AnimatedSprite2D


func _ready():

    # CAMBIAR PERSONAJE SEGÚN SELECCIÓN
    if PlayerData.selected_character == "boy":
        sprite.sprite_frames = preload("res://Sprites/boy_frames.tres")

    else:
        sprite.sprite_frames = preload("res://Sprites/girl_frames.tres")


func _physics_process(delta):

    # APLICAR GRAVEDAD
    if not is_on_floor():
        velocity.y += gravity * delta

    # MOVIMIENTO HORIZONTAL
    var dir = 0

    if Input.is_action_pressed("ui_right"):
        dir = 1

    if Input.is_action_pressed("ui_left"):
        dir = -1

    velocity.x = dir * speed

    # SALTO
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = jump_force

    # VOLTEAR SPRITE
    if dir != 0:
        sprite.flip_h = dir < 0

    move_and_slide()

    # LIMITAR MAPA
    global_position.x = clamp(global_position.x, 0, 2000)
