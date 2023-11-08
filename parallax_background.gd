extends ParallaxBackground

var bgspd = 40

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scroll_offset.x -= bgspd * delta 
