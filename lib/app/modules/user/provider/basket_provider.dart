import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter_delivery/app/modules/product/model/product_model.dart';
import 'package:flutter_delivery/app/modules/user/model/basket_item_model.dart';
import 'package:flutter_delivery/app/modules/user/model/patch_basket_body.dart';
import 'package:flutter_delivery/app/modules/user/repository/user_me_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

final basketProvider =
    StateNotifierProvider<BasketNotifier, List<BasketItemModel>>((ref) {
  final repository = ref.watch(userMeRepositoryProvider);
  return BasketNotifier(repository: repository);
});

class BasketNotifier extends StateNotifier<List<BasketItemModel>> {
  final UserMeRepository repository;
  final updateBasketDebounce = Debouncer(const Duration(seconds: 1), initialValue: null, checkEquality: false);

  BasketNotifier({required this.repository}) : super([]){
    updateBasketDebounce.values.listen((event) {
      patchBasket();
    });
  }

  Future<void> patchBasket() async {
    await repository.patchBasket(
      body: PatchBasketBody(
        basket: state
            .map(
              (e) => PatchBasketBodyBasket(
                  productId: e.product.id, count: e.count),
            )
            .toList(),
      ),
    );
  }

  Future addToBasket({required ProductModel product}) async {
    // 요청을 먼저 보내고
    // 응답이 오면
    // 캐시를 업데이트 했다.
    // 이 경우 사용자가 앱이 느리다고 느낄 수 있다.
    // 에러가 날때 치명적인 에러인가?
    // 결제창에서 다시 유저가 확인할 것이므로 치명적이지 않는 에러일 것이다.
    // 사용자가 느리다고 느끼지 않게 하기 위해 상태를 먼저 업데이트하고 통신을 한다.

    // 1) 아직 장바구니에 해당되는 상품이 없다면
    //    장바구니에 상품을 추가한다.
    // 2) 만약에 이미 들어있다면
    //    장바구니에 있는 값에 +1을 한다.
    final exists =
        state.firstWhereOrNull((e) => e.product.id == product.id) != null;

    if (exists) {
      state = state
          .map((e) =>
              e.product.id == product.id ? e.copyWith(count: e.count + 1) : e)
          .toList();
    } else {
      state = [
        ...state,
        BasketItemModel(product: product, count: 1),
      ];
    }
    // Optimistic Response (긍정적 응답)
    // 응답이 성공할거라고 가정하고 상태를 먼저 업데이트함
    updateBasketDebounce.setValue(null);
  }

  Future removeFromBasket({
    required ProductModel product,
    // count와 관계없이 완전히 삭제
    bool isDelete = false,
  }) async {
    // 1) 장바구니에 상품이 존재할 때
    //    1) 상품의 count가 1보다 크면 -1한다.
    //    2) 상품의 count가 1이면 삭제한다.
    // 2) 장바구니에 상품이 존재하지 않을때
    //    즉시 함수를 반환하고 아무것도 하지 않는다.
    final exists =
        state.firstWhereOrNull((e) => e.product.id == product.id) != null;

    if (!exists) return;

    final existingProduct = state.firstWhere((e) => e.product.id == product.id);

    if (existingProduct.count == 1 || isDelete) {
      state = state.where((e) => e.product.id != product.id).toList();
    } else {
      state = state
          .map((e) =>
              e.product.id == product.id ? e.copyWith(count: e.count - 1) : e)
          .toList();
    }
    updateBasketDebounce.setValue(null);
  }
}
