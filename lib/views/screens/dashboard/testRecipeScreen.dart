import 'package:atpl_flashing_app/logic/controller/dashboard/testRecipeController.dart';
import 'package:atpl_flashing_app/routes/routes_string.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/mainLayoutScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TestRecipeScreen extends StatelessWidget {
  TestRecipeScreen({super.key});

  // Initialize the controller
  final TestRecipeController controller = Get.put(TestRecipeController());
  // final TestRecipeController controller = Get.isRegistered<TestRecipeController>()
  //     ? Get.find<TestRecipeController>()
  //     : Get.put(TestRecipeController());
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadStoredRecipes();
    });
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    // --- RESPONSIVE FONT SIZES ---
    final double titleSize = isDesktop ? 28 : 20;
    final double tableHeaderSize = isDesktop ? 20 : 13;
    final double tableCellSize = isDesktop ? 16 : 12;
    final double buttonTextSize = isDesktop ? 18 : 14;
    final double searchHintSize = isDesktop ? 14 : 14;

    return SafeArea(
      child: MainLayout(
        title: "ATPL Diagnostic Tool",
        child: SizedBox.expand(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 60 : 12, vertical: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pass font sizes to search bar
                  _buildResponsiveSearchBar(
                      isDesktop, searchHintSize, buttonTextSize),

                  const SizedBox(height: 40),

                  Text(
                    "Recipe List",
                    style: TextStyle(
                        fontSize: titleSize, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // --- TABLE ---
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Obx(() => Table(
                          border:
                              TableBorder.all(color: Colors.black26, width: 1),
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(3.5),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(2.5),
                            4: FlexColumnWidth(2.5),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            // Header Row
                            TableRow(
                              decoration:
                                  BoxDecoration(color: Colors.grey[200]),
                              children: [
                                _buildTableCell("Sr.",
                                    fontSize: tableHeaderSize, isHeader: true),
                                _buildTableCell("Engine Model",
                                    fontSize: tableHeaderSize, isHeader: true),
                                _buildTableCell("Type",
                                    fontSize: tableHeaderSize, isHeader: true),
                                // _buildTableCell("Recipe ID",
                                //     fontSize: tableHeaderSize, isHeader: true),
                                _buildTableCell("Actions",
                                    fontSize: tableHeaderSize, isHeader: true),
                              ],
                            ),

                            // Data Rows
                            // ...controller.recipeList.map((item) => TableRow(
                            //       children: [
                            //         _buildTableCell(item.sr ?? '',
                            //             fontSize: tableCellSize),
                            //         _buildTableCell(item.model ?? '',
                            //             fontSize: tableCellSize),
                            //         _buildTableCell(item.type ?? '',
                            //             fontSize: tableCellSize),
                            //         // _buildTableCell(
                            //         //     (item.sensors.isNotEmpty)
                            //         //         ? item.sensors[0].registerNumber
                            //         //             .toString()
                            //         //         : 'N/A',
                            //         //     fontSize: tableCellSize),
                            //         TableCell(
                            //           child: Row(
                            //             mainAxisAlignment:
                            //                 MainAxisAlignment.center,
                            //             children: [
                            //               IconButton(
                            //                 icon: Icon(
                            //                     Icons
                            //                         .visibility_outlined, // Eye icon for view
                            //                     color: Colors.grey[700],
                            //                     size: isDesktop ? 22 : 18),
                            //                 onPressed: () => Get.toNamed(
                            //                     Routes
                            //                         .recipeAdditionReadOnlyScreen,
                            //                     arguments: {
                            //                       'item': item
                            //                     }), // Pass a flag
                            //               ),
                            //               IconButton(
                            //                 icon: Icon(Icons.edit,
                            //                     color: Colors.blue,
                            //                     size: isDesktop ? 22 : 18),
                            //                 onPressed: () => Get.toNamed(
                            //                     Routes.recipeAdditionScreen,
                            //                     arguments: item),
                            //               ),
                            //               IconButton(
                            //                 icon: Icon(Icons.download,
                            //                     color: Colors.green,
                            //                     size: isDesktop ? 22 : 18),
                            //                 onPressed: () => controller
                            //                     .exportSingleRecipe(item),
                            //               ),
                            //               // IconButton(
                            //               //   icon: Icon(Icons.delete, color: Colors.red, size: isDesktop ? 22 : 18),
                            //               //   onPressed: () => controller.deleteSensor(item),
                            //               // )
                            //             ],
                            //           ),
                            //         ),
                            //       ],
                            //     )),
                            // Data Rows with sequential Sr. Numbers
                            ...controller.recipeList
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key; // 0, 1, 2...
                              var item = entry.value;

                              return TableRow(
                                children: [
                                  // Display index + 1 to show 1, 2, 3...
                                  _buildTableCell((index + 1).toString(),
                                      fontSize: tableCellSize),

                                  _buildTableCell(item.model ?? '',
                                      fontSize: tableCellSize),
                                  _buildTableCell(item.type ?? '',
                                      fontSize: tableCellSize),

                                  TableCell(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.visibility_outlined,
                                              color: Colors.grey[700],
                                              size: isDesktop ? 22 : 18),
                                          onPressed: () => Get.toNamed(
                                              Routes
                                                  .recipeAdditionReadOnlyScreen,
                                              arguments: {'item': item}),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.blue,
                                              size: isDesktop ? 22 : 18),
                                          onPressed: () => Get.toNamed(
                                              Routes.recipeAdditionScreen,
                                              arguments: item),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.download,
                                              color: Colors.green,
                                              size: isDesktop ? 22 : 18),
                                          onPressed: () => controller
                                              .exportSingleRecipe(item),
                                        ),
                                        // DELETE
                                        IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: isDesktop ? 22 : 18,
                                            ),
                                            onPressed: () {
                                              controller.deleteRecipe(item);
                                            })
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// --- UPDATED HELPERS ---

  Widget _buildTableCell(String text,
      {required double fontSize, bool isHeader = false}) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: isHeader ? 16 : 12, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildResponsiveSearchBar(
      bool isDesktop, double searchFontSize, double buttonFontSize) {
    if (isDesktop) {
      return Row(
        children: [
          Expanded(flex: 5, child: _buildSearchField(searchFontSize)),
          const SizedBox(width: 15),
          _buildActionButton("Search", () {}, buttonFontSize),
          const SizedBox(width: 15),
          _buildActionButton("Add",
              () => Get.toNamed(Routes.recipeAdditionScreen), buttonFontSize),
        ],
      );
    } else {
      return Column(
        children: [
          _buildSearchField(searchFontSize),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                  child: _buildActionButton("Search", () {}, buttonFontSize)),
              const SizedBox(width: 15),
              Expanded(
                  child: _buildActionButton(
                      "Add",
                      () => Get.toNamed(Routes.recipeAdditionScreen),
                      buttonFontSize)),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildSearchField(double fontSize) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF0055BB), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        style: TextStyle(fontSize: fontSize), // Added font size for user input
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.black, size: 22),
          hintText: "Search recipes...",
          hintStyle: TextStyle(fontSize: fontSize), // Added font size for hint
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap, double fontSize) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A76C0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Text(label,
            style: TextStyle(color: Colors.white, fontSize: fontSize)),
      ),
    );
  }
}
