import 'dart:convert';
import 'dart:ffi';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Coffee {
  String shopName;
  String address;
  String description;
  String thumbNail;
  double latitude;
  double longtitude;
  Coffee({
    this.shopName,
    this.address,
    this.description,
    this.thumbNail,
    this.latitude,
    this.longtitude,
  });

  Coffee copyWith({
    String shopName,
    String address,
    String description,
    String thumbNail,
    double latitude,
    double longtitude,
  }) {
    return Coffee(
      shopName: shopName ?? this.shopName,
      address: address ?? this.address,
      description: description ?? this.description,
      thumbNail: thumbNail ?? this.thumbNail,
      latitude: latitude ?? this.latitude,
      longtitude: longtitude ?? this.longtitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopName': shopName,
      'address': address,
      'description': description,
      'thumbNail': thumbNail,
      'latitude': latitude,
      'longtitude': longtitude,
    };
  }

  Coffee.fromJson(Map<String, dynamic> map) {
    shopName = map['shopName'];
    address = map['address'];
    description = map['description'];
    thumbNail = map['thumbNail'];
    latitude = map['latitude'];
    longtitude = map['longtitude'];
  }

  String toJson() => json.encode(toMap());

  // factory Coffee.fromJson(String source) => Coffee.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Coffee(shopName: $shopName, address: $address, description: $description, thumbNail: $thumbNail, latitude: $latitude, longtitude: $longtitude)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Coffee &&
        o.shopName == shopName &&
        o.address == address &&
        o.description == description &&
        o.thumbNail == thumbNail &&
        o.latitude == latitude &&
        o.longtitude == longtitude;
  }

  @override
  int get hashCode {
    return shopName.hashCode ^
        address.hashCode ^
        description.hashCode ^
        thumbNail.hashCode ^
        latitude.hashCode ^
        longtitude.hashCode;
  }
}
