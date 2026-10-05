#import <StoreKit/StoreKit.h>
#import "../Utils.h"

// No "Enjoying SoundCloud?" / rate-the-app prompts

%hook _TtC10SoundCloud31UserExperiencePromptCoordinator
- (void)presentIfNeeded {
    if ([PSIUtils getBoolPref:@"hide_rating_prompts"]) return;

    %orig;
}
%end

%hook Engagement
- (void)presentUserExperiencePromptIfNeeded {
    if ([PSIUtils getBoolPref:@"hide_rating_prompts"]) return;

    %orig;
}
%end

// The system "rate this app" sheet
%hook SKStoreReviewController
+ (void)requestReview {
    if ([PSIUtils getBoolPref:@"hide_rating_prompts"]) return;

    %orig;
}

+ (void)requestReviewInScene:(UIWindowScene *)scene {
    if ([PSIUtils getBoolPref:@"hide_rating_prompts"]) return;

    %orig;
}
%end
