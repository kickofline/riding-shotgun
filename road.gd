extends TextureRect

@export var speed := 0.4 # Texture widths scrolled per second.

var _scroll := 0.0

# Runs in the normal process mode, so the road stops when the tree is paused (game over / win).
func _process(delta: float) -> void:
	_scroll = fposmod(_scroll + speed * delta, 1.0)
	(material as ShaderMaterial).set_shader_parameter("scroll", _scroll)
