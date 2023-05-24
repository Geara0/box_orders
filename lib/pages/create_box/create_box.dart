import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateBoxPage extends StatefulWidget {
  const CreateBoxPage({Key? key}) : super(key: key);

  @override
  State<CreateBoxPage> createState() => _CreateBoxPageState();
}

class _CreateBoxPageState extends State<CreateBoxPage> {
  final _picker = ImagePicker();

  XFile? _image;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primaryContainer,
        title: const Text('sus'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  final file = await _picker.pickImage(
                      source: ImageSource.gallery, requestFullMetadata: false);
                  setState(() => _image = file);
                },
                child: Center(
                  child: Container(
                    height: _image == null ? 300 : null,
                    width: _image == null ? double.infinity : null,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
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
              const TextField(
                maxLines: null,
                decoration: InputDecoration(
                  labelText: 'enter text',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
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
            const Flexible(
              flex: 3,
              child: TextField(
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: 'enter price',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('USD'),
            const SizedBox(width: 40),
            FilledButton(
              onPressed: () {},
              child: const Text('sell'),
            ),
          ],
        ),
      ),
    );
  }
}
