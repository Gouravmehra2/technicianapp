import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/presentation/screens/dashboard/widgets/custom_bottom_navigation_tab.dart';

class DashboardController extends GetxController {
  int selectedIndex = 0;

  final List<BottomNavItemModel> bottomList = [
    BottomNavItemModel(
      label: "Home",
      filledIcon: AppAssets.filledHomeIcon,
      outlineIcon: AppAssets.outlinedHomeIcon,
    ),
    BottomNavItemModel(
      label: "Services",
      filledIcon: AppAssets.filledServiceIcon,
      outlineIcon: AppAssets.outlinedServiceIcon,
    ),
    BottomNavItemModel(
      label: "Bookings",
      filledIcon: AppAssets.filledCalendarIcon,
      outlineIcon: AppAssets.outlinedCalendarIcon,
    ),
    BottomNavItemModel(
      label: "Profile",
      filledIcon: AppAssets.filledPersonIcon,
      outlineIcon: AppAssets.outlinedPersonIcon,
    ),
  ];

  void changeIndex({int index = 1}) {
    selectedIndex = index;
    update();
  }
}
