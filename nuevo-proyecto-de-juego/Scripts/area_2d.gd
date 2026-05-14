extends Area2D


func _on_area_2d_body_entered(body):

	if body.name == "PlayerIcon":
		body.current_level = self
