import 'dart:async'; // For Timer
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  OverlayEntry? _overlay;
  LayerLink? _currentLayerLink;
  bool _isHoveringTarget = false;
  bool _isHoveringOverlay = false;

  void _showOverlay(BuildContext context, LayerLink layerLink) {
    _overlay?.remove();
    // Update the current LayerLink and index
    _currentLayerLink = layerLink;
    _overlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 100,
          child: CompositedTransformFollower(
            link: layerLink,
            targetAnchor: Alignment.topRight,
            followerAnchor: Alignment.centerRight,
            child: MouseRegion(
              hitTestBehavior: HitTestBehavior.translucent,
              onEnter: (event) {
                print('On enter overlay');
                _isHoveringOverlay = true;
              },
              onExit: (event) {
                _isHoveringOverlay = false;
                _sheduleOverlayRemoval();
              },
              child: Material(
                color: Colors.green,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'This is a popup!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlay!);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay?.dispose();
    _overlay = null;
    _currentLayerLink = null;
  }

  void _sheduleOverlayRemoval() {
    Future.delayed(Duration(milliseconds: 300), () {
      if (!_isHoveringTarget && !_isHoveringOverlay) {
        _removeOverlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Discord-like Popup Demo')),
        body: Center(
          child: ListView.builder(
            itemCount: 5, // A list of widgets
            itemBuilder: (context, index) {
              final layerLink = LayerLink();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: MouseRegion(
                  onEnter: (event) {
                    _isHoveringTarget = true;
                    _showOverlay(context, layerLink);
                  },
                  onExit: (event) {
                    _isHoveringTarget = false;
                    _sheduleOverlayRemoval();
                    print('Trigger exit');
                  },
                  child: CompositedTransformTarget(
                    link: layerLink,
                    child: Container(
                      color: Colors.red,
                      height: 50,
                      width: double.infinity,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
