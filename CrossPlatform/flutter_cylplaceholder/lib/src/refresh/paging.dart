import 'package:flutter/foundation.dart';

import 'component.dart';

/// Hands a page's result back to a [CYLRefreshPaging]: the page's [items] (null on an error), the [total] number of
/// items and of pages ([totalPage]) when the server tells them (0 otherwise), and an [error] or null.
typedef CYLRefreshPagingCompletion<T> = void Function(List<T>? items, {int total, int totalPage, Object? error});

/// Loads one page for a [CYLRefreshPaging].
typedef CYLRefreshPagingLoader<T> = void Function(int page, CYLRefreshPagingCompletion<T> completion);

/// Pages a list through a header and a footer: the header reloads the first page, the footer loads the next one, and
/// the footer shows "no more data" at the end. A failed page changes nothing: a retry loads the same page again.
class CYLRefreshPaging<T> extends ChangeNotifier {
  /// Connects [header] and [footer] (both optional) to [loader].
  CYLRefreshPaging({this.header, this.footer, required this.loader}) {
    header?.refreshingHandler = () => _load(firstPage);
    footer?.refreshingHandler = () => _load(_page + 1);
  }

  /// The header that refreshes, or null.
  final CYLRefreshHeader? header;

  /// The footer that loads more, or null.
  final CYLRefreshFooter? footer;

  /// Loads one page.
  final CYLRefreshPagingLoader<T> loader;

  /// The first page's number.
  int firstPage = 1;

  /// True: a refresh clears the footer's "no more data".
  bool resetsFooterAfterRefresh = true;

  /// Called after the items change.
  void Function(CYLRefreshPaging<T> paging)? itemsDidChange;

  List<T>? _items;
  int _page = 0;
  int _total = 0;
  int _totalPage = 0;
  bool _noMore = false;
  bool _loading = false;
  Object? _error;

  /// The items loaded so far, or null before the first page.
  List<T>? get items => _items;

  /// How many items are loaded.
  int get count => _items?.length ?? 0;

  /// The last page loaded.
  int get page => _page;

  /// The total number of items, 0 when unknown.
  int get total => _total;

  /// The total number of pages, 0 when unknown.
  int get totalPage => _totalPage;

  /// Whether a page was loaded and there are no items.
  bool get isEmpty => _items != null && count == 0;

  /// Whether the last page is loaded.
  bool get isNoMore => _noMore;

  /// The error of the last page, or null when it succeeded.
  Object? get error => _error;

  /// Loads the first page, through the header when there is one.
  void start() => refresh();

  /// Reloads the first page.
  void refresh() {
    final header = this.header;
    if (header != null) {
      header.beginRefreshing();
    } else {
      _load(firstPage);
    }
  }

  /// Loads the next page; nothing after the last one.
  void loadMore() {
    if (_noMore) return;
    final footer = this.footer;
    if (footer != null) {
      footer.beginRefreshing();
    } else {
      _load(_page + 1);
    }
  }

  void _load(int requested) {
    if (_loading) return;
    _loading = true;
    final refreshing = requested == firstPage;
    loader(requested, (loaded, {int total = 0, int totalPage = 0, Object? error}) {
      _loading = false;
      _error = error;
      if (error == null) {
        _page = requested;
        _total = total;
        _totalPage = totalPage;
        _items = refreshing ? List<T>.of(loaded ?? const []) : [...?_items, ...?loaded];
        if (totalPage > 0) {
          _noMore = _page >= firstPage + totalPage - 1;
        } else if (total > 0) {
          _noMore = count >= total;
        } else {
          _noMore = loaded == null || loaded.isEmpty;
        }
        itemsDidChange?.call(this);
      }
      notifyListeners();
      if (refreshing) {
        header?.endRefreshing(success: error == null);
        if (error == null) {
          if (_noMore) {
            footer?.noticeNoMoreData();
          } else if (resetsFooterAfterRefresh) {
            footer?.resetNoMoreData();
          }
        }
      } else if (error == null && _noMore) {
        footer?.endRefreshingWithNoMoreData();
      } else {
        footer?.endRefreshing(success: error == null);
      }
    });
  }
}
