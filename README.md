# Obihiro - Page Object for View Controller

Testing View Controllers makes sense, I believe, but is still difficult.
The main difficulties should be the following two.

1. The UI changes a lot, and the test easily can be out of date
2. View Controller life-cycle is highly asynchronous

Page Object pattern is for the first above.
It encapsulate the complexity around UI structure, and helps keeping your tests clean.

* PageObject - Martin Fowler http://martinfowler.com/bliki/PageObject.html
* PageObjects - selenium  https://code.google.com/p/selenium/wiki/PageObjects

Instead of writing as the following:

```objc
UIButton * button = [viewController valueForKey:@"saveButton"];
[button sendActionsForControlEvents:UIControlEventTouchUpInside];
[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]]

UILabel *statusLabel = [viewController valueForKey:@"statusLabel"];
NSString *statusText = statusLabel.text;

XCTAssertEqualObjects(@"Done", statusText);
```

Page Object allows tests to be like the following:

```objc
[object tapSaveButton];

NSString *statusText = [object statusText];

XCTAssertEqualObjects(@"Done", statusText);
```

You still have to implement complex but boring view operations in the object.
However, the test looks good enough now; easy to read and understand, works better for small changes.

This library also provides some primitives to work with asynchronous View Controller events.

* It waits `viewDidAppear:` and `viewDidDisappear:`
* It provides `waitFor:` to make your tests stable by waiting completion of some status change

## Getting Started

You can install Obihiro via cocoapods.

```rb
pod 'Obihiro'
```

Your object definition would look like the following:

```objc
#import <Obihiro/Obihiro.h>
#import "YourViewController.h"

@interface YourViewControllerObject : OBHViewControllerObject<YourViewController *>

@property (nonatomic, readonly) NSString *statusText;
- (void)tapSaveButton;

@end

@implementation YourViewControllerObject

- (NSString *)statusText {
  // self.viewController is typed as YourViewController *.
  // You can use methods in YourViewController without writing casts.
  ...
}

- (void)tapSaveButton {
  // simulateUserAction: executes given block, and inserts wait for 100ms.
  // This allows running next scheduled action.
  [self simulateUserAction:^{
    ...
  }]
}

@end
```

This corresponds to Page Object in the context of Web app development.
Your test uses the object to access View Controller.

```objc
#import <XCTest/XCTest.h>
#import "YourViewControllerObject.h"

@interface YourViewControllerTests : XCTestCase

@property (nonatomic) YourViewControllerObject *object;

@end

@implementation YourViewControllerTests

- (void)setUp {
  [super setUp];
  self.object = [YourViewControllerObject objectWithInitialViewControllerFromStoryBoardWithName:@"MainStoryBoard"];
}

- (void)tearDown {
  self.object = nil;
  [super tearDown];
}

- (void)testSomething {
  // It presents your View Controller, and returns after `viewDidAppear:` finished.
  // Your View Controller would be completely initialized now.
  [self.object presentViewController];

  [self.object tapSaveButton];

  NSString *status = self.object.statusText;

  XCTAssertEqualObjects(@"Done", status);
}

@end
```

## View Controller Containment

`OBHViewControllerObject` provides `registerObjectClass:` instance method.
It allows your View Controller Object to instantiate custom class for Child View Controllers.

```objc
@implementation YourViewControllerTests

// This is the method to be used initialization.
// You do not have to override `init` methods.
- (void)initializeObject {
  [self.object registerObjectClass:[YourChildViewControllerObject class]];
  // Now View Controller Objects instantiated thorough this object for YourChildViewController instances are instances of YourViewControllerObject.
  // The class name of View Controller is guessed from the class name of View Controller Object, just dropping Object suffix.
}

@end
```

```objc
- (void)testSomething {
  YourChildViewControllerObject *childObject = [self.object firstChildObjectForViewControllerClass:[YourChildViewController class]];
}
```

### UINavigationController

It is shipped with default Object class for `UINavigationController`, one of the most frequently used View Controller Container.

```objc
OBHNavigationControllerObject *navigationObject = [OBHNavigationControllerObject objectWithViewController:navigationViewController];
```

It provides some API for View Controller stack operations; like getting object associated with View Controller which is on the top of navigation stack.

```objc
YourViewControllerObject *object = [navigationObject topObjectOfViewControllerClass:[YourViewController class]];

[navigationObject back];
```

Also has operations for UIBarButtonItems.

```objc
XCTAssertTrue(navigationObject.isRightButtonAvailable);

[navigationObject tapRightButton];
```

### Popover and Alert

`OBHViewControllerObject` allows to access to popover presented its by View Controller.
It assumes the popover is managed by `UIPopoverPresentedController`, not `UIPopoverController`.

```objc
OBHViewControllerObject *object;

XCTAssertNotNil(object.presentedPopoverObject);
```

It also allows to access to UIAlertController.

```objc
OBHViewControllerObject *object;

OBHAlertControllerObject *alertObject = object.alertObject;
XCTAssertEqualObjects(@["OK"], alertObject.titles);

[alertObject tapAlertButtonForTitles:@"OK"];
```

## Testing User Interface

Making your tests stable is difficult.
One way to keep your test stable is to make your test repeat.

Instead of testing your UI status only once:

```objc
XCTAssertTrue(self.object.hasPopover);
```

Try to write a code to repeat until success.

```objc
XCTAssertTrue([self.object eventually:^BOOL{
  return self.object.hasPopover;
}]);
```

It is good idea to make every predicate retry and you would define your predicate method something like this:

```objc
- (BOOL)hasPopover {
  return [self eventuallyNotNil:^{
    return self.presentedPopoverObject;
  }];
}
```

This helps keeping your test clean.

```objc
// Now the test retries until success
XCTAssertTrue(self.object.hasPopover);
```

However, the negation does not work as you expected.

```objc
// Write test script to close popover

// This may not work
XCTAssertFalse(self.object.hasPopover);
```

The test you want is actually something like this:

```objc
XCTAssertTrue([self.object eventuallyNil:^{
  return self.object.presentedPopoverObject;
}]);
```

The positive form of a test in your mind, *Popover is presented*, means

* (P) There will be an moment that popover is presented within a short period

The negation of a test in your mine, *Popover is not presented*, means

* (Q) There will be an moment that popover is not presented within a short period

`Q` is not a negation of `P`. You have to define another predicate:

```objc
- (BOOL)doesntHavePopover {
  return [self eventuallyNil:^{
    return self.presentedPopoverObject;
  }];
}
```

and the following test will work.

```objc
// Write test script to close popover

// This may not work
XCTAssertTrue(self.object.doesntHavePopover);
```

Defining positive and negative forms for all predicates must be boring.

Obihiro 1.2 introduces `OBHUIPredicate`.

```objc
- (OBHUIPredicate *)popoverPresented {
  return [self predicateWithTest:^{
    return self.object.presentedPopoverObject != nil;
  }];
}
```

This is like *matcher* idea in modern test frameworks including Rspec.
You can use that in your test.

```objc
// Positive form
XCTAssert(self.object.popoverPresented.holds);

// Negative form
XCTAssert(self.object.popoverPresented.doesntHold);
XCTAssert(self.object.popoverPresented.negation.hold);  // Another syntax
```

Use `OBHUIPredicate` to define tests of UI, and keep your test code clean.

## Simulating Use Actions

There are two (or more) ways to simulate user actions:

1. Write your code
2. Use KIF https://github.com/KIF/KIF

I recommend using KIF, but some actions are still difficult to simulate.
Choose better way for each action you want to simulate.

If you could not find any way to simulate user action, just access internal structure of your View Controller.
It is not very good thing, but better than stop writing tests or exposing internal structure to your test scripts.

### Tap Button

If you want to write yourself, something like the following would work.

```objc
UIButton *button;
[self simulateUserAction:^{
  [button sendActionsForControlEvents:UIControlEventTouchUpInside];  
}];
```

In KIF, you can use `tap` method.

```objc
UIButton *button;
[self simulateUserAction:^{
  [button tap];
}];
```

This looks a case there are not big difference.

### Tap Bar Button Item

I couldn't find KIF way.

```objc
UIBarButtonItem *button;

[self simulateUserAction:^{
  [button.target performSelector:button.action withObject:button afterDelay:0]; 
}];
```

Does not look great, but works.

### Select UITableViewCell

This is an action KIF works much better.

```objc
UITableViewCell *cell;

[self simulateUserAction:^{
  [cell tap];
}];
```

For UITableViewDelegate cells, it is not very difficult.

```objc
UITableView *tableView;
NSindexPath *indexPath;
UITableViewCell *cell;

[self simulateUserAction:^{
  [self.tableView.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}];
```

However, if the cell is for segue, there looks no way to simulate through public API.

```objc
UITableView *tableView;
NSindexPath *indexPath;
UITableViewCell *cell;

[self simulateUserAction:^{
  id<NSObject> template = [cell performSelector:NSSelectorFromString(@"selectionSegueTemplate")];
  if (template) {
    [template performSelector:NSSelectorFromString(@"perform:") withObject:cell];
    return;
  }
}];
```

### Fill Text Field

It depends. I personally prefer doing myself way. But KIF would provide better simulation (I'm not sure, I don't want to setup KIF completely).

```objc
UITextField *textField;

[self simulateUserAction:^{
  [field sendActionsForControlEvents:UIControlEventEditingDidBegin];
  textField.text = text;
  [field sendActionsForControlEvents:UIControlEventEditingDidEnd];
}];
```
