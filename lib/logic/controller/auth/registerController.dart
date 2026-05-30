// import 'dart:convert';

// import 'package:atpl_flashing_app/common_widgets/popup.dart' show CustomPopup;
// import 'package:atpl_flashing_app/models/oem_model.dart';
// import 'package:atpl_flashing_app/models/signIn_model.dart';
// import 'package:atpl_flashing_app/models/workshopGroup_model.dart';
// import 'package:atpl_flashing_app/routes/routes_string.dart';
// import 'package:atpl_flashing_app/services/api_services.dart';
// import 'package:get/get.dart';

// class RegistrationController extends GetxController {
//   final selectedWorkshopGroup = "".obs;
//   final selectedCity = "".obs;
//   final selectedWorkshop = "".obs;
//   final firstName = "".obs;
//   final lastName = "".obs;
//   final email = "".obs;
//   final mobileNumber = "".obs;
//   final password = "".obs;
//   final confirmPassword = "".obs;
//   final searchOem = "".obs;
//   final searchWorkshopGroup = "".obs;
//   final searchCity = "".obs;
//   final searchWorkshop = "".obs;
//   final selectedOem = "".obs;
//   final workshopGroupList = <WorkShopGroupModel>[].obs;
//   final cityList = <WorkCity>[].obs;
//   final workshopList = <WorkShopGroup>[].obs;
//   final showOemPopup = false.obs;
//   final showWorkshopGroupPopup = false.obs;
//   final showCityPopup = false.obs;
//   final showWorkshopPopup = false.obs;
//   final isBusy = false.obs;

//   final AuthApiService services = AuthApiService();
//   int workShopId = 0;

//   @override
//   void onInit() {
//     super.onInit();
//     getOemDetails();
//   }

//   void selectOem() => showOemPopup.value = true;

//   void selectWorkshopGroup() => showWorkshopGroupPopup.value = true;

//   Future<void> selectCity() async {
//     try {
//       isBusy.value = true;
//       cityList.clear();
//       if (selectedWorkshopGroup.value.isNotEmpty) {
//         final selectedGroup = workshopGroupList.firstWhereOrNull(
//           (g) => g.workshopsGroupName == selectedWorkshopGroup.value,
//         );

//         if (selectedGroup != null && selectedGroup.cityList.isNotEmpty) {
//           cityList.addAll(selectedGroup.cityList);
//           showCityPopup.value = true;
//         } else {
//           Get.dialog(
//             CustomPopup(
//               title: "Alert",
//               message: "No cities available for the selected Workshop Group.",
//               onButtonPressed: () => Get.back(),
//             ),
//             barrierDismissible: false,
//           );
//         }
//       } else {
//         Get.dialog(
//           CustomPopup(
//             title: "Alert",
//             message: "Please select a Workshop Group first.",
//             onButtonPressed: () => Get.back(),
//           ),
//           barrierDismissible: false,
//         );
//       }
//     } catch (e) {
//       print("Error in selectCity: $e");
//     } finally {
//       isBusy.value = false;
//     }
//   }

//   Future<void> selectWorkshop() async {
//     try {
//       isBusy.value = true;

//       if (selectedCity.value.isEmpty || selectedWorkshopGroup.value.isEmpty) {
//         Get.dialog(
//           CustomPopup(
//             title: "Alert",
//             message: "Select Workshop Group and City first.",
//             onButtonPressed: () => Get.back(),
//           ),
//           barrierDismissible: false,
//         );

//         return;
//       } else if (selectedCity.value == "Select City") {
//         Get.dialog(
//           CustomPopup(
//             title: "Alert",
//             message: "Select Workshop City first.",
//             onButtonPressed: () => Get.back(),
//           ),
//           barrierDismissible: false,
//         );

//         return;
//       } else {
//         showWorkshopPopup.value = true;
//       }
//     } catch (e) {
//       print("Error in selectWorkshop: $e");
//     } finally {
//       isBusy.value = false;
//     }
//   }

//   void searchWorkshopGroupFunc() {
//     try {
//       if (searchWorkshopGroup.value.isEmpty) {
//         // Reset the list to the original full list
//         workshopGroupList.refresh();
//       } else {
//         final filtered = workshopGroupList
//             .where((x) => x.workshopsGroupName!
//                 .toLowerCase()
//                 .contains(searchWorkshopGroup.value.toLowerCase()))
//             .toList();
//         workshopGroupList.assignAll(filtered);
//       }
//     } catch (e) {
//       print("Error in searchWorkshopGroupFunc: $e");
//     }
//   }

//   void searchOemFunc() {
//     try {
//       if (searchOem.value.isEmpty) {
//         // Reset to the original full list
//         oemList.assignAll(staticOemList);
//       } else {
//         final filtered = staticOemList
//             .where((x) => (x.name ?? "")
//                 .toLowerCase()
//                 .contains(searchOem.value.toLowerCase()))
//             .toList();
//         oemList.assignAll(filtered);
//       }
//     } catch (e) {
//       print("Error in searchOemFunc: $e");
//     }
//   }

//   Future<void> oemListCommand(AllOemModel selected) async {
//     try {
//       isBusy.value = true;

//       // Small delay to mimic Task.Delay(50)
//       await Future.delayed(const Duration(milliseconds: 50));

//       // Assign selected OEM
//       selectedOem.value = selected.name ?? "";

//       // Reset dependent selections
//       selectedWorkshopGroup.value = "";
//       workshopGroupList.clear();

//       selectedCity.value = "";
//       selectedWorkshop.value = "";

//       cityList.clear();
//       workshopList.clear();

//       // Fetch workshop data for selected OEM
//       await getWorkshopData();
//     } catch (e) {
//       print("Error in oemListCommand: $e");
//     } finally {
//       showOemPopup.value = false;
//       isBusy.value = false;
//     }
//   }

//   Future<void> workShopGroupListCommand(
//       WorkShopGroupModel selectedGroup) async {
//     try {
//       isBusy.value = true;

//       // Mimic Task.Delay(50)
//       await Future.delayed(const Duration(milliseconds: 50));

//       final groupName = selectedGroup.workshopsGroupName;

//       if (groupName!.isNotEmpty) {
//         selectedWorkshopGroup.value = groupName;
//         showWorkshopGroupPopup.value = false;

//         // Populate CityList with cities from selected group
//         cityList.clear();
//         cityList.addAll(selectedGroup.cityList);
//       } else {
//         Get.dialog(
//           CustomPopup(
//             title: "Alert",
//             message: "No Workshop Group found.",
//             onButtonPressed: () => Get.back(),
//           ),
//           barrierDismissible: false,
//         );
//       }
//     } catch (e) {
//       print("Error in workShopGroupListCommand: $e");
//     } finally {
//       isBusy.value = false;
//     }
//   }

//   void searchCityCommand(String searchCity) {
//     try {
//       if (searchCity.isEmpty) {
//         // Reset city list to original (if you have a static/original list, use it)
//         cityList.refresh();
//       } else {
//         final filteredList = cityList
//             .where(
//                 (x) => x.city!.toLowerCase().contains(searchCity.toLowerCase()))
//             .toList();
//         cityList.assignAll(filteredList);
//       }
//     } catch (e) {
//       print("Error in searchCityCommand: $e");
//     }
//   }

//   Future<void> cityModelListCommand(WorkCity city) async {
//     try {
//       isBusy.value = true;
//       await Future.delayed(const Duration(milliseconds: 50));

//       final selectedCityName = city.city;
//       if (selectedCityName != null && selectedCityName.isNotEmpty) {
//         selectedCity.value = selectedCityName;
//         showCityPopup.value = false;

//         workshopList.clear();
//         workshopList.addAll(city.workshops);
//       }
//     } catch (e) {
//       print("Error in cityModelListCommand: $e");
//     } finally {
//       isBusy.value = false;
//     }
//   }

//   Future<void> searchWorkshopCommand() async {
//     try {
//       if (searchWorkshop.value.isEmpty) {
//         // Reset the workshop list to original (no filtering)
//         workshopList.refresh(); // triggers UI update
//       } else {
//         // Uncomment and implement filtering logic if needed
//         // final filteredList = workShopList
//         //     .where((x) => x.name != null && x.name!.toLowerCase().contains(searchWorkshop.value.toLowerCase()))
//         //     .toList();
//         // workShopList.assignAll(filteredList);
//       }
//     } catch (e) {
//       print("Error in searchWorkshopCommand: $e");
//     }
//   }

//   Future<void> workShopListCommand(WorkShopGroup item) async {
//     try {
//       selectedWorkshop.value = item.name ?? "";
//       workShopId = item.id ?? 0;
//       showWorkshopPopup.value = false;
//     } catch (e) {
//       print("Error in workShopListCommand: $e");
//     }
//   }

//   void hideAllViews() {
//     showOemPopup.value = false;
//     showWorkshopGroupPopup.value = false;
//     showCityPopup.value = false;
//     showWorkshopPopup.value = false;
//     isBusy.value = false;
//   }

//   Future<void> submit() async {
//     try {
//       if (!await isInternetAvailable()) {
//         Get.dialog(
//           CustomPopup(
//             title: "Internet Connection Problem",
//             message: "Please check Internet Connection",
//             onButtonPressed: () => Get.back(),
//           ),
//           barrierDismissible: false,
//         );

//         return;
//       }

//       if (firstName.value.isEmpty ||
//           lastName.value.isEmpty ||
//           email.value.isEmpty ||
//           mobileNumber.value.isEmpty ||
//           password.value.isEmpty ||
//           confirmPassword.value.isEmpty ||
//           selectedWorkshopGroup.value.isEmpty ||
//           selectedCity.value.isEmpty ||
//           selectedWorkshop.value.isEmpty) {
//         Get.dialog(
//           CustomPopup(
//             title: "Alert",
//             message: "Please fill all required fields.",
//             onButtonPressed: () => Get.back(),
//           ),
//           barrierDismissible: false,
//         );

//         return;
//       }

//       if (password.value != confirmPassword.value) {
//         Get.dialog(
//           CustomPopup(
//             title: "Alert",
//             message: "Password and Confirm Password are not matched.",
//             onButtonPressed: () => Get.back(),
//           ),
//           barrierDismissible: false,
//         );

//         return;
//       }

//       isBusy.value = true;
//       await Future.delayed(Duration(milliseconds: 50));

//       // Device info (mock for now)
//       String platform = "android";
//       String deviceId = "1234567890";

//       final signinModel = SigninModel(
//         firstName: firstName.value,
//         lastName: lastName.value,
//         email: email.value,
//         mobile: mobileNumber.value,
//         password: password.value,
//         password2: confirmPassword.value,
//         deviceType: platform,
//         workshop: workShopId,
//         macId: deviceId,
//         serialNumber: "1234",
//       );

//       final result = await services.registerUser(signinModel);
//       if (result.containsKey(true)) {
//         Get.dialog(
//           CustomPopup(
//             title: "User Created Successfully",
//             message: "Please Contact Administrator!",
//             onButtonPressed: () {
//               Get.back(); // close dialog
//               Get.toNamed(Routes.loginScreen); // then navigate
//             },
//           ),
//           barrierDismissible: false,
//         );
//       } else {
//         Get.dialog(
//           CustomPopup(
//             title: "Alert!",
//             message: result[false]!,
//             onButtonPressed: () => Get.back(),
//           ),
//           barrierDismissible: false,
//         );
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       isBusy.value = false;
//     }
//   }

//   final oemList = <AllOemModel>[].obs;
//   final staticOemList = <AllOemModel>[].obs;
//   Future<void> getOemDetails() async {
//     try {
//       isBusy.value = true;
//       await Future.delayed(const Duration(milliseconds: 50));

//       final result = await services.getAllOem(); // returns OemModel
//       if (result.message == 'success') {
//         staticOemList.assignAll(result.results); // results is non-null
//         oemList.assignAll(result.results);
//       } else {
//         Get.dialog(
//           CustomPopup(
//             title: "Alert",
//             message: "Failed to get OEM data\n${result.message}",
//             onButtonPressed: () => Get.back(),
//           ),
//           barrierDismissible: false,
//         );
//       }
//     } catch (e) {
//       print("Error fetching OEMs: $e");
//     } finally {
//       isBusy.value = false;
//     }
//   }

//   Future<void> getWorkshopData() async {
//     try {
//       isBusy.value = true;

//       final result = await AuthApiService.getWorkShopData();
//       print("Raw Workshop Data: $result");

//       if (result.containsKey(true)) {
//         final decoded = jsonDecode(result[true]!);
//         print("Decoded Workshop JSON: $decoded");

//         final workshopsData = decoded['workshops'] as Map<String, dynamic>;
//         print("Workshop Groups: ${workshopsData.keys}");

//         List<WorkShopGroupModel> tempWorkshopGroups = [];

//         // Convert selected OEM name to its ID
//         final selectedOemName = selectedOem.value;
//         final selectedOemObj =
//             oemList.firstWhereOrNull((e) => e.name == selectedOemName);
//         final selectedOemId = selectedOemObj?.id ?? 0;
//         print("Selected OEM ID: $selectedOemId");

//         // Loop through each workshop group
//         workshopsData.forEach((groupName, cityMap) {
//           if (cityMap is Map<String, dynamic>) {
//             List<WorkCity> cityListForGroup = [];

//             cityMap.forEach((cityName, workshopListRaw) {
//               if (workshopListRaw is List) {
//                 List<WorkShopGroup> workshopsInCity = [];

//                 for (var workshopData in workshopListRaw) {
//                   if (workshopData is Map<String, dynamic>) {
//                     final shop = WorkShopGroup(
//                       id: workshopData['id'],
//                       name: workshopData['name'],
//                       name1: workshopData['name1'],
//                       address: workshopData['address'],
//                       pincode: workshopData['pincode'],
//                       region: workshopData['region'],
//                       oemId: workshopData['oem_id'],
//                       cityId: workshopData['city_id'],
//                       countryId: workshopData['country_id'],
//                       groupNameId: workshopData['group_name_id'],
//                       parentId: workshopData['parent_id'],
//                       stateId: workshopData['state_id'],
//                       userId: workshopData['user_id'],
//                       created: workshopData['created'],
//                       modified: workshopData['modified'],
//                       isActive: workshopData['is_active'],
//                     );

//                     // Only add if OEM matches
//                     if (shop.oemId == selectedOemId) {
//                       workshopsInCity.add(shop);
//                     }
//                   }
//                 }

//                 if (workshopsInCity.isNotEmpty) {
//                   cityListForGroup.add(
//                     WorkCity(
//                       city: cityName,
//                       workshops: workshopsInCity,
//                     ),
//                   );
//                 }
//               }
//             });

//             if (cityListForGroup.isNotEmpty) {
//               tempWorkshopGroups.add(
//                 WorkShopGroupModel(
//                   workshopsGroupName: groupName,
//                   cityList: cityListForGroup,
//                 ),
//               );
//             }
//           }
//         });

//         // Update controller lists
//         workshopGroupList.assignAll(tempWorkshopGroups);
//         print(
//             "Final workshopGroupList: ${workshopGroupList.map((e) => e.workshopsGroupName)}");
//       } else {
//         Get.dialog(
//           CustomPopup(
//             title: "Alert",
//             message: "Failed to get workshop data\n${result[false]}",
//             onButtonPressed: () => Get.back(),
//           ),
//           barrierDismissible: false,
//         );
//       }
//     } catch (e) {
//       print("Error fetching workshop data: $e");
//     } finally {
//       isBusy.value = false;
//     }
//   }

//   Future<bool> isInternetAvailable() async {
//     // Implement actual connectivity check using connectivity_plus or similar
//     return true;
//   }
// }
