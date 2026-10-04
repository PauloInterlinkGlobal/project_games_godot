extends CharacterBody2D

signal tutorial_completed

enum State { DRIVING_IN, STOPPED, DEPARTING }

@export var drive_speed: float = 150.0
## Ponto de entrada (fora da tela à esquerda)
@export var start_point: Vector2 = Vector2(-622, 340)
## Paragem no meio do cenário (perto das paragens de autocarro)
@export var stop_point: Vector2 = Vector2(120, 340)
## Saída à direita
@export var exit_point: Vector2 = Vector2(1873, 338)

var state: State = State.DRIVING_IN
var passenger_boarded: bool = false

@onready var boarding_zone: Area2D = $BoardingZone

func _ready() -> void:
	global_position = start_point
	# Garante que a zona de embarque existe e está ligada
	if boarding_zone == null:
		push_error("Taxi: BoardingZone não encontrada! Adicione um Area2D chamado 'BoardingZone' como filho do taxi.")
		return
	boarding_zone.monitoring = true
	boarding_zone.monitorable = true
	if not boarding_zone.body_entered.is_connected(_on_boarding_zone_body_entered):
		boarding_zone.body_entered.connect(_on_boarding_zone_body_entered)
	add_to_group("taxi")

func _physics_process(_delta: float) -> void:
	match state:
		State.DRIVING_IN:
			_move_towards(stop_point)
			if global_position.distance_to(stop_point) < 4.0:
				global_position = stop_point
				velocity = Vector2.ZERO
				state = State.STOPPED
				print("Taxi parou na paragem. Lotador pode chamar o passageiro (Espaço).")
		State.STOPPED:
			velocity = Vector2.ZERO
		State.DEPARTING:
			_move_towards(exit_point)
			if global_position.distance_to(exit_point) < 4.0:
				_finish_tutorial()
	move_and_slide()

func _move_towards(target: Vector2) -> void:
	var to_target := target - global_position
	if to_target.length() > 2.0:
		velocity = to_target.normalized() * drive_speed
	else:
		velocity = Vector2.ZERO

func _on_boarding_zone_body_entered(body: Node) -> void:
	if state != State.STOPPED or passenger_boarded:
		return
	if body.is_in_group("passenger"):
		passenger_boarded = true
		if body.has_method("board"):
			body.board()
		print("Passageiro subiu no taxi!")
		await get_tree().create_timer(0.6).timeout
		state = State.DEPARTING
		print("Taxi a partir...")

func _finish_tutorial() -> void:
	velocity = Vector2.ZERO
	set_physics_process(false)
	print("Tutorial concluído!")
	tutorial_completed.emit()
