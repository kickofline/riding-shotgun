extends Control

@export var fill_color := Color(0.9, 0.5, 0.1, 1)
@export var back_color := Color(0.2, 0.2, 0.2, 0.85)

var _fill: ColorRect
var _max_health := 1

func _ready() -> void:
	var back := ColorRect.new()
	back.color = back_color
	back.set_anchors_preset(Control.PRESET_FULL_RECT)
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(back)
	_fill = ColorRect.new()
	_fill.color = fill_color
	_fill.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fill)

	var boss = get_tree().get_first_node_in_group("boss")
	if boss:
		_max_health = boss.max_health
		boss.health_changed.connect(_on_health_changed)
		_on_health_changed(boss.health)

func _on_health_changed(value: int) -> void:
	# Anchors are resolution-independent, so no dependency on layout timing.
	_fill.anchor_right = float(value) / float(_max_health)
