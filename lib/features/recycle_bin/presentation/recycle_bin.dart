import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:martin_app/features/custom_drawer/presentation/custom_drawer.dart';

import '../../../constants/text_font_style.dart';
import '../../../gen/colors.gen.dart';
import '../../../helpers/ui_helpers.dart';
import '../../database/db_helper.dart';
import 'widgets/show_permamently_delete_dialog.dart';

class RecycleBinScreen extends StatefulWidget {
  @override
  _RecycleBinScreenState createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _recycleBinNotes = [];
  Set<int> _selectedNotes = Set<int>();

  @override
  void initState() {
    super.initState();
    _fetchRecycleBinNotes();
  }

  // void _fetchRecycleBinNotes() async {
  //   final notes = await DatabaseHelper().getRecycleBinNotes();
  //   setState(() {
  //     _recycleBinNotes = notes;
  //   });
  // }

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
                _selectedNotes.isEmpty
                    ? 'Recycle Bin'
                    : '${_selectedNotes.length} Selected',
                style: TextStyle(color: Colors.black)),
            if (!_isSelecting)
              Text(' (${_recycleBinNotes.length} notes)',
                  style: TextStyle(color: Colors.black, fontSize: 15.sp)),
          ],
        ),
        actions: [
          if (!_isSelecting)
            Padding(
              padding: EdgeInsets.all(16.sp),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isSelecting = true;
                    _selectedNotes.clear();
                  });
                },
                child: Text(
                  'Select',
                  style: TextFontStyle.textStylec17c000000Poppins400,
                ),
              ),
            ),
          if (_selectedNotes.isNotEmpty)
            InkWell(
                onTap: _restoreSelectedNotes,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Text('Restore',
                      style: TextStyle(color: Colors.black, fontSize: 12.sp)),
                )),
          if (_selectedNotes.isNotEmpty)
            InkWell(
                // onTap: _permanentlyDeleteSelectedNotes,
                onTap: () {
                  showPermanentlyDelete(context, () {
                    _permanentlyDeleteSelectedNotes();
                  });
                },
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                  child: Text('Delete',
                      style: TextStyle(color: Colors.black, fontSize: 12.sp)),
                )),
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
        itemCount: _recycleBinNotes.length,
        itemBuilder: (context, index) {
          final note = _recycleBinNotes[index];
          final isSelected = _selectedNotes.contains(note['id']);
          DateTime? deletedAt = note['deletedAt'] != null
              ? DateTime.parse(note['deletedAt'])
              : null;

          // int daysSinceDeleted = deletedAt != null
          //     ? DateTime.now().difference(deletedAt).inDays
          //     : 0;
          DateTime today = DateUtils.dateOnly(DateTime.now());
          DateTime deletedDate =
              DateUtils.dateOnly(deletedAt ?? DateTime.now());

          int daysSinceDeleted = today.difference(deletedDate).inDays;

          // int daysRemaining = 30 - daysSinceDeleted;
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
                      // padding: EdgeInsets.all(12.sp),
                      decoration: BoxDecoration(
                        color: AppColors.cFFFFFF,
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12.sp),
                            child: Expanded(
                              child: Text(
                                note['content'] ?? 'No Content',
                                maxLines: 10,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ),
                          Spacer(),
                          // Text(
                          //   createdAt != null
                          //       ? DateFormat('MMM dd, yyyy h:mm a').format(createdAt)
                          //       : 'No Date',
                          //   style: TextStyle(fontSize: 12, color: Colors.grey),
                          // ),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  deletedAt != null
                                      ? DateFormat('h:mm a').format(deletedAt)
                                      : 'No Date',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 8.h),

                              // Text(
                              //   daysRemaining > 0
                              //       ? '$daysRemaining days left'
                              //       : 'Deleting soon!',
                              //   style: TextStyle(
                              //     fontSize: 12,
                              //     color: daysRemaining > 0
                              //         ? Colors.orange
                              //         : Colors.red,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                            ],
                          ),
                          Container(
                            height: 30.h,
                            width: double.infinity,
                            alignment: Alignment.bottomCenter,
                            padding: EdgeInsets.all(6.sp),
                            decoration: BoxDecoration(
                                color: AppColors.cBFBBBB,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12.r),
                                  bottomRight: Radius.circular(12.r),
                                )),
                            child: Text(
                              daysSinceDeleted == 0
                                  ? 'Deleted today'
                                  : ' $daysSinceDeleted days',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
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
