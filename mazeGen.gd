@tool
extends Node3D
# Maze generator adapted from:
# https://github.com/OrWestSide/python-scripts/blob/master/maze.py

var i_seed = 0

@export var width = 10
@export var height = 10
@export var level_seed = 0:
	set (value):
		i_seed = value
		generate_maze(value)
	get:
		return i_seed

var maze = []

var wall = 'w'
var cell = 'c'
var unvisited = 'u'

var wallSegment = preload("res://wall_segment.tscn")
var nonWall = preload("res://non_wall.tscn")

var space = 2

func printMaze(maze):
	_delete_children(self)
	var y = 0
	for i in range(0, height):
		y += 1
		var x = 0
		var buf = ""
		for j in range(0, width):
			x += 1
			var current = str(maze[i][j])
			if current == "w":
				var seg = wallSegment.instantiate()
				seg.transform.origin.x = x * space
				seg.transform.origin.z = y * space
				
				add_child(seg)
			else:
				var seg = nonWall.instantiate()
				seg.transform.origin.x = x * space
				seg.transform.origin.z = y * space
				
				add_child(seg)
			

func surroundingCells(rand_wall):
	var s_cells = 0
	if (maze[rand_wall[0]-1][rand_wall[1]] == 'c'):
		s_cells += 1
	if (maze[rand_wall[0]+1][rand_wall[1]] == 'c'):
		s_cells += 1
	if (maze[rand_wall[0]][rand_wall[1]-1] == 'c'):
		s_cells +=1
	if (maze[rand_wall[0]][rand_wall[1]+1] == 'c'):
		s_cells += 1

	return s_cells

static func _delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func generate_maze(seed = 0):
	seed(seed)
	maze.clear()
	
	for i in range(0, height):
		var line = []
		for j in range(0, width):
			line.append(unvisited)
		maze.append(line)
	
	var starting_height = randi_range(0, height - 1)
	var starting_width = randi_range(0, width - 1)
	
	if (starting_height == 0):
		starting_height += 1
	if (starting_height == height-1):
		starting_height -= 1
	if (starting_width == 0):
		starting_width += 1
	if (starting_width == width-1):
		starting_width -= 1
		
	maze[starting_height][starting_width] = cell
	var walls = []
	walls.append([starting_height - 1, starting_width])
	walls.append([starting_height, starting_width - 1])
	walls.append([starting_height, starting_width + 1])
	walls.append([starting_height + 1, starting_width])

	# Denote walls in maze
	maze[starting_height-1][starting_width] = 'w'
	maze[starting_height][starting_width - 1] = 'w'
	maze[starting_height][starting_width + 1] = 'w'
	maze[starting_height + 1][starting_width] = 'w'
	
	while (walls):
		# Pick a random wall
		var rand_wall = walls[int(randi_range(0, len(walls)))-1]

		# Check if it is a left wall
		if (rand_wall[1] != 0):
			if (maze[rand_wall[0]][rand_wall[1]-1] == 'u' and maze[rand_wall[0]][rand_wall[1]+1] == 'c'):
				# Find the number of surrounding cells
				var s_cells = surroundingCells(rand_wall)

				if (s_cells < 2):
					# Denote the new path
					maze[rand_wall[0]][rand_wall[1]] = 'c'

					# Mark the new walls
					# Upper cell
					if (rand_wall[0] != 0):
						if (maze[rand_wall[0]-1][rand_wall[1]] != 'c'):
							maze[rand_wall[0]-1][rand_wall[1]] = 'w'
						if ([rand_wall[0]-1, rand_wall[1]] not in walls):
							walls.append([rand_wall[0]-1, rand_wall[1]])


					# Bottom cell
					if (rand_wall[0] != height-1):
						if (maze[rand_wall[0]+1][rand_wall[1]] != 'c'):
							maze[rand_wall[0]+1][rand_wall[1]] = 'w'
						if ([rand_wall[0]+1, rand_wall[1]] not in walls):
							walls.append([rand_wall[0]+1, rand_wall[1]])

					# Leftmost cell
					if (rand_wall[1] != 0):	
						if (maze[rand_wall[0]][rand_wall[1]-1] != 'c'):
							maze[rand_wall[0]][rand_wall[1]-1] = 'w'
						if ([rand_wall[0], rand_wall[1]-1] not in walls):
							walls.append([rand_wall[0], rand_wall[1]-1])
				

				# Delete wall
				for wall in walls:
					if (wall[0] == rand_wall[0] and wall[1] == rand_wall[1]):
						walls.erase(wall)

				continue

		# Check if it is an upper wall
		if (rand_wall[0] != 0):
			if (maze[rand_wall[0]-1][rand_wall[1]] == 'u' and maze[rand_wall[0]+1][rand_wall[1]] == 'c'):

				var s_cells = surroundingCells(rand_wall)
				if (s_cells < 2):
					# Denote the new path
					maze[rand_wall[0]][rand_wall[1]] = 'c'

					# Mark the new walls
					# Upper cell
					if (rand_wall[0] != 0):
						if (maze[rand_wall[0]-1][rand_wall[1]] != 'c'):
							maze[rand_wall[0]-1][rand_wall[1]] = 'w'
						if ([rand_wall[0]-1, rand_wall[1]] not in walls):
							walls.append([rand_wall[0]-1, rand_wall[1]])

					# Leftmost cell
					if (rand_wall[1] != 0):
						if (maze[rand_wall[0]][rand_wall[1]-1] != 'c'):
							maze[rand_wall[0]][rand_wall[1]-1] = 'w'
						if ([rand_wall[0], rand_wall[1]-1] not in walls):
							walls.append([rand_wall[0], rand_wall[1]-1])

					# Rightmost cell
					if (rand_wall[1] != width-1):
						if (maze[rand_wall[0]][rand_wall[1]+1] != 'c'):
							maze[rand_wall[0]][rand_wall[1]+1] = 'w'
						if ([rand_wall[0], rand_wall[1]+1] not in walls):
							walls.append([rand_wall[0], rand_wall[1]+1])

				# Delete wall
				for wall in walls:
					if (wall[0] == rand_wall[0] and wall[1] == rand_wall[1]):
						walls.erase(wall)

				continue

		# Check the bottom wall
		if (rand_wall[0] != height-1):
			if (maze[rand_wall[0]+1][rand_wall[1]] == 'u' and maze[rand_wall[0]-1][rand_wall[1]] == 'c'):

				var s_cells = surroundingCells(rand_wall)
				if (s_cells < 2):
					# Denote the new path
					maze[rand_wall[0]][rand_wall[1]] = 'c'

					# Mark the new walls
					if (rand_wall[0] != height-1):
						if (maze[rand_wall[0]+1][rand_wall[1]] != 'c'):
							maze[rand_wall[0]+1][rand_wall[1]] = 'w'
						if ([rand_wall[0]+1, rand_wall[1]] not in walls):
							walls.append([rand_wall[0]+1, rand_wall[1]])
					if (rand_wall[1] != 0):
						if (maze[rand_wall[0]][rand_wall[1]-1] != 'c'):
							maze[rand_wall[0]][rand_wall[1]-1] = 'w'
						if ([rand_wall[0], rand_wall[1]-1] not in walls):
							walls.append([rand_wall[0], rand_wall[1]-1])
					if (rand_wall[1] != width-1):
						if (maze[rand_wall[0]][rand_wall[1]+1] != 'c'):
							maze[rand_wall[0]][rand_wall[1]+1] = 'w'
						if ([rand_wall[0], rand_wall[1]+1] not in walls):
							walls.append([rand_wall[0], rand_wall[1]+1])

				# Delete wall
				for wall in walls:
					if (wall[0] == rand_wall[0] and wall[1] == rand_wall[1]):
						walls.erase(wall)


				continue

		# Check the right wall
		if (rand_wall[1] != width-1):
			if (maze[rand_wall[0]][rand_wall[1]+1] == 'u' and maze[rand_wall[0]][rand_wall[1]-1] == 'c'):

				var s_cells = surroundingCells(rand_wall)
				if (s_cells < 2):
					# Denote the new path
					maze[rand_wall[0]][rand_wall[1]] = 'c'

					# Mark the new walls
					if (rand_wall[1] != width-1):
						if (maze[rand_wall[0]][rand_wall[1]+1] != 'c'):
							maze[rand_wall[0]][rand_wall[1]+1] = 'w'
						if ([rand_wall[0], rand_wall[1]+1] not in walls):
							walls.append([rand_wall[0], rand_wall[1]+1])
					if (rand_wall[0] != height-1):
						if (maze[rand_wall[0]+1][rand_wall[1]] != 'c'):
							maze[rand_wall[0]+1][rand_wall[1]] = 'w'
						if ([rand_wall[0]+1, rand_wall[1]] not in walls):
							walls.append([rand_wall[0]+1, rand_wall[1]])
					if (rand_wall[0] != 0):	
						if (maze[rand_wall[0]-1][rand_wall[1]] != 'c'):
							maze[rand_wall[0]-1][rand_wall[1]] = 'w'
						if ([rand_wall[0]-1, rand_wall[1]] not in walls):
							walls.append([rand_wall[0]-1, rand_wall[1]])

				# Delete wall
				for wall in walls:
					if (wall[0] == rand_wall[0] and wall[1] == rand_wall[1]):
						walls.erase(wall)

				continue

		# Delete the wall from the list anyway
		for wall in walls:
			if (wall[0] == rand_wall[0] and wall[1] == rand_wall[1]):
				walls.erase(wall)
	
	for i in range(0, height):
		for j in range(0, width):
			if (maze[i][j] == 'u'):
				maze[i][j] = 'w'
	
	for i in range(0, width):
		if (maze[1][i] == 'c'):
			maze[0][i] = 'c'
			break

	for i in range(width-1, 0, -1):
		if (maze[height-2][i] == 'c'):
			maze[height-1][i] = 'c'
			break
	
	printMaze(maze)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

