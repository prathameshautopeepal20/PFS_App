import 'package:atpl_flashing_app/themes/app_colors.dart';
import 'package:atpl_flashing_app/utils/sizes.dart';
import 'package:atpl_flashing_app/utils/ui_helper_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

class RoundedSearchBottomContainer extends StatelessWidget {
  final String zipcode;

  const RoundedSearchBottomContainer({super.key, required this.zipcode});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25.0),
          bottomRight: Radius.circular(25.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF39A657),
                Color(0xFF177A32),
              ],
            ),
          ),
          height: Sizes.heightClipSearch(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              C50(),
              InkWell(
                //onTap: () => Get.toNamed(Routes.zipCodeScreen),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Shopping in ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: FontSizes.s14,
                          fontFamily: "Inter-Regular"),
                    ),
                    Text(
                      "${zipcode}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: FontSizes.s14,
                          fontFamily: "Inter-Bold",
                          fontWeight: FontWeight.w700),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: AppColors.white,
                    )
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 44,
                    child: TextField(
                      readOnly: true,
                      onTap: () => Get.toNamed("searchMoreScreen"),
                      // onChanged: (value) => Get.toNamed("searchMoreScreen"),
                      decoration: InputDecoration(
                          filled: true,
                          // searchMoreScreen
                          
                          fillColor: AppColors.white,
                          contentPadding: EdgeInsets.all(10),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.textFieldLableColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: 'Search for item, store and more',
                          hintStyle: TextStyle(
                              color: AppColors.textFieldLableColor,
                              fontSize: FontSizes.s14,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Inter-Regular")),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

@override
Path getClip(Size size) {
  final path = Path();
  path.lineTo(0, size.height - 30); // Start at the top-left
  path.quadraticBezierTo(size.width / 2, size.height, size.width,
      size.height - 30); // Curve to the top-right
  path.lineTo(size.width, 0); // Line to the bottom-right
  path.close(); // Close the path

  return path;
}

@override
bool shouldReclip(CustomClipper<Path> oldClipper) {
  return false;
}
