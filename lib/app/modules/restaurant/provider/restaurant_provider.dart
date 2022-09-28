import 'package:flutter_delivery/app/common/model/cursor_pagination_model.dart';
import 'package:flutter_delivery/app/common/model/pagination_params.dart';
import 'package:flutter_delivery/app/modules/restaurant/model/restaurant_model.dart';
import 'package:flutter_delivery/app/modules/restaurant/repository/restaurant_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// restaurantProvider에 이미 있는 데이터를 가져와서 보여준다.
final restaurantDetailProvider = Provider.family<RestaurantModel?, String>((ref, id) {
  final state = ref.watch(restaurantProvider);

  // 리스트가 없는 경우
  if(state is! CursorPagination){
    return null;
  }

  return state.data.firstWhere((element) => element.id == id);
});

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>((ref) {
  final repository = ref.watch(restaurantRepositoryProvider);
  final notifier = RestaurantStateNotifier(repository: repository);
  return notifier;
});

// 처음은 로딩 상태이므로 초기를 Loading으로
class RestaurantStateNotifier extends StateNotifier<CursorPaginationBase> {
  RestaurantStateNotifier({required this.repository})
      : super(CursorPaginationLoading()) {
    paginate();
  }

  final RestaurantRepository repository;

  Future<void> paginate({
    int fetchCount = 20,
    // true : 추가로 데이터 가져오기, false : 새로고침
    bool fetchMore = false,
    // 강제로 다시 로딩하기
    // true : CursorPaginationLoading()
    bool forceRefetch = false,
  }) async {
    try {
      // 5가지 가능성
      // state의 상태
      // 1) CursorPagination - 정상적으로 데이터가 있는 상태
      // 2) CursorPaginationLoading - 데이터가 로딩중인 상태 (현재 캐시 없음)
      // 3) CursorPaginationError - 에러가 있는 상태
      // 4) CursorPaginationRefetching - 첫번째 페이지부터 다시 데이터를 가져올때
      // 5) CursorPaginationFetchMore - 추가 데이터를 paginate 해오라는 요청을 받았을 때

      // 바로 반환하는 상황
      // 1) hasMore가 false일때(기존 상태에서 이미 다음 데이터가 없나는 값을 들고있다면)
      // 2) 로딩중 - fetchMore : true
      //    fetchMore가 아닐때 - 새로고침의 의도가 있다.
      if(state is CursorPagination && !forceRefetch){
        final pState = state as CursorPagination;

        if(!pState.meta.hasMore) return;
      }

      final isLoading = state is CursorPaginationLoading;
      final isRefetching = state is CursorPaginationRefetching;
      final isFetchingMore = state is CursorPaginationFetchingMore;

      // 2번 반환 상황
      if(fetchMore && (isLoading || isRefetching || isFetchingMore)) return;

      // PaginationParams 생성
      PaginationParams paginationParams = PaginationParams(count: fetchCount);

      // fetchMore
      // 데이터를 추가로 더 가져오는 상황
      if(fetchMore){
        final pState = state as CursorPagination;

        state = CursorPaginationFetchingMore(meta: pState.meta, data: pState.data);

        paginationParams = paginationParams.copyWith(after: pState.data.last.id);
      } else {
        // 데이터를 처음부터 가져오는 상황
        // 만약에 데이터가 있는 상황이라면 기존 데이터를 보존한채로 Fetch(API 요청)를 진행
        if(state is CursorPagination && !forceRefetch){
          final pState = state as CursorPagination;

          state = CursorPaginationRefetching(meta: pState.meta, data: pState.data);
        } else {
          // 나머지 상황
          state = CursorPaginationLoading();
        }
      }

      final resp = await repository.paginate(paginationParams: paginationParams);

      if(state is CursorPaginationFetchingMore) {
        final pState = state as CursorPaginationFetchingMore;

        // 기존 데이터에 새로운 데이터 추가
        state = resp.copyWith(data: [...pState.data, ...resp.data]);
      } else {
        state = resp;
      }
    } catch(e){
      state = CursorPaginationError(message: '데이터를 가져오지 못했습니다.');
    }
  }

  void getDetail({required String id}) async {
    // 만약에 아직 데이터가 하나도 없는 상태라면 (CursorPagination이 아니라면)
    // 데이터를 가져오는 시도를 한다.
    if(state is! CursorPagination){
      await paginate();
    }

    // state가 CursorPagination이 아닐때 그냥 리턴
    if(state is! CursorPagination){
      return;
    }

    final pState = state as CursorPagination;

    final resp = await repository.getRestaurantDetail(id: id);

    // 요청한 모델만 detail로 변경
    // [RestaurantModel(1), RestaurantModel(2), RestaurantModel(3)]
    // id : 2인 친구를 detail로 변경
    // getDetail(id : 2);
    // [RestaurantModel(1), RestaurantDetailModel(2), RestaurantModel(3)]
    state = pState.copyWith(
      data: pState.data.map<RestaurantModel>((e) => e.id == id ? resp : e).toList(),
    );
  }
}
