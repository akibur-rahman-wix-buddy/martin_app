import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../gen/colors.gen.dart';

class ScrollToTopButton extends StatelessWidget {
  final VoidCallback onTap;

  ScrollToTopButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20.h,
      right: 150.w,
      child: GestureDetector(
        onTap: onTap,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    );
  }
}
