class IndividualSelectModel {
  List<String> modelList;
  List<String> regulationList;
  List<String> dongleList;

  String? selectedModel;
  String? selectedRegulation;
  String? selectedDongle;

  IndividualSelectModel({
    required this.modelList,
    required this.regulationList,
    required this.dongleList,
    this.selectedModel,
    this.selectedRegulation,
    this.selectedDongle,
  });
}