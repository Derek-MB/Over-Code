extends CanvasLayer

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	# Inicia negro y hace fade al entrar al juego
	$transitionColor.modulate.a = 1
	anim.play("fade_in")

func cambiar_escena(ruta):
	anim.play("fade_out")
	await anim.animation_finished
	# pequeña pausa para asegurar que se vea
	await get_tree().create_timer(0.1).timeout 
	get_tree().change_scene_to_file(ruta)
	anim.play("fade_in")
