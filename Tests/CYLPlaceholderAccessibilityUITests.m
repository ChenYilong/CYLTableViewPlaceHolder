#import <XCTest/XCTest.h>

/// Reads the accessibility tree that VoiceOver reads, in the host app from `Tests/AccessibilityHost`.
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

- (void)testPlaceholderElementAnnouncesBadgeOnce {
    XCUIElement *element = [self element:@"element"];
    XCTAssertTrue([element waitForExistenceWithTimeout:5]);
    XCTAssertEqualObjects(element.label, @"Inbox");
    XCTAssertEqualObjects(element.value, @"Synced, 3");
    XCTAssertFalse(element.isSelected);
    // The badge label is not a second VoiceOver stop.
    XCTAssertFalse([self element:@"elementBadge"].exists);

    [[self element:@"toggle"] tap];
    XCTAssertTrue(element.isSelected);
    [[self element:@"toggle"] tap];
    XCTAssertFalse(element.isSelected);

    [[self element:@"clear"] tap];
    XCTAssertEqualObjects(element.value, @"Synced");
}

- (void)testBadgeInAccessibleContainerIsReadOnItsOwn {
    XCUIElement *badge = [self element:@"groupBadge"];
    XCTAssertTrue([badge waitForExistenceWithTimeout:5]);
    XCTAssertEqualObjects(badge.label, @"New");
    XCTAssertTrue([self element:@"groupTitle"].exists);
    [[self element:@"clear"] tap];
    XCTAssertFalse([self element:@"groupBadge"].exists);
}

- (void)testAccessibilityAudit {
    XCTAssertTrue([[self element:@"element"] waitForExistenceWithTimeout:5]);
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
