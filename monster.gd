extends Area2D

@export var bullet_scene: PackedScene
@export var fire_rate = 1.0  # seconds between shots

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

func _ready() -> void:
	screen_size = get_viewport_rect().size
	position = Vector2(screen_size.x / 6, screen_size.y / 2)
	
var fire_timer = 0.0

func _physics_process(delta):
	fire_timer -= delta
	if fire_timer <= 0.0:
		shoot()
		fire_timer = fire_rate

func shoot():
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = (get_target_position() - bullet.global_position).normalized()

func get_target_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	return player.global_position if player else global_position + Vector2.RIGHT
