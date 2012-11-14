//  L3TestResultBuilder.m
//  Created by Rob Rix on 2012-11-13.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3FunctionalUtilities.h"
#import "L3Stack.h"
#import "L3TestResult.h"
#import "L3TestResultBuilder.h"
#import "L3TestSuite.h"
#import "Lagrangian.h"

@interface L3TestResultBuilder ()

@property (strong, nonatomic, readonly) L3Stack *testResultStack;
@property (nonatomic, readonly) L3TestResult *currentTestResult;

@end

@l3_suite("Test result builders", L3TestResultBuilder) <L3TestResultBuilderDelegate>
@property L3TestResultBuilder *builder;
@property L3TestResult *builtResult;
@end

@implementation L3TestResultBuilder

@l3_set_up {
	test.builder = [L3TestResultBuilder new];
	test.builder.delegate = test;
}


#pragma mark -
#pragma mark Constructors

@l3_test("are initialized with an empty stack") {
	l3_assert([test.builder testResultStack].objects, l3_equals(@[]));
}

-(instancetype)init {
	if ((self = [super init])) {
		_testResultStack = [L3Stack new];
	}
	return self;
}


#pragma mark -
#pragma mark Event algebra

#pragma mark -
#pragma mark Test events

@l3_test("push a result when starting suites") {
	L3TestSuite *suite = [L3TestSuite testSuiteWithName:_case.name];
	NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-10];
	[test.builder testStartEventWithTest:suite date:date];
	L3TestResult *testResult = [test.builder testResultStack].topObject;
	l3_assert(testResult.name, l3_equals(_case.name));
	l3_assert(testResult.startDate, l3_equals(date));
}

-(void)testStartEventWithTest:(id<L3Test>)test date:(NSDate *)date {
	L3TestResult *testResult = [L3TestResult testResultWithName:test.name startDate:date];
	[self.testResultStack pushObject:testResult];
}


@l3_test("pop a result when ending suites") {
	L3TestResult *testResult = [L3TestResult testResultWithName:_case.name startDate:[NSDate dateWithTimeIntervalSinceNow:-10]];
	[[test.builder testResultStack] pushObject:testResult];
	L3TestSuite *suite = [L3TestSuite testSuiteWithName:_case.name];
	[test.builder testEndEventWithTest:suite date:[NSDate date]];
	l3_assert([test.builder testResultStack].objects, l3_equals(@[]));
}

@l3_test("set returned results’ end dates when ending suites") {
	NSDate *now = [NSDate date];
	L3TestSuite *suite = [L3TestSuite testSuiteWithName:_case.name];
	[test.builder.testResultStack pushObject:[L3TestResult testResultWithName:_case.name startDate:[NSDate dateWithTimeInterval:-10 sinceDate:now]]];
	L3TestResult *testResult = test.builder.testResultStack.topObject;
	[test.builder testEndEventWithTest:suite date:now];
	l3_assert(testResult.endDate, l3_equals(now));
}

@l3_test("provide their delegate with a result when ending cases") {
	L3TestResult *testResult = [L3TestResult testResultWithName:_case.name startDate:[NSDate dateWithTimeInterval:-10 sinceDate:[NSDate date]]];
	[test.builder.testResultStack pushObject:testResult];
	[test.builder testEndEventWithTest:_case date:[NSDate date]];
	l3_assert(test.builtResult, l3_equals(testResult));
}

-(void)testEndEventWithTest:(L3TestSuite *)testSuite date:(NSDate *)date {
	L3TestResult *testResult = [self.testResultStack popObject];
	testResult.endDate = date;
	[self.delegate testResultBuilder:self didCompleteTestResult:testResult];
}


#pragma mark -
#pragma mark Assertion events

-(void)assertionSuccessWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date {
	self.currentTestResult.assertionCount += 1;
}

-(void)assertionFailureWithAssertionReference:(L3AssertionReference *)assertionReference date:(NSDate *)date {
	self.currentTestResult.assertionCount += 1;
	self.currentTestResult.assertionFailureCount += 1;
}


#pragma mark -
#pragma mark Current results

-(L3TestResult *)currentTestResult {
	return self.testResultStack.topObject;
}

@end

@l3_suite_implementation(L3TestResultBuilder)

-(void)testResultBuilder:(L3TestResultBuilder *)builder didCompleteTestResult:(L3TestResult *)result {
	self.builtResult = result;
}

@end
