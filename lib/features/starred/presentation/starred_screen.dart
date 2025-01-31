import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../constants/text_font_style.dart';
import '../../../gen/colors.gen.dart';
import '../../../helpers/ui_helpers.dart';
import '../../custom_drawer/presentation/custom_drawer.dart';
import '../../database/db_helper.dart';
import '../../home/presentation/edit_notes/note_edit_screen.dart';

class StarredNotesScreen extends StatefulWidget {
  @override
  _StarredNotesScreenState createState() => _StarredNotesScreenState();
}

class _StarredNotesScreenState extends State<StarredNotesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _starredNotes = [];
  bool _isSelecting = false;
  Set<int> _selectedNoteIds = Set<int>(); // Track selected notes

  @override
  void initState() {
    super.initState();
    _loadStarredNotes();
  }

  Future<void> _loadStarredNotes() async {
    final notes = await DatabaseHelper().getStarredNotes();
    setState(() {
      _starredNotes = notes;
    });
  }

  void _toggleNoteSelection(int noteId) {
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId); // Deselect note
      } else {
        _selectedNoteIds.add(noteId); // Select note
      }
    });
  }

  void _toggleStarredStatus(int noteId) async {
    final note = _starredNotes.firstWhere((note) => note['id'] == noteId);
    final isStarred = note['isStarred'] == 1;
    await DatabaseHelper().updateNote(
      noteId,
      note['title'],
      note['content'],
      starred: !isStarred, // Toggle starred status
    );
    _loadStarredNotes(); // Refresh the list
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.black,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Text(
              'Starred',
              style: TextStyle(color: Colors.black),
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
            )
          ],
        ),
        actions: [
          if (_isSelecting) // Show action buttons when in selection mode
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Handle delete selected notes
              },
            ),
        ],
      ),
      drawer: CustomDrawer(),
      body: GridView.builder(
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
                        color: AppColors.cFFFFFF,
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note['content'] ?? 'No Content',
                            maxLines: 9,
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(fontSize: 14.sp, color: Colors.black),
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
                              color: isSelected ? Colors.red : Colors.grey,
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
    );
  }
}
