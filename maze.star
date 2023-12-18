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

LINE_COLOR = "#fff"
CELL_COLOR = "#000"

PAD_X = 0
PAD_Y = 0

def main(config):
    # two dimensional array, 20x10
    # 0,0 is top left
    # 19,9 is bottom right
    board = create_board(MAX_X, MAX_Y)
    boards = []
    solve_maze(0, 0, board, boards)

    return render.Root(
        delay = 30,
        child = render.Padding(
            child = render.Row(
                children=[
                    render.Box(width = 1, height = LINE_WIDTH, color = LINE_COLOR),
                    render.Animation(children=boards)
                ]),
            pad = (PAD_X, PAD_Y, 0, 0)
        )
    )

def randomize_directions():
    directions = []
    available = [N, S, E, W]

    for x in [0, 1, 2, 3]:
        index = random.number(0, len(available) - 1)
        directions.append(available[index])
        available.pop(index)

    return directions


def solve_maze(x, y, board, boards):
    directions = randomize_directions()

    for direction in directions:
        nx = x + DX[direction]
        ny = y + DY[direction]

        if (nx >= 0) and (nx < MAX_X) and (ny >= 0) and (ny < MAX_Y) and board[ny][nx] == EMPTY:
            board[y][x] |= direction
            board[ny][nx] |= OPPOSITE[direction]
            boards.append(render_board(board))
            solve_maze(nx, ny, board, boards)

def render_board(board):
    rows = []

    for y, row in enumerate(board):
        rows.append(render_row(row, y))

    return render.Column(children = rows)

def render_row(row, y):
    cells = []

    for x, cell in enumerate(row):
        cells.append(render_cell(cell, x, y))

    return render.Row(children = cells)

def render_cell(cell, x, y):
    children = [
        render.Box(width = CELL_WIDTH, height = CELL_WIDTH, color = CELL_COLOR)
    ]

    if cell > 0:
        children.append(render.Box(width = LINE_WIDTH, height = LINE_WIDTH, color = LINE_COLOR))

        if x == MAX_X - 1 and y == MAX_Y - 1:
            children.append(render.Box(width = CELL_WIDTH, height = LINE_WIDTH, color = LINE_COLOR))

    if cell & S == S:
        children.append(render.Box(width = LINE_WIDTH, height = CELL_WIDTH, color = LINE_COLOR))

    if cell & E == E:
        children.append(render.Box(width = CELL_WIDTH, height = LINE_WIDTH, color = LINE_COLOR))

    return render.Stack(children = children)

def create_board(width, height):
    """
    Creates a board using the provided witdth and height.
    """
    return [
        [EMPTY for y in range(width)]
        for x in range(height)
    ]
