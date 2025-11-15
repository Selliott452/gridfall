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
		
	var delta := target_cell - unit.grid_position
	var manhattan_distance = abs(delta.x) + abs(delta.y)
	if manhattan_distance != 1:
		return false
		
	return true
	
func move_unit(unit: Unit, target_cell: Vector2i) -> void:
	var unit_manager := board.unit_manager
	var grid := board.grid
	
	unit_manager.move_unit(unit, target_cell)
	unit.position = grid.cell_to_world(target_cell)
