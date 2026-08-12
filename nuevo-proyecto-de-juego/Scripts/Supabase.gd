extends Node

# Cliente mínimo de Supabase para Over Code.
# La clave publishable es pública por diseño y puede ir dentro del juego.
# Nunca agregues aquí una clave "service_role" o "secret".

const PROJECT_URL := "https://yysfbdczoixasbzdcftw.supabase.co"
const PUBLISHABLE_KEY := "sb_publishable_uiCzW3m2LKqPWChXTFi1kQ_B9t6ahZC"
const SESSION_PATH := "user://supabase_session.save"

var access_token := ""
var refresh_token := ""
var user_id := ""
var user_email := ""

var _http: HTTPRequest


func _ready() -> void:

    _http = HTTPRequest.new()
    add_child(_http)
    load_local_session()


# Registro. Si la confirmación de email está activa, el jugador deberá abrir
# el correo recibido y luego iniciar sesión desde el juego.
func sign_up(email: String, password: String, display_name: String = "", avatar: String = "boy") -> Dictionary:

    var metadata := {
        "display_name": display_name.strip_edges(),
        "avatar": avatar
    }

    var response := await _request_json(
        "/auth/v1/signup",
        HTTPClient.METHOD_POST,
        {"email": email.strip_edges(), "password": password, "data": metadata},
        false
    )

    # Cuando la confirmación de correo está desactivada, Supabase devuelve
    # una sesión directamente. Si está activada, el jugador confirma primero.
    if response.get("ok", false) and response.get("data", {}).has("access_token"):
        store_session(response.get("data", {}))

    return response


func sign_in(email: String, password: String) -> Dictionary:

    var response := await _request_json(
        "/auth/v1/token?grant_type=password",
        HTTPClient.METHOD_POST,
        {"email": email.strip_edges(), "password": password},
        false
    )

    if response.get("ok", false):
        store_session(response.get("data", {}))

    return response


func sign_out() -> Dictionary:

    if access_token.is_empty():
        clear_local_session()
        return {"ok": true}

    var response := await _request_json("/auth/v1/logout", HTTPClient.METHOD_POST, {}, true)
    clear_local_session()
    return response


func is_signed_in() -> bool:

    return not access_token.is_empty() and not user_id.is_empty()


func get_my_profile() -> Dictionary:

    if not is_signed_in():
        return {"ok": false, "message": "No hay una sesión iniciada."}

    return await _request_json(
        "/rest/v1/profiles?select=*&id=eq." + user_id,
        HTTPClient.METHOD_GET,
        null,
        true
    )


func update_my_profile(changes: Dictionary) -> Dictionary:

    if not is_signed_in():
        return {"ok": false, "message": "No hay una sesión iniciada."}

    return await _request_json(
        "/rest/v1/profiles?id=eq." + user_id,
        HTTPClient.METHOD_PATCH,
        changes,
        true,
        {"Prefer": "return=representation"}
    )


func sync_save_slot(slot_number: int, slot_data: Dictionary, play_time_seconds: int) -> Dictionary:

    if not is_signed_in():
        return {"ok": false, "message": "No hay una sesión iniciada."}

    var progreso := clampi(int(slot_data.get("progreso", 0)), 0, 5)
    var current_level := mini(progreso + 1, 5)
    var payload := {
        "user_id": user_id,
        "slot_number": slot_number,
        "slot_name": str(slot_data.get("nombre", "")),
        "world_name": _world_name_for_level(current_level),
        "current_level": current_level,
        "highest_unlocked_level": current_level,
        "play_time_seconds": play_time_seconds,
        "game_version": "1.0.0",
        "game_state": slot_data,
        "last_played_at": Time.get_datetime_string_from_system(true)
    }

    var save_result := await _request_json(
        "/rest/v1/save_slots?on_conflict=user_id,slot_number",
        HTTPClient.METHOD_POST,
        payload,
        true,
        {"Prefer": "resolution=merge-duplicates,return=representation"}
    )

    if not save_result.get("ok", false):
        return save_result

    return await update_my_profile({
        "current_level": current_level,
        "highest_unlocked_level": current_level,
        "progress": (float(progreso) / 5.0) * 100.0,
        "play_time_seconds": play_time_seconds
    })


func _world_name_for_level(level: int) -> String:

    var worlds := ["HTML", "CSS", "JavaScript", "Python", "Final"]
    return worlds[clampi(level, 1, worlds.size()) - 1]


func load_leaderboard() -> Dictionary:

    return await _request_json(
        "/rest/v1/leaderboard?select=*&order=rank.asc",
        HTTPClient.METHOD_GET,
        null,
        is_signed_in()
    )


func load_local_session() -> void:

    if not FileAccess.file_exists(SESSION_PATH):
        return

    var file := FileAccess.open(SESSION_PATH, FileAccess.READ)
    var session = JSON.parse_string(file.get_as_text())

    if session is Dictionary:
        access_token = session.get("access_token", "")
        refresh_token = session.get("refresh_token", "")
        user_id = session.get("user_id", "")
        user_email = session.get("user_email", "")


func store_session(session: Dictionary) -> void:

    access_token = session.get("access_token", "")
    refresh_token = session.get("refresh_token", "")
    var session_user: Dictionary = session.get("user", {})
    user_id = session_user.get("id", "")
    user_email = session_user.get("email", "")

    var file := FileAccess.open(SESSION_PATH, FileAccess.WRITE)
    file.store_string(JSON.stringify({
        "access_token": access_token,
        "refresh_token": refresh_token,
        "user_id": user_id,
        "user_email": user_email
    }))


func clear_local_session() -> void:

    access_token = ""
    refresh_token = ""
    user_id = ""
    user_email = ""

    if FileAccess.file_exists(SESSION_PATH):
        DirAccess.remove_absolute(SESSION_PATH)


func _request_json(path: String, method: HTTPClient.Method, payload, requires_login: bool, extra_headers: Dictionary = {}) -> Dictionary:

    var headers := PackedStringArray([
        "apikey: " + PUBLISHABLE_KEY,
		"Content-Type: application/json"
    ])

    if requires_login:
        if access_token.is_empty():
            return {"ok": false, "message": "Debes iniciar sesión primero."}
        headers.append("Authorization: Bearer " + access_token)

    for header_name in extra_headers:
        headers.append(str(header_name) + ": " + str(extra_headers[header_name]))

    var request_body := ""
    if payload != null:
        request_body = JSON.stringify(payload)

    var request_error := _http.request(PROJECT_URL + path, headers, method, request_body)
    if request_error != OK:
        return {"ok": false, "message": "No se pudo iniciar la conexión. Código: " + str(request_error)}

    # Godot entrega la señal como un Array (resultado, código HTTP,
    # cabeceras y cuerpo). Declararlo evita un error de inferencia.
    var result: Array = await _http.request_completed
    var result_code: int = result[0]
    var response_code: int = result[1]
    var response_body: PackedByteArray = result[3]
    var response_text := response_body.get_string_from_utf8()
    var parsed_data = JSON.parse_string(response_text)

    if result_code != HTTPRequest.RESULT_SUCCESS:
        return {"ok": false, "message": "No se pudo conectar con el servidor."}

    if response_code < 200 or response_code >= 300:
        var error_message := "Error de Supabase (" + str(response_code) + ")."
        if parsed_data is Dictionary:
            error_message = parsed_data.get("msg", parsed_data.get("message", error_message))
        return {"ok": false, "message": error_message, "status": response_code, "data": parsed_data}

    return {"ok": true, "status": response_code, "data": parsed_data}
