//
//  CXLThreadSafeMutableArrayTests.m
//  ThreadSafeContainerTests
//
//  Created by Csy on 28/01/2018.
//  Copyright © 2018 Csy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CXLThreadSafeMutableArray.h"

static const NSString * const kObject1 = @"1";
static const NSString * const kObject2 = @"2";
static const NSString * const kObject3 = @"3";

static const NSString * const kOtherObject = @"123";

@interface CXLThreadSafeMutableArrayTests : XCTestCase

@property (nonatomic, strong) CXLThreadSafeMutableArray *array;

@end

@implementation CXLThreadSafeMutableArrayTests

- (void)setUp {
    [super setUp];
    
    self.array = [CXLThreadSafeMutableArray array];
    [self.array addObject:kObject1];
    [self.array addObject:kObject2];
    [self.array addObject:kObject3];
}

- (void)tearDown {
    self.array = nil;
    
    [super tearDown];
}

- (void)testInit {
    CXLThreadSafeMutableArray *array = [CXLThreadSafeMutableArray array];
    XCTAssertNotNil(array);
    
    array = nil;
    array = [CXLThreadSafeMutableArray arrayWithCapacity:10];
    XCTAssertNotNil(array);
    
    array = nil;
    array = [CXLThreadSafeMutableArray arrayWithArray:@[kObject1,kObject2,kObject3]];
    XCTAssertNotNil(array);
    XCTAssertEqual(array.count, 3);
    
    array = nil;
    array = [CXLThreadSafeMutableArray arrayWithObject:kObject2];
    XCTAssertNotNil(array);
    XCTAssertEqual(array.count, 1);
    
}

- (void)testCopy {
    XCTAssertTrue(self.array.count == 3);
    
    NSArray *copiedArray = [self.array copy];
    XCTAssertTrue([copiedArray isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects([copiedArray lastObject], kObject3);
    
    NSMutableArray *mutableCopiedArray = [self.array mutableCopy];
    XCTAssertTrue([mutableCopiedArray isKindOfClass:[NSMutableArray class]]);
    XCTAssertEqualObjects([mutableCopiedArray lastObject], kObject3);
}

- (void)testAddRemove {
    //Add
    [self.array addObject:nil];
    [self.array addObjectsFromArray:nil];
    XCTAssertTrue(self.array.count == 3);
    
    [self.array addObjectsFromArray:@[kObject1,kObject2]];
    
    [self.array insertObject:kObject2 atIndex:0];
    [self.array insertObject:nil atIndex:0];
    [self.array insertObject:kObject3 atIndex:10];
    [self.array insertObject:kObject3 atIndex:2];
    XCTAssertTrue(self.array.count == 7);
    
    //Remove
    [self.array removeObjectAtIndex:0];
    [self.array removeObjectAtIndex:10];
    XCTAssertTrue(self.array.count == 6);
    
    [self.array removeLastObject];
    XCTAssertTrue(self.array.count == 5);
    
    [self.array removeObject:kObject3];
    XCTAssertTrue(self.array.count == 3);
    
    [self.array removeAllObjects];
    XCTAssertTrue(self.array.count == 0);
}

- (void)testReplace {
    XCTAssertTrue(self.array.count == 3);
    
    [self.array replaceObjectAtIndex:0 withObject:kObject3];
    XCTAssertEqualObjects([self.array objectAtIndex:0], kObject3);
    
    [self.array replaceObjectAtIndex:3 withObject:kObject1];
    XCTAssertEqualObjects([self.array objectAtIndex:3], nil);
    
    [self.array replaceObjectAtIndex:5 withObject:kObject1];
    XCTAssertEqualObjects([self.array objectAtIndex:0], kObject3);
    XCTAssertEqualObjects([self.array objectAtIndex:1], kObject2);
    
    self.array[1] = kObject1;
    XCTAssertEqualObjects([self.array objectAtIndex:1], kObject1);
    
    self.array[3] = kObject2;
    XCTAssertEqualObjects([self.array objectAtIndex:3], kObject2);
    
    //exceed the bounds of the array,do nothing
    self.array[6] = kObject1;
    XCTAssertEqualObjects([self.array objectAtIndex:1], kObject1);
    XCTAssertEqualObjects([self.array objectAtIndex:3], kObject2);
}

- (void)testQuery {
    XCTAssertEqual(self.array.count, 3);
    
    XCTAssertEqual([self.array indexOfObject:kObject3], 2);
    XCTAssertEqual([self.array indexOfObject:kOtherObject], NSNotFound);
    
    XCTAssertEqualObjects(self.array[0], kObject1);
    XCTAssertEqualObjects(self.array[5], nil);
    
    XCTAssertEqualObjects([self.array objectAtIndex:1], kObject2);
    XCTAssertEqualObjects([self.array objectAtIndex:5], nil);
    
    XCTAssertEqualObjects([self.array firstObject], kObject1);
    XCTAssertEqualObjects([self.array lastObject], kObject3);
}

- (void)testEnumerate {
    XCTAssertEqual(self.array.count, 3);
    
    __block NSInteger count = 0;
    [self.array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        count++;
        if (idx == 1) {
            XCTAssertEqualObjects(obj, kObject2);
        }
        XCTAssertNotNil(obj);
    }];
    XCTAssertEqual(count, 3);
    
    count = 0;
    [self.array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        count++;
        if (idx == 1) {
            *stop = YES;
        }
        XCTAssertLessThan(idx, 2);
    }];
    XCTAssertLessThanOrEqual(count, 3);
}

@end
