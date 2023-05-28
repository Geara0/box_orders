import 'package:boxorders/dto/box_dto.dart';
import 'package:boxorders/widgets/box_widgets/box_item_small.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final _userSubsRef = FirebaseDatabase.instance
      .ref('users/${FirebaseAuth.instance.currentUser?.uid}/subscriptions');

  Map _boxesMap = {};

  @override
  void initState() {
    _initBoxes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var boxKeys = _boxesMap.keys.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('subscriptions.header'.tr()),
      ),
      body: ListView.builder(
        itemBuilder: (context, i) => BoxItemSmall(
          callback: () => _unsubscribe(boxKeys[i]),
          child: BoxDto.fromJson(_boxesMap[boxKeys[i]]),
        ),
        itemCount: boxKeys.length,
      ),
    );
  }

  void _initBoxes() async {
    final snapshot = await _userSubsRef.get();
    setState(() {
      _boxesMap = snapshot.exists ? snapshot.value as Map : {};
    });
  }

  void _unsubscribe(String key) {
    _userSubsRef.child(key).remove();
    setState(() => _boxesMap.remove(key));
  }
}
