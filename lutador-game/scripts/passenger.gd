extends CharacterBody2D

signal boarded

enum State { WAITING, WALKING_TO_TAXI, BOARDED }

@export var walk_speed: float = 80.0
## Aponte para o BoardingZone do táxi no Inspector (ex: ../taxi/BoardingZone)
@export var boarding_target_path: NodePath

var state: State = State.WAITING
var player_in_range: bool = false
var boarding_target: Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var call_range: Area2D = $CallRange

func _ready() -> void:
	add_to_group("passenger")
	_resolve_boarding_target()
	if call_range:
		call_range.monitoring = true
		if not call_range.body_entered.is_connected(_on_call_range_body_entered):
			call_range.body_entered.connect(_on_call_range_body_entered)
		if not call_range.body_exited.is_connected(_on_call_range_body_exited):
			call_range.body_exited.connect(_on_call_range_body_exited)

func _resolve_boarding_target() -> void:
	if boarding_target_path != NodePath():
		boarding_target = get_node_or_null(boarding_target_path)
	# Fallback: procura automaticamente o BoardingZone do taxi na cena
	if boarding_target == null:
		var taxi := get_tree().get_first_node_in_group("taxi")
		if taxi:
			boarding_target = taxi.get_node_or_null("BoardingZone")
			if boarding_target == null:
				boarding_target = taxi
	if boarding_target == null:
		push_warning("Passenger: boarding_target não encontrado. Atribua boarding_target_path no Inspector.")

func _physics_process(_delta: float) -> void:
	match state:
		State.WAITING:
			velocity = Vector2.ZERO
			if player_in_range and Input.is_action_just_pressed("chamar"):
				_resolve_boarding_target()
				if boarding_target:
					state = State.WALKING_TO_TAXI
					print("Passageiro a caminho do taxi!")
				else:
					print("Passageiro: sem alvo de embarque!")
		State.WALKING_TO_TAXI:
			if boarding_target == null:
				_resolve_boarding_target()
				if boarding_target == null:
					return
			var to_target := boarding_target.global_position - global_position
			if to_target.length() < 8.0:
				velocity = Vector2.ZERO
				# Fica à espera que a BoardingZone do taxi chame board()
			else:
				velocity = to_target.normalized() * walk_speed
				_update_walk_animation(to_target)
		State.BOARDED:
			velocity = Vector2.ZERO
	move_and_slide()

func _update_walk_animation(to_target: Vector2) -> void:
	if abs(to_target.x) > abs(to_target.y):
		sprite.flip_h = to_target.x > 0
		sprite.play("npc_rivel_left")
	elif to_target.y < 0:
		sprite.play("npc_rival_up")
	else:
		sprite.play("npc_rivel_down")

func board() -> void:
	if state == State.BOARDED:
		return
	state = State.BOARDED
	hide()
	set_physics_process(false)
	if call_range:
		call_range.set_deferred("monitoring", false)
	boarded.emit()

func _on_call_range_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		print("Lotador perto do passageiro — pressione ESPAÇO para chamar")

func _on_call_range_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
