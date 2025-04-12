extends Power

@onready var interaction_area: Area2D = $InteractionArea
@onready var lever: Sprite2D = $lever

var is_player_in_area : bool = false

func _ready() -> void:
	lever.frame = int(on)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Interact") and is_player_in_area:
		on = !on
		lever.frame = int(on)
	print(on)

func _on_interaction_area_body_entered(body: Node2D) -> void:
	is_player_in_area = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	is_player_in_area = false
