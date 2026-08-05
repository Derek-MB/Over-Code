extends Control

var register_mode := false

@onready var title_label: Label = $Center/Panel/Margin/Content/Title
@onready var name_input: LineEdit = $Center/Panel/Margin/Content/Name
@onready var email_input: LineEdit = $Center/Panel/Margin/Content/Email
@onready var password_input: LineEdit = $Center/Panel/Margin/Content/Password
@onready var submit_button: Button = $Center/Panel/Margin/Content/Submit
@onready var change_mode_button: Button = $Center/Panel/Margin/Content/ChangeMode
@onready var status_label: Label = $Center/Panel/Margin/Content/Status


func _ready() -> void:
	update_form()


func update_form() -> void:
	title_label.text = "Crear cuenta" if register_mode else "Iniciar sesión"
	name_input.visible = register_mode
	submit_button.text = "Registrarme" if register_mode else "Entrar"
	change_mode_button.text = "Ya tengo una cuenta" if register_mode else "Crear una cuenta"
	status_label.text = ""


func _on_submit_pressed() -> void:
	var email := email_input.text.strip_edges()
	var password := password_input.text

	if email.is_empty() or password.is_empty():
		show_status("Escribe tu correo y contraseña.", Color("ffcf70"))
		return

	if password.length() < 6:
		show_status("La contraseña debe tener al menos 6 caracteres.", Color("ffcf70"))
		return

	submit_button.disabled = true
	show_status("Conectando...", Color.WHITE)

	var response: Dictionary
	if register_mode:
		response = await Supabase.sign_up(email, password, name_input.text)
	else:
		response = await Supabase.sign_in(email, password)

	submit_button.disabled = false
	if not response.get("ok", false):
		show_status(response.get("message", "No se pudo completar la operación."), Color("ff8d8d"))
		return

	if Supabase.is_signed_in():
		show_status("¡Bienvenido/a a Over Code!", Color("9df5a0"))
		await get_tree().create_timer(0.6).timeout
		TransitionManager.cambiar_escena("res://Scenes/jugar.tscn")
		return

	show_status("Cuenta creada. Revisa tu correo, confírmala y luego inicia sesión.", Color("9df5a0"))


func _on_change_mode_pressed() -> void:
	register_mode = not register_mode
	update_form()


func _on_back_pressed() -> void:
	TransitionManager.cambiar_escena("res://Scenes/menu.tscn")


func show_status(message: String, text_color: Color) -> void:
	status_label.text = message
	status_label.modulate = text_color
