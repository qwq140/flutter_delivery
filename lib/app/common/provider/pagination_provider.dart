import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter_delivery/app/common/model/cursor_pagination_model.dart';
import 'package:flutter_delivery/app/common/model/model_with_id.dart';
import 'package:flutter_delivery/app/common/model/pagination_params.dart';
import 'package:flutter_delivery/app/common/repository/base_pagination_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _PaginationInfo {
  final int fetchCount;
  // true : 추가로 데이터 가져오기, false : 새로고침
  final bool fetchMore;
  // 강제로 다시 로딩하기
  // true : CursorPaginationLoading()
  final bool forceRefetch;

  _PaginationInfo({
    this.fetchCount = 20,
    this.fetchMore = false,
    this.forceRefetch = false,
  });

}

class PaginationProvider<T extends IModelWithId, U extends IBasePaginationRepository<T>> extends StateNotifier<CursorPaginationBase> {
  final U repository;
  // checkEquality 함수 실행할때의 값이 똑같으면 실행하지 않겠다.
  final paginationThrottle = Throttle(const Duration(seconds: 3), initialValue: _PaginationInfo(), checkEquality: false);

  PaginationProvider({required this.repository}) : super(CursorPaginationLoading()){
    paginate();
    paginationThrottle.values.listen((state) {
      print('test');
      _throttlePagination(state);
    });
  }

  Future<void> paginate({
    int fetchCount = 20,
    // true : 추가로 데이터 가져오기, false : 새로고침
    bool fetchMore = false,
    // 강제로 다시 로딩하기
    // true : CursorPaginationLoading()
    bool forceRefetch = false,
  }) async {
    paginationThrottle.setValue(_PaginationInfo(fetchCount: fetchCount, fetchMore: fetchMore, forceRefetch: forceRefetch));
  }

  _throttlePagination(_PaginationInfo info) async {
    print('페이징');
    final fetchCount = info.fetchCount;
    final fetchMore = info.fetchMore;
    final forceRefetch = info.forceRefetch;
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
        final pState = state as CursorPagination<T>;

        state = CursorPaginationFetchingMore<T>(meta: pState.meta, data: pState.data);

        paginationParams = paginationParams.copyWith(after: pState.data.last.id);
      } else {
        // 데이터를 처음부터 가져오는 상황
        // 만약에 데이터가 있는 상황이라면 기존 데이터를 보존한채로 Fetch(API 요청)를 진행
        if(state is CursorPagination && !forceRefetch){
          final pState = state as CursorPagination<T>;

          state = CursorPaginationRefetching<T>(meta: pState.meta, data: pState.data);
        } else {
          // 나머지 상황
          state = CursorPaginationLoading();
        }
      }

      final resp = await repository.paginate(paginationParams: paginationParams);

      if(state is CursorPaginationFetchingMore) {
        final pState = state as CursorPaginationFetchingMore<T>;

        // 기존 데이터에 새로운 데이터 추가
        state = resp.copyWith(data: [...pState.data, ...resp.data]);
      } else {
        state = resp;
      }
    } catch(e, stack){
      print(e);
      print(stack);
      state = CursorPaginationError(message: '데이터를 가져오지 못했습니다.');
    }

  }
}