extends Node3D

@onready var player = get_node("../player")

var textures := {}
var solver_state: bool = false

func _ready() -> void:
	var solver_base := player.get_node("CanvasLayer/Control/main_hud/solver-indicator")

	textures = {
		"off": solver_base.get_node("off"),
		"main": solver_base.get_node("main"),
		"scale": solver_base.get_node("scale"),
		"rotate": solver_base.get_node("rotate"),
	}

	player.connect("solver_toggle", _solver_toggle)

func show_state(name: String):
	for tex_name in textures:
		textures[tex_name].visible = (tex_name == name)

func _solver_toggle():
	solver_state = !solver_state

func _physics_process(_delta: float) -> void:
	if solver_state:
		show_state("main")
		player.set_heat(player.get_heat() + 0.105)
	else:
		show_state("off")
