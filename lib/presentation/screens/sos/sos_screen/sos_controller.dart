import 'package:get/get.dart';

class EmergencyContact {
  final String name;
  final String imageUrl;
  EmergencyContact({required this.name, required this.imageUrl});
}

class SosController extends GetxController {
  final emergencyContacts = [
    EmergencyContact(name: 'Reena (Mom)', imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg'),
    EmergencyContact(name: 'Duke (Dad)', imageUrl: 'https://randomuser.me/api/portraits/men/46.jpg'),
    EmergencyContact(name: 'Sarah (Sis)', imageUrl: 'https://randomuser.me/api/portraits/women/65.jpg'),
    EmergencyContact(name: 'Maya', imageUrl: 'https://randomuser.me/api/portraits/women/32.jpg'),
  ];

  void callEmergencyServices() {}
  void callSafetyTeam() {}
  void openLiveChat() {}
  void shareLocation() {}
  void callTechnician() {}
  void messageTechnician() {}
  void addEmergencyContact() {}
  void reportMisconduct() {}
  void uploadEvidence() {}
  void requestCallBack() {}
}
