import 'package:atpl_flashing_app/common_widgets/background_widget.dart';
import 'package:atpl_flashing_app/common_widgets/text_field.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/dasboardController.dart';
import 'package:atpl_flashing_app/themes/app_textstyles.dart';
import 'package:atpl_flashing_app/utils/sizes.dart';
import 'package:atpl_flashing_app/utils/ui_helper_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../themes/app_theme.dart';
import 'custom_clipper_widget.dart';

double get extendedWidgetHeight => (screenWidth * 9) / 16;
int get maxTitleLine => 1;

AppBar appBarWithTitle({
  required String? title,
  String? subtitle,
  List<Widget>? actions,
  bool titleAction = false,
}) {
  Widget titleWidget = Text(
    title!,
    style: TextStyles.appBarTitle,
    maxLines: maxTitleLine,
    overflow: TextOverflow.ellipsis,
  );
  return AppBar(
    titleSpacing: 10,
    title: titleWidget,
    actions: actions,
    backgroundColor: AppColors.primaryColor,
    iconTheme: IconThemeData(color: Colors.white),
  );
}

// AppBar appBar({
//   required String title,
//   List<Widget>? actions,
//   VoidCallback? onMenuTap,
//   bool showSelectVci = false,
//   VoidCallback? onSelectVciTap,
// }) {
//   return AppBar(
//     titleSpacing: 10,
//     leading: Builder(
//       builder: (context) {
//         return IconButton(
//           icon: const Icon(
//             Icons.menu,
//             color: Colors.white,
//             size: 35,
//           ),
//           onPressed: onMenuTap ??
//               () {
//                 Scaffold.of(context).openDrawer();
//               },
//         );
//       },
//     ),
//     title: Text(
//       title,
//       style: TextStyles.appBarTitle.copyWith(
//         fontWeight: FontWeight.w600,
//       ),
//       maxLines: maxTitleLine,
//       overflow: TextOverflow.ellipsis,
//     ),
//     actions: [
//       if (showSelectVci)
//         Padding(
//           padding: const EdgeInsets.only(right: 16),
//           child: Obx(() {
//             final controller = Get.find<DashboardController>();

//             return GestureDetector(
//               onTap: onSelectVciTap,
//               child: Text(
//                 controller.selectedVciType.value.isEmpty
//                     ? "Select VCI"
//                     : controller.selectedVciType.value,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             );
//           }),
//         ),
//       ...?actions,
//     ],
//     backgroundColor: AppColors.primaryColor,
//     iconTheme: const IconThemeData(color: Colors.white),
//   );
// }

AppBar appBar({
  required String title,
  List<Widget>? actions,
  VoidCallback? onMenuTap,
  bool isMenu = false,
  bool isBack = false,
  VoidCallback? onBackTap,
  bool showSelectVci = false,
  VoidCallback? onSelectVciTap,
}) {
  return AppBar(
    titleSpacing: 10,
    leading: Builder(
      builder: (context) {
        if (isBack) {
          return IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
            ),
            onPressed: onBackTap ?? () => Navigator.of(context).pop(),
          );
        } else if (isMenu) {
          return IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 35,
            ),
            onPressed: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
          );
        } else {
          return const SizedBox(); // no leading widget
        }
      },
    ),
    title: Text(
      title,
      style: TextStyles.appBarTitle.copyWith(
        fontWeight: FontWeight.w600,
      ),
      maxLines: maxTitleLine,
      overflow: TextOverflow.ellipsis,
    ),
    actions: [
      if (showSelectVci)
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Obx(() {
            Get.find<DashboardController>();

            return GestureDetector(
              onTap: onSelectVciTap,
             
            );
          }),
        ),
      ...?actions,
    ],
    backgroundColor: AppColors.primaryColor,
    iconTheme: const IconThemeData(color: Colors.white),
  );
}

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  //final String? subtitle;
  final bool centerTitle;
final Widget? subtitle;
  const CommonAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.centerTitle = false,
    TextStyle? style,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold),),
      centerTitle: centerTitle,
    //  bottom: subtitle != null
    // ? PreferredSize(
    //     preferredSize: const Size.fromHeight(47),
    //     child: Padding(
    //       padding: const EdgeInsets.only(bottom: 10),
    //       child: subtitle is Widget
    //           ? subtitle as Widget
    //           : Text(
    //               subtitle!,
    //               style: const TextStyle(
    //                 fontSize: 16,
    //                 color: Colors.white70,
    //                 fontWeight: FontWeight.bold,
    //               ),
    //             ),
    //     ),
    //   )
    
          // : null,
          bottom: subtitle != null
    ? PreferredSize(
        preferredSize: const Size.fromHeight(47),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: subtitle!,
        ),
      )
    : null,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(subtitle != null ? 96 : kToolbarHeight);
}

AppBar appBarWithTwoTitle({
  required String title,
  required String subTitle,
  Function? onTap,
  List<Widget>? actions,
  bool titleAction = false,
}) {
  String sortTitle = title;
  int maxLength = 20;

  if (sortTitle.length > maxLength) {
    sortTitle = sortTitle.substring(0, maxLength - 1) + "...";
  }

  Widget titleWidget = Text(
    sortTitle,
    style: TextStyles.appBarTitle,
    maxLines: maxTitleLine,
    overflow: TextOverflow.ellipsis,
  );

  return AppBar(
    backgroundColor: Colors.grey.shade600,
    titleSpacing: 10.0,
    title: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          titleWidget,
          Text(
            subTitle,
            style: TextStyles.defaultRegular
                .copyWith(color: Colors.white, fontSize: FontSizes.s15),
          ),
        ],
      ),
    ),
    titleTextStyle: TextStyles.appBarTitle,
    actions: actions,
  );
}

AppBar appBarWithSearch({
  required TextEditingController? searchTEC,
  required String? hintText,
  required Function onSubmitted,
  List<Widget>? actions,
}) {
  return AppBar(
    titleSpacing: 0,
    elevation: 0,
    leading: BackButton(
      color: Colors.black,
    ),
    backgroundColor: Colors.white,
    title: TextField(
      controller: searchTEC,
      decoration: InputDecoration(
        filled: true,
        disabledBorder: defaultInputBorder,
        enabledBorder: defaultInputBorder,
        focusedBorder: defaultInputBorder,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.zero,
        hintText: hintText,
        hintStyle: TextStyles.hintStyle,
        errorStyle: TextStyles.errorStyle,
        labelStyle: TextStyles.labelStyle,
      ),
      onSubmitted: (_) => onSubmitted(),
    ),
    actions: actions,
  );
}

class CustomAppBar extends StatelessWidget {
  final String title;
  final String subTitle;
  final bool showBackButton;
  final bool showLogoutButton;
  final bool? loginVerification;
  final Function? onBack;

  CustomAppBar(
      {required this.title,
      required this.subTitle,
      this.showBackButton = true,
      this.showLogoutButton = false,
      this.onBack,
      this.loginVerification});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: CustomAppBarDelegate(
          title: title,
          subTitle: subTitle,
          showBackButton: showBackButton,
          showLogoutButton: showLogoutButton,
          onBack: () => onBack,
          loginVerification: loginVerification),
    );
  }
}

class CustomAppBarDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final String subTitle;
  final bool showBackButton;
  final bool showLogoutButton;
  final Function? onBack;
  final bool? loginVerification;

  CustomAppBarDelegate({
    required this.title,
    required this.subTitle,
    this.showBackButton = true,
    this.showLogoutButton = false,
    this.loginVerification,
    this.onBack,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipperWidget(
      child: Stack(
        fit: StackFit.expand,
        children: [
          BackgroundLinearGradientWidget(
            height: extendedWidgetHeight,
          ),
          Positioned(
            bottom: shrinkOffset / 4,
            child: Container(
              margin: EdgeInsets.only(
                bottom: extendedWidgetHeight / 3,
                left: Sizes.s20,
              ),
              child: Container(
                width: screenWidth - Sizes.s20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        // DevService.instance.openDevScreen(context);
                      },
                      child: Text(
                        title,
                        style: TextStyles.defaultRegular.copyWith(
                          fontSize: FontSizes.s25,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    C10(),
                    Text(
                      subTitle,
                      style: TextStyles.defaultRegular.copyWith(
                        fontSize: FontSizes.s16,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showBackButton)
            Positioned(
                top: Sizes.s30 - shrinkOffset,
                child: BackButton(
                  color: Colors.white,
                  onPressed: () => onBack,
                )),
          if (showLogoutButton)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: Sizes.s20),
                child: IconButton(
                    icon: Icon(
                      Icons.settings_power,
                      color: Colors.white,
                      size: Sizes.s40,
                    ),
                    onPressed: () => {} //auth.logout(context),
                    ),
              ),
            )
        ],
      ),
    );
  }

  @override
  double get maxExtent => extendedWidgetHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
