//
//  CYLRefreshPaging.m
//  CYLRefresh
//
//  The request rules follow flutter_easy_refresh's easy_paging (https://github.com/xuelongqy/flutter_easy_refresh, MIT).
//

#import "CYLRefreshPaging.h"
#import "CYLRefreshHeader.h"
#import "CYLRefreshFooter.h"

@interface CYLRefreshPaging ()
@property (copy, nonatomic) CYLRefreshPagingLoader loader;
@property (copy, nonatomic, readwrite, nullable) NSArray *items;
@property (nonatomic, readwrite) NSInteger page;
@property (nonatomic, readwrite) NSInteger total;
@property (nonatomic, readwrite) NSInteger totalPage;
/// [EN] Increases with every refresh, so a load that started before it is ignored. [CN] 每次刷新递增，刷新前开始的加载结果会被忽略。
@property (nonatomic) NSUInteger generation;
@end

@implementation CYLRefreshPaging

- (instancetype)initWithHeader:(CYLRefreshHeader *)header footer:(CYLRefreshFooter *)footer loader:(CYLRefreshPagingLoader)loader
{
    if (self = [super init]) {
        _header = header;
        _footer = footer;
        _loader = [loader copy];
        _firstPage = 1;
        _page = NSNotFound;
        _total = NSNotFound;
        _totalPage = NSNotFound;
        _resetsFooterAfterRefresh = YES;
        __weak typeof(self) weakSelf = self;
        header.refreshingBlock = ^{ [weakSelf refresh]; };
        footer.refreshingBlock = ^{ [weakSelf loadMore]; };
    }
    return self;
}

- (NSInteger)count
{
    return (NSInteger)self.items.count;
}

- (BOOL)isEmpty
{
    return self.items != nil && self.items.count == 0;
}

- (BOOL)isNoMore
{
    if (!self.items) return NO;
    if (self.total != NSNotFound) return self.count >= self.total;
    if (self.page != NSNotFound && self.totalPage != NSNotFound) return self.page >= self.totalPage;
    return NO;
}

- (void)start
{
    if (self.header) {
        [self.header beginRefreshing];
    } else {
        [self refresh];
    }
}

- (void)refresh
{
    NSUInteger generation = ++self.generation;
    NSInteger page = self.firstPage;
    __weak typeof(self) weakSelf = self;
    self.loader(page, ^(NSArray *items, NSInteger total, NSInteger totalPage, NSError *error) {
        [weakSelf cyl_onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self || generation != self.generation) return;
            if (error) {
                // [EN] A failed refresh keeps the items and the footer as they were. [CN] 刷新失败时保持条目与刷新尾不变。
                [self.header endRefreshingWithSuccess:NO];
                return;
            }
            self.items = items ?: @[];
            self.page = page;
            self.total = total;
            self.totalPage = totalPage;
            [self cyl_itemsChanged];
            [self.header endRefreshingWithSuccess:YES];
            if (self.resetsFooterAfterRefresh && self.footer.state == CYLRefreshStateNoMoreData) [self.footer resetNoMoreData];
            [self cyl_updateFooter];
        }];
    });
}

- (void)loadMore
{
    NSUInteger generation = self.generation;
    NSInteger page = self.page == NSNotFound ? self.firstPage : self.page + 1;
    __weak typeof(self) weakSelf = self;
    self.loader(page, ^(NSArray *items, NSInteger total, NSInteger totalPage, NSError *error) {
        [weakSelf cyl_onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            if (generation != self.generation) {
                // [EN] A refresh replaced the items meanwhile: drop this page. [CN] 期间刷新已替换条目：丢弃这一页。
                if (self.footer.isRefreshing) [self.footer endRefreshing];
                return;
            }
            if (error) {
                // [EN] Not committed: the next load asks for the same page again. [CN] 不提交：下次加载会再次请求同一页。
                [self.footer endRefreshingWithSuccess:NO];
                return;
            }
            self.items = [(self.items ?: @[]) arrayByAddingObjectsFromArray:items ?: @[]];
            self.page = page;
            self.total = total;
            self.totalPage = totalPage;
            [self cyl_itemsChanged];
            if (self.isNoMore) {
                [self.footer endRefreshingWithNoMoreData];
            } else {
                [self.footer endRefreshingWithSuccess:YES];
            }
        }];
    });
}

/// [EN] After a refresh: report no more data, or keep the footer ready. [CN] 刷新之后：报告没有更多数据，或保持刷新尾可用。
- (void)cyl_updateFooter
{
    if (self.isNoMore && self.footer.state != CYLRefreshStateNoMoreData) [self.footer endRefreshingWithNoMoreData];
}

- (void)cyl_itemsChanged
{
    if (self.itemsDidChange) self.itemsDidChange(self);
}

- (void)cyl_onMain:(dispatch_block_t)block
{
    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@end
