extends Node2D


@export var level_scene : String
@export var level_id : int

func enter_level():
    get_tree().change_scene_to_file(level_scene) # el change scene to file, ya cuando allas creado el nodo del nivel poner la direccion del mismo ejem: res://levels/level1.tscn
    
func highlight():

    $Sprite2D.modulate = Color(1.5,1.5,1.5)

func unhighlight():

    $Sprite2D.modulate = Color(1,1,1)
