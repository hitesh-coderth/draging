/*  */

import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 40),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  /// This function swaps the position of two items.
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Take a long press for dragg icons",style: TextStyle(
            color: Colors.black45,
            fontSize: 16,
            fontWeight: FontWeight.w500
        ),),
        const SizedBox(height: 20,),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black12,
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildDraggableItems(),
          ),
        ),
      ],
    );
  }

  /// Build draggable items
  List<Widget> _buildDraggableItems() {
    return List.generate(_items.length, (index) {
      final item = _items[index];
      return LongPressDraggable<T>(
        data: item,
        axis: Axis.horizontal,
        feedback: Material(
          color: Colors.transparent,
          child: widget.builder(item),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: widget.builder(item),
        ),
        child: DragTarget<T>(
          onAccept: (receivedItem) {
            final oldIndex = _items.indexOf(receivedItem);
            _onReorder(oldIndex, index);
          },
          onWillAccept: (receivedItem) => true,
          builder: (context, candidateData, rejectedData) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: AnimatedContainer(
                key: ValueKey<T>(item), // Ensures a unique key per item
                duration: const Duration(milliseconds: 300),
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[item.hashCode % Colors.primaries.length],
                ),
                child: Center(child: widget.builder(item)),
              ),
            );
          },
        ),
      );
    });
  }
}
