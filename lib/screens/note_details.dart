import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';
import 'package:notesmanagementflutterapp/models/note.dart';
import 'package:notesmanagementflutterapp/utils/database_helper.dart';
import 'package:toast/toast.dart';


import 'dart:async';



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
   var minPadding=7.0;
  File _image;

  Future getImage() async{
    var image =await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image=image;
    });
  }


  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.subtitle1;
    titleController.text = note.title;
    detailsController.text = note.description;
    return Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                 // _onBackPressed();
                 moveToLastScreen();
                }),
          ),
          body: Form(
            key: _formKeyForNote,
          child:Padding(
            padding: EdgeInsets.only(top: 10.0, left: minPadding, right: minPadding),
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: minPadding),
                  child: Row(
                    children: [
                      Expanded( child: DropdownButton(
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
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(Icons.photo_camera),
                          tooltip: 'Add Image Note',
                          onPressed: (){
                            getImage();
                          },
                        ),
                      )
                    ],

                  ),

                ),

                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: minPadding, bottom: minPadding),
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
                        fillColor: Colors.white,
                        filled: true,
                        labelStyle: textStyle,
                        border: InputBorder.none,
                       ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10.0,left: minPadding, right: minPadding),
                  child: TextFormField(
                    controller: detailsController,
                    maxLines: 20,
                    style: textStyle,
                    validator: ( value) {
                      if (value.length>=2000) {
                        debugPrint("Description is too long");
                        return 'Please Enter short Description';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      debugPrint("Something happen in Details field");
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Details',
                        fillColor: Colors.white,
                        filled: true,
                        border: InputBorder.none,
                        alignLabelWithHint: true,
                        labelStyle: textStyle,
                       ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: minPadding, right: minPadding),
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
        ));
  }

  void moveToLastScreen() {
      Navigator.pop(context, true);
  }
  Future<bool> _onBackPressed(){
    return showDialog(context: context,
    builder: (context)=>AlertDialog(
      title: Text('Do you want to save the Note?'),
      actions: [
        FlatButton(onPressed:()=> Navigator.pop(context, false), child: Text('yes')),
        FlatButton(onPressed:()=> Navigator.pop(context, true), child: Text('No'))
      ],
    ));
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
    note.date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    int result;
    if (note.id != null) {
      result = await helper.updateNote(note);
    } else {
      result = await helper.insertNote(note);
    }
    if (result != 0) {
      Toast.show("Note Saved Successfully ", context, duration: Toast.LENGTH_LONG);
    } else {
      Toast.show("Something Went Wrong", context, duration: Toast.LENGTH_LONG);
    }
  }

  void _delete() async {
    moveToLastScreen();
    if (note.id == null) {
      _showCustomDailog('Status', 'No Note was Deleted');
      return;
    } else {
      int result = await helper.deleteNote(note.id);
      if (result != 0) {
        _showCustomDailog('Status', 'Note Delete Successfully');
      } else {
        _showCustomDailog('Status', 'Error Occurred while deleting the Note');
      }
    }
  }
  void _showCustomDailog(String title, String msg) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(msg),
    );
    showDialog(context: context, builder: (_) => alertDialog); 
  }
}
