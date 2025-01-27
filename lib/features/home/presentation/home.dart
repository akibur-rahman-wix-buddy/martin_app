import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:martin_app/constants/text_font_style.dart';
import 'package:martin_app/features/home/presentation/database/db_helper.dart';
import 'package:martin_app/gen/colors.gen.dart';
import 'package:martin_app/helpers/navigation_service.dart';
import 'package:martin_app/helpers/ui_helpers.dart';

import '../../../gen/assets.gen.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/helper_methods.dart';
import '../../custom_drawer/presentation/custom_drawer.dart';
import 'edit_notes/note_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _filteredNotes = [];
  List<Map<String, dynamic>> _previousNotes = [];
  CarouselSliderController _carouselController = CarouselSliderController();
  int _currentSlideIndex = 0;
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isSearching = false;
  String _searchQuery = '';

  Set<int> _selectedNotes = Set<int>();

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  // void _fetchNotes() async {
  //   final notes = await DatabaseHelper().getNotes();
  //   setState(() {
  //     _notes = notes;
  //     _filteredNotes = notes; // Initialize filtered notes as all notes
  //     _previousNotes = notes.take(3).toList();
  //   });
  // }

  void _fetchNotes() async {
    final notes = await DatabaseHelper().getActiveNotes();
    setState(() {
      _notes = notes;
      _filteredNotes = notes;
      _previousNotes = notes.take(3).toList();
    });
  }

  void _deleteSelectedNotes() async {
    for (var id in _selectedNotes) {
      await DatabaseHelper().moveToRecycleBin(id);
    }
    setState(() {
      _selectedNotes.clear();
    });
    _fetchNotes();
  }

  void _toggleNoteSelection(int noteId) {
    setState(() {
      if (_selectedNotes.contains(noteId)) {
        _selectedNotes.remove(noteId);
      } else {
        _selectedNotes.add(noteId);
      }
    });
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredNotes = _notes.where((note) {
        final content = note['content']?.toLowerCase() ?? '';
        return content.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) async {
        showMaterialDialog(context);
      },
      child: Scaffold(
        // key: _scaffoldKey,
        appBar: AppBar(
          elevation: 1,
          shadowColor: AppColors.cFFFFFF,
          surfaceTintColor: AppColors.cFFFFFF,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: _isSearching
              ? TextField(
                  autofocus: true,
                  onChanged: _onSearchQueryChanged,
                  decoration: InputDecoration(
                    hintText: 'Search Notes...',
                    hintStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.black),
                )
              : Text(
                  _selectedNotes.isEmpty
                      ? 'All Notes (${_filteredNotes.length})'
                      : '${_selectedNotes.length} Selected',
                  style: TextFontStyle.textStylec17cA1ABCCInter700,
                ),
          actions: [
            // IconButton(
            //   icon: Icon(
            //     Icons.search,
            //     size: 35,
            //   ),
            //   onPressed: () {
            //     setState(() {
            //       _isSearching = !_isSearching;
            //     });
            //   },
            // ),
            if (_selectedNotes.isNotEmpty)
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: _deleteSelectedNotes,
              ),
            InkWell(
              onTap: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              },
              child: Padding(
                padding: EdgeInsets.all(4.sp),
                child: Image.asset(Assets.icons.searchIcon.path),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14.sp),
              child: Image.asset(Assets.icons.more.path),
            ),
          ],
        ),
        drawer: CustomDrawer(),
        body: Column(
          children: [
            UIHelper.verticalSpace(4.h),
            _isSearching
                ? SizedBox.shrink()
                : Column(
                    children: [
                      Text(
                        'Previous Notes',
                        style: TextFontStyle.textStylec17cA09E9EPoppins700,
                      ),
                      UIHelper.verticalSpace(4.h),
                      if (_previousNotes.isNotEmpty)
                        Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: CarouselSlider(
                                carouselController: _carouselController,
                                options: CarouselOptions(
                                  height: 122.h,
                                  viewportFraction: 1,
                                  autoPlay: true,
                                  enlargeCenterPage: true,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentSlideIndex = index;
                                    });
                                  },
                                ),
                                items: _previousNotes.map((note) {
                                  return Container(
                                    width: double.infinity,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.w),
                                    padding: EdgeInsets.all(10.sp),
                                    decoration: BoxDecoration(
                                      color: AppColors.cEFF0F3,
                                      borderRadius: BorderRadius.circular(22.r),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 5),
                                        Text(
                                          note['content'] ?? 'No Content',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 35.h,
                              child: IconButton(
                                icon: Icon(Icons.arrow_back_ios,
                                    size: 20.sp, color: AppColors.cBFBBBB),
                                onPressed: () {
                                  if (_currentSlideIndex > 0) {
                                    _carouselController.previousPage();
                                  }
                                },
                              ),
                            ),
                            Positioned(
                              right: -5,
                              top: 35.h,
                              child: IconButton(
                                icon: Icon(Icons.arrow_forward_ios,
                                    size: 20.sp, color: AppColors.cBFBBBB),
                                onPressed: () {
                                  if (_currentSlideIndex <
                                      _previousNotes.length - 1) {
                                    _carouselController.nextPage();
                                  }
                                },
                              ),
                            ),
                            Positioned(
                              right: 50.w,
                              bottom: 8.h,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _previousNotes.length,
                                  (index) => Container(
                                    width: 8.w,
                                    height: 8.h,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 4.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentSlideIndex == index
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      UIHelper.verticalSpace(6.h),
                      Text(
                        'Learning from mistakes - 09/03',
                        style: TextFontStyle.textStylec17cA09E9EPoppins700
                            .copyWith(fontSize: 16.sp),
                      ),
                      UIHelper.verticalSpace(6.h),
                      Text(
                        'All Notes (${_filteredNotes.length})',
                        style: TextFontStyle.textStylec17cA1ABCCInter700,
                      ),
                    ],
                  ),
            Expanded(
              child: GridView.builder(
                  padding: EdgeInsets.all(12.sp),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 30,
                    mainAxisSpacing: 20,
                    childAspectRatio: 2 / 3,
                  ),
                  itemCount: _filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = _filteredNotes[index];
                    bool isSelected = _selectedNotes.contains(note['id']);

                    return GestureDetector(
                      onLongPress: () => _toggleNoteSelection(note['id']),
                      onTap: () {
                        if (_selectedNotes.isEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteEditorScreen(
                                note: note,
                                onSave: _fetchNotes,
                              ),
                            ),
                          );
                        } else {
                          _toggleNoteSelection(note['id']);
                        }
                      },
                      child: Column(
                        children: [
                          AnimatedContainer(
                            height: 200.h,
                            width: double.infinity,
                            duration: Duration(milliseconds: 200),
                            margin: EdgeInsets.all(4.sp),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blueAccent.withOpacity(0.3)
                                  : AppColors.cFFFFFF,
                              borderRadius: BorderRadius.circular(22.r),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blueAccent
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note['content'] ?? 'No Content',
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            note['title'] ?? 'No title',
                            maxLines: 9,
                            overflow: TextOverflow.ellipsis,
                            style: TextFontStyle.textStylec17cA1ABCCInter700,
                          ),
                          UIHelper.verticalSpace(4.h),
                          Text(
                            note['createAt'] != null
                                ? DateFormat('h:mm a')
                                    .format(DateTime.parse(note['createAt']))
                                : 'No Title',
                            style: TextFontStyle.textStylec17cA1ABCCInter700
                                .copyWith(fontSize: 12.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          foregroundColor: AppColors.cFFFFFF,
          backgroundColor: AppColors.cA1ABCC,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoteEditorScreen(
                onSave: _fetchNotes,
              ),
            ),
          ),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
