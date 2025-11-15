extends Control
class_name Hud

@onready var player_hp_label: Label = $TopRow/PlayerHPLabel
@onready var enemy_hp_label: Label = $TopRow/EnemyHPLabel
@onready var turn_label: Label = $TopRow/TurnLabel

func update(player, enemy, current_turn: int) -> void:
	#player HP
	if player != null and is_instance_valid(player) and player.is_inside_tree():
		player_hp_label.text = "Player: %d/%d" % [player.current_health, player.max_health]
	else:
		player_hp_label.text = "Player: DEAD"
		
	#enemy HP
	if enemy != null and is_instance_valid(enemy) and enemy.is_inside_tree():
		enemy_hp_label.text = "Enemy: %d/%d" % [enemy.current_health, enemy.max_health]
	else:
		enemy_hp_label.text = "Enemy: DEAD"
		
	#turn Label
	match current_turn:
		0:
			turn_label.text = "Turn: Player"
		1:
			turn_label.text = "Turn: Enemey"
		_:
			turn_label.text = "Turn: ?"
