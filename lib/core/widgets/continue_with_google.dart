// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:neoconcept/core/helpers/spacing.dart';
// import 'package:neoconcept/core/theming/colors_manager.dart';
// import 'package:neoconcept/core/theming/text_styles.dart';

// class ContinueWithGoogle extends StatelessWidget {
//   const ContinueWithGoogle({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         decoration: BoxDecoration(
//           color: ColorsManager.darkBlue,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(color: ColorsManager.lighterGray),
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
//         child: Row(
//           children: [
//             Container(
//               width: 35.w,
//               height: 35.h,
//               decoration: BoxDecoration(shape: BoxShape.circle),
//               child: ClipOval(child: Image.asset("assets/images/google.png")),
//             ),
//             horizontalSpacing(20.w),
//             Text("Continue with Google", style: TextStyles.font18WhiteBold),
//           ],
//         ),
//       );
//   }
// }
