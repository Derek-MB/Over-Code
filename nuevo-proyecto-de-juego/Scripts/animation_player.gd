extends AnimationPlayer


func highlight():
	$AnimationPlayer.play("highlight")

func unhighlight():
	$AnimationPlayer.stop()
