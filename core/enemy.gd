extends Unit
class_name Enemy

func take_turn(board) -> void:
	# Don't act if we're not actually in the scene anymore
	if not is_inside_tree():
		return
		
	var player = board.player
	
	if player == null or not is_instance_valid(player) or not player.is_inside_tree():
		print("Enemy has no valid player to act on.")
		return
	
	# Compute distance to player
	var dx = player.grid_position.x - grid_position.x
	var dy = player.grid_position.y - grid_position.y
	var distance = abs(dx) + abs(dy)
	
	#If in range, attack
	if distance <= attack_range:
		print(name, " attacks Player!")
		player.take_damage(attack_damage)
		
		# Update HUD
		board.hud.update(player, board.enemy, board.turn_manager.current_turn)
		
		return
		
	# Otherwise move toward player
	var next_cell := grid_position
	
	if abs(dx) > abs(dy):
		next_cell.x += sign(dx)
	else:
		next_cell.y += sign(dy)
		
	if board.movement.can_move(self, next_cell):
		board.movement.move_unit(self, next_cell)
		print("Enemy moved to: ", next_cell)
	else:
		print("Enemy could not move")
