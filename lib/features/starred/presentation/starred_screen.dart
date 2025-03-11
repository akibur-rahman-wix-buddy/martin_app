import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../common_widgets/not_found_widget.dart';
import '../../../constants/text_font_style.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../../helpers/ui_helpers.dart';
import '../../custom_drawer/presentation/custom_drawer.dart';
import '../../database/db_helper.dart';
import '../../home/presentation/edit_notes/note_edit_screen.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../theme_controller/theme_controller.dart';

class StarredNotesScreen extends StatefulWidget {
  @override
  _StarredNotesScreenState createState() => _StarredNotesScreenState();
}

class _StarredNotesScreenState extends State<StarredNotesScreen> {
  final ThemeController themeController = Get.find<ThemeController>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  quill.QuillController _controller = quill.QuillController.basic();
  List<Map<String, dynamic>> _starredNotes = [];
  List<Map<String, dynamic>> _filteredNotes = [];
  bool _isSelecting = false;
  Set<int> _selectedNoteIds = Set<int>(); // Track selected notes
  String _searchQuery = "";
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    _loadStarredNotes();
  }

  Future<void> _loadStarredNotes() async {
    final notes = await DatabaseHelper().getStarredNotes();
    setState(() {
      _starredNotes = notes;
      _filteredNotes = notes;
    });
  }

  void _searchNotes(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredNotes = _starredNotes; // Reset to all notes
      } else {
        _filteredNotes = _starredNotes.where((note) {
          final title = note['title']?.toLowerCase() ?? '';
          final content = note['content']?.toLowerCase() ?? '';
          return title.contains(query.toLowerCase()) ||
              content.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleNoteSelection(int noteId) {
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId); // Deselect note
      } else {
        _selectedNoteIds.add(noteId); // Select note
      }
      if (_selectedNoteIds.isEmpty) {
        _isSelecting = false;
      }
    });
  }

  void _deleteSelectedNotes() async {
    for (var id in _selectedNoteIds) {
      await DatabaseHelper().moveToRecycleBin(id);
    }
    setState(() {
      _selectedNoteIds.clear();
      if (_selectedNoteIds.isEmpty) {
        _isSelecting = false;
      }
    });
    _loadStarredNotes();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No Date';

    DateTime createAt = DateTime.parse(dateString);
    DateTime now = DateTime.now();

    // Check if the note was created today
    bool isToday = createAt.year == now.year &&
        createAt.month == now.month &&
        createAt.day == now.day;

    return isToday
        ? DateFormat('h:mm a').format(createAt) // Show time only if today
        : DateFormat('dd MMM,').format(createAt); // Show date if older
  }

  Future<void> _unfavoriteSelectedNotes() async {
    final dbHelper = DatabaseHelper();

    for (int noteId in _selectedNoteIds) {
      final existingNotes = await dbHelper.getStarredNotes();
      final note = existingNotes.firstWhere((note) => note['id'] == noteId,
          orElse: () => {});

      if (note.isNotEmpty) {
        await dbHelper.updateNote(
          noteId,
          note['title'],
          note['content'],
          starred: false,
        );
      }
    }

    _selectedNoteIds.clear();
    _isSelecting = false;
    _loadStarredNotes();
    setState(() {});
  }

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

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (_isSearching) {
          setState(() {
            _isSearching = false;
            _searchQuery = '';
            _filteredNotes = _filteredNotes;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.menu,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          titleSpacing: 0,
          title: _isSearching
              ? TextField(
                  autofocus: true,
                  onChanged: _searchNotes,
                  decoration: InputDecoration(
                    hintText: 'Search Notes...',
                    // hintStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                  ),
                  // style: TextStyle(color: Colors.black),
                )
              : Row(
                  children: [
                    if (!_isSearching)
                      Text(
                        'Starred',
                      ),
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                    )
                  ],
                ),
          actions: [
            _isSelecting
                ? IconButton(
                    onPressed: _deleteSelectedNotes,
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ))
                : SizedBox.shrink(),
            if (!_isSelecting)
              InkWell(
                onTap: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Image.asset(
                    Assets.icons.searchIcon.path,
                    color: themeController.isDarkMode.value
                        ? const Color.fromARGB(255, 255, 255, 255)
                        : Color(0xFF1E1E1E),
                  ),
                ),
              ),
            if (_isSelecting)
              IconButton(
                icon: Icon(Icons.star_border_outlined, color: Colors.amber),
                onPressed: () {
                  _unfavoriteSelectedNotes();
                },
              ),
            PopupMenuButton<String>(
              iconColor: themeController.isDarkMode.value
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : Color(0xFF1E1E1E),
              color: themeController.isDarkMode.value
                  ? Color(0xFF1E1E1E)
                  : const Color.fromARGB(255, 255, 255, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              onSelected: (String value) async {
                if (value == "edit_preview") {
                  setState(() {
                    _isSelecting = true;
                    _selectedNoteIds.clear();
                  });
                } else if (value == "pin_unfavourite") {
                  await _unfavoriteSelectedNotes();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: "edit_preview",
                  child: Text("Edit"),
                ),
                PopupMenuItem(
                  value: "pin_unfavourite",
                  child: Text("Unfavourite"),
                ),
              ],
            ),
          ],
        ),
        drawer: CustomDrawer(),
        body: _filteredNotes.isEmpty
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Empty Data",
                    style: TextFontStyle.textStylec17cA1ABCCInter700,
                  ),
                  NotFoundWidget(),
                ],
              ))
            : GridView.builder(
                padding: EdgeInsets.all(12.sp),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 30.w,
                  childAspectRatio: 0.5,
                ),
                itemCount: _starredNotes.length,
                itemBuilder: (context, index) {
                  final note = _starredNotes[index];
                  final isSelected = _selectedNoteIds.contains(note['id']);

                  return GestureDetector(
                    onLongPress: () {
                      setState(() {
                        _isSelecting = true;
                        _toggleNoteSelection(note['id']);
                      });
                    },
                    onTap: () {
                      if (_isSelecting) {
                        _toggleNoteSelection(note['id']);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoteEditorScreen(
                              note: note,
                              onSave: _loadStarredNotes,
                            ),
                          ),
                        );
                      }
                    },
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            AnimatedContainer(
                              height: 250.h,
                              width: double.infinity,
                              duration: Duration(milliseconds: 200),
                              margin: EdgeInsets.all(4.sp),
                              padding: EdgeInsets.all(12.sp),
                              decoration: BoxDecoration(
                                color: themeController.isDarkMode.value
                                    ? Color(0xFF1E1E1E)
                                    : const Color.fromARGB(255, 255, 255, 255),
                                borderRadius: BorderRadius.circular(22.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  note['content'] is String
                                      ? Text(
                                          extractPlainText(note['content']),
                                          maxLines: 12,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.left,
                                        )
                                      : QuillEditor(
                                          controller: _controller,
                                          focusNode: FocusNode(),
                                          scrollController: ScrollController(),
                                        ),
                                ],
                              ),
                            ),
                            if (_isSelecting)
                              Positioned(
                                top: 8.sp,
                                right: 8.sp,
                                child: Container(
                                  height: 25.h,
                                  width: 25.w,
                                  padding: EdgeInsets.zero,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          isSelected ? Colors.red : Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  child: Transform.scale(
                                    scale: 1.2,
                                    child: Checkbox(
                                      value: isSelected,
                                      onChanged: (bool? value) {
                                        _toggleNoteSelection(note['id']);
                                      },
                                      activeColor: Colors.red,
                                      checkColor: Colors.white,
                                      shape: CircleBorder(),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          note['title'] ?? 'No title',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextFontStyle.textStylec17cA1ABCCInter700,
                        ),
                        UIHelper.verticalSpace(4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _formatDate(note['createAt']),
                              style: TextFontStyle.textStylec17cA1ABCCInter700
                                  .copyWith(fontSize: 12.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            UIHelper.horizontalSpace(2.w),
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16.sp,
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
