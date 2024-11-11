import 'package:flutter/material.dart';

class InRouteScreen extends StatefulWidget {
  final void Function()? onPressed;
  int distance;
  int time;

  InRouteScreen({
    super.key,
    required this.onPressed,
    required this.distance,
    required this.time,
  });

  @override
  State<InRouteScreen> createState() => _InRouteScreenState();
}

class _InRouteScreenState extends State<InRouteScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // In-Route Text
            const Text(
              'In-Route',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // Distance Remaining
            Text('Distance Remaing: ${widget.distance}'),
            // Time Remaining
            Text('Time Remaining: ${widget.time}'),
            // End Route Button
            ElevatedButton(
                onPressed: widget.onPressed,
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.red)),
                child: const Text(
                  'End Route',
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }
}
