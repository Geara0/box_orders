import 'dart:io';

import 'package:boxorders/dto/box_dto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CreateBoxPage extends StatefulWidget {
  const CreateBoxPage({Key? key}) : super(key: key);

  @override
  State<CreateBoxPage> createState() => _CreateBoxPageState();
}

class _CreateBoxPageState extends State<CreateBoxPage> {
  final _userBoxesRef = FirebaseDatabase.instance
      .ref('users/${FirebaseAuth.instance.currentUser?.uid}/boxes');
  final _allBoxesRef = FirebaseDatabase.instance.ref('boxes');

  final _picker = ImagePicker();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String? _nameError;
  String? _priceError;
  bool _showNameError = false;
  bool _showPriceError = false;

  XFile? _image;
  bool showLoader = false;

  @override
  void initState() {
    _nameController.addListener(() {
      setState(() => _nameError =
          _nameController.text.isNotEmpty || !_showNameError
              ? null
              : 'createBox.emptyNameError'.tr());
      _showNameError = true;
    });
    _priceController.addListener(() {
      setState(() => _priceError =
          _priceController.text.isNotEmpty || !_showPriceError
              ? null
              : 'createBox.emptyPriceError'.tr());
      _showPriceError = true;
    });
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: Text('createBox.header'.tr()),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final file = await _picker.pickImage(
                          source: ImageSource.gallery,
                          requestFullMetadata: false);
                      setState(() => _image = file);
                    },
                    child: Center(
                      child: Container(
                        height: _image == null ? 300 : null,
                        width: _image == null ? double.infinity : null,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6)),
                          border: Border.all(
                            style: BorderStyle.solid,
                            width: 1,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        child: _image == null
                            ? const Icon(Icons.image)
                            : ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                                child: Image.file(File(_image!.path)),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      errorText: _nameError,
                      labelText: 'createBox.nameLabel'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'createBox.descriptionLabel'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showLoader)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black38,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: EdgeInsets.only(
          left: 8,
          right: 8,
          bottom: MediaQuery.paddingOf(context).bottom +
              MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Row(
          children: [
            Flexible(
              flex: 3,
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLines: 1,
                decoration: InputDecoration(
                  errorText: _priceError,
                  labelText: 'createBox.priceLabel'.tr(),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('USD'),
            const SizedBox(width: 40),
            FilledButton(
              onPressed: _image != null &&
                      _priceController.text.isNotEmpty &&
                      _nameController.text.isNotEmpty
                  ? _placeItem
                  : null,
              child: Text('createBox.pasteButton'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  _placeItem() {
    showLoader = true;
    final box = _createBox().toJson();
    final key = _userBoxesRef.push().key;
    _allBoxesRef.update({key!: box});
    _userBoxesRef.update({key: box}).then((value) => context.pop());
  }

  BoxDto _createBox() => BoxDto(
        name: _nameController.text,
        image: _image!,
        description: _descriptionController.text,
        price: int.parse(_priceController.text),
      );
}
