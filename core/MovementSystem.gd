extends Node
class_name MovementSystem

var board: Board

func _ready() -> void:
	board = get_parent() as Board
	
func can_move(unit: Unit, target_cell: Vector2i) -> bool:
	var grid := board.grid
	var unit_manager := board.unit_manager
	
	# Bounds check
	if not grid.is_in_bounds(target_cell):
		return false
		
	# Occupancy check
	if unit_manager.get_unit_at(target_cell) != null:
		return false
		
	# wall check
	if grid.is_wall(target_cell):
		return false
		
	# No distance checks here - callers will decide rules	
	return true

func is_path_clear(unit: Unit, target_cell: Vector2i, max_steps: int) -> bool:
	var grid := board.grid
	var unit_manager := board.unit_manager
	
	var start = unit.grid_position
	var delta = target_cell - start
	var distance = abs(delta.x) + abs(delta.y)
	
	if distance <= 0 or distance > max_steps:
		return false
		
	# for now only straight lines
	var dir := Vector2i.ZERO
	if delta.x != 0 and delta.y == 0:
		dir = Vector2i(sign(delta.x), 0)
	elif delta.y != 0 and delta.x == 0:
		dir = Vector2i(0, sign(delta.y))
	else:
		return false
		
	var current = start
		
	for i in range(distance):
		current += dir
		
		if not grid.is_in_bounds(current):
			return false
			
		if grid.is_wall(current):
			return false
			
		var occupant := unit_manager.get_unit_at(current)
		if occupant != null and occupant != unit:
			return false
			
	return true
	
func move_unit(unit: Unit, target_cell: Vector2i) -> void:
	var unit_manager := board.unit_manager
	var grid := board.grid
	
	unit_manager.move_unit(unit, target_cell)
	unit.position = grid.cell_to_world(target_cell)
