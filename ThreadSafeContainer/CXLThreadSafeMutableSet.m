//
//  CXLThreadSafeMutableSet.m
//  ThreadSafeContainer
//
//  Created by Csy on 14/02/2018.
//  Copyright © 2018 Csy. All rights reserved.
//

#import "CXLThreadSafeMutableSet.h"
#import "CXLThreadSafeHeader.h"

@implementation CXLThreadSafeMutableSet {
    pthread_mutex_t _lock;
    CFMutableSetRef _set;
}

#pragma mark - Init
+ (instancetype)set {
    return [[self alloc] init];
}

+ (instancetype)setWithCapacity:(NSUInteger)num {
    return [[self alloc] initWithCapacity:num];
}

+ (instancetype)setWithArray:(NSArray *)array {
    CXLThreadSafeMutableSet *set = [self set];
    [set addObjectsFromArray:array];
    return set;
}

+ (instancetype)setWithObject:(id)object {
    CXLThreadSafeMutableSet *set = [self set];
    [set addObject:object];
    return set;
}

- (instancetype)init {
    return [self initWithCapacity:kDefaultCapacity];
}

- (instancetype)initWithCapacity:(NSUInteger)num {
    if (self = [super init]) {
        pthread_mutex_init(&_lock, NULL);
        _set = CFSetCreateMutable(kCFAllocatorDefault, num,  &kCFTypeSetCallBacks);
    }
    return self;
}

#pragma mark - Copy
- (id)copyWithZone:(NSZone *)zone {
    NSArray *set = nil;
    
    LOCK
    CFSetRef setRef = CFSetCreateCopy(kCFAllocatorDefault, _set);
    if (setRef) {
        set = CFBridgingRelease(setRef);
    }
    UNLOCK
    
    return set;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    NSMutableSet *mutableSet = nil;
    
    LOCK
    CFMutableSetRef mutableSetRef = CFSetCreateMutableCopy(kCFAllocatorDefault, CFSetGetCount(_set),_set);
    if (mutableSetRef) {
        mutableSet = CFBridgingRelease(mutableSetRef);
    }
    UNLOCK
    
    return mutableSet;
}

#pragma mark - Add
- (void)addObject:(id)object {
    if (!object) {
        return;
    }
    
    LOCK
    CFSetAddValue(_set, (__bridge const void *)object);
    UNLOCK
}

- (void)addObjectsFromArray:(NSArray *)array {
    if (!([array isKindOfClass:[NSArray class]] && (array.count > 0))) {
        return;
    }
    
    LOCK
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CFSetAddValue(_set, (__bridge const void *)obj);
    }];
    UNLOCK;
}

#pragma mark - Remove
- (void)removeObject:(id)object {
    if (!object) {
        return;
    }
    
    LOCK
    CFSetRemoveValue(_set, (__bridge const void *)(object));
    UNLOCK
}

- (void)removeAllObjects {
    LOCK
    CFSetRemoveAllValues(_set);
    UNLOCK
}

#pragma mark - Query
- (NSUInteger)count {
    LOCK
    NSUInteger result = CFSetGetCount(_set);
    UNLOCK
    
    return result;
}

- (nullable NSArray *)allObjects {
    NSMutableArray *array = nil;
    
    LOCK
    NSUInteger count = CFSetGetCount(_set);
    if (count > 0) {
        array = [NSMutableArray arrayWithCapacity:count];
        
        CFTypeRef *objects = malloc(count * sizeof(CFTypeRef));
        CFSetGetValues(_set, (const void **) objects);
        
        for (CFIndex index = 0; index < count; index++) {
            [array addObject:(__bridge id)(objects[index])];
        }
        
        free(objects);
    }
    UNLOCK
    return [array copy];
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block {
    if (!block) {
        return;
    }
    
    LOCK
    NSUInteger count = CFSetGetCount(_set);
    if (count > 0) {
        CFTypeRef *objects = malloc(count * sizeof(CFTypeRef));
        CFSetGetValues(_set, (const void **) objects);
        
        BOOL stop = NO;
        for (CFIndex index = 0; index < count; index++) {
            if (stop) {
                break;
            }
            block((__bridge id)(objects[index]), &stop);
        }
        
        free(objects);
    }
    UNLOCK
}

@end
