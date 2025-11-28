// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:neoconcept/core/helpers/spacing.dart';

// class OrLine extends StatelessWidget {
//   const OrLine({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 55.w),
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(height: 1.h, color: Colors.white),
//           ),
//           horizontalSpacing(8.w),
//           //circle contains or in it:
//           Container(
//             width: 30.w,
//             height: 30.w,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white,
//             ),
//             child: Center(
//               child: Text(
//                 "OR",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           horizontalSpacing(8.w),
//           Expanded(
//             child: Container(height: 1.h, color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }
// }
