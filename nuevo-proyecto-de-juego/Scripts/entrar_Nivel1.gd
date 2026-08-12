extends Area2D

@export var nivel_id := 1
@export_file("*.tscn") var level_scene := "res://Scenes/nivel_1.tscn"

const NIVEL_BLOQUEADO := preload("res://Assets/Art/Interface/level_locked.png")
const NIVEL_DESBLOQUEADO := preload("res://Assets/Art/Interface/level_unlocked.png")

var player_inside = false


func _on_body_entered(body):
    if body.name == "CharacterBody2D" and esta_desbloqueado():
        player_inside = true
        $Label.visible = true
        var animation_player := get_node_or_null("AnimationPlayer") as AnimationPlayer
        if animation_player:
            animation_player.play("show")

func _on_body_exited(body):

    if body.name == "CharacterBody2D":
        player_inside = false
        $Label.visible = false
        var animation_player := get_node_or_null("AnimationPlayer") as AnimationPlayer
        if animation_player:
            animation_player.play("hide")

func _process(_delta):

    if player_inside and Input.is_action_just_pressed("ui_accept"):
        TransitionManager.cambiar_escena(level_scene)


func _ready() -> void:
    $Label.hide()
    $Sprite2D.texture = NIVEL_DESBLOQUEADO if esta_desbloqueado() else NIVEL_BLOQUEADO


func esta_desbloqueado() -> bool:
    if nivel_id == 1:
        return true

    var nivel_anterior := nivel_id - 1
    return SaveManager.current_slot_data.get("nivel_%d_completado" % nivel_anterior, false) \
        or int(SaveManager.current_slot_data.get("progreso", 0)) >= nivel_anterior
