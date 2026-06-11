import 'package:get/get.dart';
import 'package:atpl_flashing_app/models/vehicle_flashing_model.dart';

class VehicleFlashingController extends GetxController {

  // ================= INDIVIDUAL ECU ROWS =================

  RxList<VehicleFlashingModel> individualList =
      <VehicleFlashingModel>[].obs;


  // ================= FLASHING TABLE LIST =================

  RxList<VehicleFlashingModel> vehicleList =
      <VehicleFlashingModel>[].obs;


  @override
  void onInit() {
    super.onInit();

    // Create 4 empty rows for Individual flashing
    for (int i = 0; i < 4; i++) {
      individualList.add(
        VehicleFlashingModel.empty(),
      );
    }
  }


  // ================= ADD VEHICLE =================

  void addVehicleRow() {

    vehicleList.add(
      VehicleFlashingModel.empty(),
    );

  }


  // ================= START FLASHING =================

  void startFlashing(
    VehicleFlashingModel vehicle,
  ) {

    int index = vehicleList.indexOf(vehicle);

    if (index == -1) return;


    // Update status
    vehicleList[index] =
        vehicle.copyWith(
          statusMessage: "Flashing Started",
          progressValue: 0.1,
          flashStarted: true,
        );


    _simulateProgress(index);
  }


  // ================= FLASH PROGRESS =================

  Future<void> _simulateProgress(
    int index,
  ) async {


    for (
      double i = 0.1;
      i <= 1.0;
      i += 0.1
    ) {

      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );


      // Safety check
      if (index >= vehicleList.length) {
        return;
      }


      vehicleList[index] =
          vehicleList[index].copyWith(

        progressValue: i,

        statusMessage:
          i >= 1.0
          ? "Completed"
          : "Flashing...",

      );
    }
  }


  // ================= FUTURE API METHODS =================

  Future<void> connectDongle() async {

    // Dongle connection API
  }


  Future<void> checkEcuConnection() async {

    // ECU connection API
  }


  Future<void> startFlashApi() async {

    // Start flashing API
  }


  Future<void> getFlashProgress() async {

    // Progress API
  }

}