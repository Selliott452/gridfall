extends CardAction
class_name MoveCardAction

@export var max_range: int = 2

func _init() -> void:
	card_type = CardType.MOVE

func play(board: Node, caster: Unit, target_cell: Vector2i) -> bool:
	var delta := target_cell - caster.grid_position
	var manhattan_distance = abs(delta.x) + abs(delta.y)

	if manhattan_distance <= 0 or manhattan_distance > max_range:
		print(name, "cannot move that far:", manhattan_distance, ">", max_range)
		return false

	if not board.movement.is_path_clear(caster, target_cell, max_range):
		print(name, "path blocked to", target_cell)
		return false

	print("Playing card:", name, "moving to", target_cell)
	board.movement.move_unit(caster, target_cell)
	return true
