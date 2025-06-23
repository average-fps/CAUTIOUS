extends CharacterBody3D

signal solver_toggle()
signal solver_target_set(target: Node3D)
signal solver_target_drop()

@export var speed: float = 5.0
@export var mouse_sensitivity: float = 0.003
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8

var solver_repair: bool = false
var warning_showing: bool = false
var mouse_locked := true
var heat: float = 50.0
var integrity: float = 50.0
var warnings: Array = []

@onready var canvas = $CanvasLayer
@onready var camera = $Camera3D
@onready var main_warning = $"CanvasLayer/Control/main-warning"
@onready var warning_label = main_warning.get_node("warning text")  # fix this if node name differs
@onready var warnings_label = $CanvasLayer/Control/main_hud/warnings
@onready var info_label = $CanvasLayer/Control/main_hud/info

var pitch: float = 0.0  # Up/down rotation

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func show_warning(text):
	warning_label.text = str(text)
	main_warning.visible = true
	warning_showing = true
	awts(text)

func hide_warning(warn = null):
	if warn != null:
		var idx = warnings.find(warn)
		if idx != -1:
			warnings.remove_at(idx)

		# Also hide the main warning if it's the same text
		if warning_label.text == warn:
			warning_label.text = ""
			main_warning.visible = false
			warning_showing = false
	else:
		# Force hide all
		warning_label.text = ""
		main_warning.visible = false
		warning_showing = false


func add_warning_to_stack(warn):
	warnings.append(str(warn))

func remove_warning_from_stack(warn):
	var idx = warnings.find(warn)
	if idx != -1:
		warnings.remove_at(idx)

func awts(warn):
	add_warning_to_stack(warn)

func rwfs(warn):
	remove_warning_from_stack(warn)

func get_heat():
	return heat

func set_heat(seto):
	heat = float(seto)

func get_integrity():
	return integrity

func set_integrity(seto):
	integrity = float(seto)

func _input(event):
	if event is InputEventMouseMotion and mouse_locked:
		rotation.y -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-89), deg_to_rad(89))
		camera.rotation.x = pitch

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		mouse_locked = !mouse_locked
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if mouse_locked else Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	warnings_label.text = "\n".join(warnings)
	info_label.text = "HEAT: %.1f\nINTEGRITY: %.1f" % [heat, integrity]

	var input_dir = Vector3.ZERO
	var forward = -transform.basis.z.normalized()
	var right = transform.basis.x.normalized()

	if Input.is_action_pressed("forward"):
		input_dir += forward
	if Input.is_action_pressed("backward"):
		input_dir -= forward
	if Input.is_action_pressed("left"):
		input_dir -= right
	if Input.is_action_pressed("right"):
		input_dir += right
	if Input.is_action_just_pressed("solver_repair"):
		solver_repair = !solver_repair
	if Input.is_action_just_pressed("solver_toggle"):
		emit_signal("solver_toggle")
	if solver_repair:
		if not get_integrity() > 100:
			set_heat(get_heat() + 0.3)
			set_integrity(get_integrity() + 0.03)
		elif not get_integrity() > 120:
			set_heat(get_heat() + 0.6)
			set_integrity(get_integrity() + 0.01)
		
	input_dir = input_dir.normalized()
	var horizontal_velocity = input_dir * speed

	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	move_and_slide()
