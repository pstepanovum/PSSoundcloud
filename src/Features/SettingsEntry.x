#import "../Utils.h"

// A "PSSoundcloud" row at the top of SoundCloud's Settings (Library > gear), besides the four-finger gesture

@interface PSISettingsEntryView : UIControl
@end

@implementation PSISettingsEntryView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;

    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"slider.horizontal.3"]];
    icon.tintColor = [UIColor colorWithRed:1 green:0.33 blue:0 alpha:1];
    icon.contentMode = UIViewContentModeScaleAspectFit;

    UILabel *title = [UILabel new];
    title.text = @"PSSoundcloud";
    title.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    title.textColor = [UIColor labelColor];

    UILabel *subtitle = [UILabel new];
    subtitle.text = @"Ads, prompts and tabs";
    subtitle.font = [UIFont systemFontOfSize:13];
    subtitle.textColor = [UIColor secondaryLabelColor];

    UIStackView *labels = [[UIStackView alloc] initWithArrangedSubviews:@[title, subtitle]];
    labels.axis = UILayoutConstraintAxisVertical;
    labels.spacing = 2;

    UIImageView *chevron = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    chevron.tintColor = [UIColor tertiaryLabelColor];
    chevron.contentMode = UIViewContentModeScaleAspectFit;
    [labels setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[icon, labels, chevron]];
    row.alignment = UIStackViewAlignmentCenter;
    row.spacing = 14;
    row.userInteractionEnabled = NO;
    row.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:row];

    [NSLayoutConstraint activateConstraints:@[
        [icon.widthAnchor constraintEqualToConstant:26],
        [icon.heightAnchor constraintEqualToConstant:26],
        [chevron.widthAnchor constraintEqualToConstant:10],
        [chevron.heightAnchor constraintEqualToConstant:16],
        [row.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
        [row.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        [row.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
    ]];

    self.accessibilityLabel = @"PSSoundcloud settings";
    self.accessibilityTraits = UIAccessibilityTraitButton;
    self.isAccessibilityElement = YES;

    [self addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];

    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.backgroundColor = highlighted ? [UIColor tertiarySystemFillColor] : [UIColor clearColor];
}

- (void)openSettings {
    [PSIUtils showSettingsVC:self.window];
}

@end

static UITableView *PSIFindTableView(UIView *view) {
    if ([view isKindOfClass:[UITableView class]]) return (UITableView *)view;

    for (UIView *subview in view.subviews) {
        UITableView *found = PSIFindTableView(subview);
        if (found) return found;
    }

    return nil;
}

%hook _TtC12SCCollection22SettingsViewController
- (void)viewWillAppear:(BOOL)animated {
    %orig;

    UITableView *tableView = PSIFindTableView(((UIViewController *)self).view);
    if (!tableView || [tableView.tableHeaderView isKindOfClass:[PSISettingsEntryView class]]) return;

    tableView.tableHeaderView = [[PSISettingsEntryView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 64)];
}
%end
