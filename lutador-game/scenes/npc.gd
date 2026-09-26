extends CharacterBody2D

@export var speed: float = 60.0
@export var change_direction_time: float = 2.0

var direction: Vector2 = Vector2.RIGHT
var timer: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	_change_direction()

func _physics_process(delta):
	timer += delta
	
	# Muda de direção de tempos em tempos
	if timer >= change_direction_time:
		timer = 0.0
		_change_direction()
	
	# Aplica o movimento
	velocity = direction * speed
	move_and_slide()
	
	# Atualiza a animação
	_update_animation()

func _change_direction():
	var directions = [
		Vector2.RIGHT,
		Vector2.LEFT,
		Vector2.UP,
		Vector2.DOWN
	]
	direction = directions[randi() % directions.size()]

func _update_animation():
	if direction.x > 0:
		# Direita
		animated_sprite.play("npc_rivel_left")
		animated_sprite.flip_h = true
	elif direction.x < 0:
		# Esquerda
		animated_sprite.play("npc_rivel_left")
		animated_sprite.flip_h = false
	elif direction.y < 0:
		# Cima
		animated_sprite.play("npc_rival_up")
		animated_sprite.flip_h = false
	elif direction.y > 0:
		# Baixo
		animated_sprite.play("npc_rivel_down")
		animated_sprite.flip_h = false
