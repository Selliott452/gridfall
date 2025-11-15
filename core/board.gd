extends Node2D

# How many cells wide and tall the grid is.
@export var grid_size: Vector2i = Vector2i(10,8)

# Size of each tile in pixels
@export var tile_size: Vector2 =  Vector2(64,64)

# Dictonary mapping grid cells to Units
var units_by_cell: Dictionary = {}

var selected_cell: Vector2i = Vector2i(-1, -1)

@onready var player: Unit = $Units/Player
@onready var enemy: Unit = $Units/Enemy

enum TurnState { PLAYER, ENEMY }
var current_turn: TurnState = TurnState.PLAYER
var player_action_used: bool = false

var strike_card: CardAction = preload("res://data/cards/Strike.tres")
var move_card: MoveCardAction = preload("res://data/cards/Move.tres")

var hand: Array[CardAction] = []
var active_card_index: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print ("Board Ready.  GridSize:", grid_size)
	
	# Place player on start cell
	var start_cell: Vector2i = Vector2i(1,1)
	units_by_cell[start_cell] = player
	player.grid_position = start_cell
	player.position = cell_to_world(start_cell)
	
	# Place enemy on start cell
	var enemy_cell: Vector2i = Vector2i(4, 2)
	units_by_cell[enemy_cell] = enemy
	enemy.grid_position = enemy_cell
	enemy.position = cell_to_world(enemy_cell)
	
	print("Units Registered")
	print("units_by_cell keys after setup: ", units_by_cell.keys())
	
	hand.clear()
	hand.append(strike_card)
	hand.append(move_card)
	hand.append(strike_card)

	active_card_index = 0
	print("Hand Registered")
	print_hand()
	
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	
	# Only handle input on player turn
	if current_turn != TurnState.PLAYER:
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		
		match key_event.keycode:
			KEY_1:
				set_active_card_slot(0)
			KEY_2:
				set_active_card_slot(1)
			KEY_3:
				set_active_card_slot(2)
			_:
				pass
		return
	
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		
		# Only handle on left pressed
		if not mouse_event.pressed:
			return
		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
			
		var mouse_pos: Vector2 = mouse_event.position
		var cell: Vector2i = world_to_cell(mouse_pos)
			
		if not is_in_bounds(cell):
			print("Clicked outside grid: ", cell)
			return
			
		selected_cell = cell
		queue_redraw()
		
		var card := get_active_card()
		if card == null:
			print("No active card.")
			return
			
		print("left-clicked call: ", cell, " with card: ", card.name)
		card.play(self, player, cell)
		
		end_player_turn()
			
			
func cell_to_world(cell: Vector2i) -> Vector2:
	# Convert a grid cell coordinate to a 2D world postion.
	return Vector2(
		float(cell.x) * tile_size.x,
		float(cell.y) * tile_size.y
	)

func world_to_cell(pos: Vector2) -> Vector2i:
	# Convert a world position to a grid cell.
	return Vector2i(
		int(floor(pos.x / tile_size.x)),
		int(floor(pos.y / tile_size.y))
	)

func is_in_bounds(cell: Vector2i) -> bool:
	# Check if a cell is inside the grid rectangle.
	return (
		cell.x >= 0 and 
		cell.y >= 0 and 
		cell.x < grid_size.x and 
		cell.y < grid_size.y
	)
	
func get_unit_at(cell: Vector2i) -> Unit:
	return units_by_cell.get(cell, null)
	
func can_move(unit:Unit, target_cell: Vector2i) -> bool:
	# CAn't move out of bounds
	if not is_in_bounds(target_cell):
		print("con_move false: out of bounds: ", target_cell)
		return false
		
	# Can't move onto another unit
	var unit_at_target := get_unit_at(target_cell)
	if unit_at_target != null:
		print("can_move false: cell occupied by: ", unit_at_target.name)
		return false
		
	# Only allow moving 1 tile for now
	var delta := target_cell - unit.grid_position
	var manhattan_distance = abs(delta.x) + abs(delta.y)
	if manhattan_distance != 1:
		print("can_move false: too far. Distance: ", manhattan_distance)
		return false
		
	return true

func can_attack_tile(attacker: Unit, target_cell: Vector2i) -> bool:
	if not is_in_bounds(target_cell):
		print("can_attack false: out of bounds: ", target_cell)
		return false
		
	var target_unit := get_unit_at(target_cell)
	if target_unit == null:
		print("can_attack false: no unit on tile: ", target_cell)
		return false
		
	# Distance check
	var delta := target_cell - attacker.grid_position
	var manhattan_distance = abs(delta.x) + abs(delta.y)
	if manhattan_distance > attacker.attack_range:
		print("can_attack false: target too far.  Dist: ", manhattan_distance)
		return false
		
	return true
	
func attack_tile(attacker: Unit, target_cell: Vector2i) -> void:
	if not can_attack_tile(attacker, target_cell):
		return
		
	var target_unit := get_unit_at(target_cell)
	print(attacker.name, " attacks ", target_unit.name)
	
	target_unit.take_damage(attacker.attack_damage)
	
	if not target_unit.is_inside_tree():
		# Unit died and removed itself
		units_by_cell.erase(target_cell)

func move_unit(unit: Unit, target_cell: Vector2i) -> void:
	#remove from old cell
	if units_by_cell.has(unit.grid_position):
		units_by_cell.erase(unit.grid_position)
		
	# Add to new cell
	units_by_cell[target_cell] = unit
	
	# Update unit data + visual position
	unit.grid_position = target_cell
	unit.position = cell_to_world(target_cell)

func print_hand() -> void:
	print("Hand: ")
	for i in range(hand.size()):
		var card := hand[i]
		var marker := " "
		if i == active_card_index:
			marker = ">"
		print(marker, "slot ", i, "-", card.name)

func get_active_card() -> CardAction:
	if hand.is_empty():
		return null
	return hand[active_card_index]

func set_active_card_slot(index: int) -> void:
	if index < 0 or index >= hand.size():
		print("No card in slot ", index)
		return
		
	active_card_index = index
	print("Selected card slot: ", index, " -> ", hand[index].name)
	print_hand()

func end_player_turn() -> void:
	current_turn = TurnState.ENEMY
	enemy_take_turn()
	
func enemy_take_turn() -> void:
	if not enemy.is_inside_tree():
		print("Enemy is dead.  Player wins!")
		
	var dx := player.grid_position.x - enemy.grid_position.x
	var dy := player.grid_position.y - enemy.grid_position.y
	var delta = abs(dx) + abs(dy)
	
	var attack_range := enemy.attack_range
	
	if delta <= attack_range:
		# enemy is already in range -> attack
		print("Enemy attacks Player!")
		player.take_damage(enemy.attack_damage)
		
		if not player.is_inside_tree():
			print("Player is dead. Game over.")
			return
	else:
		# not in range -> move
		var next_step := enemy.grid_position
		
		if abs(dx) > abs(dy):
			next_step.x += sign(dx)
		else:
			next_step.y += sign(dy)
			
		if is_in_bounds(next_step) and get_unit_at(next_step) == null:
			move_unit(enemy, next_step)
			print("enemy moved to: ", next_step)
		else:
			print("Enemy could not move")
			
	start_player_turn()		
		
func start_player_turn() -> void:
	current_turn = TurnState.PLAYER
	player_action_used = false

func _draw() -> void:
	# Draw a simple rectangle for each cell so we cn see the grid
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var cell := Vector2i(x,y)
			var top_left := cell_to_world(cell)
			var rect := Rect2(top_left, tile_size)
			
			# fill
			draw_rect(rect, Color(0.9, 0.9, 0.9, 1.0), true)
			# Outline
			draw_rect(rect, Color(0.7, 0.7, 0.7, 1.0), false)
	
	# Draw highlight for selected cell
	if is_in_bounds(selected_cell):
		var top_left := cell_to_world(selected_cell)
		var rect := Rect2(top_left, tile_size)
		
		# Slightly transpaent overlay
		draw_rect(rect, Color(1.0, 1.0, 0.0, 0.3), true)
		# Outline
		draw_rect(rect, Color(1.0, 1.0, 0.0, 1.0), false)
