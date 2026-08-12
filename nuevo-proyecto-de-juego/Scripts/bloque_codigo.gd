class_name BloqueCodigo
extends CharacterBody2D

@export var orden_correcto := 1
@export_multiline var codigo_texto := ""
@export var distancia_agrupacion := 40.0

var agarrado := false
var velocidad_lanzamiento := Vector2.ZERO

@onready var colision: CollisionShape2D = $CollisionShape2D
@onready var etiqueta: Label = $Label

func _ready() -> void:
	add_to_group("bloques_codigo")
	etiqueta.text = codigo_texto
	queue_redraw()

func tomar() -> void:
	agarrado = true
	velocidad_lanzamiento = Vector2.ZERO
	colision.set_deferred("disabled", true)

func soltar(impulso: Vector2) -> void:
	agarrado = false
	velocidad_lanzamiento = impulso
	colision.set_deferred("disabled", false)

func _physics_process(delta: float) -> void:
	if agarrado:
		return
	if velocidad_lanzamiento.length() > 1.0:
		velocity = velocidad_lanzamiento
		move_and_slide()
		velocidad_lanzamiento = velocidad_lanzamiento.move_toward(Vector2.ZERO, 700.0 * delta)
	else:
		velocity = Vector2.ZERO
		_ajustar_con_vecino()

func _ajustar_con_vecino() -> void:
	for otro in get_tree().get_nodes_in_group("bloques_codigo"):
		if otro == self or otro.agarrado:
			continue
		var distancia := global_position.distance_to(otro.global_position)
		if distancia <= distancia_agrupacion and abs(global_position.y - otro.global_position.y) <= 20.0:
			global_position.x = otro.global_position.x + (48.0 if global_position.x >= otro.global_position.x else -48.0)
			global_position.y = otro.global_position.y
			return

func _draw() -> void:
	draw_rect(Rect2(-28, -16, 56, 32), Color("26364a"), true)
	draw_rect(Rect2(-28, -16, 56, 32), Color("8cbbdf"), false, 2.0)
