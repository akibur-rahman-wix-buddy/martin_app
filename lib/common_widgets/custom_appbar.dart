import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/text_font_style.dart';
import '../gen/colors.gen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final double elevation;
  final Function()? onBackPressed;
  final bool isCenterd;

  const CustomAppBar({
    super.key,
    this.title,
    this.elevation = 0.0,
    this.onBackPressed,
    this.isCenterd = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.keyboard_arrow_left,
            color: AppColors.c394456,
          )),
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: isCenterd,
      title: Text(title ?? ''),
      titleTextStyle: TextFontStyle.headline18c292E34ODmSans500
          .copyWith(fontWeight: FontWeight.w700),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
