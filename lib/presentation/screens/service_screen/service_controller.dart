import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';

class ServiceModel {
  final String name;
  final String price;
  final double rating;
  final int reviews;
  final String image;

  ServiceModel({
    required this.name,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.image,
  });
}

class ServiceCategory {
  final String name;
  final String image;
  final String selectedImage;
  final List<ServiceModel> services;

  ServiceCategory({
    required this.name,
    required this.image,
    required this.selectedImage,
    required this.services,
  });
}

class ServiceController extends GetxController {
  final selectedIndex = 0.obs;
  final rightScrollController = ScrollController();
  final leftScrollController = ScrollController();

  final List<GlobalKey> categoryKeys = [];

  final List<ServiceCategory> categories = [
    ServiceCategory(
      name: 'Smart Home',
      image:AppAssets.smartHomeOutlineImage,
      selectedImage: AppAssets.smartHomeFilledImage,
      services: [
        ServiceModel(name: 'Thermostats Installation', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Video Doorbell Setup', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Smart Lock Installation', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Smart Garage Door Setup', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Smart Hubs & Speaker Setup', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
      ],
    ),
    ServiceCategory(
      name: 'TV Mounting',
      image: AppAssets.tvOutlineImage,
      selectedImage: AppAssets.tvFilledImage,
      services: [
        ServiceModel(name: 'TV Mounting', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'TV Dismount', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Wire Concealment', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'TV Remote SetUp', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
      ],
    ),
    ServiceCategory(
      name: 'WiFi & Networking',
      image: AppAssets.wifiOutlineImage,
      selectedImage: AppAssets.wifiFilledImage,
      services: [
        ServiceModel(name: 'Router Installation & SetUp', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Network Troubleshooting', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Mesh Wifi', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Wall-Cable Running', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
      ],
    ),
    ServiceCategory(
      name: 'Computer & Device',
      image: AppAssets.computerDeviceOutlineImage,
      selectedImage: AppAssets.computerDeviceFilledImage,
      services: [
        ServiceModel(name: 'Computer System Setup', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Printer Installation & Setup', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Software Setup Support', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Device Setup & Driver Installations', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Troubleshooting Support', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
      ],
    ),
    ServiceCategory(
      name: 'Security',
      image: AppAssets.securityOutlineImage,
      selectedImage: AppAssets.securityFilledImage,
      services: [
        ServiceModel(name: 'Smart Camera Installation', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Smart Door Lock Installation', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Smart Alarm System Setup', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Security Diagnostics', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
      ],
    ),
    ServiceCategory(
      name: 'Audio & Video',
      image: AppAssets.videoOutlineImage,
      selectedImage: AppAssets.videoFilledImage,
      services: [
        ServiceModel(name: 'Home Theater System Setup', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Sound System Setup', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Gaming Consoles Setup', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Streaming Devices Setup', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
        ServiceModel(name: 'Universal Remote Setup', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
      ],
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    categoryKeys.addAll(List.generate(categories.length, (_) => GlobalKey()));
  }

  @override
  void onClose() {
    rightScrollController.dispose();
    leftScrollController.dispose();
    super.onClose();
  }

  void onCategoryTap(int index) {
    selectedIndex.value = index;
    final key = categoryKeys[index];
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
    _scrollLeftIfNeeded(index);
  }

  void _scrollLeftIfNeeded(int index) {
    if (!leftScrollController.hasClients) return;
    const itemHeight = 80.0;
    final itemTop = index * itemHeight;
    final itemBottom = itemTop + itemHeight;
    final offset = leftScrollController.offset;
    final viewportHeight = leftScrollController.position.viewportDimension;
    final isVisible = itemTop >= offset && itemBottom <= offset + viewportHeight;
    if (!isVisible) {
      leftScrollController.animateTo(
        itemTop,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
