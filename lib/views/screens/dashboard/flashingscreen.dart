// lib/views/screens/dashboard/flash_process_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/flash_process_controller.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/mainLayoutScreen.dart';

// ── Colors ───────────────────────────────────────────────────
const Color _kOrange = Color(0xFFF9772C);
const Color _kBg     = Color(0xFFF5F6FA);
const Color _kText   = Color(0xFF1E293B);
const Color _kBorder = Color(0xFFBDBDBD);
const Color _kDark   = Color(0xFF1E2A3A);

// ════════════════════════════════════════════════════════════
//  SCREEN
// ════════════════════════════════════════════════════════════
class FlashProcessScreen extends StatelessWidget {
  FlashProcessScreen({super.key});

  final FlashProcessController controller = Get.put(FlashProcessController());

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'ECU Flashing Process',
      child: Stack(
        children: [

          // ── Main content ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FlashTypeRow(controller: controller),
                const SizedBox(height: 30),
                Expanded(
                  child: Obx(() => controller.isBatch.value
                      ? _BatchView(controller: controller)
                      : _IndividualView(controller: controller)),
                ),
              ],
            ),
          ),

          // ── Loading overlay ────────────────────────────────
          Obx(() => controller.isLoading.value
              ? Container(
                  color: Colors.black38,
                  child: const Center(
                    child: CircularProgressIndicator(color: _kOrange),
                  ),
                )
              : const SizedBox()),

          // ── Popup overlay ──────────────────────────────────
          Obx(() => controller.showPopup.value
              ? _SelectionPopup(controller: controller)
              : const SizedBox()),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Flashing Type Row
// ════════════════════════════════════════════════════════════
class _FlashTypeRow extends StatelessWidget {
  final FlashProcessController controller;
  const _FlashTypeRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 24,
          runSpacing: 12,
          children: [
            const Text(
              'Select Flashing Type  :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _kText,
              ),
            ),
            _CheckItem(
              label: 'Batch Flashing',
              checked: controller.isBatch.value,
              onTap: controller.selectBatch,
            ),
            if (controller.individualVisible.value)
              _CheckItem(
                label: 'Individual Flashing',
                checked: !controller.isBatch.value,
                onTap: controller.selectIndividual,
              ),
          ],
        ));
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  final bool checked;
  final VoidCallback onTap;
  const _CheckItem({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: checked,
              onChanged: (_) => onTap(),
              activeColor: _kDark,
              side: const BorderSide(color: _kText, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 18, color: _kText)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Batch View
// ════════════════════════════════════════════════════════════
class _BatchView extends StatelessWidget {
  final FlashProcessController controller;
  const _BatchView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _DropField(
                    label: 'Model Codes :',
                    value: controller.selectedModel.value?.name ?? '',
                    placeholder: '--Select Model Description--',
                    onTap: () => controller.openPopup('ModelDescription'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _DropField(
                    label: 'Regulations :',
                    value: controller.selectedSubModel.value?.name ?? '',
                    placeholder: '--Select Regulation--',
                    onTap: () => controller.openPopup('Regulation'),
                  ),
                ),
              ],
            )),
        const Spacer(),
        Align(
          alignment: Alignment.bottomRight,
          child: ElevatedButton(
            onPressed: controller.onBatchNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kOrange,
              foregroundColor: Colors.white,
              minimumSize: const Size(150, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
            child: const Text(
              'NEXT',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DropField extends StatelessWidget {
  final String label;
  final String value;
  final String placeholder;
  final VoidCallback onTap;
  const _DropField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _kText)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _kBorder, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isNotEmpty ? value : placeholder,
                    style: TextStyle(
                      fontSize: 15,
                      color: value.isNotEmpty
                          ? _kText
                          : Colors.grey.shade500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: _kText),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Individual View
// ════════════════════════════════════════════════════════════
class _IndividualView extends StatelessWidget {
  final FlashProcessController controller;
  const _IndividualView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _kBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
            children: [
              SizedBox(width: 70, child: _HCell('Sr. No.')),
              Expanded(child: _HCell('Select Model Code')),
              Expanded(child: _HCell('Select Regulation')),
              Expanded(child: _HCell('Select From Active Dongles')),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // 4 data rows
        Obx(() => Column(
              children: List.generate(
                controller.individualList.length,
                (i) => _IndRow(index: i, controller: controller),
              ),
            )),

        const Spacer(),

        // NEXT button
        Align(
          alignment: Alignment.bottomRight,
          child: ElevatedButton(
            onPressed: controller.onIndividualNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kOrange,
              foregroundColor: Colors.white,
              minimumSize: const Size(150, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
            child: const Text(
              'NEXT',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _HCell extends StatelessWidget {
  final String text;
  const _HCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 15, color: _kText),
    );
  }
}

class _IndRow extends StatelessWidget {
  final int index;
  final FlashProcessController controller;
  const _IndRow({required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (index >= controller.individualList.length) return const SizedBox();
      final row = controller.individualList[index];

      return Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _kBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(
                '${index + 1}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: _kText),
              ),
            ),
            Expanded(
              child: _RowDrop<ModelResult>(
                items: row.modelList,
                selected: row.selectedModel,
                label: (m) => m.name,
                hint: '--Model--',
                onChanged: (m) {
                  if (m != null) controller.onModelSelected(index, m);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RowDrop<SubModel>(
                items: row.selectedModel?.subModels ?? [],
                selected: row.selectedSubModel,
                label: (s) => s.name,
                hint: '--Regulation--',
                onChanged: (s) {
                  if (s != null) controller.onSubModelSelected(index, s);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RowDrop<DongleRow>(
                items: row.tableInfo,
                selected: row.selectedDongle,
                label: (d) => 'Dongle ${d.srNo}',
                hint: '--Dongle--',
                onChanged: (d) {
                  if (d != null) controller.onDongleSelected(index, d);
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _RowDrop<T> extends StatelessWidget {
  final List<T> items;
  final T? selected;
  final String Function(T) label;
  final String hint;
  final void Function(T?) onChanged;
  const _RowDrop({
    required this.items,
    required this.selected,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selected,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: _kText, size: 20),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      label(item),
                      style:
                          const TextStyle(fontSize: 14, color: _kText),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Selection Popup
// ════════════════════════════════════════════════════════════
class _SelectionPopup extends StatelessWidget {
  final FlashProcessController controller;
  const _SelectionPopup({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isModel = controller.popupTitle.value == 'Model Descriptions';
    final items   = isModel
        ? controller.modelList as List<dynamic>
        : (controller.selectedModel.value?.subModels ?? <SubModel>[])
            as List<dynamic>;

    return GestureDetector(
      onTap: controller.closePopup,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 320,
              height: 440,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 12)
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    height: 58,
                    decoration: const BoxDecoration(
                      color: _kDark,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(height: 5, color: _kOrange),
                        Container(height: 2, color: _kOrange),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Obx(() => Text(
                                    controller.popupTitle.value,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16),
                                  )),
                              Positioned(
                                right: 6,
                                child: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white, size: 20),
                                  onPressed: controller.closePopup,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List items
                  Expanded(
                    child: items.isEmpty
                        ? const Center(
                            child: Text('Loading...',
                                style: TextStyle(color: Colors.grey)),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 4),
                            itemBuilder: (_, i) {
                              final item = items[i];
                              final name = item is ModelResult
                                  ? item.name
                                  : (item as SubModel).name;
                              return InkWell(
                                onTap: () =>
                                    controller.selectPopupItem(item),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.shade200),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 15, color: _kText),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}