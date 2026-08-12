extends Node

var player_character = "boy"
var current_level = 1
var monedas = 0
var opciones_return_scene = "res://Scenes/menu.tscn"

# Estado de navegación temporal. No reemplaza guardados ni autenticación.
var cinematic_return_scene = "res://Scenes/menu.tscn"
var level_return_scene = ""
var level_resume_position = Vector2.INF
