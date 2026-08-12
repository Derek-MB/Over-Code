extends AnimatedSprite2D

var hacia_adelante := true

func _ready():
    # Reproducir la animación automáticamente
    play("default")

    # Detectar cuando termina
    animation_finished.connect(_on_animation_finished)


func _on_animation_finished():
    if hacia_adelante:
        hacia_adelante = false
        play_backwards("default")
    else:
        hacia_adelante = true
        play("default")
