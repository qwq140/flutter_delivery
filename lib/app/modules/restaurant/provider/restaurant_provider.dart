import 'package:flutter_delivery/app/modules/restaurant/model/restaurant_model.dart';
import 'package:flutter_delivery/app/modules/restaurant/repository/restaurant_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final restaurantProvider = StateNotifierProvider<RestaurantStateNotifier, List<RestaurantModel>>((ref) {
  final repository = ref.watch(restaurantRepositoryProvider);
  final notifier = RestaurantStateNotifier(repository: repository);
  return notifier;
});

class RestaurantStateNotifier extends StateNotifier<List<RestaurantModel>> {
  RestaurantStateNotifier({required this.repository}) : super([]){
    paginate();
  }

  final RestaurantRepository repository;

  paginate() async {
    final resp = await repository.paginate();

    state = resp.data;
  }
}