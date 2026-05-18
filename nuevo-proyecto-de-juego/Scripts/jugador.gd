extends CharacterBody2D

var current_level = null
var speed = 200

func _physics_process(_delta):

    var dir = Vector2.ZERO

    if Input.is_action_pressed("ui_right"):
        dir.x += 1
    if Input.is_action_pressed("ui_left"):
        dir.x -= 1
    if Input.is_action_pressed("ui_down"):
        dir.y += 1
    if Input.is_action_pressed("ui_up"):
        dir.y -= 1

    velocity = dir.normalized() * speed
    move_and_slide()
