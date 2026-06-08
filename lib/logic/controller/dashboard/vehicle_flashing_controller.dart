import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:atpl_flashing_app/api/app_envirments.dart';
import 'package:atpl_flashing_app/api/app_urls.dart';
import 'package:atpl_flashing_app/routes/routes_string.dart';

class VehicleFlashingController extends GetxController {
  /// VEHICLE LIST
  RxList<VehicleFlashingModel> vehicleList = <VehicleFlashingModel>[].obs;

  /// ADD VEHICLE (Popup replaced with dummy data)
  Future<void> addVehicle() async {
    vehicleList.add(
      VehicleFlashingModel(
        modelName: "Toyota",
        subModelName: "Corolla",
        statusMessage: "Ready",
        progressValue: 0.0,
        dongleConnected: false,
        ecuConnected: false,
        flashStarted: false,
      ),
    );
  }

  /// CONNECT DONGLE (SIMULATION)
  Future<void> connectDongle(VehicleFlashingModel v) async {
    v.statusMessage = "Connecting Dongle...";
    vehicleList.refresh();

    await Future.delayed(const Duration(seconds: 2));

    v.dongleConnected = true;
    v.ecuConnected = true;
    v.statusMessage = "Dongle + ECU Connected";
    vehicleList.refresh();
  }

  /// START FLASHING (SIMULATION)
  Future<void> startFlashing(VehicleFlashingModel v) async {
    if (!v.dongleConnected || !v.ecuConnected) {
      v.statusMessage = "Connect Dongle & ECU first";
      vehicleList.refresh();
      return;
    }

    v.flashStarted = true;

    for (int i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      v.progressValue = i / 100;
      v.statusMessage = "Flashing... $i%";
      vehicleList.refresh();
    }

    v.statusMessage = "Flashing Completed";
    v.flashStarted = false;
    vehicleList.refresh();
  }
}

/// MODEL
class VehicleFlashingModel {
  String modelName;
  String subModelName;

  String statusMessage;

  double progressValue;

  bool dongleConnected;
  bool ecuConnected;
  bool flashStarted;

  VehicleFlashingModel({
    required this.modelName,
    required this.subModelName,
    required this.statusMessage,
    required this.progressValue,
    required this.dongleConnected,
    required this.ecuConnected,
    required this.flashStarted,
  });
}