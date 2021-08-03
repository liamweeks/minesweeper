// @dart=2.9
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';
import 'settings.dart';
//import 'constants.dart' as constants;
import 'package:flutter/services.dart';
//import 'settings.dart' as settings;

// ATTENTION
// RUN WITH: flutter run --no-sound-null-safety
// ATTENTION

enum TileState { covered, blown, open, flagged, revealed }

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) {
    runApp(MineSweeper());
  });
}

class MineSweeper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Minesweeper",
        home: Board(colsProp: 9, rowsProp: 9, minesProp: 11));
  }
}

class Board extends StatefulWidget {
  final int rowsProp;
  final int colsProp;
  final int minesProp;
  Board({this.rowsProp, this.colsProp, this.minesProp});
  @override
  BoardState createState() => BoardState(cols: colsProp, rows: rowsProp, mines: minesProp);
}

class BoardState extends State<Board> {
  bool alive;
  bool wonGame;
  int minesFound;
  Timer timer;
  Stopwatch stopwatch = Stopwatch();
  final int rows;
  final int cols;
  final int mines;
  BoardState({this.rows, this.cols, this.mines});

  List<List<TileState>> uiState; // 2D list for rows and cols
  List<List<bool>> tiles; // 2D list for tile states

  void resetBoard() {
    alive = true;
    wonGame = false;
    minesFound = 0;
    stopwatch.reset();

    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {});
    });

    uiState = new List<List<TileState>>.generate(rows, (row) {
      return new List<TileState>.filled(cols, TileState.covered);
    });

    tiles = new List<List<bool>>.generate(rows, (row) {
      return new List<bool>.filled(cols, false);
    });

    Random random = Random();
    int remainingMines = mines;

    while (remainingMines > 0) {
      int row;
      int col;

      //if (rows == cols) {
        int pos = random.nextInt(rows * cols);
        row = pos ~/ rows;
        col = pos % cols;
      // } else {
      //   row = random.nextInt(rows);
      //   col = random.nextInt(cols);
      // }

      if (!tiles[row][col]) {
        tiles[row][col] = true;
        remainingMines--;
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    resetBoard();
    super.initState();
  }

  Widget buildBoard() {
    bool hasCoveredCell = false;
    List<Row> boardRow = <Row>[];
    for (int y = 0; y < rows; y++) {
      List<Widget> rowChildren = <Widget>[];
      for (int x = 0; x < cols; x++) {
        TileState state = uiState[y][x];
        int count = mineCount(x, y);

        if (!alive) {
          if (state != TileState.blown) {
            state = tiles[y][x]
                ? TileState.revealed
                : state; // if the tile has a bomb, open it. else, leave it
          }
        }
        if (state == TileState.covered || state == TileState.flagged && alive) {
          rowChildren.add(GestureDetector(
              onLongPress: () {
                flag(x, y);
                HapticFeedback.lightImpact();
              },
              onTap: () {
                if (state == TileState.covered && alive) {
                  probe(x, y);
                  HapticFeedback.vibrate();
                }
              },
              child: Listener(
                  child: CoveredMineTile(
                flagged: state == TileState.flagged,
                posX: x,
                posY: y,
              ))));
          if (state == TileState.covered) {
            hasCoveredCell = true;
          }
        } else {
          rowChildren.add(OpenMineTile(state: state, count: count));
        }
      }
      boardRow.add(Row(
        children: rowChildren,
        mainAxisAlignment: MainAxisAlignment.center,
        key: ValueKey<int>(y),
      ));
    }
    if (!hasCoveredCell) {
      if ((minesFound == mines) && alive) {
        wonGame = true;
        stopwatch.stop();
      }
    }
    return Container(
        color: Colors.grey[800],
        padding: EdgeInsets.all(10.0),
        child: Column(children: boardRow));
  }

  double columnValue = 9.0;

  @override
  Widget build(BuildContext context) {
    int elapsedTime = stopwatch.elapsedMilliseconds ~/ 1000;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.restart_alt_rounded),
            onPressed: () {
              resetBoard();
            },
          ),
        ],
        leading: IconButton(
            icon: Icon(Icons.storage_rounded),
            onPressed: () {
              Navigator.push(
                context,
                //MaterialPageRoute(builder: (context) => Preferences(this)),
                MaterialPageRoute(builder: (context) => Preferences()),
              );
            }),
        centerTitle: true,
        title: Text("Minesweeper"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(41.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              height: 40.0,
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(
                    text: wonGame
                        ? "You Won! $elapsedTime seconds"
                        : alive
                            ? "[Mines Found: $minesFound] [Total Mines: $mines] [$elapsedTime seconds ]"
                            : "You Lost! $elapsedTime seconds"),
              ),
            )
          ]),
        ),
      ),
      backgroundColor: Colors.grey[800],
      body: Container(
        color: Colors.grey[800],
        child: Center(child: SingleChildScrollView(
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, child: buildBoard()))),
      ),
    );
  }

  void probe(int x, int y) {
    if (!alive) return;
    if (uiState[y][x] == TileState.flagged) return;
    setState(() {
      if (tiles[y][x]) {
        uiState[y][x] = TileState.blown;
        alive = false;
        timer.cancel();
      } else {
        open(x, y);
        if (!stopwatch.isRunning) stopwatch.start();
      }
    });
  }

  void open(int x, int y) {
    if (!inBoard(x, y)) return;
    if (uiState[y][x] == TileState.open) return;
    uiState[y][x] = TileState.open;

    if (mineCount(x, y) > 0) return;

    open(x - 1, y);
    open(x + 1, y);
    open(x, y - 1);
    open(x, y + 1);
    open(x - 1, y - 1);
    open(x + 1, y + 1);
    open(x + 1, y - 1);
    open(x - 1, y + 1);
  }

  void flag(int x, int y) {
    if (!alive) return;
    setState(() {
      if (uiState[y][x] == TileState.flagged) {
        uiState[y][x] = TileState.covered;
        minesFound--;
      } else {
        uiState[y][x] = TileState.flagged;
        minesFound++;
      }
    });
  }

  int mineCount(int x, int y) {
    int count = 0;
    count += bombs(x, y);
    count += bombs(x - 1, y);
    count += bombs(x + 1, y);
    count += bombs(x, y - 1);
    count += bombs(x, y + 1);

    count += bombs(x - 1, y - 1);
    count += bombs(x + 1, y + 1);
    count += bombs(x + 1, y - 1);
    count += bombs(x - 1, y + 1);
    return count;
  }

  int bombs(int x, int y) {
    if (inBoard(x, y) && tiles[y][x]) {
      return 1;
    }
    return 0;
  }

  bool inBoard(int x, int y) =>
      x >= 0 &&
      x < cols &&
      y >= 0 &&
      y < rows; // if the tile is on the board, it returns true
}

Widget buildTile(Widget child) {
  return Container(
      padding: EdgeInsets.all(1.0),
      height: 33.0,
      width: 33.0,
      color: Colors.grey[400],
      margin: EdgeInsets.all(2.0),
      child: child);
}

Widget buildInnerTile(Widget child) {
  return Container(
      padding: EdgeInsets.all(1.0),
      margin: EdgeInsets.all(2.0),
      height: 21.0,
      width: 21.0,
      child: child);
}

class CoveredMineTile extends StatelessWidget {
  final bool flagged;
  final int posX;
  final int posY;

  CoveredMineTile({this.flagged, this.posX, this.posY});

  @override
  Widget build(BuildContext context) {
    Widget text;
    if (flagged) {
      text = buildInnerTile(RichText(
        text: TextSpan(
            text: "\u2691",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )),
        textAlign: TextAlign.center,
      ));
    }

    Widget innerTile = Container(
      padding: EdgeInsets.all(1.0),
      margin: EdgeInsets.all(2.0),
      height: 20.0,
      width: 20.0,
      color: Colors.grey[350],
      child: text,
    );
    return buildTile(innerTile);
  }
}

class OpenMineTile extends StatelessWidget {
  final TileState state; //needs default value
  final int count; // equal to how many tiles adxacent to the current tile have bombs in them
  OpenMineTile({this.count, this.state});

  final textColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.black,
    Colors.grey,
    Colors.amber,
    Colors.teal
  ];

  @override
  Widget build(BuildContext context) {
    Widget text;

    if (state == TileState.open) {
      if (count != 0) {
        text = RichText(
          text: TextSpan(
              text: "$count",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: textColors[count - 1])),
          textAlign: TextAlign.center,
        );
      }
    } else {
      text = RichText(
        text: TextSpan(
            text: "\u2739",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        textAlign: TextAlign.center,
      );
    }
    return buildTile(buildInnerTile(text));
  }
}
