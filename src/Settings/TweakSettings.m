#import "TweakSettings.h"
#import "PSISettingsBackup.h"

@implementation PSITweakSettings

// MARK: - Sections

///
/// This returns an array of sections, with each section consisting of a dictionary
///
/// `"title"`: The section title (leave blank for no title)
///
/// `"rows"`: An array of **PSISetting** classes, potentially containing a "navigationCellWithTitle" initializer to allow for nested setting pages.
///
/// `"footer`: The section footer (leave blank for no footer)

+ (NSArray *)sections {
    return @[
        @{
            @"header": @"Ads",
            @"rows": @[
                [PSISetting switchCellWithTitle:@"Block ads" subtitle:@"No audio, video or banner ads" defaultsKey:@"block_ads" requiresRestart:YES]
            ],
            @"footer": @"Turns on SoundCloud's own ad-free mode and blocks requests to ad servers."
        },
        @{
            @"header": @"Prompts",
            @"rows": @[
                [PSISetting switchCellWithTitle:@"Hide rating prompts" subtitle:@"No \"Enjoying SoundCloud?\" or rate-the-app popups" defaultsKey:@"hide_rating_prompts"]
            ]
        },
        @{
            @"header": @"Debug",
            @"rows": @[
                [PSISetting switchCellWithTitle:@"Enable FLEX gesture" subtitle:@"Hold 5 fingers on the screen to open the FLEX explorer" defaultsKey:@"flex_gesture"],
                [PSISetting switchCellWithTitle:@"Log SoundCloud requests" subtitle:@"Writes the path of every SoundCloud API request to the system log" defaultsKey:@"log_requests"]
            ]
        },
        @{
            @"header": @"About",
            @"rows": @[
                [PSISetting linkCellWithTitle:@"GitHub" subtitle:@"@pstepanovum" icon:[PSISymbol symbolWithName:@"person.crop.circle"] url:@"https://github.com/pstepanovum"],
                [PSISetting linkCellWithTitle:@"Repository" subtitle:@"pstepanovum/PSSoundcloud" icon:[PSISymbol symbolWithName:@"chevron.left.forwardslash.chevron.right"] url:@"https://github.com/pstepanovum/PSSoundcloud"]
            ],
            @"footer": [NSString stringWithFormat:@"PSSoundcloud %@\n\nSoundCloud v%@", PSIVersionString, [PSIUtils appVersionString]]
        }
    ];
}


// MARK: - Title

+ (NSString *)title {
    return @"PSSoundcloud Settings";
}


// MARK: - Menus

+ (NSDictionary *)menus {
    return @{};
}

@end
