import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:notesmanagementflutterapp/models/note.dart';
import 'package:notesmanagementflutterapp/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteDetails extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetails(this.note, this.appBarTitle);

  @override
  _NoteDetailsState createState() =>
      _NoteDetailsState(this.note, this.appBarTitle);
}

class _NoteDetailsState extends State<NoteDetails> {
  String appBarTitle;
  Note note;
  DatabaseHelper helper = DatabaseHelper();
  _NoteDetailsState(this.note, this.appBarTitle);
  var _formKeyForNote = GlobalKey<FormState>();
  static var _priorities = ['High', 'Low'];
  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    titleController.text = note.title;
    detailsController.text = note.description;
    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                }),
          ),
          body: Form(
            key: _formKeyForNote,
          child:Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(

              children: [
                ListTile(
                  title: DropdownButton(
                      items: _priorities.map(
                        (String dropDownStringItem) {
                          return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: Text(dropDownStringItem),
                          );
                        },
                      ).toList(),
                      style: textStyle,
                      value: getPriorityAsString(note.priority),
                      onChanged: (valueSelectedByUser) {
                        setState(() {
                          debugPrint('Value selected is $valueSelectedByUser');
                          updatePriorityAsInt(valueSelectedByUser);
                        });
                      }),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextFormField(
                    controller: titleController,
                    style: textStyle,
                    validator: (value) {
                      if (value.isEmpty) {
                        debugPrint("Title is Empty");
                        return 'Please Enter Title';
                      }
                      return null;
                    },

                      onChanged: (value) {
                      debugPrint("Something happen in title field");
                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextFormField(
                    controller: detailsController,
                    style: textStyle,
                    validator: ( value) {
                      if (value.isEmpty) {
                        debugPrint("Description is Empty");
                        return 'Please Enter Description';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      debugPrint("Something happen in Details field");
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Details',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text('Save', textScaleFactor: 1.5),
                          onPressed: () {
                            setState(() {
                              if (_formKeyForNote.currentState.validate()) {
                                debugPrint("Save Button Clicked");
                                _save();
                              }
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text('Delete', textScaleFactor: 1.5),
                          onPressed: () {
                            setState(() {
                              debugPrint("Delete Button Clicked");
                              _delete();
                            });
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void updateTitle() {
    note.title = titleController.text;
  }

  void updateDescription() {
    note.description = detailsController.text;
  }

  void _save() async {
    moveToLastScreen();
    debugPrint("in Save Method");
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      result = await helper.updateNote(note);
    } else {
      result = await helper.insertNote(note);
    }
    if (result != 0) {
      _showDailog('Status', 'Note Saved Successfully');
    } else {
      _showDailog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();
    if (note.id == null) {
      _showDailog('Status', 'No Note was Deleted');
      return;
    } else {
      int result = await helper.deleteNote(note.id);
      if (result != 0) {
        _showDailog('Status', 'Note Delete Successfully');
      } else {
        _showDailog('Status', 'Error Occurred while deleting the Note');
      }
    }
  }

  void _showDailog(String title, String msg) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(msg),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
