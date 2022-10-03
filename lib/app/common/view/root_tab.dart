import 'package:flutter/material.dart';
import 'package:flutter_delivery/app/common/const/colors.dart';
import 'package:flutter_delivery/app/common/layout/default_layout.dart';
import 'package:flutter_delivery/app/modules/restaurant/view/restaurant_screen.dart';
import 'package:flutter_delivery/app/modules/user/view/profile_screen.dart';

import '../../modules/product/view/product_screen.dart';

class RootTab extends StatefulWidget {

  static String routeName = 'home';

  const RootTab({Key? key}) : super(key: key);

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  int index = 0;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(tabListener);
  }

  void tabListener(){
    setState((){
      index = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(tabListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '코팩 딜리버리',
      child: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          RestaurantScreen(),
          ProductScreen(),
          Container(child: Center(child: Text('주문')),),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: PRIMARY_COLOR,
        unselectedItemColor: BODY_TEXT_COLOR,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          _tabController.animateTo(index);
        },
        currentIndex: index,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fastfood_outlined), label: '음식'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined), label: '주문'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: '프로필'),
        ],
      ),
    );
  }
}
