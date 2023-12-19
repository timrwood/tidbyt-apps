# A simple clock applet

load("random.star", "random")
load("render.star", "render")
load("time.star", "time")

EMPTY = 0

N = 1
S = 2
E = 4
W = 8

DIRECTIONS = [N, S, E, W]

DX = {E: 1, W: -1, N: 0, S: 0}
DY = {E: 0, W: 0, N: -1, S: 1}
OPPOSITE = {E: W, W: E, N: S, S: N}

MAX_X = 21
MAX_Y = 11

CELL_WIDTH = 3
LINE_WIDTH = 2

LINE_COLOR = "#fbe5b8"
TAIL_COLOR = "#f9a96e"
HEAD_COLOR = "#de3a20"
CELL_COLOR = "#000"

PAD_X = 1
PAD_Y = 0

def main(config):
    board = create_board(MAX_X, MAX_Y)
    order = create_board(MAX_X, MAX_Y)
    sx = random.number(0, MAX_X - 1)
    sy = random.number(0, MAX_Y - 1)

    solve_maze(sx, sy, board, order)

    return render.Root(
        delay = 30,
        child = render.Padding(
            child = render.Animation(children=render_boards(board, order)),
            pad = (PAD_X, PAD_Y, 0, 0)
        )
    )

def max_in_order(order):
    max = 0
    for x in order:
        for y in x:
            if y > max:
                max = y

    return max

def render_boards(board, order):
    boards = []

    max = max_in_order(order)

    for i in range(0, max + 1):
        boards.append(render_board(board, order, i))

    for i in range(0, 60):
        boards.append(render_board(board, order, max + 2))

    for i in range(0, max):
        boards.append(render_board(board, order, -i - 1))

    for i in range(0, 10):
        boards.append(render.Box(width = CELL_WIDTH, height = CELL_WIDTH, color = CELL_COLOR))

    return boards

def randomize_directions():
    directions = []
    available = [N, S, E, W]

    for x in range(0, 4):
        index = random.number(0, len(available) - 1)
        directions.append(available[index])
        available.pop(index)

    return directions

def solve_maze(x, y, board, order):
    directions = randomize_directions()


    for direction in directions:
        nx = x + DX[direction]
        ny = y + DY[direction]

        if (nx >= 0) and (nx < MAX_X) and (ny >= 0) and (ny < MAX_Y) and board[ny][nx] == EMPTY:
            board[y][x] |= direction
            board[ny][nx] |= OPPOSITE[direction]
            order[ny][nx] = order[y][x] + 1
            solve_maze(nx, ny, board, order)

def render_board(board, order, i):
    rows = []

    for y, row in enumerate(board):
        rows.append(render_row(row, y, order, i))

    return render.Column(children = rows)

def render_row(row, y, order, i):
    cells = []

    for x, cell in enumerate(row):
        cells.append(render_cell(cell, x, y, order, i))

    return render.Row(children = cells)

def render_cell(cell, x, y, order, i):
    children = [
        render.Box(width = CELL_WIDTH, height = CELL_WIDTH, color = CELL_COLOR)
    ]

    color = LINE_COLOR

    if i >= 0 and order[y][x] >= i:
        color = CELL_COLOR

    if i < 0 and order[y][x] < -i:
        color = CELL_COLOR

    if (i == order[y][x] + 1) or (-i == order[y][x] - 1):
        color = TAIL_COLOR

    if i == order[y][x] or -i == order[y][x]:
        color = HEAD_COLOR

    if cell > 0:
        children.append(render.Box(width = LINE_WIDTH, height = LINE_WIDTH, color = color))

    if cell & S == S:
        children.append(render.Box(width = LINE_WIDTH, height = CELL_WIDTH, color = color))

    if cell & E == E:
        children.append(render.Box(width = CELL_WIDTH, height = LINE_WIDTH, color = color))

    return render.Stack(children = children)

def create_board(width, height):
    """
    Creates a board using the provided witdth and height.
    """
    return [
        [EMPTY for y in range(width)]
        for x in range(height)
    ]
