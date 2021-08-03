//@dart=2.13
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'constants.dart' as constants;
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'dart:io';

final themesInString = [
//  "No theme selected",
  "Dark",
  "Light",
  "Original",
  "Modern",
];

// TESTING PURPOSES
void message() {
  //print(
      //"-------------------------- Value of constants.colCount: ${constants.colCount} -----------------------------");

  //print(
      //"-------------------------- Value of constants.rowCount: ${constants.rowCount} -----------------------------");

  //print(
      //"-------------------------- Value of constants.mineCount: ${constants.mineCount} -----------------------------");
  //print(
      //"-------------------------------------------------------------------------------------------------");
}

final themes = themesInString
    .map(
        (String value) => DropdownMenuItem(value: value, child: Text("$value")))
    .toList();

String currentTheme = "Original";

double colValue = 9;
double rowValue = 9;
double mineValue = 11;

class Preferences extends StatefulWidget {
  //final BoardState boardState;

  //Preferences(this.boardState);

  @override
  _PreferencesState createState() =>
      _PreferencesState(); //_PreferencesState(boardState);
}

class _PreferencesState extends State<Preferences> {
  //final BoardState boardState;

  //_PreferencesState(this.boardState);

  final backgroundColor = Colors.grey[800];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final githubLogo = Image.asset(
      'assets/images/githubLogo.png',
      width: size.width / 2.1,
      color: Colors.grey,
    );
    final neutrino_logo = Image.asset('assets/images/neutrino_redo_test1.png',
        width: size.width / 2.1, color: Colors.grey);
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: Text("Preferences"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            //message();
            // boardState.Board();
            // Navigator.pop(context);
            // (colValue != constants.colCount) ||
            //     (rowValue != constants.rowCount) ||
            //     (mineValue != constants.mineCount)
            //if (settingChanged) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => Board(
                        colsProp: colValue.toInt(),
                        rowsProp: rowValue.toInt(),
                        minesProp: mineValue.toInt())),
                (route) => false);
            //} else {
            //Navigator.pop(context);
            //}
          },
        ),
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  // GAME SETTINGS  MINES/ROWS/COLUMNS ECT.
                  Row(children: [
                    Header("Game Settings"),
                  ]),
                  GameSettings(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        neutrino_logo,
                        Column(children: [
                          InkWell(
                            child: githubLogo,
                            onTap: () async {
                              const url =
                                  "https://github.com/liamweeks/minesweeper";
                              if (await canLaunch(url))
                                await launch(url);
                              else
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text("Failed to launch"),
                                  action: SnackBarAction(
                                    label: "Ok",
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ));
                            },
                          ),
                          Text(
                            "liamweeks/minesweeper",
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          )
                        ])
                      ])
                ],
              ))),
    );
  }
}

class Header extends StatelessWidget {
  final backgroundColor = Colors.grey[800];
  final String content;
  final int fontSize;
  final Color color;
  Header(this.content, {this.color = Colors.grey, this.fontSize = 25});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        color: backgroundColor,
        child: Text(
          "$content",
          style: TextStyle(
              color: color,
              fontSize: fontSize.toDouble(),
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class InfoPanel extends StatelessWidget {
  final List<Widget> children;

  InfoPanel(this.children);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: children,
        ));
  }
}

// class ThemeChooser extends StatefulWidget {
//   @override
//   _ThemeChooserState createState() => _ThemeChooserState();
// }

// class _ThemeChooserState extends State<ThemeChooser> {
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Padding(
//         padding: EdgeInsets.only(left: size.width / 12),
//         child: Row(
//           children: [
//             Header("Theme", color: Colors.white, fontSize: 18),
//             SizedBox(
//               width: size.width / 3,
//             ),
//             DropdownButton(
//                 hint: Text("$currentTheme"),
//                 value: currentTheme,
//                 style: TextStyle(color: Colors.white),
//                 dropdownColor: Colors.grey,
//                 onChanged: (newValue) {
//                   setState(() {
//                     currentTheme = "$newValue";
//                   });
//                 },
//                 // hint: Text(
//                 //   " Select",
//                 //   style: TextStyle(color: Colors.grey),
//                 //),
//                 items: themes)
//           ],
//         ));
//   }
// }

class GameSettings extends StatefulWidget {
  @override
  _GameSettingsState createState() => _GameSettingsState();
}

class _GameSettingsState extends State<GameSettings> {
  Widget _buildChip(int cols, int rows, int mines, String difficulty) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              message();
              HapticFeedback.vibrate();
              // constants.rowCount = rows;
              // constants.colCount = cols;
              // constants.mineCount = mines;
              //message();

              setState(() {
                colValue = cols.toDouble();
                rowValue = rows.toDouble();
                mineValue = mines.toDouble();
              });
              // if ((constants.rowCount != rows) &&
              //     (constants.colCount != cols) &&
              //     (constants.mineCount != mines)) {
              //   settingChanged = true;
              //   message();
              // }
            },
            child: Chip(
              labelPadding: EdgeInsets.all(2.0),
              avatar: CircleAvatar(
                backgroundColor: difficulty == "easy"
                    ? Colors.lightGreen
                    : difficulty == "intermediate"
                        ? Colors.yellow
                        : Colors.red,
                child: Text("$mines"),
              ),
              label: Text(
                "${cols}x$rows",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              backgroundColor: Colors.grey,
              elevation: 6.0,
              shadowColor: Colors.grey[60],
              padding: EdgeInsets.all(8.0),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header("Columns: ${colValue.toInt()}",
            color: Colors.white, fontSize: 18),
        Slider(
          min: 8,
          max: 50,
          value: colValue,
          label: "${colValue.toInt()}",
          onChanged: (newValue) {
            // col count has changed
            //constants.colCount = newValue.toInt();
            //colValue = newValue;
            setState(() {
              colValue = newValue;
              //   constants.colCount = newValue.toInt();
            });
          },
        ),
        Header("Rows: ${rowValue.toInt()}", color: Colors.white, fontSize: 18),
        Slider(
          min: 8,
          max: 50,
          value: rowValue,
          label: "${rowValue.toInt()}",
          onChanged: (newValue) {
            //constants.rowCount = newValue.toInt();
            //rowValue = newValue;
            setState(() {
              rowValue = newValue;
              //   constants.rowCount = newValue.toInt();
            });
          },
        ),
        Header("Mines: ${mineValue.toInt()}",
            color: Colors.white, fontSize: 18),
        Slider(
          min: 10,
          max: 625,
          value: mineValue,
          label: "${mineValue.toInt()}",
          onChanged: (newValue) {
            //constants.mineCount = newValue.toInt();
            //mineValue = newValue;
            setState(() {
              mineValue = newValue;
              //   constants.mineCount = newValue.toInt();
            });
          },
        ),
        Text(
          "Higher densities tend to more often generate 50/50 scenarios or other required guesses; nevertheless, they are much more entertaining.",
          style: TextStyle(color: Colors.grey),
        ),
        Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildChip(8, 8, 10, 'easy'),
                _buildChip(9, 9, 11, 'easy'),
                _buildChip(10, 10, 10, 'easy'),
                //_buildChip(13, 15, 40, 'intermediate'),
                //_buildChip(13, 16, 40, 'intermediate'),
                //_buildChip(14, 15, 40, 'intermediate'),
                //_buildChip(14, 16, 40, 'intermediate'),
                _buildChip(15, 15, 40, 'intermediate'),
                //_buildChip(15, 16, 40, 'intermediate'),
                _buildChip(16, 16, 40, 'intermediate'),
                //_buildChip(16, 30, 99, 'expert')
              ],
            ))
      ],
    );
  }
}



// return showDialog<void>(
                        //   context: context,
                        //   barrierDismissible: false, // user must tap button!
                        //   builder: (BuildContext context) {
                        //     return AlertDialog(
                        //       contentPadding:
                        //           EdgeInsets.only(left: 25, right: 25),
                        //       title: Center(child: Text("Standardized Games")),
                        //       shape: RoundedRectangleBorder(
                        //           borderRadius:
                        //               BorderRadius.all(Radius.circular(20.0))),
                        //       content: Container(
                        //           height: 200,
                        //           width: 300,
                        //           child: Scrollbar(
                        //               child: SingleChildScrollView(
                        //             child: Column(children: [
                        //               Text(
                        //                   "Higher densities tend to more often generate 50/50 scenarios or other required guesses; nevertheless, they are much more entertaining."),
                        //               DataTable(
                        //                 columns: [
                        //                   DataColumn(label: Text("Mode")),
                        //                   DataColumn(label: Text("Size")),
                        //                   DataColumn(label: Text("Mines")),
                        //                 ],
                        //                 rows: [
                        //                   DataRow(cells: [
                        //                     DataCell(Text("Easy #1")),
                        //                     DataCell(Text("8x8")),
                        //                     DataCell(Text("10"))
                        //                   ]),
                        //                   DataRow(cells: [
                        //                     DataCell(Text("Easy #2")),
                        //                     DataCell(Text("9x9")),
                        //                     DataCell(Text("11"))
                        //                   ]),
                        //                   DataRow(cells: [
                        //                     DataCell(Text("Easy #3")),
                        //                     DataCell(Text("10x10")),
                        //                     DataCell(Text("10"))
                        //                   ]),
                        //                   DataRow(cells: [
                        //                     DataCell(Text("Medium #1")),
                        //                     DataCell(Text("13x15")),
                        //                     DataCell(Text("40"))
                        //                   ]),
                        //                   DataRow(cells: [
                        //                     DataCell(Text("Medium #2")),
                        //                     DataCell(Text("13x16")),
                        //                     DataCell(Text("40"))
                        //                   ]),
                        //                   DataRow(cells: [
                        //                     DataCell(Text("Medium #3")),
                        //                     DataCell(Text("14x15")),
                        //                     DataCell(Text("40"))
                        //                   ]),
                        //                   DataRow(cells: [
                        //                     DataCell(Text("Medium #4")),
                        //                     DataCell(Text("14x16")),
                        //                     DataCell(Text("40"))
                        //                   ]),
                        //                   DataRow(cells: [
                        //                     DataCell(Text("Medium #5")),
                        //                     DataCell(Text("15x15")),
                        //                     DataCell(Text("40"))
                        //                   ]),
                        //                   DataRow(cells: [
                        //                     DataCell(Text("Medium #6")),
                        //                     DataCell(Text("15x16")),
                        //                     DataCell(Text("40"))
                        //                   ]),
                        //                   DataRow(cells: [
                        //                     DataCell(Text("Medium #7")),
                        //                     DataCell(Text("16x16")),
                        //                     DataCell(Text("40"))
                        //                   ]),
                        //                   DataRow(cells: [
                        //                     DataCell(Text("Expert")),
                        //                     DataCell(Text("16x30")),
                        //                     DataCell(Text("99"))
                        //                   ]),
                        //                 ],
                        //               )
                        //             ]),
                        //           ))),
                        //       actions: [
                        //         TextButton(
                        //             onPressed: () {
                        //               Navigator.of(context).pop();
                        //             },
                        //             child: Text("Ok"))
                        //       ],
                        //     );
                        //   },
                        // );