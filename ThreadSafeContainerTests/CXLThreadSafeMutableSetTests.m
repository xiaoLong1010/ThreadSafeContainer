//
//  CXLThreadSafeMutableSetTests.m
//  ThreadSafeContainerTests
//
//  Created by Csy on 14/02/2018.
//  Copyright © 2018 Csy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CXLThreadSafeMutableSet.h"

static const NSString * const kObject1 = @"1";
static const NSString * const kObject2 = @"2";
static const NSString * const kObject3 = @"3";

@interface BaiduAPMThreadSafeMutableSetTests : XCTestCase

@property (nonatomic, strong) CXLThreadSafeMutableSet *set;

@end

@implementation BaiduAPMThreadSafeMutableSetTests

- (void)setUp {
    [super setUp];
    self.set = [CXLThreadSafeMutableSet set];
    [self.set addObject:kObject1];
    [self.set addObject:kObject2];
    [self.set addObject:kObject3];
}

- (void)tearDown {
    self.set = nil;
    
    [super tearDown];
}

- (void)testInit {
    CXLThreadSafeMutableSet *set = [CXLThreadSafeMutableSet set];
    XCTAssertNotNil(set);
    
    set = nil;
    set = [CXLThreadSafeMutableSet setWithCapacity:10];
    XCTAssertNotNil(set);
    
    set = nil;
    set = [CXLThreadSafeMutableSet setWithArray:@[kObject1,kObject2,kObject3]];
    XCTAssertNotNil(set);
    
    set = nil;
    set = [CXLThreadSafeMutableSet setWithObject:kObject1];
    XCTAssertNotNil(set);
    
}

- (void)testCopy {
    XCTAssertTrue(self.set.count == 3);
    
    NSSet *copiedSet = [self.set copy];
    XCTAssertTrue([copiedSet isKindOfClass:[NSSet class]]);
    XCTAssertEqual(copiedSet.count, 3);
    
    NSMutableSet *mutableCopiedSet = [self.set mutableCopy];
    XCTAssertTrue([mutableCopiedSet isKindOfClass:[NSMutableSet class]]);
    XCTAssertEqual(mutableCopiedSet.count, 3);
}

- (void)testAddRemove {
    NSObject *nilObject = nil;
    NSArray *nilArr = nil;
    //Add
    [self.set addObject:nilObject];
    XCTAssertTrue(self.set.count == 3);
    
    //Remove
    [self.set removeObject:kObject3];
    XCTAssertTrue(self.set.count == 2);
    
    [self.set removeAllObjects];
    XCTAssertTrue(self.set.count == 0);
    
    //Add Array
    [self.set addObjectsFromArray:@[kObject2, kObject1, kObject3]];
    [self.set addObjectsFromArray:nilArr];
    XCTAssertTrue(self.set.count == 3);
}

- (void)testQuery {
    XCTAssertTrue(self.set.count == 3);
    
    NSArray *array = [self.set allObjects];
    XCTAssertNotNil(array);
    XCTAssertEqual(array.count, 3);
    XCTAssertEqualObjects(array[0], kObject1);
}

- (void)testEnumerate {
    XCTAssertTrue(self.set.count == 3);
    
    __block NSInteger count = 0;
    [self.set enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        count++;
    }];
    XCTAssertEqual(count, 3);
    
    count = 0;
    [self.set enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        count++;
        if (obj == kObject2) {
            *stop = YES;
        }
    }];
    XCTAssertLessThanOrEqual(count, 3);
}

@end

