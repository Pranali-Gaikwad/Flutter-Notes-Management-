import 'package:flutter/material.dart';
import 'package:notesmanagementflutterapp/screens/note_list.dart';
import 'package:notesmanagementflutterapp/screens/note_details.dart';
main(){
  runApp(NotesManagement());
}

class NotesManagement extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
   return MaterialApp(
     title: 'Notes Management',
     debugShowCheckedModeBanner: false,
     theme: ThemeData(primarySwatch: Colors.deepPurple),
     home: NoteList(),
   );
  }

}