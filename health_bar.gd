extends Control

@export var filled_color := Color(0.8, 0.15, 0.15, 1)
@export var empty_color := Color(0.2, 0.2, 0.2, 1)
@export var gap := 2.0 # Pixels between segments.

var segments: Array[ColorRect] = []

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		_build_segments(player.max_health)
		player.health_changed.connect(_on_health_changed)
		_on_health_changed(player.health)


func _build_segments(count: int) -> void:
	for segment in segments:
		segment.queue_free()
	segments.clear()

	var width = get_viewport_rect().size.x
	var height = size.y
	var seg_width = (width - gap * (count - 1)) / float(count)

	for i in count:
		var segment = ColorRect.new()
		segment.color = empty_color
		segment.position = Vector2(i * (seg_width + gap), 0)
		segment.size = Vector2(seg_width, height)
		segment.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(segment)
		segments.append(segment)

func _on_health_changed(value: int) -> void:
	for i in segments.size():
		segments[i].color = filled_color if i < value else empty_color
