extends ColorRect


func _ready() -> void:

    # Comenzamos completamente negros.
    modulate.a = 100.0

    # Fade hacia el menú.
    var tween := create_tween()

    tween.set_trans(Tween.TRANS_QUAD)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(
        self,
        "modulate:a",
        0.0,
        0.8
    )
