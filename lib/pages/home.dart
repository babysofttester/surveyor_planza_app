
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:surveyor_app_planzaa/common/custom_colors.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/controller/status_update_controller.dart';
import 'package:surveyor_app_planzaa/pages/dashboard.dart';
import 'package:surveyor_app_planzaa/pages/earning.dart';
import 'package:surveyor_app_planzaa/pages/profileScreen.dart';
import 'package:surveyor_app_planzaa/pages/work.dart';
import 'package:surveyor_app_planzaa/pages/workHistory.dart';
import 'package:surveyor_app_planzaa/services/location_channel.dart';

class Home extends StatefulWidget {
  
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  RxBool toUSEOBX = true.obs;

  /// Controller to handle PageView and also handles initial page
  final _pageController = PageController(initialPage: 0);

  /// Controller to handle bottom nav bar and also handles initial page
  // ignore: unused_field
  final _controller = NotchBottomBarController(index: 1);
  double fourthDepth = 50;
  late AnimationController _animationController;
  int maxCount = 4;

  late SharedPreferences prefs;

  // int pageIndex = 0;
  int? pageIndex;
  // @override
  // void initState() {
  //   super.initState();
  //   _animationController = AnimationController(vsync: this);
  //   load();

  //     pageIndex = 0;

  // final pages = [
  //   HomeScreen(
  //     onTabChange: (index) {
  //       setState(() {
  //         pageIndex = index;

  //         if (index == 0) appTitle = "Home";
  //         if (index == 1) appTitle = "Services";
  //         if (index == 2) appTitle = "Projects";
  //         if (index == 3) appTitle = "Order History";
  //         if (index == 4) appTitle = "Profile";
  //       });
  //     },
  //   ),
  //   const ServiceScreen(),
  //   ProjectPage(),
  //   const OrderHistory(),
  //   const ProfileScreen(),
  // ];
  // }

  late List<Widget> pages;
  late StatusUpdateController statusUpdateController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    statusUpdateController = Get.put(StatusUpdateController(this));

    pageIndex = 0;
appTitle = "Dashboard";
    // pages = [
    //  const Dashboard(),
    //  const Work(),
    //  const WorkHistory(),
    //  const Earning(),
    //  const ProfileScreen(),
 
    // ];
// pages = [];
    load();
  } 

  load() async {
    pageIndex = 0;

    prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // final pages = [
  //   const HomeScreen(),
  //   const ServiceScreen(),
  //   ProjectPage(),
  //   const OrderHistory(),
  //   const ProfileScreen(),

  //   // const Goals(),
  //   // const Obstacles(),
  //   // const Actionss(),
  //   // const Level(),
  //   // const ShareScreen(),
  // ];
bool isOnline = true;
  String appTitle = "Dashboard";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.white,
      appBar: AppBar(
              toolbarHeight: MediaQuery.of(context).size.width < 600
                  ? Get.width * 0.15
                  : Get.width * 0.075,
              elevation: 0,
              backgroundColor: CustomColors.boxColor,
              foregroundColor: CustomColors.boxColor,
              surfaceTintColor: CustomColors.boxColor,
              // leading:
 
              //     Padding(
              //         padding: MediaQuery.of(context).size.width < 600
              //             ? EdgeInsets.all(Get.width * 0.02)
              //             : EdgeInsets.all(Get.width * 0.01),
              //         child: Text("")),
              title: Utils.textView(
                appTitle,
                MediaQuery.of(context).size.width < 600
                    ? Get.width * 0.05
                    : Get.width * 0.03,
                CustomColors.white,
                FontWeight.bold,
              ),
              centerTitle: true,
             actions: pageIndex == 0
    ? [
        Row(
          children: [
       Switch(
  value: isOnline,
  activeColor: CustomColors.white,
  activeTrackColor: CustomColors.btnColor.withOpacity(0.5),
  onChanged: (value) async {
    if (value) { 
      
      final success = await LocationChannel.goOnline();
      if (success) {
        final apiSuccess = await statusUpdateController.updateOnlineStatus(1);
        if (apiSuccess) {
          setState(() { isOnline = true; });
          Utils.showToast("You are Online");
        } else {
          Utils.showToast("Failed to update status. Try again.");
        }
      } 
    } else {
   
    
    }
  },
),
          ],
        ),
      ]
    : [],
            ),
    body: _buildPage(pageIndex ?? 0),
      extendBody: true,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 75,
         decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 12,
      offset: const Offset(0, -3),
    ),
  ],
),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                 GestureDetector(
  onTap: () {
    setState(() { 
      pageIndex = 0;
      appTitle = "Dashboard"; 
    });
  },
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(0, pageIndex == 0 ? -4 : 0, 0),
        child: Icon(
          pageIndex == 0 ? Icons.home : Icons.home_outlined,
          size: pageIndex == 0 ? 30 : 22,
          color: pageIndex == 0 ? const Color(0xFF1E3A8A) : Colors.grey,
        ),
      ),
      //const SizedBox(height: 2),
      Text(
        "Home",
        style: TextStyle(
          fontSize: 12,
          fontWeight: pageIndex == 0 ? FontWeight.bold : FontWeight.normal,
          color: pageIndex == 0 ? const Color(0xFF1E3A8A) : Colors.grey,
        ),
      ),
  
    ],
  ),
),
                ],
              ),
            
            
              GestureDetector(
  onTap: () {
    setState(() { pageIndex = 1; appTitle = "Work History"; });
  },
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(0, pageIndex == 1 ? -4 : 0, 0),
        child: Icon(
          pageIndex == 1 ? Icons.file_copy : Icons.file_copy_outlined,
          size: pageIndex == 1 ? 30 : 22,
          color: pageIndex == 1 ? const Color(0xFF1E3A8A) : Colors.grey,
        ),
      ),
    //  const SizedBox(height: 4),
      Text(
        "Work History",
        style: TextStyle(
          fontSize: 12,
          fontWeight: pageIndex == 1 ? FontWeight.bold : FontWeight.normal,
          color: pageIndex == 1 ? const Color(0xFF1E3A8A) : Colors.grey,
        ),
      ),
      
    ],
  ),
),
             GestureDetector(
  onTap: () {
    setState(() { pageIndex = 2; appTitle = "Earning"; });
  },
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(0, pageIndex == 2 ? -4 : 0, 0),
        child: Icon(
          pageIndex == 2 ? Icons.receipt_long : Icons.receipt_long_outlined,
          size: pageIndex == 2 ? 30 : 22,
          color: pageIndex == 2 ? const Color(0xFF1E3A8A) : Colors.grey,
        ),
      ),
     // const SizedBox(height: 4),
      Text(
        "Earning",
        style: TextStyle(
          fontSize: 12,
          fontWeight: pageIndex == 2 ? FontWeight.bold : FontWeight.normal,
          color: pageIndex == 2 ? const Color(0xFF1E3A8A) : Colors.grey,
        ),
      ),
     
    ],
  ),
),
             GestureDetector(
  onTap: () {
    setState(() { pageIndex = 3; appTitle = "Profile"; });
  },
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(0, pageIndex == 3 ? -4 : 0, 0),
        child: Icon(
          pageIndex == 3 ? Icons.person : Icons.person_outline,
          size: pageIndex == 3 ? 30 : 22,
          color: pageIndex == 3 ? const Color(0xFF1E3A8A) : Colors.grey,
        ),
      ),
     // const SizedBox(height: 4),
      Text(
        "Profile",
        style: TextStyle(
          fontSize: 12,
          fontWeight: pageIndex == 3 ? FontWeight.bold : FontWeight.normal,
          color: pageIndex == 3 ? const Color(0xFF1E3A8A) : Colors.grey,
        ),
      ),
         ],
  ),
), 
            ],
          ),
        ),
      ),
    
    );
    // );
  }
  Widget _buildPage(int index) {
  switch (index) {
case 0:
  return Dashboard(
    onTabChange: (tabIndex) {
      setState(() {
        pageIndex = tabIndex;
        if (tabIndex == 0) appTitle = "Dashboard";
        if (tabIndex == 1) appTitle = "Work History";
        if (tabIndex == 2) appTitle = "Earning";
        if (tabIndex == 3) appTitle = "Profile";
      });
    },   
  );
    // case 1: return const Work();
    case 1: return const WorkHistory();
    case 2: return const Earning();
    case 3:
  return ProfileScreen(
    onTabChange: (tabIndex) {
      setState(() {
        pageIndex = tabIndex;

        if (tabIndex == 0) appTitle = "Dashboard";
        if (tabIndex == 1) appTitle = "Work History";
        if (tabIndex == 2) appTitle = "Earning";
        if (tabIndex == 3) appTitle = "Profile";
      });
    },
  );
    default: return const Dashboard();
  }
}
}


//////customer wale me change krna h /////////