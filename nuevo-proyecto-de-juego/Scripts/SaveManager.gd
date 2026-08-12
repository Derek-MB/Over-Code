extends Node

const SAVE_PATH = "user://slot_"

var current_slot = 0
var current_slot_data = {}
var play_time_seconds := 0
var _session_started_at := 0


func _ready() -> void:
    _session_started_at = Time.get_unix_time_from_system()


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
            "progreso": 0,
            "play_time_seconds": 0
        }

    play_time_seconds = int(current_slot_data.get("play_time_seconds", 0))
    _session_started_at = Time.get_unix_time_from_system()


    # Restaurar personaje
    if current_slot_data["personaje"] != null:

        Global.player_character = current_slot_data["personaje"]


# Guardar slot
func save_slot(slot):

    _actualizar_tiempo_jugado()
    current_slot_data["play_time_seconds"] = play_time_seconds

    var path = "user://slot_%d.save" % slot

    var file = FileAccess.open(path, FileAccess.WRITE)

    file.store_string(JSON.stringify(current_slot_data))

    if Supabase.is_signed_in() and slot > 0:
        Supabase.sync_save_slot(slot, current_slot_data, play_time_seconds)


func _actualizar_tiempo_jugado() -> void:

    var now := Time.get_unix_time_from_system()
    play_time_seconds += maxi(0, now - _session_started_at)
    _session_started_at = now


func delete_slot(slot):

    var path = SAVE_PATH + str(slot) + ".save"

    if FileAccess.file_exists(path):

        DirAccess.remove_absolute(path)

    current_slot_data = {}
