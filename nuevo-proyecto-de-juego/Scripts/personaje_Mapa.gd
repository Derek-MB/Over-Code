extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

@export var speed = 200

var boy_frames = preload("res://Sprites/boy_frames.tres")
var girl_frames = preload("res://Sprites/girl_frames.tres")
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


    # ANIMACIONES
    if direction != Vector2.ZERO:

        if Global.player_character == "boy":
            sprite.play("walk")
        else:
            sprite.play("walk")

    else:

        if Global.player_character == "girl":
            sprite.play("idle")
        else:
            sprite.play("idle")
