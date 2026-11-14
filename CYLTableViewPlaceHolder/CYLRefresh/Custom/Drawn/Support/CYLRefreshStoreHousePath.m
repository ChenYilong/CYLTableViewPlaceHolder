//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  StoreHouse/StoreHousePath.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshStoreHousePath.h"

NSArray<NSArray<CYLRefreshStoreHouseLine *>*>* LETTERS = nil;
NSArray<NSArray<CYLRefreshStoreHouseLine *>*>* NUMBERS = nil;
NSDictionary<NSNumber*,NSArray<CYLRefreshStoreHouseLine *>*>* CODEMAP = nil;

@implementation CYLRefreshStoreHousePath

+ (void)initialize {
    LETTERS = [NSArray arrayWithObjects:
          //A
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{24,  0}", @"{1, 22}",
                                         @"{1,  22}", @"{1, 72}",
                                         @"{24,  0}", @"{47, 22}",
                                         @"{47, 22}", @"{47, 72}",
                                         @"{1,  48}", @"{47, 48}",
                                         nil]],
          //B
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,  0 }", @"{0, 72}",
                                         @"{0,  0 }", @"{37, 0}",
                                         @"{37, 0 }", @"{47, 11}",
                                         @"{47, 11}", @"{47, 26}",
                                         @"{47, 26}", @"{38, 36}",
                                         @"{38, 36}", @"{0, 36}",
                                         @"{38, 36}", @"{47, 46}",
                                         @"{47, 46}", @"{47, 61}",
                                         @"{47, 61}", @"{38, 71}",
                                         @"{37, 72}", @"{0, 72}",
                                         nil]],
          //C
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{47, 0}", @"{ 0, 0}",
                                         @"{0,  0}", @"{ 0, 72}",
                                         @"{0, 72}", @"{47, 72}",
                                         nil]],
          
          //D
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,   0}", @"{0,  72}",
                                         @"{0,   0}", @"{24,  0}",
                                         @"{24,  0}", @"{47, 22}",
                                         @"{47, 22}", @"{47, 48}",
                                         @"{47, 48}", @"{23, 72}",
                                         @"{23, 72}", @"{0,  72}",
                                         nil]],
          //E
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,  0}", @"{ 0, 72}",
                                         @"{0,  0}", @"{47,  0}",
                                         @"{0, 36}", @"{37, 36}",
                                         @"{0, 72}", @"{47, 72}",
                                         nil]],
          //F
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,  0}", @"{ 0, 72}",
                                         @"{0,  0}", @"{47,  0}",
                                         @"{0, 36}", @"{37, 36}",
                                         nil]],
          //G
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{47, 23}", @"{47,  0}",
                                         @"{47,  0}", @"{ 0,  0}",
                                         @"{0,   0}", @"{ 0, 72}",
                                         @"{0,  72}", @"{47, 72}",
                                         @"{47, 72}", @"{47, 48}",
                                         @"{47, 48}", @"{24, 48}",
                                         nil]],
          //H
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,  0}", @"{0,  72}",
                                         @"{0, 36}", @"{47, 36}",
                                         @"{47, 0}", @"{47, 72}",
                                         nil]],
          
           // I
           [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                       @"{0,  0}", @"{47,  0}",
                       @"{24, 0}", @"{24, 72}",
                       @"{0, 72}", @"{47, 72}",
               nil]],

           // J
           [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                       @"{47,  0}", @"{47, 72}",
                       @"{47, 72}", @"{24, 72}",
                       @"{24, 72}", @"{ 0, 48}",
                nil]],
          // K
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,  0}", @"{ 0, 72}",
                                         @"{47, 0}", @"{ 3, 33}",
                                         @"{3, 38}", @"{47, 72}",
                                         nil]],

          // L
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,  0}", @"{ 0, 72}",
                                         @"{0, 72}", @"{47, 72}",
                                         nil]],

          // M
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,   0}", @"{ 0, 72}",
                                         @"{0,   0}", @"{24, 23}",
                                         @"{24, 23}", @"{47,  0}",
                                         @"{47,  0}", @"{47, 72}",
                                         nil]],

          // N
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,  0}", @"{ 0, 72}",
                                         @"{0,  0}", @"{47, 72}",
                                         @"{47,72}", @"{47,  0}",
                                         nil]],

          // O
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,  0}", @"{ 0,72}",
                                         @"{0, 72}", @"{47,72}",
                                         @"{47,72}", @"{47, 0}",
                                         @"{47, 0}", @"{ 0, 0}",
                                         nil]],

          // P
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,  0}", @"{ 0, 72}",
                                         @"{0,  0}", @"{47,  0}",
                                         @"{47, 0}", @"{47, 36}",
                                         @"{47,36}", @"{ 0, 36}",
                                         nil]],

          // Q
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,   0}", @"{ 0, 72}",
                                         @"{0,  72}", @"{23, 72}",
                                         @"{23, 72}", @"{47, 48}",
                                         @"{47, 48}", @"{47,  0}",
                                         @"{47,  0}", @"{ 0,  0}",
                                         @"{24, 28}", @"{47, 71}",
                                         nil]],

          // R
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,  0}", @"{ 0, 72}",
                                         @"{0,  0}", @"{47,  0}",
                                         @"{47, 0}", @"{47, 36}",
                                         @"{47,36}", @"{ 0, 36}",
                                         @"{0, 37}", @"{47, 72}",
                                         nil]],

          // S
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{47,  0}", @"{ 0,  0}",
                                         @"{0,   0}", @"{ 0, 36}",
                                         @"{0,  36}", @"{47, 36}",
                                         @"{47, 36}", @"{47, 72}",
                                         @"{47, 72}", @"{ 0, 72}",
                                         nil]],

          // T
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0, 0}", @"{47,  0}",
                                         @"{24,0}", @"{24, 72}",
                                         nil]],

          // U
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,   0}", @"{ 0, 72}",
                                         @"{0,  72}", @"{47, 72}",
                                         @"{47, 72}", @"{47,  0}",
                                         nil]],

          // V
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,   0}", @"{24, 72}",
                                         @"{24, 72}", @"{47,  0}",
                                         nil]],

          // W
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,   0}", @"{ 0, 72}",
                                         @"{0,  72}", @"{24, 49}",
                                         @"{24, 49}", @"{47, 72}",
                                         @"{47, 72}", @"{47,  0}",
                                         nil]],

          // X
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,  0}", @"{47, 72}",
                                         @"{47, 0}", @"{ 0, 72}",
                                         nil]],

          // Y
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,   0}", @"{24, 23}",
                                         @"{47,  0}", @"{24, 23}",
                                         @"{24, 23}", @"{24, 72}",
                                         nil]],

          // Z
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                         @"{0,  0}", @"{47,  0}",
                                         @"{47, 0}", @"{ 0, 72}",
                                         @"{0, 72}", @"{47, 72}",
                                         nil]],
           nil];

    NUMBERS = [NSArray arrayWithObjects:
              // 0
           [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                          @"{0,  0}", @"{ 0, 72}",
                                          @"{0, 72}", @"{47, 72}",
                                          @"{47,72}", @"{47,  0}",
                                          @"{47, 0}", @"{ 0,  0}",
                                          nil]],
          // 1
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                          @"{24, 0}", @"{24, 72}",
                                         nil]],

          // 2
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                       @"{0,  0}", @"{47,  0}",
                                       @"{47, 0}", @"{47, 36}",
                                       @"{47,36}", @"{ 0, 36}",
                                       @"{0, 36}", @"{ 0, 72}",
                                       @"{0, 72}", @"{47, 72}",
                                       nil]],

          // 3
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                       @"{0,   0}", @"{47,  0}",
                                       @"{47,  0}", @"{47, 36}",
                                       @"{47, 36}", @"{ 0, 36}",
                                       @"{47, 36}", @"{47, 72}",
                                       @"{47, 72}", @"{ 0, 72}",
                                       nil]],

          // 4
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                       @"{0,   0}",  @"{ 0, 36}",
                                       @"{0,  36}",  @"{47, 36}",
                                       @"{47,  0}",  @"{47, 72}",
                                       nil]],

          // 5
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                       @"{0,   0}", @"{ 0, 36}",
                                       @"{0,  36}", @"{47, 36}",
                                       @"{47, 36}", @"{47, 72}",
                                       @"{47, 72}", @"{ 0, 72}",
                                       @"{0,   0}", @"{47,  0}",
                                        nil]],

          // 6
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                       @"{0,   0}", @"{ 0, 72}",
                                       @"{0,  72}", @"{47, 72}",
                                       @"{47, 72}", @"{47, 36}",
                                       @"{47, 36}", @"{ 0, 36}",
                                       nil]],

          // 7
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                       @"{0,  0}", @"{47,  0}",
                                       @"{47, 0}", @"{47, 72}",
                                           nil]],

          // 8
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                       @"{0,  0}", @"{0,  72}",
                                       @"{0, 72}", @"{47, 72}",
                                       @"{47,72}", @"{47,  0}",
                                       @"{47, 0}", @"{0,   0}",
                                       @"{0, 36}", @"{47, 36}",
                                       nil]],

          // 9
          [CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                                       @"{47, 0}", @"{ 0,  0}",
                                       @"{0,  0}", @"{ 0, 36}",
                                       @"{0, 36}", @"{47, 36}",
                                       @"{47, 0}", @"{47, 72}",
                                        nil]],
      nil];
    
    NSMutableDictionary<NSNumber*, NSArray<CYLRefreshStoreHouseLine *>*>* dictionaty = [NSMutableDictionary dictionary];
    
    // A - Z
    for (NSUInteger i = 0, len = LETTERS.count; i < len; i++) {
        NSNumber *key = [NSNumber numberWithLong:(i + 'A')];
        [dictionaty setObject:LETTERS[i] forKey:key];
    }
    // a - z
    for (NSUInteger i = 0, len = LETTERS.count; i < len; i++) {
        NSNumber *key = [NSNumber numberWithLong:(i + 'a')];
        [dictionaty setObject:LETTERS[i] forKey:key];
    }
    // 0 - 9
    for (NSUInteger i = 0, len = NUMBERS.count; i < len; i++) {
        NSNumber *key = [NSNumber numberWithLong:(i + '0')];
        [dictionaty setObject:NUMBERS[i] forKey:key];
    }
    // blank
    NSNumber *blankKey = [NSNumber numberWithLong:(long)' '];
    [dictionaty setObject:[NSArray array] forKey:blankKey];
    // -
    NSNumber *reduceKey = [NSNumber numberWithLong:(long)'-'];
    [dictionaty setObject:[CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                     @"{0, 36}", @"{47, 36}",
          nil]] forKey:reduceKey];
    // .
    NSNumber *dotKey = [NSNumber numberWithLong:(long)'-'];
    [dictionaty setObject:[CYLRefreshStoreHousePath linesFromArray:[NSArray arrayWithObjects:
                     @"{24, 60}", @"{24, 72}",
          nil]] forKey:dotKey];
    
    CODEMAP = dictionaty;
}

+ (NSArray<CYLRefreshStoreHouseLine *>*)linesFromArray:(NSArray<NSString*>*)array {
    NSMutableArray<CYLRefreshStoreHouseLine*>* items = [NSMutableArray array];
    for (NSUInteger i = 0; i * 2 + 1 < array.count; i++) {
        CGPoint startPoint = CGPointFromString(array[i*2]);
        CGPoint endPoint = CGPointFromString(array[i*2+1]);
        CYLRefreshStoreHouseLine* item = [CYLRefreshStoreHouseLine new];
        item.index = items.count;
        item.start = startPoint;
        item.end = endPoint;
        item.middle = CGPointMake((item.start.x + item.end.x)/2, (item.start.y + item.end.y)/2);
        item.offset = ((NSInteger)(arc4random() % 200) - 100) / 100.0;
        [items addObject:item];
    }
    return items;
}

+ (NSArray<CYLRefreshStoreHouseLine *> *)linesFrom:(NSString *)str scale:(CGFloat)scale space:(NSInteger)space {
    scale *= 0.25;
    CGFloat offsetX = 0;
    NSMutableArray<CYLRefreshStoreHouseLine*>* items = [NSMutableArray array];
    for (NSUInteger i = 0, len = str.length; i < len; i++) {
        unichar ch = [str characterAtIndex:i];
        NSNumber *key = [NSNumber numberWithLong:(long)ch];
        NSArray<CYLRefreshStoreHouseLine *>* points = [CODEMAP objectForKey:key];
        if (points) {
            for (CYLRefreshStoreHouseLine* p in points) {
                CYLRefreshStoreHouseLine* item = [CYLRefreshStoreHouseLine new];
                item.index = items.count;
                item.start = CGPointMake((offsetX + p.start.x) * scale, p.start.y * scale);
                item.end = CGPointMake((offsetX + p.end.x) * scale, p.end.y * scale);
                item.middle = CGPointMake((item.start.x + item.end.x)/2, (item.start.y + item.end.y)/2);
                item.offset = ((NSInteger)(arc4random() % 200) - 100) / 100.0;
                [items addObject:item];
            }
        }
        offsetX += 57 + space;
    }
    return items;
}

+ (NSArray<NSString *> *)arrayAkta {
    return @[
        @"{22,0}",
        @"{0,30}",
        @"{22,0}",
        @"{30,0}",
        @"{30,0}",
        @"{52,30}",
        @"{0,30}",
        @"{26,30}",
        @"{60,0}",
        @"{60,15}",
        @"{60,15}",
        @"{60,30}",
        @"{60,15}",
        @"{85,15}",
        @"{85,15}",
        @"{108,0}",
        @"{85,15}",
        @"{108,30}",
        @"{117,0}",
        @"{147,0}",
        @"{147,0}",
        @"{177,0}",
        @"{147,0}",
        @"{147,32}",
        @"{198,0}",
        @"{176,30}",
        @"{198,0}",
        @"{206,0}",
        @"{206,0}",
        @"{228,30}",
        @"{176,30}",
        @"{202,30}",
    ];
}

+ (NSArray<NSString *> *)arrayStoreHouse {
    return @[
        @"{0,35}",
        @"{12,42}",
        @"{12,42}",
        @"{24,35}",
        @"{24,35}",
        @"{12,28}",
        @"{0,35}",
        @"{12,28}",
        @"{0,21}",
        @"{12,28}",
        @"{12,28}",
        @"{24,21}",
        @"{24,35}",
        @"{24,21}",
        @"{24,21}",
        @"{12,14}",
        @"{0,21}",
        @"{12,14}",
        @"{0,21}",
        @"{0,7}",
        @"{12,14}",
        @"{0,7}",
        @"{12,14}",
        @"{24,7}",
        @"{24,7}",
        @"{12,0}",
        @"{0,7}",
        @"{12,0}",
    ];
}

@end
