import 'dart:async';

import 'package:boxorders/dto/box_dto.dart';
import 'package:boxorders/widgets/box_widgets/box_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _allBoxesRef = FirebaseDatabase.instance.ref('boxes');
  List<BoxDto> _boxes = [];

  late final StreamSubscription<DatabaseEvent> _boxListener;

  @override
  void initState() {
    _initBoxes();
    _boxListener = _allBoxesRef.onChildAdded.listen((DatabaseEvent event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        final boxJson = snapshot.value;
        setState(() => _boxes.add(BoxDto.fromJson(boxJson)));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _boxListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('hello'.tr()),
        actions: [
          IconButton(
            onPressed: () => context.push('/box'),
            icon: const Badge(
              label: Text('12'),
              child: Icon(Icons.shopping_bag_outlined),
            ),
          ),
          IconButton(
            onPressed: () => context.push('/box/create'),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, i) => BoxItem(
          child: _boxes[i],
        ),
        itemCount: _boxes.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint(_boxes.length.toString());
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _initBoxes() async {
    final snapshot = await _allBoxesRef.get();
    setState(() {
      _boxes = snapshot.exists
          ? ((snapshot.value as Map).values.toList())
              .map((e) => BoxDto.fromJson(e))
              .toList()
          : [];
    });
  }
}
