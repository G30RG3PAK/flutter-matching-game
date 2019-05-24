import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_match_animal_game/models/block.dart';
import 'package:flutter_match_animal_game/models/coordinate.dart';
import 'package:flutter_match_animal_game/game_config.dart';
import 'package:flutter_match_animal_game/features/game/game_table.dart';
import 'package:flutter_match_animal_game/features/lines_match/lines_match_builder.dart';
import 'package:flutter_match_animal_game/features/lines_match/lines_match_painter.dart';

class GamePlayScreen extends StatefulWidget {
  GamePlayScreen({Key key}) : super(key: key);

  @override
  _GamePlayScreenState createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  GameTable gameTable;
  Coordinate coordinateSelected;
  LinesMatchPainter linesMatchPainter;

  @override
  void initState() {
    gameTable = GameTable(
        countRow: GameConfig.COUNT_ROW_DEFAULT,
        countCol: GameConfig.COUNT_COL_DEFAULT,
        blockSize: GameConfig.BLOCK_SIZE_DEFAULT);
    gameTable.init();

    linesMatchPainter = null;

    // Force landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
  }

  bool isSelectedMode() {
    return coordinateSelected != null;
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[200],
          title: Text("Onet story".toUpperCase()),
          centerTitle: true,
          elevation: 0,
          actions: <Widget>[
            Opacity(
                opacity: gameTable.canRenovate() ? 1 : 0.2,
                child: FlatButton.icon(
                    label: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.red[200],
                        ),
                        padding: EdgeInsets.all(4),
                        child: Text("${gameTable.countRenovate}",
                            style: TextStyle(color: Colors.white))),
                    icon: Icon(Icons.crop_rotate, color: Colors.white),
                    onPressed: () => renovateTable())),
            FlatButton(
                child: Text(
                  '${gameTable.countBlock}',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {}),
          ],
        ),
        body: GestureDetector(
            child: Container(
                color: Colors.green[100],
                child: Center(
                    child: CustomPaint(
                        painter: linesMatchPainter,
                        child: Container(child: buildGameTable())))),
            onTap: () {
              clear();
            }));
  }

  buildGameTable() {
    List<Row> listRow = List();
    for (int row = 0; row < gameTable.countRow; row++) {
      List<Widget> listBlock = List();
      for (int col = 0; col < gameTable.countCol; col++) {
        Block block = gameTable.tableData[row][col];
        Coordinate coor = Coordinate(row: row, col: col);
        listBlock.add(GestureDetector(
          child: buildBlock(block, isSelected: coor.equals(coordinateSelected)),
          onTap: () {
            selectBlock(block, coor);
          },
        ));
      }
      listRow.add(Row(mainAxisSize: MainAxisSize.min, children: listBlock));
    }

    return Column(mainAxisSize: MainAxisSize.min, children: listRow);
  }

  Container buildBlock(Block block, {bool isSelected = false}) {
    if (block.isColorBlock()) {
      return buildBlockColor(block, isSelected: isSelected);
    } else {
      return buildBlockImage(block, isSelected: isSelected);
    }
  }

  Container buildBlockColor(Block block, {bool isSelected = false}) {
    if (block.value != 0 && isSelected) {
      return Container(
        margin: EdgeInsets.all(2),
        width: gameTable.blockSize,
        height: gameTable.blockSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: block.color,
        ),
        child: Icon(Icons.check, color: Colors.white),
      );
    } else {
      return Container(
          margin: EdgeInsets.all(2),
          width: gameTable.blockSize,
          height: gameTable.blockSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: block.color,
          ));
    }
  }

  Container buildBlockImage(Block block, {bool isSelected = false}) {
    if (block.value != 0 && isSelected) {
      return Container(
        margin: EdgeInsets.all(2),
        width: gameTable.blockSize,
        height: gameTable.blockSize,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.blue[600], width: 4),
            color: Colors.grey[200]
        ),
        child: Image.asset(block.asset,
            width: gameTable.blockSize,
            height: gameTable.blockSize),
      );
    } else {
      if (block.value == 0) {
        return Container(
            margin: EdgeInsets.all(2),
            width: gameTable.blockSize,
            height: gameTable.blockSize);
      } else {
        return Container(
            margin: EdgeInsets.all(2),
            width: gameTable.blockSize,
            height: gameTable.blockSize,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.blue[200]
            ),
            child: Image.asset(block.asset,
                width: gameTable.blockSize,
                height: gameTable.blockSize));
      }
    }
  }

  clear() {
    setState(() {
      coordinateSelected = null;
    });
  }

  setCoordinateSelected(Coordinate coor) {
    print("setCoordinateSelected");
    setState(() {
      coordinateSelected = coor;
    });
  }

  void selectBlock(Block block, Coordinate coor) {
    if (block.value != 0 &&
        isSelectedMode() &&
        !coordinateSelected.equals(coor)) {
      LineMatchResult result =
      gameTable.checkBlockMatch(coordinateSelected, coor);
      if (result.available) {
        linesMatchPainter = LineMatchBuilder(gameTable: gameTable).build(
          a: result.a,
          b: result.b,
          c: result.c,
          d: result.d,
        );

        gameTable.removeBlock(result.a);
        gameTable.removeBlock(result.b);
        gameTable.removeBlock(result.c);
        gameTable.removeBlock(result.d);
        gameTable.countBlock -= 2;
        clear();

        delay(
            milli: 200,
            then: () {
              linesMatchPainter = null;
            });
      } else {
        clear();
      }
    } else if (block.value != 0 && !isSelectedMode()) {
      setCoordinateSelected(coor);
    } else {
      clear();
    }
  }

  void delay({int milli = 300, Function then}) {
    Future.delayed(Duration(milliseconds: milli), () {
      if (then != null) {
        setState(() {
          then();
        });
      }
    });
  }

  renovateTable() {
    if (gameTable.canRenovate()) {
      setState(() {
        gameTable.renovate();
        gameTable.countRenovate--;
      });
    }
  }
}
