import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class BoxDto {
  late final String name;
  late final String _image;
  late final String description;
  late final int price;

  Image get image {
    try {
      return Image.memory(base64Decode(_image), fit: BoxFit.fitWidth);
    } catch (e) {
      return Image.asset('assets/images/not_found.png', fit: BoxFit.fitWidth);
    }
  }

  BoxDto({
    required this.name,
    required XFile image,
    required this.description,
    required this.price,
  }) {
    _image = base64Encode(File(image.path).readAsBytesSync());
  }

  BoxDto.fromJson(json) {
    name = json['name'];
    _image = json['image'];
    description = json['description'];
    price = json['price'];
  }

  Map<String, Object> toJson() => {
        'name': name,
        'image': _image,
        'description': description,
        'price': price,
      };
}
