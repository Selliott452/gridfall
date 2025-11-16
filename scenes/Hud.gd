extends Control
class_name Hud

signal end_turn_pressed

@onready var player_hp_bar: ProgressBar = $TopRow/PlayerHPBar
@onready var player_hp_label: Label = $TopRow/PlayerHPBar/PlayerHPLabel

@onready var enemy_hp_bar: ProgressBar = $TopRow/EnemyHPBar
@onready var enemy_hp_label: Label = $TopRow/EnemyHPBar/EnemyHPLabel

@onready var turn_label: Label = $TopRow/TurnLabel

@onready var stamina_bar: ProgressBar = $"../BottomRightUI/BottomBar/StaminaBar"
@onready var stamina_label: Label = $"../BottomRightUI/BottomBar/StaminaBar/StaminaLabel"
@onready var end_turn_button: Button = $"../BottomRightUI/BottomBar/EndTurnButton"

func _ready() -> void:
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	
func _on_end_turn_button_pressed() -> void:
	end_turn_pressed.emit()

func set_end_turn_enabled(enabled: bool) -> void:
	end_turn_button.disabled = not enabled
	
func update(player, enemy, current_turn: int, current_stamina: int, max_stamina: int) -> void:
	#player HP
	var player_ratio := 0.0
	if player != null and is_instance_valid(player) and player.is_inside_tree():
		player_hp_label.text = "Player: %d/%d" % [player.current_health, player.max_health]
		if player.max_health > 0:
			player_ratio = clamp(float(player.current_health) / float(player.max_health), 0.0, 1.0)
	else:
		player_hp_label.text = "Player: DEAD"
		player_ratio = 0.0
		
	player_hp_bar.value = player_ratio * 100.0
		
	#enemy HP
	var enemy_ratio := 0.0
	if enemy != null and is_instance_valid(enemy) and enemy.is_inside_tree():
		enemy_hp_label.text = "Enemy: %d/%d" % [enemy.current_health, enemy.max_health]
		if enemy.max_health > 0:
			enemy_ratio = clamp(float(enemy.current_health) / float(enemy.max_health), 0.0, 1.0)
	else:
		enemy_hp_label.text = "Enemy: DEAD"
		enemy_ratio = 0.0
		
	enemy_hp_bar.value = enemy_ratio * 100.0
	
	#turn Label
	match current_turn:
		0:
			turn_label.text = "Turn: Player"
		1:
			turn_label.text = "Turn: Enemey"
		_:
			turn_label.text = "Turn: ?"
			
	# Stamina
	var stam_ratio := 0.0
	if max_stamina > 0:
		stam_ratio = clamp(float(current_stamina) / float(max_stamina), 0.0, 1.0)
		
	stamina_label.text = "Stamina: %d/%d" % [current_stamina, max_stamina]
	
	stamina_bar.value = stam_ratio * 100.0
