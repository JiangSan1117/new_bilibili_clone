// lib/widgets/lazy_load_list.dart

import 'package:flutter/material.dart';
import '../services/performance_service.dart';

class LazyLoadList<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) loadData;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int pageSize;
  final String cacheKey;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;

  const LazyLoadList({
    super.key,
    required this.loadData,
    required this.itemBuilder,
    required this.cacheKey,
    this.pageSize = 20,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  @override
  State<LazyLoadList<T>> createState() => _LazyLoadListState<T>();
}

class _LazyLoadListState<T> extends State<LazyLoadList<T>> {
  final List<T> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadData(0);
  }

  Future<void> _loadData(int page) async {
    if (_isLoading || (!_hasMore && page > 0)) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      PerformanceService.startTimer('lazy_load_${widget.cacheKey}_page_$page');
      
      final newItems = await widget.loadData(page, widget.pageSize);
      
      setState(() {
        if (page == 0) {
          _items.clear();
        }
        _items.addAll(newItems);
        _hasMore = newItems.length == widget.pageSize;
        _currentPage = page;
      });
      
      PerformanceService.stopTimer('lazy_load_${widget.cacheKey}_page_$page');
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;
    await _loadData(_currentPage + 1);
  }

  Future<void> _refresh() async {
    await _loadInitialData();
  }

  Widget _buildListItem(BuildContext context, int index) {
    if (index < _items.length) {
      return widget.itemBuilder(context, _items[index], index);
    }
    
    // 加載更多指示器
    if (_hasMore) {
      return _buildLoadMoreIndicator();
    }
    
    return _buildEndIndicator();
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEndIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          '沒有更多內容了',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return widget.emptyWidget ?? const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '暫無內容',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ?? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? '載入失敗',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refresh,
            child: const Text('重試'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _items.isEmpty) {
      return _buildErrorWidget();
    }

    if (!_isLoading && _items.isEmpty) {
      return _buildEmptyWidget();
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: widget.controller,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length - 5 && _hasMore && !_isLoading) {
            // 預先加載更多數據
            _loadMore();
          }
          
          return _buildListItem(context, index);
        },
      ),
    );
  }
}

// 懶加載網格組件
class LazyLoadGrid<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) loadData;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int crossAxisCount;
  final int pageSize;
  final String cacheKey;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;

  const LazyLoadGrid({
    super.key,
    required this.loadData,
    required this.itemBuilder,
    required this.cacheKey,
    required this.crossAxisCount,
    this.pageSize = 20,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  @override
  State<LazyLoadGrid<T>> createState() => _LazyLoadGridState<T>();
}

class _LazyLoadGridState<T> extends State<LazyLoadGrid<T>> {
  final List<T> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadData(0);
  }

  Future<void> _loadData(int page) async {
    if (_isLoading || (!_hasMore && page > 0)) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      PerformanceService.startTimer('lazy_load_grid_${widget.cacheKey}_page_$page');
      
      final newItems = await widget.loadData(page, widget.pageSize);
      
      setState(() {
        if (page == 0) {
          _items.clear();
        }
        _items.addAll(newItems);
        _hasMore = newItems.length == widget.pageSize;
        _currentPage = page;
      });
      
      PerformanceService.stopTimer('lazy_load_grid_${widget.cacheKey}_page_$page');
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;
    await _loadData(_currentPage + 1);
  }

  Future<void> _refresh() async {
    await _loadInitialData();
  }

  Widget _buildGridItem(BuildContext context, int index) {
    if (index < _items.length) {
      return widget.itemBuilder(context, _items[index], index);
    }
    
    // 加載更多指示器
    if (_hasMore) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return const Center(
      child: Text(
        '沒有更多內容了',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return widget.emptyWidget ?? const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grid_view,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '暫無內容',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ?? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? '載入失敗',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refresh,
            child: const Text('重試'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _items.isEmpty) {
      return _buildErrorWidget();
    }

    if (!_isLoading && _items.isEmpty) {
      return _buildEmptyWidget();
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: GridView.builder(
        controller: widget.controller,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          childAspectRatio: widget.childAspectRatio ?? 1.0,
          crossAxisSpacing: widget.crossAxisSpacing ?? 0.0,
          mainAxisSpacing: widget.mainAxisSpacing ?? 0.0,
        ),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length - (widget.crossAxisCount * 2) && _hasMore && !_isLoading) {
            // 預先加載更多數據
            _loadMore();
          }
          
          return _buildGridItem(context, index);
        },
      ),
    );
  }
}
