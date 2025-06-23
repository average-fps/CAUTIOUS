extends CanvasLayer

@onready var shader_mat := $ColorRect.material as ShaderMaterial

func _process(_delta):
	shader_mat.set_shader_parameter("screen_size", get_viewport().get_visible_rect().size)
