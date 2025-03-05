import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../gen/colors.gen.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class NotesCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> previousNotes;
  final int currentSlideIndex;
  final CarouselSliderController carouselController;

  NotesCarousel({
    required this.previousNotes,
    required this.currentSlideIndex,
    required this.carouselController,
  });

  quill.QuillController _controller = quill.QuillController.basic();

  String extractPlainText(String deltaJson) {
    try {
      var document =
          quill.Document.fromJson(jsonDecode(deltaJson) as List<dynamic>);
      return document.toPlainText();
    } catch (e) {
      print("Error decoding delta JSON: $e");
      return deltaJson;
    }
  }

  void _openNoteDetail(BuildContext context, Map<String, dynamic> note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return previousNotes.isEmpty
        ? SizedBox.shrink()
        : Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: CarouselSlider(
                  carouselController: carouselController,
                  options: CarouselOptions(
                    height: 122.h,
                    viewportFraction: 1,
                    autoPlay: true,
                    enlargeCenterPage: true,
                  ),
                  items: previousNotes.map((note) {
                    return GestureDetector(
                      onTap: () => _openNoteDetail(context, note),
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 8.w),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: AppColors.cEFF0F3,
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 5),
                            note['content'] is String
                                ? Text(
                                    extractPlainText(note['content']),
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextFontStyle
                                        .textStylec17cA1ABCCInter700
                                        .copyWith(
                                      fontSize: 14.sp,
                                    ),
                                  )
                                : QuillEditor(
                                    controller: _controller,
                                    focusNode: FocusNode(),
                                    scrollController: ScrollController(),
                                  ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Positioned(
                left: 0,
                top: 35.h,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, size: 20.sp),
                  onPressed: () {
                    if (currentSlideIndex > 0) {
                      carouselController.previousPage();
                    }
                  },
                ),
              ),
              Positioned(
                right: -5,
                top: 35.h,
                child: IconButton(
                  icon: Icon(Icons.arrow_forward_ios, size: 20.sp),
                  onPressed: () {
                    if (currentSlideIndex < previousNotes.length - 1) {
                      carouselController.nextPage();
                    }
                  },
                ),
              ),
            ],
          );
  }
}

// NoteDetailScreen to display the selected note in full
class NoteDetailScreen extends StatelessWidget {
  final Map<String, dynamic> note;

  NoteDetailScreen({required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          note['title'] ?? 'Note',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Display the note content
              note['content'] is String
                  ? Text(
                      extractPlainText(note['content']),
                      style: TextStyle(fontSize: 16),
                    )
                  : QuillEditor(
                      controller: quill.QuillController(
                        document: quill.Document.fromJson(
                          jsonDecode(note['content']) as List<dynamic>,
                        ),
                        selection: TextSelection.collapsed(offset: 0),
                      ),
                      focusNode: FocusNode(),
                      scrollController: ScrollController(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  String extractPlainText(String deltaJson) {
    try {
      var document =
          quill.Document.fromJson(jsonDecode(deltaJson) as List<dynamic>);
      return document.toPlainText();
    } catch (e) {
      print("Error decoding delta JSON: $e");
      return deltaJson; // Return the original string if it's not valid JSON
    }
  }
}
