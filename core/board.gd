extends Node2D
class_name Board

@export var damage_popup_scene: PackedScene

@onready var hud: Hud = $UI/RootUI/TopBar

@onready var grid: Grid = $Grid
@onready var unit_manager: UnitManager = $UnitManager
@onready var turn_manager: TurnManager = $TurnManager
@onready var movement: MovementSystem = $MovementSystem
@onready var combat: CombatSystem = $CombatSystem
@onready var card_system: CardSystem = $CardSystem

@onready var player: Unit = $Units/Player
@onready var enemy: Enemy = $Units/Enemy

@export var level_index: int = 0

var strike_card: CardAction = preload("res://data/cards/Strike.tres")
var move_card: MoveCardAction = preload("res://data/cards/Move.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hud.end_turn_pressed.connect(_on_end_turn_pressed)
	
	# load level data
	var level: Dictionary = Levels.get_level(level_index)
	grid.grid_size = level["grid_size"]
	grid.set_walls(level["walls"])
	grid.rebuild()
	
	
	# Place player on start cell
	var start_cell: Vector2i = level["player_start"]
	unit_manager.register_unit(player, start_cell)
	player.grid_position = start_cell
	player.position = grid.cell_to_world(start_cell)
	
	# Place enemy on start cell
	var enemy_cell: Vector2i = start_cell + Vector2i(2, 0)
	var enemy_starts: Array[Vector2i] = level["enemy_starts"]
	if enemy_starts.size() > 0:
		enemy_cell = enemy_starts[0]
		unit_manager.register_unit(enemy, enemy_cell)
		enemy.grid_position = enemy_cell
		enemy.position = grid.cell_to_world(enemy_cell)
	
	print("Units Registered")
	
	var starting_hand: Array[CardAction] = []
	starting_hand.append(strike_card)
	starting_hand.append(move_card)
	starting_hand.append(strike_card)
	
	card_system.set_starting_hand(starting_hand)
	
	turn_manager.start_player_turn()
	
	card_system.active_card_changed.connect(_on_active_card_changed)
	
	update_tile_highlighting()
	
	queue_redraw()

func _on_active_card_changed(card: CardAction) -> void:
	update_tile_highlighting()

func _on_end_turn_pressed() -> void:
	# Only react on player's turn
	if turn_manager.current_turn != TurnManager.TurnState.PLAYER:
		return

	print("End Turn button pressed.")
	turn_manager.end_player_turn()

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
			
		if card.cost > turn_manager.current_stamina:
			print("not enough stamina to play ", card.name)
			return
			
		print("left-clicked call: ", cell, " with card: ", card.name)
		var success := card.play(self, player, cell)
		
		if not success:
			return
			
		turn_manager.current_stamina -= card.cost
		
		hud.update(player, enemy, turn_manager.current_turn, turn_manager.current_stamina, turn_manager.max_stamina)
		update_tile_highlighting()

func update_tile_highlighting() -> void:
	var card := card_system.get_active_card()
	
	# No card or not turn don't highlight
	if card == null or turn_manager.current_turn != TurnManager.TurnState.PLAYER:
		grid.clear_highlight_cells()
		return
		
	# can't afford card don't highlight
	if card.cost > turn_manager.current_stamina:
		grid.clear_highlight_cells()
		return
	
	# No card selectd or not players turn = no highlights
	if card == null or turn_manager.current_turn != TurnManager.TurnState.PLAYER:
		grid.clear_highlight_cells()
		return
		
	var cells: Array[Vector2i] = []
	
	match card.card_type:
	# Movement card: show empty cells within range
		CardAction.CardType.MOVE:
			var origin := player.grid_position
			var max_range = card.max_range
			
			for x in range(grid.grid_size.x):
				for y in range(grid.grid_size.y):
					var cell := Vector2i(x,y)
					var dist = abs(cell.x - origin.x) + abs(cell.y - origin.y)
					if dist == 0 or dist > max_range:
						continue
					if not grid.is_in_bounds(cell):
						continue
					if grid.is_wall(cell):
						continue
					if unit_manager.get_unit_at(cell) != null:
						continue
					if not movement.is_path_clear(player, cell, max_range):
						continue
					cells.append(cell)
					
			grid.set_highlight_cells(cells, Color(0.3, 0.7, 1.0, 0.4))
			
		CardAction.CardType.ATTACK:
			# Assume attack for now highlight enemy tiles in range
			var origin := player.grid_position
			var max_range := player.attack_range
			
			for x in range(grid.grid_size.x):
				for y in range(grid.grid_size.y):
					var cell := Vector2i(x,y)
					var dist = abs(cell.x - origin.x) + abs(cell.y - origin.y)
					if dist == 0 or dist > max_range:
						continue
						
					var unit = unit_manager.get_unit_at(cell)
					if unit == null or unit == player:
						continue
						
					cells.append(cell)
					
			grid.set_highlight_cells(cells, Color(1.0, 0.3, 0.3, 0.4))
		
		_:
			# Other card types: no highlight for now
			grid.clear_highlight_cells()
			
func show_damage_popup(amount: int, world_position: Vector2, is_heal: bool = false) -> void:
	if damage_popup_scene == null:
		return
		
	var popup := damage_popup_scene.instantiate() as DamagePopup
	add_child(popup)
	popup.position = world_position + Vector2(0, -10)
	popup.show_value(amount, is_heal)
