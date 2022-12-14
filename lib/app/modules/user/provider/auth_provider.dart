import 'package:flutter/cupertino.dart';
import 'package:flutter_delivery/app/common/view/root_tab.dart';
import 'package:flutter_delivery/app/common/view/splash_screen.dart';
import 'package:flutter_delivery/app/modules/order/view/order_done_screen.dart';
import 'package:flutter_delivery/app/modules/restaurant/view/basket_screen.dart';
import 'package:flutter_delivery/app/modules/restaurant/view/restaurant_detail_screen.dart';
import 'package:flutter_delivery/app/modules/user/model/user_model.dart';
import 'package:flutter_delivery/app/modules/user/provider/user_me_provider.dart';
import 'package:flutter_delivery/app/modules/user/view/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(ref: ref);
});

// 변경사항 알리는 용도
class AuthProvider extends ChangeNotifier {
  final Ref ref;

  AuthProvider({required this.ref}) {
    ref.listen<UserModelBase?>(userMeProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }

  void logout() {
    ref.read(userMeProvider.notifier).logout();
  }

  List<GoRoute> get routes => [
        GoRoute(
            path: '/',
            name: RootTab.routeName,
            builder: (_, __) => const RootTab(),
            routes: [
              GoRoute(
                  path: 'restaurant/:rid',
                  name: RestaurantDetailScreen.routeName,
                  builder: (_, state) =>
                      RestaurantDetailScreen(id: state.params['rid']!))
            ]),
        GoRoute(
          path: '/basket',
          name: BasketScreen.routeName,
          builder: (_, state) => const BasketScreen(),
        ),
        GoRoute(
          path: '/order_done',
          name: OrderDoneScreen.routeName,
          builder: (_, state) => const OrderDoneScreen(),
        ),
        GoRoute(
          path: '/splash',
          name: SplashScreen.routeName,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: LoginScreen.routeName,
          builder: (_, __) => const LoginScreen(),
        ),
      ];

  // SplashScreen
  // 앱을 처음 시작했을때
  // 토큰이 존재하는지 확인하고
  // 로그인 스크린으로 보내줄지
  // 홈 스크린으로 보내줄지 확인하는 과정이 필요하다.
  String? redirectLogic(BuildContext context, GoRouterState state) {
    final UserModelBase? user = ref.read(userMeProvider);

    // 현재 위치가 로그인 스크린인가?
    final logginIn = state.location == '/login';

    // 유저 정보가 없는데
    // 로그인중이면 그대로 로그인 페이지에 두고
    // 만약에 로그인중이 아니라면 로그인 페이지로 이동
    if (user == null) {
      return logginIn ? null : '/login';
    }

    //user가 null이 아님

    // UserModel
    // 사용자 정보가 있는 상태면
    // 로그인 중이거나 현재 위치가 SplashScreen이면
    // 홈으로 이동
    if (user is UserModel) {
      return logginIn || state.location == '/splash' ? '/' : null;
    }

    // UserModelError
    // 로그인 페이지가 아닌 다른 페이지에서 error가 발생했으면 로그인 페이지로 이동
    // 로그인 페이지에서 UserModelError이면 null 리턴
    if (user is UserModelError) {
      return !logginIn ? '/login' : null;
    }

    return null;
  }
}
