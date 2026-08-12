class_name PuzzleCodigo
extends Node

@export var bloques: Array[NodePath] = []

@export var tolerancia_y: float = 32.0
@export var distancia_maxima_entre_bloques: float = 60.0

var barrera: CollisionShape2D

var completado: bool = false
var bloques_configurados: Array[BloqueCodigo] = []
var ultimo_estado_depuracion: String = ""


func _ready() -> void:
    # ------------------------------------------------
    # BUSCAR LOS BLOQUES
    # ------------------------------------------------
    for ruta_bloque in bloques:
        var bloque := get_node_or_null(ruta_bloque) as BloqueCodigo

        if bloque != null:
            bloques_configurados.append(bloque)

    # ------------------------------------------------
    # BUSCAR LA BARRERA
    #
    # PuzzleCodigo y BarreraPuzzle son hermanos,
    # por eso usamos ../
    # ------------------------------------------------
    barrera = get_node_or_null(
		"../BarreraPuzzle/CollisionShape2D"
    ) as CollisionShape2D

    print(
		"[PuzzleCodigo] Bloques detectados: %d | Barrera valida: %s"
        % [
            bloques_configurados.size(),
            is_instance_valid(barrera)
        ]
    )


func _process(_delta: float) -> void:
    if completado:
        return

    if bloques_configurados.size() < 2:
        _imprimir_estado(
            false,
            false,
			"Faltan bloques configurados"
        )
        return

    # Crear copia para ordenar sin alterar el Array original
    var ordenados: Array[BloqueCodigo] = []

    for bloque in bloques_configurados:
        ordenados.append(bloque)

    # Ordenar de izquierda a derecha
    ordenados.sort_custom(
        func(a: BloqueCodigo, b: BloqueCodigo) -> bool:
            return a.global_position.x < b.global_position.x
    )

    # Comprobar proximidad
    var proximidad_correcta: bool = _estan_juntos(ordenados)

    # Comprobar orden
    var orden_correcto: bool = _orden_es_correcto(ordenados)

    _imprimir_estado(
        proximidad_correcta,
        orden_correcto
    )

    # Si el jugador todavía sostiene un bloque,
    # esperamos a que lo suelte.
    for bloque in bloques_configurados:
        if bloque.agarrado:
            return

    # Si no están juntos, no completar
    if not proximidad_correcta:
        return

    # Si no están en el orden correcto, no completar
    if not orden_correcto:
        return

    # Todo correcto
    _completar_puzzle()


func _orden_es_correcto(
    ordenados: Array[BloqueCodigo]
) -> bool:

    for indice in ordenados.size():

        if ordenados[indice].orden_correcto != indice + 1:
            return false

    return true


func _completar_puzzle() -> void:

    if not is_instance_valid(barrera):
        print(
			"[PuzzleCodigo] ERROR: no se encontró BarreraPuzzle."
        )

        # Intentar buscarla nuevamente
        barrera = get_node_or_null(
			"../BarreraPuzzle/CollisionShape2D"
        ) as CollisionShape2D

        if not is_instance_valid(barrera):
            print(
				"[PuzzleCodigo] ERROR: BarreraPuzzle sigue sin encontrarse."
            )
            return

    # Marcar como completado
    completado = true

    # DESACTIVAR COLISIÓN
    barrera.set_deferred("disabled", true)

    print(
		"[PuzzleCodigo] ¡PUZZLE COMPLETADO!"
    )

    print(
		"[PuzzleCodigo] BarreraPuzzle desactivada correctamente."
    )


func _estan_juntos(
    ordenados: Array[BloqueCodigo]
) -> bool:

    for indice in ordenados.size() - 1:

        var bloque_actual: BloqueCodigo = ordenados[indice]

        var bloque_siguiente: BloqueCodigo = ordenados[indice + 1]

        var distancia: float = bloque_actual.global_position.distance_to(
            bloque_siguiente.global_position
        )

        var diferencia_y: float = abs(
            bloque_actual.global_position.y
            - bloque_siguiente.global_position.y
        )

        if distancia > distancia_maxima_entre_bloques:
            return false

        if diferencia_y > tolerancia_y:
            return false

    return true


func _imprimir_estado(
    proximidad_correcta: bool,
    orden_correcto: bool,
    motivo: String = ""
) -> void:

    var estado: String = "%s|%s|%s" % [
        proximidad_correcta,
        orden_correcto,
        motivo
    ]

    if estado == ultimo_estado_depuracion:
        return

    ultimo_estado_depuracion = estado

    var detalle: Array[String] = []

    for bloque in bloques_configurados:

        detalle.append(
			"orden=%d x=%.1f y=%.1f"
            % [
                bloque.orden_correcto,
                bloque.global_position.x,
                bloque.global_position.y
            ]
        )

    print(
		"[PuzzleCodigo] %s | proximidad=%s | orden=%s | %s"
        % [
            detalle,
            proximidad_correcta,
            orden_correcto,
            motivo
        ]
    )
