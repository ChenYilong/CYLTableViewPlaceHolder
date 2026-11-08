#import "UITableView+CYLPlaceholder.h"
#import "UICollectionView+CYLPlaceholder.h"
#import <objc/runtime.h>

typedef UIView * _Nullable (^CYLPlaceholderProvider)(UIScrollView *);
typedef void (^CYLPlaceholderRestore)(UIScrollView *);

@interface CYLPlaceholderController : NSObject
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, copy) CYLPlaceholderProvider provider;
@property (nonatomic, copy) CYLPlaceholderRestore restore;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, copy) NSArray<NSLayoutConstraint *> *constraints;
@property (nonatomic) NSUInteger batchDepth;
@property (nonatomic) NSUInteger batchCallDepth;
@property (nonatomic) BOOL scheduled;
@property (nonatomic) NSUInteger generation;
- (void)scheduleUpdate;
- (void)removeView;
@end

static const void *CYLPlaceholderControllerKey = &CYLPlaceholderControllerKey;

static CYLPlaceholderController *CYLController(UIScrollView *scrollView) {
    return objc_getAssociatedObject(scrollView, CYLPlaceholderControllerKey);
}

@implementation CYLPlaceholderController

- (void)removeView {
    if (!self.view) return;
    [NSLayoutConstraint deactivateConstraints:self.constraints];
    self.constraints = nil;
    [self.view removeFromSuperview];
    self.view = nil;
    if (self.restore && self.scrollView) self.restore(self.scrollView);
}

- (BOOL)isEmpty {
    UIScrollView *scrollView = self.scrollView;
    if ([scrollView isKindOfClass:UITableView.class]) {
        UITableView *table = (UITableView *)scrollView;
        id<UITableViewDataSource> source = table.dataSource;
        if (!source) return NO;
        NSInteger sections = [source respondsToSelector:@selector(numberOfSectionsInTableView:)] ?
            [source numberOfSectionsInTableView:table] : 1;
        for (NSInteger section = 0; section < sections; section++) {
            if ([source tableView:table numberOfRowsInSection:section] > 0) return NO;
        }
    } else {
        UICollectionView *collection = (UICollectionView *)scrollView;
        id<UICollectionViewDataSource> source = collection.dataSource;
        if (!source) return NO;
        NSInteger sections = [source respondsToSelector:@selector(numberOfSectionsInCollectionView:)] ?
            [source numberOfSectionsInCollectionView:collection] : 1;
        for (NSInteger section = 0; section < sections; section++) {
            if ([source collectionView:collection numberOfItemsInSection:section] > 0) return NO;
        }
    }
    return YES;
}

- (void)scheduleUpdate {
    if (!self.provider || self.scheduled || self.batchDepth) return;
    self.scheduled = YES;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        CYLPlaceholderController *controller = weakSelf;
        controller.scheduled = NO;
        UIScrollView *scrollView = controller.scrollView;
        if (!controller.provider || !scrollView || controller.batchDepth) return;
        if (![controller isEmpty]) {
            [controller removeView];
            return;
        }
        NSUInteger generation = controller.generation;
        UIView *view = controller.provider(scrollView);
        if (generation != controller.generation || !controller.provider) return;
        if (!view || view == scrollView || [scrollView isDescendantOfView:view]) {
            NSLog(@"CYLTableViewPlaceHolder: placeholder block must return a valid view.");
            [controller removeView];
            return;
        }
        if (view != controller.view) {
            [NSLayoutConstraint deactivateConstraints:controller.constraints];
            [controller.view removeFromSuperview];
            controller.view = view;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [scrollView addSubview:view];
            UILayoutGuide *frame = scrollView.frameLayoutGuide;
            controller.constraints = @[
                [view.leadingAnchor constraintEqualToAnchor:frame.leadingAnchor],
                [view.trailingAnchor constraintEqualToAnchor:frame.trailingAnchor],
                [view.topAnchor constraintEqualToAnchor:frame.topAnchor],
                [view.bottomAnchor constraintEqualToAnchor:frame.bottomAnchor]
            ];
            [NSLayoutConstraint activateConstraints:controller.constraints];
        }
        [scrollView bringSubviewToFront:view];
    });
}
@end

static void CYLInstallPlaceholder(UIScrollView *scrollView, CYLPlaceholderProvider provider,
                                  CYLPlaceholderRestore restore) {
    NSCAssert(NSThread.isMainThread, @"Placeholder configuration must run on the main thread.");
    CYLPlaceholderController *controller = CYLController(scrollView);
    if (!controller && !provider) return;
    if (!controller) {
        controller = [CYLPlaceholderController new];
        controller.scrollView = scrollView;
        objc_setAssociatedObject(scrollView, CYLPlaceholderControllerKey, controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSUInteger generation = ++controller.generation;
    [controller removeView];
    if (controller.generation != generation) return;
    controller.provider = provider;
    controller.restore = restore;
    [controller scheduleUpdate];
}

static void CYLSwizzle(Class cls, SEL original, SEL replacement) {
    Method oldMethod = class_getInstanceMethod(cls, original);
    Method newMethod = class_getInstanceMethod(cls, replacement);
    if (!oldMethod || !newMethod) return;
    if (class_addMethod(cls, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(cls, replacement, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
    } else {
        method_exchangeImplementations(oldMethod, newMethod);
    }
}

@interface UITableView (CYLLegacyPlaceholderInternal)
- (void)cyl_removeLegacyPlaceholder;
@end

@implementation UITableView (CYLPlaceholder)

+ (void)load {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        SEL selectors[] = {
            @selector(reloadData), @selector(setDataSource:),
            @selector(beginUpdates), @selector(endUpdates),
            @selector(insertSections:withRowAnimation:), @selector(deleteSections:withRowAnimation:),
            @selector(reloadSections:withRowAnimation:), @selector(moveSection:toSection:),
            @selector(insertRowsAtIndexPaths:withRowAnimation:), @selector(deleteRowsAtIndexPaths:withRowAnimation:),
            @selector(reloadRowsAtIndexPaths:withRowAnimation:), @selector(moveRowAtIndexPath:toIndexPath:),
            @selector(performBatchUpdates:completion:), NSSelectorFromString(@"reconfigureRowsAtIndexPaths:")
        };
        SEL replacements[] = {
            @selector(cyl_ph_reloadData), @selector(cyl_ph_setDataSource:),
            @selector(cyl_ph_beginUpdates), @selector(cyl_ph_endUpdates),
            @selector(cyl_ph_insertSections:withRowAnimation:), @selector(cyl_ph_deleteSections:withRowAnimation:),
            @selector(cyl_ph_reloadSections:withRowAnimation:), @selector(cyl_ph_moveSection:toSection:),
            @selector(cyl_ph_insertRowsAtIndexPaths:withRowAnimation:), @selector(cyl_ph_deleteRowsAtIndexPaths:withRowAnimation:),
            @selector(cyl_ph_reloadRowsAtIndexPaths:withRowAnimation:), @selector(cyl_ph_moveRowAtIndexPath:toIndexPath:),
            @selector(cyl_ph_performBatchUpdates:completion:), @selector(cyl_ph_reconfigureRowsAtIndexPaths:)
        };
        for (NSUInteger i = 0; i < sizeof(selectors) / sizeof(SEL); i++) CYLSwizzle(self, selectors[i], replacements[i]);
    });
}

- (void)cyl_placeholderViewBlock:(CYLTablePlaceholderViewBlock)block {
    [self cyl_placeholderViewBlock:block backToNormalBlock:nil];
}
- (void)cyl_placeholderViewBlock:(CYLTablePlaceholderViewBlock)block
               backToNormalBlock:(CYLTablePlaceholderNormalBlock)restore {
    if (block) [self cyl_removeLegacyPlaceholder];
    CYLPlaceholderProvider provider = block ? ^UIView *(UIScrollView *view) { return block((UITableView *)view); } : nil;
    CYLPlaceholderRestore normal = restore ? ^(UIScrollView *view) { restore((UITableView *)view); } : nil;
    CYLInstallPlaceholder(self, provider, normal);
}
- (void)cyl_ph_reloadData { [self cyl_ph_reloadData]; [CYLController(self) scheduleUpdate]; }
- (void)cyl_ph_setDataSource:(id<UITableViewDataSource>)source { [self cyl_ph_setDataSource:source]; [CYLController(self) scheduleUpdate]; }
- (void)cyl_ph_beginUpdates {
    [self cyl_ph_beginUpdates];
    CYLPlaceholderController *controller = CYLController(self);
    if (!controller.batchCallDepth) controller.batchDepth++;
}
- (void)cyl_ph_endUpdates {
    [self cyl_ph_endUpdates];
    CYLPlaceholderController *controller = CYLController(self);
    if (!controller.batchCallDepth && controller.batchDepth) controller.batchDepth--;
    [controller scheduleUpdate];
}
#define CYL_TABLE_ANIMATED(method, type, name) \
- (void)cyl_ph_##method:(type)value withRowAnimation:(UITableViewRowAnimation)animation { \
    [self cyl_ph_##method:value withRowAnimation:animation]; [CYLController(self) scheduleUpdate]; \
}
CYL_TABLE_ANIMATED(insertSections, NSIndexSet *, sections)
CYL_TABLE_ANIMATED(deleteSections, NSIndexSet *, sections)
CYL_TABLE_ANIMATED(reloadSections, NSIndexSet *, sections)
CYL_TABLE_ANIMATED(insertRowsAtIndexPaths, NSArray<NSIndexPath *> *, paths)
CYL_TABLE_ANIMATED(deleteRowsAtIndexPaths, NSArray<NSIndexPath *> *, paths)
CYL_TABLE_ANIMATED(reloadRowsAtIndexPaths, NSArray<NSIndexPath *> *, paths)
#undef CYL_TABLE_ANIMATED
- (void)cyl_ph_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    [self cyl_ph_moveSection:section toSection:newSection]; [CYLController(self) scheduleUpdate];
}
- (void)cyl_ph_moveRowAtIndexPath:(NSIndexPath *)path toIndexPath:(NSIndexPath *)newPath {
    [self cyl_ph_moveRowAtIndexPath:path toIndexPath:newPath]; [CYLController(self) scheduleUpdate];
}
- (void)cyl_ph_reconfigureRowsAtIndexPaths:(NSArray<NSIndexPath *> *)paths {
    [self cyl_ph_reconfigureRowsAtIndexPaths:paths]; [CYLController(self) scheduleUpdate];
}
- (void)cyl_ph_performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion {
    if (!CYLController(self).provider) {
        [self cyl_ph_performBatchUpdates:updates completion:completion];
        return;
    }
    __weak typeof(self) weakSelf = self;
    void (^wrappedUpdates)(void) = updates ? ^{
        CYLPlaceholderController *controller = CYLController(weakSelf);
        controller.batchDepth++;
        @try { updates(); }
        @finally {
            if (controller.batchDepth) controller.batchDepth--;
            [controller scheduleUpdate];
        }
    } : nil;
    CYLPlaceholderController *controller = CYLController(self);
    controller.batchCallDepth++;
    @try {
        [self cyl_ph_performBatchUpdates:wrappedUpdates completion:^(BOOL finished) {
            if (completion) completion(finished);
            [CYLController(weakSelf) scheduleUpdate];
        }];
    } @finally {
        controller.batchCallDepth--;
    }
    [CYLController(self) scheduleUpdate];
}
@end

@implementation UICollectionView (CYLPlaceholder)
+ (void)load {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        SEL selectors[] = {
            @selector(reloadData), @selector(setDataSource:), @selector(insertSections:),
            @selector(deleteSections:), @selector(reloadSections:), @selector(moveSection:toSection:),
            @selector(insertItemsAtIndexPaths:), @selector(deleteItemsAtIndexPaths:),
            @selector(reloadItemsAtIndexPaths:), @selector(moveItemAtIndexPath:toIndexPath:),
            @selector(performBatchUpdates:completion:), NSSelectorFromString(@"reconfigureItemsAtIndexPaths:")
        };
        SEL replacements[] = {
            @selector(cyl_ph_reloadData), @selector(cyl_ph_setDataSource:), @selector(cyl_ph_insertSections:),
            @selector(cyl_ph_deleteSections:), @selector(cyl_ph_reloadSections:), @selector(cyl_ph_moveSection:toSection:),
            @selector(cyl_ph_insertItemsAtIndexPaths:), @selector(cyl_ph_deleteItemsAtIndexPaths:),
            @selector(cyl_ph_reloadItemsAtIndexPaths:), @selector(cyl_ph_moveItemAtIndexPath:toIndexPath:),
            @selector(cyl_ph_performBatchUpdates:completion:), @selector(cyl_ph_reconfigureItemsAtIndexPaths:)
        };
        for (NSUInteger i = 0; i < sizeof(selectors) / sizeof(SEL); i++) CYLSwizzle(self, selectors[i], replacements[i]);
    });
}
- (void)cyl_placeholderViewBlock:(CYLCollectionPlaceholderViewBlock)block {
    [self cyl_placeholderViewBlock:block backToNormalBlock:nil];
}
- (void)cyl_placeholderViewBlock:(CYLCollectionPlaceholderViewBlock)block
               backToNormalBlock:(CYLCollectionPlaceholderNormalBlock)restore {
    CYLPlaceholderProvider provider = block ? ^UIView *(UIScrollView *view) { return block((UICollectionView *)view); } : nil;
    CYLPlaceholderRestore normal = restore ? ^(UIScrollView *view) { restore((UICollectionView *)view); } : nil;
    CYLInstallPlaceholder(self, provider, normal);
}
- (void)cyl_ph_reloadData { [self cyl_ph_reloadData]; [CYLController(self) scheduleUpdate]; }
- (void)cyl_ph_setDataSource:(id<UICollectionViewDataSource>)source { [self cyl_ph_setDataSource:source]; [CYLController(self) scheduleUpdate]; }
#define CYL_COLLECTION_UPDATE(method, type) \
- (void)cyl_ph_##method:(type)value { [self cyl_ph_##method:value]; [CYLController(self) scheduleUpdate]; }
CYL_COLLECTION_UPDATE(insertSections, NSIndexSet *)
CYL_COLLECTION_UPDATE(deleteSections, NSIndexSet *)
CYL_COLLECTION_UPDATE(reloadSections, NSIndexSet *)
CYL_COLLECTION_UPDATE(insertItemsAtIndexPaths, NSArray<NSIndexPath *> *)
CYL_COLLECTION_UPDATE(deleteItemsAtIndexPaths, NSArray<NSIndexPath *> *)
CYL_COLLECTION_UPDATE(reloadItemsAtIndexPaths, NSArray<NSIndexPath *> *)
CYL_COLLECTION_UPDATE(reconfigureItemsAtIndexPaths, NSArray<NSIndexPath *> *)
#undef CYL_COLLECTION_UPDATE
- (void)cyl_ph_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    [self cyl_ph_moveSection:section toSection:newSection]; [CYLController(self) scheduleUpdate];
}
- (void)cyl_ph_moveItemAtIndexPath:(NSIndexPath *)path toIndexPath:(NSIndexPath *)newPath {
    [self cyl_ph_moveItemAtIndexPath:path toIndexPath:newPath]; [CYLController(self) scheduleUpdate];
}
- (void)cyl_ph_performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion {
    if (!CYLController(self).provider) {
        [self cyl_ph_performBatchUpdates:updates completion:completion];
        return;
    }
    __weak typeof(self) weakSelf = self;
    void (^wrappedUpdates)(void) = updates ? ^{
        CYLPlaceholderController *controller = CYLController(weakSelf);
        controller.batchDepth++;
        @try { updates(); }
        @finally {
            if (controller.batchDepth) controller.batchDepth--;
            [controller scheduleUpdate];
        }
    } : nil;
    [self cyl_ph_performBatchUpdates:wrappedUpdates completion:^(BOOL finished) {
        if (completion) completion(finished);
        [CYLController(weakSelf) scheduleUpdate];
    }];
    [CYLController(self) scheduleUpdate];
}
@end

BOOL CYLAutomaticPlaceholderEnabled(UIScrollView *scrollView) {
    return CYLController(scrollView).provider != nil;
}
