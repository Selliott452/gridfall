extends CardAction
class_name MoveCardAction

@export var max_range: int = 2

func play(board: Node, caster: Unit, target_cell: Vector2i) -> void:
	var delta := target_cell - caster.grid_position
	var manhattan_distance = abs(delta.x) + abs(delta.y)
	
	if manhattan_distance > max_range:
		print(name, " cannot move that far: ", manhattan_distance, " > ", max_range)
		return
		
	if not board.movement.can_move(caster, target_cell):
		print(name, " cannot move to ", target_cell)
		return
		
	print("Playing card: ", name, "moving to ", target_cell)
	board.movement.move_unit(caster, target_cell)
