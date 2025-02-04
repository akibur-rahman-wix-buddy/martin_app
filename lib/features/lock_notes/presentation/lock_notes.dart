import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:martin_app/features/lock_notes/presentation/widget/show_lock_dialog.dart';
import 'package:martin_app/features/lock_notes/presentation/widget/show_unlock_dialog.dart';
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

  bool isSelected = false;
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
    });
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
        title: Text(
          'Lock Notes',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Image.asset(
              Assets.icons.searchIcon.path,
              color: Colors.black,
            ),
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
        itemCount: _lockedNotes.length,
        itemBuilder: (context, index) {
          final note = _lockedNotes[index];
          return Column(
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            // showLockNotesDialog(
                            //   context,
                            //   () => () {},
                            // );

                            showUnlockDialog(
                              context,
                              note['id'],
                              note['password'], // Pass the stored password
                              () => _loadLockedNotes, // Refresh after unlocking
                            );
                          },
                          child: Center(
                            child: Image.asset(
                              Assets.icons.lock.path,
                              height: 30.h,
                            ),
                          ),
                        )
                        // Text(
                        //   'Content Data',
                        //   maxLines: 12,
                        //   overflow: TextOverflow.ellipsis,
                        //   style:
                        //       TextStyle(fontSize: 14.sp, color: Colors.black),
                        // ),
                      ],
                    ),
                  ),
                  if (isSelected)
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
                            color: Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {},
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
                note['title'],
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
              UIHelper.horizontalSpace(2.w),
            ],
          );
        },
      ),
    );
  }
}
