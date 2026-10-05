#import "../Utils.h"

// No ads: SoundCloud's own "ad-free" switch is turned on, and requests to ad servers fail

// Ad networks and SoundCloud ad endpoints. Hosts match the domain and its subdomains
static NSArray<NSString *> *PSIBlockedHosts(void) {
    static NSArray *hosts;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hosts = @[
            @"doubleclick.net", @"doubleclick-cn.net", @"googlesyndication.com", @"googleadservices.com",
            @"adsenseformobileapps.com", @"app-ads-services.com", @"imasdk.googleapis.com", @"mediation.goog",
            @"admob-gmats.uc.r.appspot.com", @"prebid-server.com", @"aditude.io", @"an.facebook.com",
            // SoundCloud's audio and video ads are served through Pandora (SiriusXM) and measured by these
            @"promoted.soundcloud.com", @"pandora.com", @"moatads.com", @"adsafeprotected.com", @"flashtalking.com",
            @"agkn.com", @"cdnsynd.com"
        ];
    });

    return hosts;
}

static BOOL PSIIsAdRequest(NSURLRequest *request) {
    NSString *host = request.URL.host.lowercaseString;
    if (!host) return NO;

    // SoundCloud's own audio and video ads, fetched when playback starts (/ads/queue_start)
    NSString *path = request.URL.path;
    if ([host hasSuffix:@"soundcloud.com"] && ([path isEqualToString:@"/ads"] || [path hasPrefix:@"/ads/"])) return YES;

    for (NSString *blocked in PSIBlockedHosts()) {
        if ([host isEqualToString:blocked] || [host hasSuffix:[@"." stringByAppendingString:blocked]]) return YES;
    }

    return NO;
}

@interface PSIAdBlockProtocol : NSURLProtocol
@end

@implementation PSIAdBlockProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([PSIUtils getBoolPref:@"log_requests"] && [request.URL.host hasSuffix:@"soundcloud.com"]) {
        PSILog(@"Request %@ %@", request.HTTPMethod, request.URL.path);
    }

    return [PSIUtils getBoolPref:@"block_ads"] && PSIIsAdRequest(request);
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    PSILog(@"Blocked ad request to %@%@", self.request.URL.host, self.request.URL.path);

    [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil]];
}

- (void)stopLoading {
}

@end

// Sessions only consult the protocol classes in their configuration, so add ours to every one
%hook NSURLSessionConfiguration
- (NSArray *)protocolClasses {
    NSArray *classes = %orig ?: @[];
    if ([classes containsObject:[PSIAdBlockProtocol class]]) return classes;

    return [@[[PSIAdBlockProtocol class]] arrayByAddingObjectsFromArray:classes];
}
%end

///////////////////////////////////////////////////////////

// The switch SoundCloud Go and Go+ turn on for their subscribers
%hook _TtC10SoundCloud19UserFeaturesService
- (BOOL)isNoAudioAdsEnabled {
    return [PSIUtils getBoolPref:@"block_ads"] ? YES : %orig;
}
%end

// Asked before requesting any ad: audio ads in the play queue, banners and interstitials
%hook _TtC10SoundCloud19AdsRequestPermitter
- (BOOL)shouldRequestAds {
    return [PSIUtils getBoolPref:@"block_ads"] ? NO : %orig;
}
%end

// Banner slots on track, playlist, profile and search pages; without this an empty box is left behind
%hook _TtC3Ads30DisplayAdBannerFeatureProvider
- (BOOL)canRequestAdBanner {
    return [PSIUtils getBoolPref:@"block_ads"] ? NO : %orig;
}
%end

%ctor {
    [NSURLProtocol registerClass:[PSIAdBlockProtocol class]];

    %init;
}
