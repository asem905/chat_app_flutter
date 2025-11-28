// import 'package:flutter/widgets.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:neoconcept/core/theming/text_styles.dart';

// class TermsAndConditionsText extends StatelessWidget {
//   final String agreeText;
//   const TermsAndConditionsText({super.key, required this.agreeText});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 15.w),
//       child: RichText(
//         textAlign: TextAlign.center,
//         text: TextSpan(
//         children:[
//           TextSpan(text: agreeText,style: TextStyles.font14WhiteRegular,),
//           TextSpan(text: "Terms & Conditions", style: TextStyles.font14LessLightBlueMedium),
//           TextSpan(text: " and ",
//               style: TextStyles.font13GrayRegular.copyWith(height: 1.5)
//           ),
//           TextSpan(text: "Privacy Policy", style: TextStyles.font14LessLightBlueMedium),
//         ]
//       )),
//     );
//   }
// }