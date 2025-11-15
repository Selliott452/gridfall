extends Node2D
class_name Board

@onready var hud: Hud = $UI/RootUI/TopBar

@onready var grid: Grid = $Grid
@onready var unit_manager: UnitManager = $UnitManager
@onready var turn_manager: TurnManager = $TurnManager
@onready var movement: MovementSystem = $MovementSystem
@onready var combat: CombatSystem = $CombatSystem
@onready var card_system: CardSystem = $CardSystem

@onready var player: Unit = $Units/Player
@onready var enemy: Enemy = $Units/Enemy

var strike_card: CardAction = preload("res://data/cards/Strike.tres")
var move_card: MoveCardAction = preload("res://data/cards/Move.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Place player on start cell
	var start_cell: Vector2i = Vector2i(1,1)
	unit_manager.register_unit(player, start_cell)
	player.position = grid.cell_to_world(start_cell)
	
	# Place enemy on start cell
	var enemy_cell: Vector2i = Vector2i(4, 2)
	unit_manager.register_unit(enemy, enemy_cell)
	enemy.position = grid.cell_to_world(enemy_cell)
	
	print("Units Registered")
	
	var starting_hand: Array[CardAction] = []
	starting_hand.append(strike_card)
	starting_hand.append(move_card)
	starting_hand.append(strike_card)
	
	card_system.set_starting_hand(starting_hand)
	
	turn_manager.start_player_turn()
	
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	
	# Only handle input on player turn
	if turn_manager.current_turn != TurnManager.TurnState.PLAYER:
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		card_system.handle_number_key(key_event.keycode)
		return
	
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		
		# Only handle on left pressed
		if not mouse_event.pressed:
			return
		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
			
		var mouse_pos: Vector2 = mouse_event.position
		var cell: Vector2i = grid.world_to_cell(mouse_pos)
			
		if not grid.is_in_bounds(cell):
			print("Clicked outside grid: ", cell)
			return
			
		grid.set_selected_cell(cell)
		queue_redraw()
		
		var card = card_system.get_active_card()
		if card == null:
			print("No active card.")
			return
			
		print("left-clicked call: ", cell, " with card: ", card.name)
		card.play(self, player, cell)
		
		turn_manager.end_player_turn()
