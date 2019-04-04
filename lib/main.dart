import 'package:flutter/material.dart'; // material package
import 'package:flutter/services.dart'; // Fullscreen package

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]); // Fullscreen

    // return App
    return MaterialApp(
      title: 'Saper',
      home: Scaffold(
        body: BoardWidget(),
      ),
    );
  }
}      

class BoardWidget extends StatefulWidget {
  @override
  _BoardWidgetState createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  List<List<Color>> color = List<List<Color>>();    // color of every tile
  List<List<bool>> isOpened = List<List<bool>>();   // is every tile opened
  List<List<Square>> values = List<List<Square>>(); // hasBomb and bombsNear for every tile
  final int rows = 14, columns = 25, bombs = 36;    // how many rows, columns and bombs are in
  int winCount = 0; // win count if it's equal rows*columns - bombs (you won)

  // On create reset everything
  _BoardWidgetState() {
    _reset();
  }

  // Tile Widget
  Widget _square(int r, int c) {
    return InkWell(
      onTap: isOpened[r][c] ? null : () => _openTileHandle(r, c), // if it's already opened prevent user from clicking, else _openTileHandle
      onLongPress: isOpened[r][c] ? null : () => _flag(r, c), // Flag the square if you can
      child: Container(
        width: 25.5,
        height: 25.5,
        decoration: BoxDecoration(
          // TODO: Simplify border
          // border: Border.all(color: color[r][c] == Colors.yellow[300] ? Colors.yellow[300] : color[r][c] == Colors.green[300] ? Colors.green[300] : Colors.white, width: 0.5, style: BorderStyle.solid),
          border:  color[r][c] != Colors.red[300] ? null : Border.all(color: Colors.white, width: 0.5, style: BorderStyle.solid),
          color: color[r][c],
        ),
        child: Center(
          child: Text(
            color[r][c] != Colors.yellow[300] || values[r][c].nearBombs == 0 ? '' : values[r][c].nearBombs.toString(), // no Text if bombs are 0 or if the color is != yellow
            //r.toString() + ' ' + c.toString(), // helper to show r and c indexes on the screen
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(int c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _square(0, c),
        _square(1, c),
        _square(2, c),
        _square(3, c),
        _square(4, c),
        _square(5, c),
        _square(6, c),
        _square(7, c),
        _square(8, c),
        _square(9, c),
        _square(10, c),
        _square(11, c),
        _square(12, c),
        _square(13, c),
      ],
    );
  }

  Widget _column() {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _row(0),
        _row(1),
        _row(2),
        _row(3),
        _row(4),
        _row(5),
        _row(6),
        _row(7),
        _row(8),
        _row(9),
        _row(10),
        _row(11),
        _row(12),
        _row(13),
        _row(14),
        _row(15),
        _row(16),
        _row(17),
        _row(18),
        _row(19),
        _row(20),
        _row(21),
        _row(22),
        _row(23),
        _row(24),
        
      ],
    );
  }

  // Reset all UI vars
  void _reset() {
    color = List<List<Color>>.generate(rows, (i) => List<Color>.generate(columns, (j) => Colors.red[300]));
    isOpened = List<List<bool>>.generate(rows, (i) => List<bool>.generate(columns, (j) => false));
    _resetGame();
  }

  // reset all game vars
  void _resetGame() {
    values = List<List<Square>>.generate(rows, (i) => List<Square>.generate(columns, (j) => Square(0, false)));
    _bombGenerator();
    _nearBombGenerator();
    winCount = 0;
  }

  // Handle winning
  void _winHandle() {
    // make bomb everywhere so if you press on any tile your game will reset
    values = List<List<Square>>.generate(rows, (i) => List<Square>.generate(columns, (j) => Square(0, true)));
    // yellow everywhere 
    color = List<List<Color>>.generate(rows, (i) => List<Color>.generate(columns, (j) => Colors.yellow[300]));
    // you can open any tile from now on
    isOpened = List<List<bool>>.generate(rows, (i) => List<bool>.generate(columns, (j) => false));

    // red smile
    color[3][4] = Colors.red[300];
    color[4][4] = Colors.red[300];
    color[3][5] = Colors.red[300];
    color[4][5] = Colors.red[300];
    color[9][4] = Colors.red[300];
    color[10][4] = Colors.red[300];
    color[9][5] = Colors.red[300];
    color[10][5] = Colors.red[300];
    color[1][9] = Colors.red[300];
    color[2][9] = Colors.red[300];
    color[3][10] = Colors.red[300];
    color[4][10] = Colors.red[300];
    color[5][11] = Colors.red[300];
    color[6][12] = Colors.red[300];
    color[7][12] = Colors.red[300];
    color[8][11] = Colors.red[300];
    color[9][10] = Colors.red[300];
    color[10][10] = Colors.red[300];
    color[11][9] = Colors.red[300];
    color[12][9] = Colors.red[300];
  }

  // Generates bomb on the map and adds it to the values
  void _bombGenerator() {
    var list = new List<int>.generate(rows*columns, (int index) => index); // list of rows*columns elements
    list.shuffle(); // shuffle list to take first elements as random numbers
    for(int i = 0; i < bombs; i++) {
      values[list[i] ~/ columns][list[i] % columns] = Square(-1, true);
      //color[list[i] ~/ columns][list[i] % columns] = Colors.white; // color helper to make places where is bomb 'white squares
    }
  }

  // ++ everywhere near where is bomb
  void _nearBombGenerator() {
    for(int i = 0; i < rows; i++) {
      for(int j = 0; j < columns; j++) {
        if(values[i][j].hasBomb) {
          if(j - 1 >= 0 && !values[i][j - 1].hasBomb)
            values[i][j - 1].nearBombs++;

          if(j + 1 < columns && !values[i][j + 1].hasBomb)
            values[i][j + 1].nearBombs++;  

          if(i - 1 >= 0 && !values[i - 1][j].hasBomb)
            values[i - 1][j].nearBombs++;

          if(i - 1 >= 0 && j - 1 >= 0 && !values[i - 1][j - 1].hasBomb)
            values[i - 1][j - 1].nearBombs++;

          if(i - 1 >= 0 && j + 1 < columns && !values[i - 1][j + 1].hasBomb)
            values[i - 1][j + 1].nearBombs++;

          if(i + 1 < rows && !values[i + 1][j].hasBomb)
            values[i + 1][j].nearBombs++;

          if(i + 1 < rows && j - 1 >= 0 && !values[i + 1][j - 1].hasBomb)
            values[i + 1][j - 1].nearBombs++;

          if(i + 1 < rows && j + 1 < columns && !values[i + 1][j + 1].hasBomb)
            values[i + 1][j + 1].nearBombs++;
        }
      }
    }
  }

  // build function
  Widget build(BuildContext context) {
    return Center(
      child: _column(),
    );
  }

  // put a flag on the square
  void _flag(int r, int c) {
    setState(() {
      color[r][c] = color[r][c] == Colors.green[300] ? Colors.red[300] : Colors.green[300];
    });
  }

  // Opening handle tile
  void _openTileHandle(int r, int c) {
    setState(() {
      isOpened[r][c] = true; // you can't open it anymore
      color[r][c] = Colors.yellow[300]; 
      winCount++;

      // opeanArea
      if(values[r][c].nearBombs == 0)
        _openAreaHandle(r, c);

      // Lose
      if(values[r][c].hasBomb)
        _reset();

      // Win
      if(winCount == (rows * columns) - bombs)
        _winHandle();
    });
  }

  // Opeans full area of squares
  void _openAreaHandle(int r, int c) {
    setState(() {
      if(c - 1 >= 0 && !isOpened[r][c - 1]) {
        isOpened[r][c - 1] = true;
        color[r][c - 1] = Colors.yellow[300];
        winCount++;

        if(values[r][c - 1].nearBombs == 0)
          _openAreaHandle(r, c - 1);
      }

      if(c + 1 < columns && !isOpened[r][c + 1]) {
        isOpened[r][c + 1] = true;
        color[r][c + 1] = Colors.yellow[300];
        winCount++;

        if(values[r][c + 1].nearBombs == 0)
          _openAreaHandle(r, c + 1);
      } 

      if(r - 1 >= 0 && !isOpened[r - 1][c]) {
        isOpened[r - 1][c] = true;
        color[r - 1][c] = Colors.yellow[300];
        winCount++;

        if(values[r - 1][c].nearBombs == 0)
          _openAreaHandle(r - 1, c);
      }

      if(r - 1 >= 0 && c - 1 >= 0 && !isOpened[r - 1][c - 1]) {
        isOpened[r - 1][c - 1] = true;
        color[r - 1][c - 1] = Colors.yellow[300];
        winCount++;

        if(values[r - 1][c - 1].nearBombs == 0)
          _openAreaHandle(r - 1, c - 1);
      }

      if(r - 1 >= 0 && c + 1 < columns && !isOpened[r - 1][c + 1]) {
        isOpened[r - 1][c + 1] = true;
        color[r - 1][c + 1] = Colors.yellow[300];
        winCount++;

        if(values[r - 1][c + 1].nearBombs == 0)
          _openAreaHandle(r - 1, c + 1);
      }

      if(r + 1 < rows && !isOpened[r + 1][c]) {
        isOpened[r + 1][c] = true;
        color[r + 1][c] = Colors.yellow[300];
        winCount++;

        if(values[r + 1][c].nearBombs == 0)
          _openAreaHandle(r + 1, c);
      }

      if(r + 1 < rows && c - 1 >= 0 && !isOpened[r + 1][c - 1]) {
        isOpened[r + 1][c - 1] = true;
        color[r + 1][c - 1] = Colors.yellow[300];
        winCount++;

        if(values[r + 1][c - 1].nearBombs == 0)
          _openAreaHandle(r + 1, c - 1);
      }

      if(r + 1 < rows && c + 1 < columns && !isOpened[r + 1][c + 1]) {
        isOpened[r + 1][c + 1] = true;
        color[r + 1][c + 1] = Colors.yellow[300];
        winCount++;

        if(values[r + 1][c + 1].nearBombs == 0)
          _openAreaHandle(r + 1, c + 1);
      }
    });
  }
}

class Square {
  int nearBombs = 0;
  bool hasBomb = false;

  Square(int b, bool hB) {
    nearBombs = b;
    hasBomb = hB;
  }
}