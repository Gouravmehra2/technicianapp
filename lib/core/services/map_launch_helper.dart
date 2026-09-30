// import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class MapLaunchHelper {
//   MapLaunchHelper._();
//
//   /// Opens Google Maps navigation from current location to [lat],[lng].
//   /// Falls back to a geo URI if the Google Maps app is not installed.
//   static Future<void> navigateTo({
//     required double lat,
//     required double lng,
//   }) async {
//     final googleMapsUrl = Uri.parse(
//       'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
//     );
//     final geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
//
//     if (await canLaunchUrl(googleMapsUrl)) {
//       await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
//     } else if (await canLaunchUrl(geoUrl)) {
//       await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
//     } else {
//       Get.snackbar(
//         'Navigation',
//         'Could not open Google Maps.',
//         snackPosition: SnackPosition.TOP,
//       );
//     }
//   }
// }
