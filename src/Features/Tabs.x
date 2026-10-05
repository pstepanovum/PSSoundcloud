#import "../Utils.h"

// No Feed tab (the scrolling feed from accounts you follow) and no Upgrade tab (the SoundCloud Go / Go+ sales page)

static UIViewController *PSIRootOfTab(UIViewController *controller) {
    if ([controller isKindOfClass:[UINavigationController class]]) {
        return ((UINavigationController *)controller).viewControllers.firstObject ?: controller;
    }

    return controller;
}

static BOOL PSIShouldHideTab(UIViewController *controller) {
    NSString *rootClass = NSStringFromClass([PSIRootOfTab(controller) class]);

    if ([PSIUtils getBoolPref:@"hide_feed_tab"] && [rootClass containsString:@"ElevatorFeed"]) return YES;
    if ([PSIUtils getBoolPref:@"hide_upgrade_tab"] && ([rootClass containsString:@"Upsell"] || [rootClass containsString:@"Upgrade"])) return YES;

    return NO;
}

@interface _TtC10SoundCloud20RootTabBarController : UITabBarController
@end

%hook _TtC10SoundCloud20RootTabBarController
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    for (UIViewController *controller in viewControllers) {
        PSILog(@"Tab %@ (%@)", controller.tabBarItem.title, NSStringFromClass([PSIRootOfTab(controller) class]));
    }

    NSMutableArray *kept = [NSMutableArray array];
    for (UIViewController *controller in viewControllers) {
        if (!PSIShouldHideTab(controller)) [kept addObject:controller];
    }

    // Never leave the tab bar empty
    %orig(kept.count > 0 ? kept : viewControllers, animated);
}
%end
