extends Node2D
class_name Unit

@export var max_health: int = 10
@export var attack_damage: int = 3
@export var attack_range: int = 1

var current_health: int
var grid_position: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	current_health -= amount
	
	if current_health < 0:
		current_health = 0
	
	if current_health <= 0:
		die()

func die() -> void:
	queue_free()
