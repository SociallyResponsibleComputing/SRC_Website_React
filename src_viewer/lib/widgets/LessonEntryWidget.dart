import 'package:animate_do/animate_do.dart';
import 'package:animate_on_hover/animate_on_hover.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:src_viewer/classes/LessonEntry.dart';
import 'package:src_viewer/widgets/LessonEntryModal.dart';
import 'dart:html' as html;

class LessonEntryWidget extends StatelessWidget {
  LessonEntry entry;
  LessonEntryWidget({super.key, required this.entry});
  int currentDelay = 0;

  int increaseCurrentDelay(int byMilliSeconds) {
    return currentDelay+=byMilliSeconds;
  }

  Widget getFadeInDelayWidget(int delay, Widget child) {
    return FadeIn(
        delay: Duration(milliseconds: increaseCurrentDelay(delay)),
        child: child
    );
  }

  @override
  Widget build(BuildContext context) {
    int delayMilliSeconds = 200;

    return InkWell(
      onTap: () {
        createLessonEntryModal(entry, context);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getFadeInDelayWidget(
                      delayMilliSeconds,
                      Text(
                        entry.getSubmissionField("Activity").value,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 25
                        ),
                      ),
                    ),
                    getFadeInDelayWidget(
                      delayMilliSeconds,
                      Text(
                        entry.getSubmissionField("Contributor").value,
                        style: TextStyle(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    getFadeInDelayWidget(
                      delayMilliSeconds,
                      Text(
                        entry.getSubmissionField("Contributor Email").value,
                        style: TextStyle(
                          fontStyle: FontStyle.italic
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 90,
                child: getFadeInDelayWidget(
                    delayMilliSeconds,
                    IgnorePointer(
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TyperAnimatedText(''),
                          TyperAnimatedText('          ' + entry.getSubmissionField("Description").value, speed: Duration(milliseconds: 5), textStyle: TextStyle(fontSize: 15.5)),
                        ],
                        pause: Duration(seconds: 1),
                        repeatForever: false,
                        totalRepeatCount: 1,
                      ),
                    )
                ),
              )
            ],
          ),
        ),
      ).increaseSizeOnHover(1.03, duration: Duration(milliseconds: 150)),
    );
  }
}