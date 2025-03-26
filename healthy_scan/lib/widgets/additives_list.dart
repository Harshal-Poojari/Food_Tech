import 'package:flutter/material.dart';

class AdditivesList extends StatelessWidget {
  final List<String> additives;

  const AdditivesList({super.key, required this.additives});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final additive in additives)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 4, right: 6),
                    decoration: BoxDecoration(
                      color: Colors.red[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(additive, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
