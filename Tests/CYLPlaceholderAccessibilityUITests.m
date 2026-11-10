#import <XCTest/XCTest.h>

/// Reads the accessibility tree that VoiceOver reads, in the host app from `Tests/AccessibilityHost`.
/// Upper bound for the accessibility tree to catch up: on loaded CI runners one element query can take ~9 s.
static const NSTimeInterval CYLTestTimeout = 30;

@interface CYLPlaceholderAccessibilityUITests : XCTestCase
@property (nonatomic, strong) XCUIApplication *app;
@end

@implementation CYLPlaceholderAccessibilityUITests

- (void)setUp {
    self.continueAfterFailure = NO;
    self.app = [[XCUIApplication alloc] init];
    [self.app launch];
}

- (XCUIElement *)element:(NSString *)identifier {
    return [[self.app descendantsMatchingType:XCUIElementTypeAny] matchingIdentifier:identifier].firstMatch;
}

- (BOOL)waitForElement:(XCUIElement *)element selected:(BOOL)selected {
    XCTNSPredicateExpectation *expectation = [[XCTNSPredicateExpectation alloc]
        initWithPredicate:[NSPredicate predicateWithFormat:@"selected == %@", @(selected)] object:element];
    return [XCTWaiter waitForExpectations:@[expectation] timeout:CYLTestTimeout] == XCTWaiterResultCompleted;
}

- (void)testPlaceholderElementAnnouncesBadgeOnce {
    XCUIElement *element = [self element:@"element"];
    XCTAssertTrue([element waitForExistenceWithTimeout:CYLTestTimeout]);
    XCTAssertEqualObjects(element.label, @"Inbox");
    XCTAssertEqualObjects(element.value, @"Synced, 3");
    XCTAssertFalse(element.isSelected);
    // The badge label is not a second VoiceOver stop.
    XCTAssertFalse([self element:@"elementBadge"].exists);

    // Wait for the accessibility tree to report the new state; on loaded CI runners it can
    // lag behind the tap, as the badge-clearing check below already allows for.
    [[self element:@"toggle"] tap];
    XCTAssertTrue([self waitForElement:element selected:YES]);
    [[self element:@"toggle"] tap];
    XCTAssertTrue([self waitForElement:element selected:NO]);

    [[self element:@"clear"] tap];
    XCTNSPredicateExpectation *cleared = [[XCTNSPredicateExpectation alloc]
        initWithPredicate:[NSPredicate predicateWithFormat:@"value == %@", @"Synced"] object:element];
    XCTAssertEqual([XCTWaiter waitForExpectations:@[cleared] timeout:CYLTestTimeout], XCTWaiterResultCompleted);
}

- (void)testBadgeInAccessibleContainerIsReadOnItsOwn {
    XCUIElement *badge = [self element:@"groupBadge"];
    XCTAssertTrue([badge waitForExistenceWithTimeout:CYLTestTimeout]);
    XCTAssertEqualObjects(badge.label, @"New");
    XCTAssertTrue([self element:@"groupTitle"].exists);
    [[self element:@"clear"] tap];
    // The accessibility tree refreshes asynchronously after the badge view is removed.
    XCTNSPredicateExpectation *gone = [[XCTNSPredicateExpectation alloc]
        initWithPredicate:[NSPredicate predicateWithFormat:@"exists == NO"] object:[self element:@"groupBadge"]];
    XCTAssertEqual([XCTWaiter waitForExpectations:@[gone] timeout:CYLTestTimeout], XCTWaiterResultCompleted);
}

- (void)testAccessibilityAudit {
    XCTAssertTrue([[self element:@"element"] waitForExistenceWithTimeout:CYLTestTimeout]);
    [self auditCurrentApp];
}

/// The same audit with one part of the host at a time, so an issue names its view.
- (void)testAccessibilityAuditPerPart {
    self.continueAfterFailure = YES;
    for (NSString *part in @[@"element", @"group", @"buttons"]) {
        [self.app terminate];
        self.app.launchArguments = @[@"-CYLShow", part];
        [self.app launch];
        NSLog(@"CYLAccessibilityAudit: part %@", part);
        [self auditCurrentApp];
    }
}

- (void)auditCurrentApp {
    if (@available(iOS 17.0, *)) {
        // Every reported issue fails. An audit that errors out without reporting any issue (seen on CI as
        // com.apple.xcode.xctest.accessibilityAudit -56 right after a relaunch) is a tool failure: retry it.
        for (NSInteger attempt = 1; attempt <= 3; attempt++) {
            __block NSInteger issues = 0;
            NSError *error = nil;
            BOOL passed = [self.app performAccessibilityAuditWithAuditTypes:XCUIAccessibilityAuditTypeAll
                issueHandler:^BOOL(XCUIAccessibilityAuditIssue *issue) {
                issues++;
                NSLog(@"CYLAccessibilityAudit: %@ | %@ | %@", issue.compactDescription, issue.detailedDescription, issue.element);
                return NO;
            } error:&error];
            if (passed) return;
            if (issues > 0 || attempt == 3) {
                XCTFail(@"Accessibility audit failed (%ld issues): %@", (long)issues, error);
                return;
            }
            NSLog(@"CYLAccessibilityAudit: audit error without issues, retrying (%@)", error);
            [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
        }
    }
}

@end
