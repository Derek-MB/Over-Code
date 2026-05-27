extends Area2D

@export var level_scene : String

var player_inside = false


func _on_body_entered(body):

    if body.name == "CharacterBody2D":
        player_inside = true
        $Label.visible = true
        $AnimationPlayer.play("show")

func _on_body_exited(body):

    if body.name == "CharacterBody2D":
        player_inside = false
        "$Label.visible = false"
        $AnimationPlayer.play("hide")

func _process(_delta):

    if player_inside and Input.is_action_just_pressed("ui_accept"):
        TransitionManager.cambiar_escena("res://Scenes/nivel_1.tscn")
