import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../constants/text_font_style.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class NotesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> filteredNotes;
  final Set<int> selectedNotes;
  final bool isSelecting;
  final Function(int) toggleNoteSelection;
  final Function(int) onNoteTap;

  NotesGrid({
    required this.filteredNotes,
    required this.selectedNotes,
    required this.isSelecting,
    required this.toggleNoteSelection,
    required this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(12.sp),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 30.w,
        childAspectRatio: 0.5,
      ),
      itemCount: filteredNotes.length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        bool isSelected = selectedNotes.contains(note['id']);

        return GestureDetector(
          onLongPress: () {
            toggleNoteSelection(note['id']);
          },
          onTap: () {
            if (selectedNotes.isEmpty) {
              onNoteTap(note['id']);
            } else {
              toggleNoteSelection(note['id']);
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
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                  if (isSelecting)
                    Positioned(
                      top: 8.sp,
                      right: 8.sp,
                      child: Container(
                        height: 25.h,
                        width: 25.w,
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
                              toggleNoteSelection(note['id']);
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
    );
  }
}
