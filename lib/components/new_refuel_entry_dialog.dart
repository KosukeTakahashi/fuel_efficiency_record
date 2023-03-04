import 'package:flutter/material.dart';

class NewRefuelEntryDialog extends StatelessWidget {
  const NewRefuelEntryDialog({super.key});

  Widget _buildField(BuildContext context, String label, String unit, ValueChanged<String> onChanged) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: label
            ),
          ),
        ),
        const SizedBox(
            width: 32.0
        ),
        Text(unit),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // title: const Text('新しい給油履歴'),
        actions: [
          TextButton(
            child: const Text('保存'),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            _buildField(context, '給油量', 'L', (value) {

            }),
          ],
        ),
      ),
    );
  }
}
