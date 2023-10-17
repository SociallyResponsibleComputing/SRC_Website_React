import 'package:anim_search_app_bar/anim_search_app_bar.dart';
import 'package:animate_do/animate_do.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:csv/csv.dart';
import 'package:src_viewer/classes/LessonEntry.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:src_viewer/screens/publish.dart';
import 'package:src_viewer/widgets/LessonEntryWidget.dart';
import 'package:src_viewer/misc.dart';

import '../widgets/PasswordEntryModal.dart';

class DisplayPage extends StatefulWidget {
  const DisplayPage({super.key});

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> with SingleTickerProviderStateMixin {
  var fetchResponse;
  TextEditingController filterQuery = TextEditingController();
  var _animation;
  var _animationController;

  Future<String> _fetchSubmissions() async {
    String url = formFetchURL;

    final response = await http.get(Uri.parse(url));
    return response.body;
  }

  List<LessonEntry> parseResponse(String responseBody){
    List<List<dynamic>> rows = CsvToListConverter().convert(responseBody);
    List<LessonEntry> output = [];

    //remove the header row
    rows.removeAt(0);

    //I would have used the header row, but Google automatically changes it whenever a new update is made.
    List labels = formFields;

    for (int i = 0; i<rows.length; i++) {
      var map = Map<String, dynamic>();
      for (int j = 0; j<labels.length; j++) {
        map[labels[j]] = rows[i][j];
      }
      LessonEntry entry = LessonEntry.fromMap(map);
      if (entry.getSubmissionField("Approved").value.isNotEmpty) {
        output.add(LessonEntry.fromMap(map));
      }
    }

    return output;
  }

  @override
  void initState() {
    super.initState();
    fetchResponse = _fetchSubmissions();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation = CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int delayMilliSeconds = 75;
    int currentDelay = 0;

    return Scaffold(
      body: Column(
        children: [
          AnimSearchAppBar(
            cancelButtonText: "Cancel",
            hintText: 'Search for a specific assignment with a keyword',
            cSearch: filterQuery,
            onChanged: (String entry) {
              setState(() {

              });
            },
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                "Socially Responsible Computing Curriculum Viewer",
                style: TextStyle(
                    color: Colors.white
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchResponse,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) { // Successfully loaded data
                  String responseBody = snapshot.data!;
                  if (responseBody != null) {
                    List<LessonEntry> entries = parseResponse(responseBody);
                    if (entries.isEmpty) {
                      return Text(
                        "There are no published materials available at the moment.",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      );
                    }
                    return ListView.builder( // Once posts are retrieved, generates ListView
                      itemCount: entries.length,
                      itemBuilder: (BuildContext context, int index) {
                        //can we perform an actual filter?
                        if (filterQuery.text.isNotEmpty && !entries[index].matchesQuery(filterQuery.text)) {
                          print("Filtered out");
                          return SizedBox.shrink();
                        }
                        else {
                          print("Not filtered out");
                          currentDelay+=delayMilliSeconds;
                          return FadeInLeft(
                              delay: Duration(milliseconds: currentDelay),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15, left: 15, right: 1),
                                child: LessonEntryWidget(entry: entries[index]),
                              )
                          );
                        }
                      },
                    );
                  } else { // Problem loading data
                    return const Text("Error loading data");
                  }
                } else { // Loading data
                  return Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.black, size: 75),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionBubble(
        // Menu items
        items: <Bubble>[

          // Floating action menu item
          Bubble(
            title: "Submit Material",
            iconColor: Colors.white,
            bubbleColor: Theme.of(context).primaryColor,
            icon:Icons.add,
            titleStyle: TextStyle(fontSize: 16 , color: Colors.white),
            onPress: () {
              String url = formURL;
              html.window.open(url, "Submission Form");

              _animationController.reverse();
            },
          ),
          Bubble(
            title:"Approve Material",
            iconColor: Colors.white,
            bubbleColor: Theme.of(context).primaryColor,
            icon:Icons.people,
            titleStyle:TextStyle(fontSize: 16 , color: Colors.white),
            onPress: () {
              createPasswordEntryModal(context, TextEditingController());

              _animationController.reverse();
            },
          ),
        ],

        animation: _animation,
        onPress: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),
        iconColor: Colors.white,
        iconData: Icons.settings,
        backGroundColor: Theme.of(context).primaryColor,
      )
    );
  }
}