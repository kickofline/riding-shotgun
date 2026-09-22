extends CanvasLayer

func _ready() -> void:
	# Keep receiving input/process while the tree is paused -- this node IS
	# the pause screen, so it must be exempt from the pause it triggers.
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.died.connect(_on_player_died)

func _on_player_died() -> void:
	visible = true
	get_tree().paused = true

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_accept"):
		get_tree().paused = false
		get_tree().reload_current_scene()
