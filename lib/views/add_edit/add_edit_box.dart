import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../../database_helper.dart';

class AddEditBoxDialog extends StatefulWidget {
  final Map<String, dynamic>? boxData;
  final ValueChanged<Map<String, dynamic>> onSave;

  const AddEditBoxDialog({
    Key? key,
    this.boxData,
    required this.onSave,
  }) : super(key: key);

  @override
  AddEditBoxDialogState createState() => AddEditBoxDialogState();
}

class AddEditBoxDialogState extends State<AddEditBoxDialog> {
  late TextEditingController _nameController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _depthController;

  bool _hasCompartments = false;
  int? _compartmentsCount;

  bool isNameEmpty = false;
  bool isCompartmentsCountEmpty = false;
  bool isWidthEmpty = false;
  bool isHeightEmpty = false;
  bool isDepthEmpty = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.boxData?['name'] ?? '');
    _widthController = TextEditingController(
        text: widget.boxData?['width']?.toStringAsFixed(1) ?? '');
    _heightController = TextEditingController(
        text: widget.boxData?['height']?.toStringAsFixed(1) ?? '');
    _depthController = TextEditingController(
        text: widget.boxData?['depth']?.toStringAsFixed(1) ?? '');
    _hasCompartments = widget.boxData?['hasCompartments'] == 1;
    _compartmentsCount = widget.boxData?['compartmentsCount'];
  }

  Future<void> _save() async {
    setState(() {
      isNameEmpty = _nameController.text.trim().isEmpty;
      isCompartmentsCountEmpty = _hasCompartments &&
          (_compartmentsCount == null || _compartmentsCount == 0);
      isWidthEmpty = _widthController.text.isEmpty;
      isHeightEmpty = _heightController.text.isEmpty;
      isDepthEmpty = _depthController.text.isEmpty;
    });

    if (isNameEmpty ||
        isCompartmentsCountEmpty ||
        isWidthEmpty ||
        isHeightEmpty ||
        isDepthEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('fillAllFields'))),
      );
      return;
    }

    final boxData = {
      'name': _nameController.text.trim(),
      'hasCompartments': _hasCompartments ? 1 : 0,
      'compartmentsCount': _hasCompartments ? (_compartmentsCount ?? 0) : 0,
      'width':
          double.tryParse(_widthController.text.replaceAll(',', '.')) ?? 0.0,
      'height':
          double.tryParse(_heightController.text.replaceAll(',', '.')) ?? 0.0,
      'depth':
          double.tryParse(_depthController.text.replaceAll(',', '.')) ?? 0.0,
    };

    try {
      final result = await DatabaseHelper().insertBox(boxData);
      if (result == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translate('duplicateBoxError'))),
        );
      } else {
        widget.onSave(boxData);
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving box: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final List<TextInputFormatter> numberInputFormatter = [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: theme.colorScheme.surface,
      child: IntrinsicWidth(
        stepWidth: 1,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.boxData == null
                      ? translate('addBox')
                      : translate('editBox'),
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: translate('boxName'),
                    errorText: isNameEmpty ? translate('fieldRequired') : null,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      translate('hasCompartments'),
                      style: textTheme.bodyLarge,
                    ),
                    Switch(
                      value: _hasCompartments,
                      onChanged: (value) {
                        setState(() {
                          _hasCompartments = value;
                          if (!_hasCompartments) {
                            _compartmentsCount = null;
                            isCompartmentsCountEmpty = false;
                          }
                        });
                      },
                    ),
                  ],
                ),
                if (_hasCompartments)
                  TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: numberInputFormatter,
                    onChanged: (value) {
                      _compartmentsCount = int.tryParse(value);
                      setState(() {
                        isCompartmentsCountEmpty = false;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: translate('compartmentsCount'),
                      errorText: isCompartmentsCountEmpty
                          ? translate('fieldRequired')
                          : null,
                    ),
                  ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    TextField(
                      controller: _widthController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: numberInputFormatter,
                      decoration: InputDecoration(
                        labelText: translate('width'),
                        errorText:
                            isWidthEmpty ? translate('fieldRequired') : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _heightController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: numberInputFormatter,
                      decoration: InputDecoration(
                        labelText: translate('height'),
                        errorText:
                            isHeightEmpty ? translate('fieldRequired') : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _depthController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: numberInputFormatter,
                      decoration: InputDecoration(
                        labelText: translate('depth'),
                        errorText:
                            isDepthEmpty ? translate('fieldRequired') : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(translate('cancel')),
                    ),
                    ElevatedButton(
                      onPressed: _save,
                      child: Text(translate('save')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
