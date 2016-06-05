{ createable } = require './createable'
{ Thing } = require './thing'

#
# Direct conversion from code at http://weblog.jamisbuck.org/2010/12/27/maze-generation-recursive-backtracking
#
buildMaze = (width=10, height=10) ->

  pickOne = (lst) -> lst[Math.floor(Math.random() * 4)]

  [N, S, E, W] = [1, 2, 4, 8]
  DIRECTION_LABELS = 1: "North", 2: "South", 4: "East", 8: "West"
  DX  = 4: 1, 8: -1, 1: 0,  2: 0
  DY  = 4: 0, 8: 0,  1: -1, 2: 1
  OPP = 4: W, 8: E,  1: S,  2: N

  carve_passages_from = (cx, cy, grid, iter = 0) ->
    directions = [N, S, W, E].sort () -> Math.random() - 0.5
    for direction in directions
      [nx, ny] = [cx + DX[direction], cy + DY[direction]]
      if 0 <= ny < height
        if 0 <= nx < width
          if grid[ny][nx] is 0
            grid[cy][cx] |= direction
            grid[ny][nx] |= OPP[direction]
            carve_passages_from nx, ny, grid, iter + 1

  grid = ([0..width-1] for x in [0..height-1])

  for y in [0..height-1]
    for x in [0..width-1]
      grid[y][x] = 0

  carve_passages_from 0, 0, grid
  grid

buildMaze.verticalToHorizontalRatio = (grid) ->
  width = grid[0].length
  height = grid.length
  [N, S, E, W] = [1, 2, 4, 8]
  walls = 1: 0, 2: 0, 4: 0, 8: 0
  for y in [0..height-1]
    for x in [0..width-1]
      walls[N] += 1 if grid[y][x] & N
      walls[S] += 1 if grid[y][x] & S
      walls[E] += 1 if grid[y][x] & E
      walls[W] += 1 if grid[y][x] & W
  [walls["1"] / walls["4"], walls[N], walls[S], walls[E], walls[W]]

buildMaze.raw_grid = (grid) ->
  width = grid[0].length
  height = grid.length
  buffer = ""
  for y in [0..height-1]
    for x in [0..width-1]
      buffer += " " + grid[y][x]
    buffer += "\r\n"
  buffer

buildMaze.ascii_grid = (grid) ->
  width = grid[0].length
  height = grid.length
  [N, S, E, W] = [1, 2, 4, 8]
  walls = 1: 0, 2: 0, 4: 0, 8: 0
  buffer = " " + ("" for x in [0..width*2-1]).join("_") + "\r\n"
  for y in [0..height-1]
    buffer += "|"
    for x in [0..width-1]
      walls[N] += 1 if grid[y][x] & N
      walls[S] += 1 if grid[y][x] & S
      walls[E] += 1 if grid[y][x] & E
      walls[W] += 1 if grid[y][x] & W
      buffer += if grid[y][x] & S then " " else "_"
      if grid[y][x] & E
        buffer += if (grid[y][x] | grid[y][x+1]) & S then " " else "_"
      else
        buffer += "|"
    buffer += "\r\n"
  stats = buildMaze.verticalToHorizontalRatio grid
  buffer += stats[0] + "\r\n"
  buffer

class MazeBuilder extends Thing
  constructor: ->
    super

  start: (char, params) ->
    width  = params[0] || +@attr('width')  || 10
    height = params[1] || +@attr('height') || 10
    maxRatio = +@attr("ratio") || 1.5

    grid    = buildMaze width, height
    [ratio] = buildMaze.verticalToHorizontalRatio grid
    while ratio > maxRatio
      grid    = buildMaze width, height
      [ratio] = buildMaze.verticalToHorizontalRatio grid
    buildMaze.ascii_grid grid

  construct: (char, params) ->
    [N, S, E, W] = [1, 2, 4, 8]
    width  = params[0] || +@attr('width')  || 10
    height = params[1] || +@attr('height') || 10

    linkRooms = (r1, d1Label, r2) ->
      d1 = new Door d1Label, destination: r2.gid
      r1.add d1

    grid = buildMaze width, height
    rooms = ([0..width-1] for x in [0..height-1])
    for y in [0..height-1]
      for x in [0..width-1]
        rooms[y][x] = new Room("Maze Room #{x} #{y}")
    for y in [0..height-1]
      for x in [0..width-1]
        linkRooms(rooms[y][x], "East",  rooms[y][x+1]) if grid[y][x] & E
        linkRooms(rooms[y][x], "West",  rooms[y][x-1]) if grid[y][x] & W
        linkRooms(rooms[y][x], "North", rooms[y-1][x]) if grid[y][x] & N
        linkRooms(rooms[y][x], "South", rooms[y+1][x]) if grid[y][x] & S
    debug buildMaze.ascii_grid grid
    "#{rooms[0][0]}"

  interface:
    start:     1
    construct: 1

inter =
  MazeBuilder: MazeBuilder

createable.addObject inter

module.exports = inter
