// lib/views/screens/dashboard/flash_process_screen.dart
// Premium Dark UI — Deep Navy + Orange gradient theme

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/flash_process_controller.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/mainLayoutScreen.dart';

// ── Color Palette ─────────────────────────────────────────────
const Color _cBg      = Color(0xFF0F172A);
const Color _cSurface = Color(0xFF1E293B);
const Color _cSurface2= Color(0xFF243044);
const Color _cBorder  = Color(0xFF2D3F55);
const Color _cOrange  = Color(0xFFF97316);
const Color _cOrangD  = Color(0xFFEA580C);
const Color _cOrangDD = Color(0xFF9A3412);
const Color _cWhite   = Color(0xFFFFFFFF);
const Color _cWhite70 = Color(0xB3FFFFFF);
const Color _cblack70  =Color(0xB3000000);
const Color _cWhite40 = Color(0x66FFFFFF);
const Color _cWhite15 = Color(0x26FFFFFF);

const _gradientOrange = LinearGradient(
  colors: [_cOrange, _cOrangD, _cOrangDD],
  begin: Alignment.topLeft, end: Alignment.bottomRight,
);

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
      child: Container(
        color: _cBg,
        child: Stack(
          children: [
            // ── Main content ───────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FlashTypeRow(controller: controller),
                  const SizedBox(height: 28),
                  Expanded(
                    child: Obx(() => controller.isBatch.value
                        ? _BatchView(controller: controller)
                        : _IndividualView(controller: controller)),
                  ),
                ],
              ),
            ),

            // ── Loading overlay ────────────────────────────
            Obx(() => controller.isLoading.value
                ? Container(
                    color: Colors.black54,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_cSurface, _cSurface2]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _cBorder)),
                        child: const CircularProgressIndicator(color: _cOrange)),
                    ),
                  )
                : const SizedBox()),

            // ── Popup overlay ──────────────────────────────
            Obx(() => controller.showPopup.value
                ? _SelectionPopup(controller: controller)
                : const SizedBox()),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Flash Type Row
// ════════════════════════════════════════════════════════════
class _FlashTypeRow extends StatelessWidget {
  final FlashProcessController controller;
  const _FlashTypeRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cSurface, _cSurface2],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cBorder),
        boxShadow: const [BoxShadow(
          color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 4))]),
      child: Row(children: [
        // Orange accent bar
        Container(width: 3, height: 22,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_cOrange, _cOrangD],
              begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        const Text('Select Flashing Type  :',
          style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: _cWhite)),
        const SizedBox(width: 28),
        _CheckItem(
          label: 'Batch Flashing',
          checked: controller.isBatch.value,
          onTap: controller.selectBatch),
        const SizedBox(width: 24),
        if (controller.individualVisible.value)
          _CheckItem(
            label: 'Individual Flashing',
            checked: !controller.isBatch.value,
            onTap: controller.selectIndividual),
      ]),
    ));
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  final bool checked;
  final VoidCallback onTap;
  const _CheckItem({required this.label, required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22, height: 22,
        decoration: BoxDecoration(
          gradient: checked ? const LinearGradient(
            colors: [_cOrange, _cOrangD]) : null,
          color: checked ? null : Colors.transparent,
          border: Border.all(
            color: checked ? _cOrange : _cWhite40, width: 1.5),
          borderRadius: BorderRadius.circular(4)),
        child: checked
            ? const Icon(Icons.check, color: _cWhite, size: 14) : null),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(
        fontSize: 15,
        color: checked ? _cOrange : _cWhite70,
        fontWeight: checked ? FontWeight.w600 : FontWeight.normal)),
    ]),
  );
}

// ════════════════════════════════════════════════════════════
//  Batch View
// ════════════════════════════════════════════════════════════
class _BatchView extends StatelessWidget {
  final FlashProcessController controller;
  const _BatchView({required this.controller});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Obx(() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _DropField(
            label: 'Model Codes',
            value: controller.selectedModel.value?.name ?? '',
            placeholder: '-- Select Model Description --',
            onTap: () => controller.openPopup('ModelDescription'))),
          const SizedBox(width: 20),
          Expanded(child: _DropField(
            label: 'Regulations',
            value: controller.selectedSubModel.value?.name ?? '',
            placeholder: '-- Select Regulation --',
            onTap: () => controller.openPopup('Regulation'))),
        ],
      )),
      const Spacer(),
      Align(
        alignment: Alignment.bottomRight,
        child: _NextButton(onTap: controller.onBatchNext)),
      const SizedBox(height: 16),
    ],
  );
}

class _DropField extends StatelessWidget {
  final String label, value, placeholder;
  final VoidCallback onTap;
  const _DropField({required this.label, required this.value,
    required this.placeholder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 6, height: 6,
          decoration: const BoxDecoration(
            color: _cOrange, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: _cWhite70, letterSpacing: 0.3)),
      ]),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_cSurface, _cSurface2],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: Border.all(
              color: hasValue ? _cOrange : _cBorder,
              width: hasValue ? 1.5 : 1),
            borderRadius: BorderRadius.circular(10),
            boxShadow: hasValue ? const [BoxShadow(
              color: Color(0x30F97316),
              blurRadius: 8, offset: Offset(0, 2))] : null),
          child: Row(children: [
            Expanded(child: Text(
              hasValue ? value : placeholder,
              style: TextStyle(
                fontSize: 14,
                color: hasValue ? _cWhite : _cWhite40),
              overflow: TextOverflow.ellipsis)),
            Icon(Icons.keyboard_arrow_down_rounded,
              color: hasValue ? _cOrange : _cWhite40, size: 22),
          ]),
        ),
      ),
    ]);
  }
}

// ════════════════════════════════════════════════════════════
//  Individual View
// ════════════════════════════════════════════════════════════
class _IndividualView extends StatelessWidget {
  final FlashProcessController controller;
  const _IndividualView({required this.controller});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      // Table header — orange gradient
      Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_cOrange, _cOrangD, _cOrangDD],
            begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(
            color: Color(0x40F97316), blurRadius: 12, offset: Offset(0, 4))]),
        child: const Row(children: [
          SizedBox(width: 70, child: _HCell('Sr. No.')),
          Expanded(child: _HCell('Select Model Code')),
          Expanded(child: _HCell('Select Regulation')),
          Expanded(child: _HCell('Select From Active Dongles')),
        ]),
      ),
      const SizedBox(height: 6),

      // Rows
      Obx(() => Column(
        children: List.generate(
          controller.individualList.length,
          (i) => _IndRow(index: i, controller: controller)),
      )),

      const Spacer(),
      Align(
        alignment: Alignment.bottomRight,
        child: _NextButton(onTap: controller.onIndividualNext)),
      const SizedBox(height: 16),
    ],
  );
}

class _HCell extends StatelessWidget {
  final String text;
  const _HCell(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 14, color: _cWhite));
}

class _IndRow extends StatelessWidget {
  final int index;
  final FlashProcessController controller;
  const _IndRow({required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (index >= controller.individualList.length) return const SizedBox();
      final row    = controller.individualList[index];
      final isEven = index % 2 == 0;
      return Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isEven
              ? const Color(0x141E293B)
              : const Color(0x0A243044),
          border: Border.all(color: _cBorder),
          borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          // Sr No badge
          SizedBox(width: 70, child: Center(
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_cOrange, _cOrangD]),
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(
                  color: Color(0x40F97316),
                  blurRadius: 6, offset: Offset(0, 2))]),
              child: Center(child: Text('${index + 1}',
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold,
                  color: _cWhite)))))),
          Expanded(child: _RowDrop<ModelResult>(
            items: row.modelList,
            selected: row.selectedModel,
            label: (m) => m.name, hint: '--Model--',
            onChanged: (m) {
              if (m != null) controller.onModelSelected(index, m);
            })),
          const SizedBox(width: 8),
          Expanded(child: _RowDrop<SubModel>(
            items: row.selectedModel?.subModels ?? [],
            selected: row.selectedSubModel,
            label: (s) => s.name, hint: '--Regulation--',
            onChanged: (s) {
              if (s != null) controller.onSubModelSelected(index, s);
            })),
          const SizedBox(width: 8),
          Expanded(child: _RowDrop<DongleRow>(
            items: row.tableInfo,
            selected: row.selectedDongle,
            label: (d) => 'Dongle ${d.srNo}', hint: '--Dongle--',
            onChanged: (d) {
              if (d != null) controller.onDongleSelected(index, d);
            })),
        ]),
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
  const _RowDrop({required this.items, required this.selected,
    required this.label, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    height: 42,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [_cSurface, _cSurface2],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      border: Border.all(
        color: selected != null ? _cOrange : _cBorder,
        width: selected != null ? 1.5 : 1),
      borderRadius: BorderRadius.circular(8)),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: selected, isExpanded: true,
        dropdownColor: _cSurface,
        hint: Text(hint,
          style: const TextStyle(color: _cWhite40, fontSize: 13)),
        icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: selected != null ? _cOrange : _cWhite40, size: 20),
        items: items.map((item) => DropdownMenuItem<T>(
          value: item,
          child: Text(label(item),
            style: const TextStyle(fontSize: 13, color: _cWhite),
            overflow: TextOverflow.ellipsis),
        )).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════
//  NEXT Button
// ════════════════════════════════════════════════════════════
class _NextButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NextButton({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cOrange, _cOrangD, _cOrangDD],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(
          color: Color(0x60F97316),
          blurRadius: 16, offset: Offset(0, 5))]),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Text('NEXT', style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold,
          color: _cWhite, letterSpacing: 1.5)),
        SizedBox(width: 8),
        Icon(Icons.arrow_forward_rounded, color: _cWhite, size: 18),
      ]),
    ),
  );
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
        color: _cblack70,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 340, height: 460,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_cSurface, _cSurface2],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cBorder),
                boxShadow: const [BoxShadow(
                  color: Colors.black54, blurRadius: 24, offset: Offset(0, 8))]),
              child: Column(children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_cOrange, _cOrangD, _cOrangDD],
                      begin: Alignment.centerLeft, end: Alignment.centerRight),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16))),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                  child: Row(children: [
                    const Icon(Icons.list_alt_rounded,
                      color: _cWhite, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Obx(() => Text(
                      controller.popupTitle.value,
                      style: const TextStyle(
                        color: _cWhite, fontSize: 16,
                        fontWeight: FontWeight.bold)))),
                    GestureDetector(
                      onTap: controller.closePopup,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: _cWhite15, shape: BoxShape.circle),
                        child: const Icon(Icons.close,
                          color: _cWhite, size: 18))),
                  ]),
                ),

                // Count badge
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0x1AF97316),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _cBorder)),
                    child: Row(children: [
                      const Icon(Icons.info_outline,
                        color: _cOrange, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '${items.length} item${items.length != 1 ? 's' : ''} available',
                        style: const TextStyle(
                          color: _cOrange, fontSize: 12)),
                    ]),
                  ),
                ),

                // List
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: CircularProgressIndicator(
                          color: _cOrange))
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (_, i) {
                            final item = items[i];
                            final name = item is ModelResult
                                ? item.name
                                : (item as SubModel).name;
                            return GestureDetector(
                              onTap: () => controller.selectPopupItem(item),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF243044), Color(0xFF1E293B)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                                  border: Border.all(color: _cBorder),
                                  borderRadius: BorderRadius.circular(8)),
                                child: Row(children: [
                                  Container(width: 6, height: 6,
                                    decoration: const BoxDecoration(
                                      color: _cOrange, shape: BoxShape.circle)),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(name,
                                    style: const TextStyle(
                                      fontSize: 14, color: _cWhite))),
                                  const Icon(Icons.arrow_forward_ios_rounded,
                                    color: _cWhite40, size: 12),
                                ]),
                              ),
                            );
                          },
                        ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}