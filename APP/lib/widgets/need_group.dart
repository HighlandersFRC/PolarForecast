import 'package:flutter/material.dart';

class NeedGroup extends StatelessWidget {
  const NeedGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(children: [
                const Text('You must be part of a group to use this feature',
                    style: TextStyle(fontFamily: 'Font')),
                IconButton(
                    icon: Icon(Icons.help_outline),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/documentation/groups');
                    })
              ]),
            )));
  }
}
