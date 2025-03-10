import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notely/features/custom_drawer/presentation/custom_drawer.dart';

import '../../../common_widgets/not_found_widget.dart';
import '../../../constants/text_font_style.dart';
import '../../../gen/colors.gen.dart';
import '../../../helpers/ui_helpers.dart';
import '../../database/db_helper.dart';
import '../../theme_controller/theme_controller.dart';
import 'widgets/show_permamently_delete_dialog.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class RecycleBinScreen extends StatefulWidget {
  @override
  _RecycleBinScreenState createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  quill.QuillController _controller = quill.QuillController.basic();
  List<Map<String, dynamic>> _recycleBinNotes = [];
  Set<int> _selectedNotes = Set<int>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _fetchRecycleBinNotes();
  }

  void _fetchRecycleBinNotes() async {
    await DatabaseHelper().deleteOldNotes(); // Auto-delete expired notes
    final notes = await DatabaseHelper().getRecycleBinNotes();
    setState(() {
      _recycleBinNotes = notes;
    });
  }

  void _restoreSelectedNotes() async {
    for (var id in _selectedNotes) {
      await DatabaseHelper().restoreNoteFromRecycleBin(id);
    }
    setState(() {
      _selectedNotes.clear();
      if (_selectedNotes.isEmpty) {
        _isSelecting = false;
      }
    });
    _fetchRecycleBinNotes();
  }

  void _permanentlyDeleteSelectedNotes() async {
    for (var id in _selectedNotes) {
      await DatabaseHelper().permanentlyDeleteNote(id);
    }
    setState(() {
      _selectedNotes.clear();
      if (_selectedNotes.isEmpty) {
        _isSelecting = false;
      }
    });
    _fetchRecycleBinNotes();
  }

  void _toggleNoteSelection(int noteId) {
    setState(() {
      if (_selectedNotes.contains(noteId)) {
        _selectedNotes.remove(noteId);
      } else {
        _selectedNotes.add(noteId);
      }
      if (_selectedNotes.isEmpty) {
        _isSelecting = false;
      }
    });
  }

  bool _isSelecting = false;

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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            // color: Colors.black,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Text(
              _selectedNotes.isEmpty
                  ? 'Recycle Bin'
                  : '${_selectedNotes.length} Selected',
            ),
            if (!_isSelecting)
              Text(' (${_recycleBinNotes.length} notes)',
                  style: TextStyle(fontSize: 15.sp)),
          ],
        ),
        actions: [
          if (!_isSelecting)
            InkWell(
              onTap: () {
                setState(() {
                  _isSelecting = true;
                  _selectedNotes.clear();
                });
              },
              child: Text(
                'Select',
                style: TextFontStyle.textStylec17c000000Poppins400.copyWith(
                  color: themeController.isDarkMode.value
                      ? AppColors.cFFFFFF
                      : AppColors.c000000,
                ),
              ),
            ),
          if (_selectedNotes.isNotEmpty)
            InkWell(
                onTap: _restoreSelectedNotes,
                child: Text('Restore', style: TextStyle(fontSize: 12.sp))),
          UIHelper.horizontalSpaceSmall,
          if (_selectedNotes.isNotEmpty)
            InkWell(
                // onTap: _permanentlyDeleteSelectedNotes,
                onTap: () {
                  showPermanentlyDelete(context, () {
                    _permanentlyDeleteSelectedNotes();
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 20.w),
                  child: Text('Delete', style: TextStyle(fontSize: 12.sp)),
                )),
        ],
      ),
      drawer: CustomDrawer(),
      body: _recycleBinNotes.isEmpty
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
              itemCount: _recycleBinNotes.length,
              itemBuilder: (context, index) {
                final note = _recycleBinNotes[index];
                final isSelected = _selectedNotes.contains(note['id']);
                DateTime? deletedAt = note['deletedAt'] != null
                    ? DateTime.parse(note['deletedAt'])
                    : null;

                DateTime today = DateUtils.dateOnly(DateTime.now());
                DateTime deletedDate =
                    DateUtils.dateOnly(deletedAt ?? DateTime.now());

                int daysSinceDeleted = today.difference(deletedDate).inDays;

                return GestureDetector(
                  onLongPress: () {
                    setState(() {
                      _isSelecting = true;
                    });
                    _toggleNoteSelection(note['id']);
                  },
                  onTap: () {
                    if (_selectedNotes.isNotEmpty) {
                      _toggleNoteSelection(note['id']);
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
                            decoration: BoxDecoration(
                              color: themeController.isDarkMode.value
                                  ? Color(0xFF1E1E1E)
                                  : AppColors.cFFFFFF,
                              borderRadius: BorderRadius.circular(22.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(12.sp),
                                  child: note['content'] is String
                                      ? Text(
                                          extractPlainText(note['content']),
                                          maxLines: 11,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.left,
                                        )
                                      : QuillEditor(
                                          controller: _controller,
                                          focusNode: FocusNode(),
                                          scrollController: ScrollController(),
                                        ),
                                ),
                                Spacer(),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        deletedAt != null
                                            ? DateFormat('h:mm a')
                                                .format(deletedAt)
                                            : 'No Date',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                  ],
                                ),
                                Container(
                                  height: 30.h,
                                  width: double.infinity,
                                  alignment: Alignment.bottomCenter,
                                  padding: EdgeInsets.all(6.sp),
                                  decoration: BoxDecoration(
                                      color: themeController.isDarkMode.value
                                          ? const Color.fromARGB(
                                              255, 66, 63, 63)
                                          : AppColors.cFFFFFF,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(12.r),
                                        bottomRight: Radius.circular(12.r),
                                      )),
                                  child: Text(
                                    daysSinceDeleted == 0
                                        ? 'Deleted today'
                                        : ' $daysSinceDeleted days',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                )
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
                      Text(
                        deletedAt != null
                            ? DateFormat('dd MMM').format(deletedAt)
                            : 'No Date',
                        style: TextFontStyle.textStylec17cA1ABCCInter700
                            .copyWith(fontSize: 12.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
