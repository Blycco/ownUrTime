import 'package:flutter/material.dart';

import 'package:ownurtime/core/l10n/app_localizations.dart';

class DurationSelector extends StatefulWidget {
  const DurationSelector({super.key, required this.onSelect});

  final void Function(Duration) onSelect;

  @override
  State<DurationSelector> createState() => _DurationSelectorState();
}

class _DurationSelectorState extends State<DurationSelector> {
  final TextEditingController _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  Future<void> _openCustomSheet() async {
    _customController.clear();
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _customController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).sessionDurationCustom,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final parsed = int.tryParse(_customController.text.trim());
                    final minutes = parsed == null || parsed < 1 ? 1 : parsed;
                    Navigator.of(context).pop(minutes);
                  },
                  child: Text(MaterialLocalizations.of(context).okButtonLabel),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      widget.onSelect(Duration(minutes: result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: Text(l10n.sessionDuration10Min),
          selected: false,
          onSelected: (_) => widget.onSelect(const Duration(minutes: 10)),
        ),
        ChoiceChip(
          label: Text(l10n.sessionDuration15Min),
          selected: false,
          onSelected: (_) => widget.onSelect(const Duration(minutes: 15)),
        ),
        ChoiceChip(
          label: Text(l10n.sessionDuration25Min),
          selected: false,
          onSelected: (_) => widget.onSelect(const Duration(minutes: 25)),
        ),
        ChoiceChip(
          label: Text(l10n.sessionDurationCustom),
          selected: false,
          onSelected: (_) => _openCustomSheet(),
        ),
      ],
    );
  }
}
