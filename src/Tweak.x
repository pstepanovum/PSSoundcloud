#import "Utils.h"
#import "Tweak.h"
#import "Settings/PSISettingsBackup.h"

// * Tweak version *
NSString *PSIVersionString = @"v0.1.0";

// Settings are set up before any SoundCloud code runs, so no feature can read them unset
static void PSISetupSettings(void) {
    // Bring back settings from before a reinstall
    [PSISettingsBackup restoreIfNeeded];

    // Default config
    NSDictionary *psiDefaults = @{
        @"block_ads": @(YES),
        @"hide_rating_prompts": @(YES),
        @"hide_tracking_prompt": @(YES),
        @"hide_upgrade_tab": @(YES),
        @"log_requests": @(NO),
        @"flex_gesture": @(NO)
    };
    [[NSUserDefaults standardUserDefaults] registerDefaults:psiDefaults];
}

///////////////////////////////////////////////////////////

// Settings and FLEX access: hold 4 fingers for settings, 5 fingers for FLEX (when enabled)
@interface PSIGestureHandler : NSObject
@end

@implementation PSIGestureHandler
- (void)handleSettingsGesture:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    [PSIUtils showSettingsVC:sender.view.window];
}
- (void)handleFlexGesture:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan || ![PSIUtils getBoolPref:@"flex_gesture"]) return;

    id manager = ((id (*)(id, SEL))objc_msgSend)((id)objc_getClass("FLEXManager"), sel_registerName("sharedManager"));
    ((void (*)(id, SEL))objc_msgSend)(manager, sel_registerName("showExplorer"));
}
@end

static PSIGestureHandler *gestureHandler;

%hook UIWindow
- (void)becomeKeyWindow {
    %orig;

    if ([objc_getAssociatedObject(self, _cmd) boolValue]) return;
    objc_setAssociatedObject(self, _cmd, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if (!gestureHandler) gestureHandler = [PSIGestureHandler new];

    UILongPressGestureRecognizer *settingsGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:gestureHandler action:@selector(handleSettingsGesture:)];
    settingsGesture.minimumPressDuration = 1;
    settingsGesture.numberOfTouchesRequired = 4;
    settingsGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:settingsGesture];

    UILongPressGestureRecognizer *flexGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:gestureHandler action:@selector(handleFlexGesture:)];
    flexGesture.minimumPressDuration = 1;
    flexGesture.numberOfTouchesRequired = 5;
    flexGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:flexGesture];
}
%end

%ctor {
    PSISetupSettings();

    %init;
}
