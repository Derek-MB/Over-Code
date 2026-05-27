extends Node

const SAVE_PATH = "user://slot_"

var current_slot = 0
var current_slot_data = {}


func _ready() -> void:
    pass


# Seleccionar slot y cargar datos
func set_slot(slot):

    current_slot = slot
    load_slot(slot)


# Cargar slot (o crearlo si no existe)
func load_slot(slot):

    var path = "user://slot_%d.save" % slot

    if FileAccess.file_exists(path):

        var file = FileAccess.open(path, FileAccess.READ)

        current_slot_data = JSON.parse_string(file.get_as_text())

    else:

        # PARTIDA NUEVA
        current_slot_data = {
            "nuevo": true,
            "personaje": null,
            "progreso": 0
        }


    # Restaurar personaje
    if current_slot_data["personaje"] != null:

        Global.player_character = current_slot_data["personaje"]


# Guardar slot
func save_slot(slot):

    var path = "user://slot_%d.save" % slot

    var file = FileAccess.open(path, FileAccess.WRITE)

    file.store_string(JSON.stringify(current_slot_data))


func delete_slot(slot):

    var path = SAVE_PATH + str(slot) + ".save"

    if FileAccess.file_exists(path):

        DirAccess.remove_absolute(path)

    current_slot_data = {}
