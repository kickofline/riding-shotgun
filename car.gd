extends Node2D
signal hit
signal health_changed(value: int)
signal died

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var max_health := 3
@export var invincibility_time := 0.6 # Seconds of immunity + flash after a hit.
var health := max_health
var is_invincible := false
var screen_size # Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	position = Vector2(screen_size.x*2.5 / 3, screen_size.y / 2)
	health_changed.emit(health)

func take_damage(amount := 1) -> void:
	if health <= 0 or is_invincible:
		return
	health = max(health - amount, 0)
	hit.emit()
	health_changed.emit(health)
	_flash_damage()
	if health <= 0:
		died.emit()
	else:
		_start_invincibility()

func _start_invincibility() -> void:
	is_invincible = true
	await get_tree().create_timer(invincibility_time).timeout
	is_invincible = false

func _flash_damage() -> void:
	var sprite = $AnimatedSprite2D
	sprite.modulate = Color(1, 0.2, 0.2, 1)
	create_tween().tween_property(sprite, "modulate", Color(1, 1, 1, 1), invincibility_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		#$AnimatedSprite2D.play()
	#else:
		#$AnimatedSprite2D.stop()
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
