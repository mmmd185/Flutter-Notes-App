import 'package:flutter/material.dart';

class ViewNotePage extends StatefulWidget {
  final list;
  ViewNotePage({Key? key, this.list}) : super(key: key);

  @override
  State<ViewNotePage> createState() => _ViewNotePageState();
}

class _ViewNotePageState extends State<ViewNotePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Note"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 22,
          ),
          Image.network(
            "${widget.list['imageUrl']}",
            height: 200,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
          SizedBox(
            height: 22,
          ),
          Text(
            "${widget.list['Title']}",
            style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
                fontSize: 22),
          ),
          SizedBox(
            height: 22,
          ),
          Text("${widget.list['Body']}",
              style: TextStyle(color: Colors.blue[500], fontSize: 22))
        ],
      ),
    );
  }
}
