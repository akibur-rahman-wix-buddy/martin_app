// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:notely/features/lock_notes/presentation/widget/show_unlock_dialog.dart';
// import '../../../constants/text_font_style.dart';
// import '../../../gen/assets.gen.dart';
// import '../../../gen/colors.gen.dart';
// import '../../../helpers/ui_helpers.dart';
// import '../../custom_drawer/presentation/custom_drawer.dart';
// import '../../database/db_helper.dart';

// class LockNotesScreen extends StatefulWidget {
//   @override
//   _LockNotesScreenState createState() => _LockNotesScreenState();
// }

// class _LockNotesScreenState extends State<LockNotesScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   List<Map<String, dynamic>> _lockedNotes = [];

//   bool isSelected = false;
//   String _searchQuery = '';
//   bool _isSearching = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadLockedNotes();
//   }

//   void _loadLockedNotes() async {
//     List<Map<String, dynamic>> lockedNotes =
//         await DatabaseHelper().getLockedNotes();
//     setState(() {
//       _lockedNotes = lockedNotes;
//     });
//   }

//   void _onSearchQueryChanged(String query) {
//     setState(() {
//       _searchQuery = query;
//       _lockedNotes = _lockedNotes.where((note) {
//         final content = note['title']?.toLowerCase() ?? '';
//         return content.contains(query.toLowerCase());
//       }).toList();
//     });

//     // Save the query to the database
//     DatabaseHelper().addSearchQuery(query);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         leading: IconButton(
//           icon: Icon(
//             Icons.menu,
//             color: Colors.black,
//           ),
//           onPressed: () {
//             _scaffoldKey.currentState?.openDrawer();
//           },
//         ),
//         titleSpacing: 0,
//         title: _isSearching
//             ? TextField(
//                 autofocus: true,
//                 onChanged: _onSearchQueryChanged,
//                 decoration: InputDecoration(
//                   hintText: 'Search Notes...',
//                   hintStyle: TextStyle(color: Colors.black),
//                   border: InputBorder.none,
//                 ),
//                 style: TextStyle(color: Colors.black),
//               )
//             : Text(
//                 'Lock Notes',
//                 style: TextStyle(color: Colors.black),
//               ),
//         actions: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//             child: InkWell(
//               onTap: () {
//                 setState(() {
//                   _isSearching = !_isSearching;
//                 });
//               },
//               child: Image.asset(
//                 Assets.icons.searchIcon.path,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ],
//       ),
//       drawer: CustomDrawer(),
//       body: GridView.builder(
//         padding: EdgeInsets.all(12.sp),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 30.w,
//           childAspectRatio: 0.5,
//         ),
//         itemCount: _lockedNotes.length,
//         itemBuilder: (context, index) {
//           final note = _lockedNotes[index];
//           return Column(
//             children: [
//               Stack(
//                 children: [
//                   AnimatedContainer(
//                     height: 250.h,
//                     width: double.infinity,
//                     duration: Duration(milliseconds: 200),
//                     margin: EdgeInsets.all(4.sp),
//                     padding: EdgeInsets.all(12.sp),
//                     decoration: BoxDecoration(
//                       color: AppColors.cFFFFFF,
//                       borderRadius: BorderRadius.circular(22.r),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             showUnlockDialog(
//                                 context, note['id'], note['password'], () {
//                               _loadLockedNotes();
//                               setState(() {});
//                             });
//                           },
//                           child: Center(
//                             child: Image.asset(
//                               Assets.icons.lock.path,
//                               height: 30.h,
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                   if (isSelected)
//                     Positioned(
//                       top: 8.sp,
//                       right: 8.sp,
//                       child: Container(
//                         height: 25.h,
//                         width: 25.w,
//                         padding: EdgeInsets.zero,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: Colors.grey,
//                             width: 2,
//                           ),
//                         ),
//                         child: Transform.scale(
//                           scale: 1.2,
//                           child: Checkbox(
//                             value: isSelected,
//                             onChanged: (bool? value) {},
//                             activeColor: Colors.red,
//                             checkColor: Colors.white,
//                             shape: CircleBorder(),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               Text(
//                 note['title'],
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextFontStyle.textStylec17cA1ABCCInter700,
//               ),
//               UIHelper.verticalSpace(4.h),
//               Text(
//                 note['createAt'] != null
//                     ? DateFormat('h:mm a')
//                         .format(DateTime.parse(note['createAt']))
//                     : 'No Title',
//                 style: TextFontStyle.textStylec17cA1ABCCInter700
//                     .copyWith(fontSize: 12.sp),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               UIHelper.horizontalSpace(2.w),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:notely/features/lock_notes/presentation/widget/show_unlock_dialog.dart';
import '../../../common_widgets/not_found_widget.dart';
import '../../../constants/text_font_style.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../../helpers/ui_helpers.dart';
import '../../custom_drawer/presentation/custom_drawer.dart';
import '../../database/db_helper.dart';

class LockNotesScreen extends StatefulWidget {
  @override
  _LockNotesScreenState createState() => _LockNotesScreenState();
}

class _LockNotesScreenState extends State<LockNotesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _lockedNotes = [];
  List<Map<String, dynamic>> _filteredNotes = [];

  Set<int> _selectedNotes = {}; // Track selected notes
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLockedNotes();
  }

  void _loadLockedNotes() async {
    List<Map<String, dynamic>> lockedNotes =
        await DatabaseHelper().getLockedNotes();
    setState(() {
      _lockedNotes = lockedNotes;
      _filteredNotes = lockedNotes; // Keep original list intact
    });
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _filteredNotes = _lockedNotes.where((note) {
        final content = note['title']?.toLowerCase() ?? '';
        return content.contains(query.toLowerCase());
      }).toList();
    });

    // Save the query to the database
    DatabaseHelper().addSearchQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        titleSpacing: 0,
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
            : Text('Lock Notes', style: TextStyle(color: Colors.black)),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    _filteredNotes = _lockedNotes;
                  }
                });
              },
              child: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: Colors.black,
                size: 28.sp,
              ),
            ),
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
                  'Data Not Found',
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
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                final note = _filteredNotes[index];
                final isSelected = _selectedNotes.contains(note['id']);

                return Column(
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              showUnlockDialog(
                                  context, note['id'], note['password'], () {
                                _loadLockedNotes();
                              });
                            },
                            child: Center(
                              child: Image.asset(
                                Assets.icons.lock.path,
                                height: 30.h,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Text(
                      note['title'] ?? 'No Title',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextFontStyle.textStylec17cA1ABCCInter700,
                    ),
                    UIHelper.verticalSpace(4.h),
                    Text(
                      note['createAt'] != null
                          ? DateFormat('h:mm a')
                              .format(DateTime.parse(note['createAt']))
                          : 'No Date',
                      style: TextFontStyle.textStylec17cA1ABCCInter700.copyWith(
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    UIHelper.horizontalSpace(2.w),
                  ],
                );
              },
            ),
    );
  }
}
