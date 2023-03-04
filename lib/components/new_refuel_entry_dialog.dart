import 'package:flutter/material.dart';

class NewRefuelEntryDialog extends StatelessWidget {
  const NewRefuelEntryDialog({super.key});

  TableRow _buildStatsItem<T>(BuildContext context, Icon icon, String title,
          T value, String unit) =>
      TableRow(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0), child: icon),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Text(
            '$value',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          Text(
            unit,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      );

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
        title: const Text('新しい給油履歴'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('給油情報'),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '給油量',
                      suffixText: 'L',
                    ),
                    onChanged: (input) {},
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 1,
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '単価',
                      suffixText: '円/L',
                    ),
                    onChanged: (input) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '総額',
                  suffixText: '円'),
              onChanged: (input) {},
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '現在の走行距離',
                suffixText: 'km',
              ),
              onChanged: (input) {},
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '日時',
              ),
              onChanged: (input) {},
            ),
            const SizedBox(height: 16.0),
            const Text('今回の記録'),
            // const AverageFuelEfficiency(fuelEfficiency: 20.3),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const <int, TableColumnWidth>{
                  0: IntrinsicColumnWidth(),
                  1: IntrinsicColumnWidth(),
                  2: FlexColumnWidth(),
                  3: IntrinsicColumnWidth(),
                },
                children: [
                  _buildStatsItem(
                    context,
                    const Icon(Icons.drive_eta),
                    '前回からの走行距離',
                    389,
                    'km',
                  ),
                  _buildStatsItem(
                    context,
                    const Icon(Icons.speed),
                    '今回の平均燃費',
                    24.0,
                    'km/L',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
