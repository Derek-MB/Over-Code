extends Control

var deleting_mode = false
var slot_to_delete = -1

func _on_slot_1_pressed():
    start_slot(1)

func _on_slot_2_pressed():
    start_slot(2)

func _on_slot_3_pressed():
    start_slot(3)

func start_slot(slot):
    
    if deleting_mode:
        slot_to_delete = slot
        $panelConfirmacion.show()
        return
    
    SaveManager.set_slot(slot)
    
    if SaveManager.current_slot_data.get("nuevo", true):
        TransitionManager.cambiar_escena("res://Scenes/seleccion_de_personaje.tscn")
    else:
        TransitionManager.cambiar_escena("res://Scenes/mapa.tscn")
    
func _on_atras_pressed():
    TransitionManager.cambiar_escena("res://Scenes/menu.tscn")


"boton borrar funciones
BORRAR
SI 
Y NO
"
func _on_borrar_pressed():
    deleting_mode = true
    $"datos de borrado".show()
    
#boton si borra todo
func _on_si_pressed():
    SaveManager.delete_slot(slot_to_delete)
    
    deleting_mode = false
    slot_to_delete = -1
    
    $panelConfirmacion.hide()
    
    TransitionManager.cambiar_escena("res://Scenes/seleccion_de_personaje.tscn")
    
#boton no chill
func _on_no_pressed():
    deleting_mode = false
    slot_to_delete = -1
    
    $panelConfirmacion.hide()
    
