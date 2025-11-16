extends Node
class_name CombatSystem

var board: Board

func _ready() -> void:
	board = get_parent() as Board
	
func can_attack_tile(attacker: Unit, target_cell: Vector2i) -> bool:
	var grid := board.grid
	var unit_manager := board.unit_manager
	
	# Clean up stale units for safety
	unit_manager.cleanup()
	
	if not grid.is_in_bounds(target_cell):
		return false
		
	var target_unit := unit_manager.get_unit_at(target_cell)
	if target_unit == null:
		return false
		
	var delta := target_cell - attacker.grid_position
	var manhattan_distance = abs(delta.x) + abs(delta.y)
	if manhattan_distance > attacker.attack_range:
		return false
		
	return true
	
func attack_tile(attacker: Unit, target_cell: Vector2i) -> void:
	if not can_attack_tile(attacker, target_cell):
		return
	
	var unit_manager := board.unit_manager
	var target_unit := unit_manager.get_unit_at(target_cell)
	if target_unit == null:
		return
		
	print(attacker.name, " attacks ", target_unit.name)
		
	target_unit.take_damage(attacker.attack_damage)
	board.hud.update(
		board.player,
		board.enemy,
		 board.turn_manager.current_turn,
		 board.turn_manager.current_stamina,
		 board.turn_manager.max_stamina
		)
		
	# if the unit died and removed itself, clean up
	if not is_instance_valid(target_unit) or not target_unit.is_inside_tree():
		unit_manager.remove_unit(target_unit)
			
		if target_unit == board.enemy:
			board.enemy = null
