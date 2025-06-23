extends Node3D
@onready var player = get_node("../player")
const temp_warning = "WARNING: TEMPERATURE TEMP_CRITICAL"
const integrity_warning = "WARNING: HULL INTEGRITY CRITICAL"

func _physics_process(_delta: float) -> void:
	if player.get_integrity() <= 0:
		get_tree().quit(0)
	
	if player.get_heat() > 100.0:
		if not temp_warning in player.warnings:
			player.show_warning(temp_warning)

		if player.get_integrity() < 15.0:
			player.set_integrity(player.get_integrity() - 0.01)
		else:
			player.set_integrity(player.get_integrity() - 0.02)
	else:
		# Remove from stack and hide if it’s the main warning
		player.hide_warning(temp_warning)
	if player.get_integrity() < 15.0:
		if not integrity_warning in player.warnings:
			player.show_warning(integrity_warning)
	else:	
		# Remove from stack and hide if it’s the main warning
		player.hide_warning(integrity_warning)
	# Passive cooling
	if not player.get_heat() < -50:
		player.set_heat(player.get_heat() - 0.1)
