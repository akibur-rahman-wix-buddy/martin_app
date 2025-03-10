import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:notely/features/home/presentation/widgets/carousel_widget.dart';
import 'package:notely/features/home/presentation/widgets/file_saver.dart';
import '../../../common_widgets/not_found_widget.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/text_font_style.dart';
import '../../../gen/colors.gen.dart';
import '../../../helpers/di.dart';
import '../../../helpers/helper_methods.dart';
import '../../../helpers/ui_helpers.dart';
import '../../custom_drawer/presentation/custom_drawer.dart';
import '../../database/db_helper.dart';
import '../../theme_controller/theme_controller.dart';
import 'edit_notes/note_edit_screen.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();
  quill.QuillController _controller = quill.QuillController.basic();
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchNotes();
    _loadNoteCounts();
    // _loadRecentSearches();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_isScrolling) {
      setState(() {
        _isScrolling = true;
      });
    } else if (_scrollController.offset <= 200 && _isScrolling) {
      setState(() {
        _isScrolling = false;
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _filteredNotes = [];
  List<Map<String, dynamic>> _previousNotes = [];

  final ThemeController themeController = Get.find<ThemeController>();

  List<String> _recentSearches = [];
  CarouselSliderController _carouselController = CarouselSliderController();
  int _currentSlideIndex = 0;

  bool _isSearching = false;
  String _searchQuery = '';

  Set<int> _selectedNotes = Set<int>();

  void _fetchNotes() async {
    final notes = await DatabaseHelper().getActiveNotes();

    setState(() {
      _notes = notes;
      _filteredNotes = notes;
      _previousNotes = notes.take(3).toList();
    });
    _loadNoteCounts();
  }

  void _deleteSelectedNotes() async {
    for (var id in _selectedNotes) {
      await DatabaseHelper().moveToRecycleBin(id);
    }
    setState(() {
      _selectedNotes.clear();
      if (_selectedNotes.isEmpty) {
        _isSelecting = false;
      }
    });
    _fetchNotes();
  }

  void _toggleNoteSelection(int noteId) {
    setState(() {
      if (_isSelecting) {
        if (_selectedNotes.contains(noteId)) {
          _selectedNotes.remove(noteId);
        } else {
          _selectedNotes.add(noteId);
        }

        // If no notes are selected, exit selection mode
        if (_selectedNotes.isEmpty) {
          _isSelecting = false;
        }
      }
    });
  }

  Future<void> _requestPermissionsAndDownload(String title, String note) async {
    String name = getCurrentTime();
    try {
      FileSaver fileSaver = FileSaver();
      await fileSaver.saveFileToDownload(name, note);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Notes downloaded successfully to \nDownloads folder as $name.txt')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download note: $e')),
      );
    }
  }

  String getCurrentTime() {
    DateTime now = DateTime.now();
    int hour = now.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour; // Convert 0 hour to 12 for 12 AM
    return '${hour.toString().padLeft(2, '0')}_${now.minute.toString().padLeft(2, '0')}_${now.second.toString().padLeft(2, '0')}_$period';
  }

  Future<void> _downloadSelectedNotes() async {
    DateTime now = DateTime.now();
    print(
        'Note${now.hour.toString().padLeft(2, '0')}_${now.minute.toString().padLeft(2, '0')}_${now.second.toString().padLeft(2, '0')}');
    if (_selectedNotes.isEmpty) return;

    try {
      getCurrentTime();
      FileSaver fileSaver = FileSaver();

      for (var id in _selectedNotes) {
        final note = _notes.firstWhere((note) => note['id'] == id);
        await fileSaver.saveFileToDownload(getCurrentTime(), note['content']);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selected notes downloaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download notes: $e')),
      );
    }
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredNotes = _notes.where((note) {
        final content = note['title']?.toLowerCase() ?? '';
        return content.contains(query.toLowerCase());
      }).toList();
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

  int _totalNotes = 0;
  int _editedNotes = 0;

  Future<void> _loadNoteCounts() async {
    int total = await DatabaseHelper().getTotalNotesCount();
    // int edited = await DatabaseHelper().getEditedNotesCount();
    setState(() {
      _totalNotes = total;
      // _editedNotes = edited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (_isSearching || _isSelecting) {
          setState(() {
            _isSearching = false;
            _isSelecting = false;
            _searchQuery = '';
            _filteredNotes = _notes;
            _selectedNotes.clear();
          });
        } else {
          showMaterialDialog(context);
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        drawer: CustomDrawer(),
        body: Stack(
          children: [
            if (_previousNotes.isNotEmpty)
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    UIHelper.verticalSpace(4.h),
                    Column(
                      children: [
                        Text(
                          'Previous Notes',
                          style: TextFontStyle.textStylec17cA09E9EPoppins700,
                        ),
                        UIHelper.verticalSpace(4.h),
                        if (_previousNotes.isNotEmpty)
                          NotesCarousel(
                            previousNotes: _previousNotes,
                            currentSlideIndex: _currentSlideIndex,
                            carouselController: _carouselController,
                          ),
                        UIHelper.verticalSpace(6.h),
                        Text(
                          '${appData.read(kEditCount)}',
                          style: TextFontStyle.textStylec17cA09E9EPoppins700
                              .copyWith(fontSize: 16.sp),
                        ),
                        UIHelper.verticalSpace(6.h),
                        _buildAllNotes(),
                      ],
                    ),
                  ],
                ),
              )
            else
              Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Empty Data",
                    style: TextFontStyle.textStylec17cA1ABCCInter700,
                  ),
                  NotFoundWidget(),
                ],
              )),
            if (_isScrolling)
              Positioned(
                bottom: 20.h,
                right: 150.w,
                child: GestureDetector(
                  onTap: _scrollToTop,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cCBD9F5,
                        ),
                      ),
                      child: Icon(Icons.arrow_upward, color: AppColors.cCBD9F5),
                    ),
                  ),
                ),
              )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          foregroundColor: themeController.isDarkMode.value
              ? AppColors.cFFFFFF
              : Color.fromARGB(255, 20, 20, 20),
          backgroundColor: themeController.isDarkMode.value
              ? Color.fromARGB(255, 20, 20, 20)
              : AppColors.cFFFFFF,
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

  Widget _buildAllNotes() {
    return Column(
      children: [
        Text(
          'All Notes (${_filteredNotes.length})',
          style: TextFontStyle.textStylec17cA1ABCCInter700,
        ),
        _filteredNotes.isEmpty
            ? Padding(
                padding: EdgeInsets.all(20),
                child: Text("No notes found", style: TextStyle(fontSize: 16)),
              )
            : GridView.builder(
                padding: EdgeInsets.all(12.sp),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 30.w,
                  childAspectRatio: 0.5,
                ),
                itemCount: _filteredNotes.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final note = _filteredNotes[index];
                  bool isSelected = _selectedNotes.contains(note['id']);

                  return GestureDetector(
                    onLongPress: () {
                      setState(() {
                        _isSelecting = true;
                      });
                      _toggleNoteSelection(note['id']);
                    },
                    onTap: () {
                      if (_selectedNotes.isEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoteEditorScreen(
                                note: note,
                                onSave: () {
                                  _fetchNotes();
                                  _loadNoteCounts();
                                }),
                          ),
                        );
                      } else {
                        // Handle selection mode
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
                            if (!_isSelecting)
                              Positioned(
                                bottom: 8.sp,
                                right: 8.sp,
                                child: IconButton(
                                  icon:
                                      Icon(Icons.download, color: Colors.blue),
                                  onPressed: () =>
                                      _requestPermissionsAndDownload(
                                          note['title'], note['content']),
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
                        // Text(
                        //   note['createAt'] != null
                        //       ? DateFormat('h:mm a')
                        //           .format(DateTime.parse(note['createAt']))
                        //       : 'No Title',
                        //   style: TextFontStyle.textStylec17cA1ABCCInter700
                        //       .copyWith(fontSize: 12.sp),
                        //   maxLines: 1,
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                        Text(
                          note['updatedAt'] != null
                              ? DateFormat('h:mm a').format(DateTime.parse(
                                  note['updatedAt'])) // Display updated time
                              : DateFormat('h:mm a').format(DateTime.parse(
                                  note['createAt'])), // Fallback to create time
                          style: TextFontStyle.textStylec17cA1ABCCInter700
                              .copyWith(fontSize: 12.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 1,
      shadowColor: AppColors.cFFFFFF,
      // iconTheme: IconThemeData(
      //   color: Colors.black,
      // ),
      title: _isSearching
          ? TextField(
              controller: _searchController,
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
        Obx(() => IconButton(
              icon: Icon(
                themeController.isDarkMode.value
                    ? Icons.nightlight_round // Dark mode icon (Moon)
                    : Icons.wb_sunny, // Light mode icon (Sun)
                color: themeController.isDarkMode.value
                    ? Colors.white
                    : Colors.black,
              ),
              onPressed: themeController.toggleTheme,
            )),
        if (_selectedNotes.isNotEmpty) ...[
          IconButton(
            icon: Icon(Icons.download, color: Colors.blue),
            onPressed: () async {
              await _downloadSelectedNotes();
              setState(() {
                _isSelecting = false;
                _selectedNotes.clear();
              });
            }, // Download selected notes
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteSelectedNotes,
          ),
        ],
        if (!_isSelecting)
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              size: 22.sp,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                  _filteredNotes = _filteredNotes; // Reset filtered notes
                }
              });
            },
          ),
        PopupMenuButton<String>(
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
                _selectedNotes.clear();
              });
            } else if (value == "pin_favourite") {
              for (var id in _selectedNotes) {
                await DatabaseHelper().toggleFavouriteStatus(id, true);
              }
              setState(() {
                _selectedNotes.clear();
                _isSelecting = false;
              });
              _fetchNotes();
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: "edit_preview",
              child: Text("Edit"),
            ),
            PopupMenuItem(
              value: "pin_favourite",
              child: Text("Pin to Favourite"),
            ),
          ],
        ),
      ],
    );
  }
}
