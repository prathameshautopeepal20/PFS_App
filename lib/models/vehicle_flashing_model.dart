class VehicleFlashingModel {
  String modelId;
  String modelName;

  String subModelId;
  String subModelName;

  String ecuId;
  String ecuName;

  String dongleId;
  String dongleName;

  String statusMessage;
  double progressValue;

  bool dongleConnected;
  bool ecuConnected;
  bool flashStarted;


  VehicleFlashingModel({
    required this.modelId,
    required this.modelName,
    required this.subModelId,
    required this.subModelName,
    required this.ecuId,
    required this.ecuName,
    required this.dongleId,
    required this.dongleName,
    required this.statusMessage,
    required this.progressValue,
    required this.dongleConnected,
    required this.ecuConnected,
    required this.flashStarted,
  });


  factory VehicleFlashingModel.empty() {
    return VehicleFlashingModel(
      modelId: "",
      modelName: "",
      subModelId: "",
      subModelName: "",
      ecuId: "",
      ecuName: "",
      dongleId: "",
      dongleName: "",
      statusMessage: "Ready",
      progressValue: 0.0,
      dongleConnected: false,
      ecuConnected: false,
      flashStarted: false,
    );
  }


  VehicleFlashingModel copyWith({
    String? modelId,
    String? modelName,
    String? subModelId,
    String? subModelName,
    String? ecuId,
    String? ecuName,
    String? dongleId,
    String? dongleName,
    String? statusMessage,
    double? progressValue,
    bool? dongleConnected,
    bool? ecuConnected,
    bool? flashStarted,
  }) {

    return VehicleFlashingModel(
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      subModelId: subModelId ?? this.subModelId,
      subModelName: subModelName ?? this.subModelName,
      ecuId: ecuId ?? this.ecuId,
      ecuName: ecuName ?? this.ecuName,
      dongleId: dongleId ?? this.dongleId,
      dongleName: dongleName ?? this.dongleName,
      statusMessage: statusMessage ?? this.statusMessage,
      progressValue: progressValue ?? this.progressValue,
      dongleConnected: dongleConnected ?? this.dongleConnected,
      ecuConnected: ecuConnected ?? this.ecuConnected,
      flashStarted: flashStarted ?? this.flashStarted,
    );
  }
}