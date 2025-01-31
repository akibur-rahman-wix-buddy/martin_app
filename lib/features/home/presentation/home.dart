import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/text_font_style.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../../helpers/helper_methods.dart';
import '../../../helpers/ui_helpers.dart';
import '../../custom_drawer/presentation/custom_drawer.dart';
import '../../database/db_helper.dart';
import 'edit_notes/note_edit_screen.dart';

import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchNotes(); // Attach scroll listener
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener); // Remove listener
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Show the button only when scrolling down past 200 pixels
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
  }

  Future<void> _loadRecentSearches() async {
    List<String> searches = await DatabaseHelper().getRecentSearches();
    setState(() {
      _recentSearches = searches;
    });
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

  // void _onSearchQueryChanged(String query) {
  //   setState(() {
  //     _searchQuery = query;
  //     _filteredNotes = _notes.where((note) {
  //       final content = note['content']?.toLowerCase() ?? '';
  //       return content.contains(query.toLowerCase());
  //     }).toList();
  //   });
  // }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredNotes = _notes.where((note) {
        final content = note['content']?.toLowerCase() ?? '';
        return content.contains(query.toLowerCase());
      }).toList();
    });

    // Save the query to the database
    DatabaseHelper().addSearchQuery(query);
  }

  void _clearSearchHistory() async {
    await DatabaseHelper().clearRecentSearches();
    setState(() {
      // Update your UI if necessary
    });
  }

  bool _isSelecting = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (_isSearching) {
          setState(() {
            _isSearching = false;
            _searchQuery = '';
            _filteredNotes = _notes;
          });
        } else {
          showMaterialDialog(context);
        }
      },

      // PopScope(
      //   canPop: false,
      //   onPopInvokedWithResult: (bool didPop, _) async {
      //     showMaterialDialog(context);
      //   },
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          shadowColor: AppColors.cFFFFFF,
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
            if (_selectedNotes.isNotEmpty)
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: _deleteSelectedNotes,
              ),
            if (!_isSelecting)
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
            PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == "edit_preview") {
                  setState(() {
                    _isSelecting = true; // Enable selection mode
                    _selectedNotes.clear(); // Clear previous selections
                  });
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: "edit_preview",
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.black),
                      SizedBox(width: 10),
                      Text("Edit Preview"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        drawer: CustomDrawer(),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  UIHelper.verticalSpace(4.h),
                  _isSearching
                      ? SizedBox.shrink()
                      : Column(
                          children: [
                            Text(
                              'Previous Notes',
                              style:
                                  TextFontStyle.textStylec17cA09E9EPoppins700,
                            ),
                            UIHelper.verticalSpace(4.h),
                            if (_previousNotes.isNotEmpty)
                              Stack(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.w),
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
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 8.w),
                                          padding: EdgeInsets.all(10.sp),
                                          decoration: BoxDecoration(
                                            color: AppColors.cEFF0F3,
                                            borderRadius:
                                                BorderRadius.circular(22.r),
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
                                          size: 20.sp,
                                          color: AppColors.cBFBBBB),
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
                                          size: 20.sp,
                                          color: AppColors.cBFBBBB),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        _previousNotes.length,
                                        (index) => Container(
                                          width: 8.w,
                                          height: 8.h,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 4.w),
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
                  GridView.builder(
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
                                  onSave: _fetchNotes,
                                ),
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
                                    color: AppColors.cFFFFFF,
                                    borderRadius: BorderRadius.circular(22.r),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note['content'] ?? 'No Content',
                                        maxLines: 9,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.black),
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
                                          color: isSelected
                                              ? Colors.red
                                              : Colors.grey,
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
                    },
                  ),
                ],
              ),
            ),
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

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // [State variables and methods from original code]

//   final ScrollController _scrollController = ScrollController();
//   bool _isScrolling = false;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_scrollListener);
//     _fetchNotes(); // Attach scroll listener
//     _loadRecentSearches();
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_scrollListener); // Remove listener
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _scrollListener() {
//     // Show the button only when scrolling down past 200 pixels
//     if (_scrollController.offset > 200 && !_isScrolling) {
//       setState(() {
//         _isScrolling = true;
//       });
//     } else if (_scrollController.offset <= 200 && _isScrolling) {
//       setState(() {
//         _isScrolling = false;
//       });
//     }
//   }

//   void _scrollToTop() {
//     _scrollController.animateTo(
//       0.0,
//       duration: Duration(milliseconds: 500),
//       curve: Curves.easeInOut,
//     );
//   }

//   List<Map<String, dynamic>> _notes = [];
//   List<Map<String, dynamic>> _filteredNotes = [];
//   List<Map<String, dynamic>> _previousNotes = [];
//   List<String> _recentSearches = [];
//   CarouselSliderController _carouselController = CarouselSliderController();
//   int _currentSlideIndex = 0;

//   bool _isSearching = false;
//   String _searchQuery = '';

//   Set<int> _selectedNotes = Set<int>();

//   void _fetchNotes() async {
//     final notes = await DatabaseHelper().getActiveNotes();
//     setState(() {
//       _notes = notes;
//       _filteredNotes = notes;
//       _previousNotes = notes.take(3).toList();
//     });
//   }

//   Future<void> _loadRecentSearches() async {
//     List<String> searches = await DatabaseHelper().getRecentSearches();
//     setState(() {
//       _recentSearches = searches;
//     });
//   }

//   void _deleteSelectedNotes() async {
//     for (var id in _selectedNotes) {
//       await DatabaseHelper().moveToRecycleBin(id);
//     }
//     setState(() {
//       _selectedNotes.clear();
//     });
//     _fetchNotes();
//   }

//   void _toggleNoteSelection(int noteId) {
//     setState(() {
//       if (_isSelecting) {
//         if (_selectedNotes.contains(noteId)) {
//           _selectedNotes.remove(noteId);
//         } else {
//           _selectedNotes.add(noteId);
//         }

//         // If no notes are selected, exit selection mode
//         if (_selectedNotes.isEmpty) {
//           _isSelecting = false;
//         }
//       }
//     });
//   }

//   // void _onSearchQueryChanged(String query) {
//   //   setState(() {
//   //     _searchQuery = query;
//   //     _filteredNotes = _notes.where((note) {
//   //       final content = note['content']?.toLowerCase() ?? '';
//   //       return content.contains(query.toLowerCase());
//   //     }).toList();
//   //   });
//   // }

//   void _onSearchQueryChanged(String query) {
//     setState(() {
//       _searchQuery = query;
//       _filteredNotes = _notes.where((note) {
//         final content = note['content']?.toLowerCase() ?? '';
//         return content.contains(query.toLowerCase());
//       }).toList();
//     });

//     // Save the query to the database
//     DatabaseHelper().addSearchQuery(query);
//   }

//   void _clearSearchHistory() async {
//     await DatabaseHelper().clearRecentSearches();
//     setState(() {
//       // Update your UI if necessary
//     });
//   }

//   bool _isSelecting = false;

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (bool didPop, _) async {
//         showMaterialDialog(context);
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           elevation: 1,
//           shadowColor: AppColors.cFFFFFF,
//           iconTheme: IconThemeData(
//             color: Colors.black,
//           ),
//           title: _isSearching
//               ? TextField(
//                   autofocus: true,
//                   onChanged: _onSearchQueryChanged,
//                   decoration: InputDecoration(
//                     hintText: 'Search Notes...',
//                     hintStyle: TextStyle(color: Colors.black),
//                     border: InputBorder.none,
//                   ),
//                   style: TextStyle(color: Colors.black),
//                 )
//               : Text(
//                   _selectedNotes.isEmpty
//                       ? 'All Notes (${_filteredNotes.length})'
//                       : '${_selectedNotes.length} Selected',
//                   style: TextFontStyle.textStylec17cA1ABCCInter700,
//                 ),
//           actions: [
//             if (_selectedNotes.isNotEmpty)
//               IconButton(
//                 icon: Icon(Icons.delete, color: Colors.red),
//                 onPressed: _deleteSelectedNotes,
//               ),
//             InkWell(
//               onTap: () {
//                 setState(() {
//                   _isSearching = !_isSearching;
//                 });
//               },
//               child: Padding(
//                 padding: EdgeInsets.all(4.sp),
//                 child: Image.asset(Assets.icons.searchIcon.path),
//               ),
//             ),
//             PopupMenuButton<String>(
//               onSelected: (String value) {
//                 if (value == "edit_preview") {
//                   setState(() {
//                     _isSelecting = true; // Enable selection mode
//                     _selectedNotes.clear(); // Clear previous selections
//                   });
//                 }
//               },
//               itemBuilder: (BuildContext context) => [
//                 PopupMenuItem(
//                   value: "edit_preview",
//                   child: Row(
//                     children: [
//                       Icon(Icons.edit, color: Colors.black),
//                       SizedBox(width: 10),
//                       Text("Edit Preview"),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         drawer: CustomDrawer(),
//         body: Stack(
//           children: [
//             SingleChildScrollView(
//                 controller: _scrollController,
//                 child: Column(
//                   children: [
//                     _isSearching
//                         ? SizedBox.shrink()
//                         : Column(
//                             children: [
//                               NotesCarousel(
//                                 previousNotes: _previousNotes,
//                                 currentSlideIndex: _currentSlideIndex,
//                                 carouselController: _carouselController,
//                               ),
//                               UIHelper.verticalSpace(6.h),
//                               NotesGrid(
//                                 filteredNotes: _filteredNotes,
//                                 selectedNotes: _selectedNotes,
//                                 isSelecting: _isSelecting,
//                                 toggleNoteSelection: _toggleNoteSelection,
//                                 onNoteTap: (id) {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => NoteEditorScreen(
//                                         note: _filteredNotes.firstWhere(
//                                             (note) => note['id'] == id),
//                                         onSave: _fetchNotes,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                   ],
//                 )),
//             if (_isScrolling) ScrollToTopButton(onTap: _scrollToTop),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           foregroundColor: AppColors.cFFFFFF,
//           backgroundColor: AppColors.cA1ABCC,
//           onPressed: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => NoteEditorScreen(onSave: _fetchNotes),
//             ),
//           ),
//           child: Icon(Icons.add),
//         ),
//       ),
//     );
//   }
// }
