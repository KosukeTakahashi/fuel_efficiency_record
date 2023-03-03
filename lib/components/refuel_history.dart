import 'package:flutter/material.dart';

class RefuelHistory extends StatelessWidget {
  const RefuelHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '給油履歴',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(),
                for (int i = 0; i < 5; i++)
                  ListTile(
                    title: Text('履歴 #$i'),
                  )
              ],
            )
        ),
      )
    );
  }
}
