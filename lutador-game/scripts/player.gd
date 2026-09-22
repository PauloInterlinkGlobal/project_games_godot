extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
const SPEED = 120.0

enum Direction { DOWN, UP, LEFT, RIGHT }
var facing_direction: Direction = Direction.DOWN

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * SPEED
	move_and_slide()
	update_animation(input_vector)

func update_animation(input_vector: Vector2) -> void:
	var is_moving := input_vector.length() > 0.1

	# só atualiza pra que lado o personagem está olhando enquanto ele se move
	if is_moving:
		if abs(input_vector.x) > abs(input_vector.y):
			facing_direction = Direction.RIGHT if input_vector.x > 0 else Direction.LEFT
		else:
			facing_direction = Direction.DOWN if input_vector.y > 0 else Direction.UP

	# usa a última direção conhecida, mesmo parado
	match facing_direction:
		Direction.LEFT:
			sprite.flip_h = false
			sprite.play("run_left" if is_moving else "idle_left")
		Direction.RIGHT:
			sprite.flip_h = true
			sprite.play("run_left" if is_moving else "idle_left")
		Direction.UP:
			sprite.flip_h = false
			sprite.play("run_up" if is_moving else "idle_up")
		Direction.DOWN:
			sprite.flip_h = false
			sprite.play("run_down" if is_moving else "idle_down")
