
#import "Settings/ModernSettingsViewController.h"
#import "Core/BHTBundle.h"
#import "Core/BHTManager.h"
#import "Settings/ModernSettingsCells.h"
#import "Settings/ModernSettingsPageViewController.h"
#import "Settings/Pages/AppearanceSettingsViewController.h"
#import "Settings/Pages/ChatSettingsViewController.h"
#import "Settings/Pages/DebugSettingsViewController.h"
#import "Settings/Pages/PresetsSettingsViewController.h"
#import "Settings/Pages/ProfilesSettingsViewController.h"
#import "Settings/Pages/TimelinesSettingsViewController.h"
#import "Settings/Pages/TweetsSettingsViewController.h"
#import "Settings/Pages/WebSettingsViewController.h"
#import "ThemeColor/Palette.h"

@interface ModernSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) TFNTwitterAccount* account;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSArray* sections;

@end

@implementation ModernSettingsViewController

#pragma mark - Section Header

- (UIView*)tableView:(UITableView*)tableView
 viewForHeaderInSection:(NSInteger)section {

    if (section != 0) {
        return nil;
    }

    UIView* headerView = [[UIView alloc] init];
    headerView.backgroundColor = [Palette currentBackgroundColor];

    UILabel* subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    subtitleLabel.text =
        [[BHTBundle sharedBundle] localizedStringForKey:@"NFB_SETTINGS_DETAIL"];
    subtitleLabel.numberOfLines = 0;
    subtitleLabel.textAlignment = NSTextAlignmentLeft;

    id fontGroup = [BHTManager sharedFontGroup];
    subtitleLabel.font = [fontGroup performSelector:@selector(subtext2Font)];

    Class colorSettingsClass = objc_getClass("TAEColorSettings");
    id settings = [colorSettingsClass sharedSettings];
    id currentPalette = [settings currentColorPalette];
    id colorPalette = [currentPalette colorPalette];

    UIColor* subtitleColor =
        [colorPalette performSelector:@selector(tabBarItemColor)];

    subtitleLabel.textColor = subtitleColor;

    [headerView addSubview:subtitleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [subtitleLabel.leadingAnchor
            constraintEqualToAnchor:headerView.leadingAnchor constant:20],
        [subtitleLabel.trailingAnchor
            constraintEqualToAnchor:headerView.trailingAnchor constant:-20],
        [subtitleLabel.topAnchor
            constraintEqualToAnchor:headerView.topAnchor constant:16],
        [subtitleLabel.bottomAnchor
            constraintEqualToAnchor:headerView.bottomAnchor constant:-16]
    ]];

    return headerView;
}

- (CGFloat)tableView:(UITableView*)tableView
 heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? UITableViewAutomaticDimension : 0;
}

#pragma mark - Section Footer

- (UIView*)tableView:(UITableView*)tableView
 viewForFooterInSection:(NSInteger)section {

    if (section == 0) {
        UIView* separator = [[UIView alloc] initWithFrame:CGRectZero];
        separator.backgroundColor = [UIColor separatorColor];
        return separator;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView*)tableView
 heightForFooterInSection:(NSInteger)section {

    if (section == 0) {
        return 1.0 / UIScreen.mainScreen.scale;
    }

    return CGFLOAT_MIN;
}

#pragma mark - Lifecycle & Setup

- (instancetype)initWithAccount:(TFNTwitterAccount*)account {

    self = [super init];

    if (self) {
        _account = account;
        [self setupSections];
    }

    return self;
}

- (void)setupSections {

    self.sections = @[
        @{
            @"title": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_LAYOUT_TITLE"],
            @"subtitle": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_LAYOUT_SUBTITLE"],
            @"icon": @"settings_stroke",
            @"action": @"showLayoutSettings"
        },
        @{
            @"title": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_APPEARANCE_TITLE"],
            @"subtitle": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_APPEARANCE_SUBTITLE"],
            @"icon": @"paintbrush_stroke",
            @"action": @"showAppearanceSettings"
        },
        @{
            @"title": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_GROK_TITLE"],
            @"subtitle": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_GROK_SUBTITLE"],
            @"icon": @"grok_icon_stroke",
            @"action": @"showGrokSettings"
        },
        @{
            @"title": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_TIMELINES_TITLE"],
            @"subtitle": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_TIMELINES_SUBTITLE"],
            @"icon": @"home_stroke",
            @"action": @"showTimelinesSettings"
        },
        @{
            @"title": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_TWEETS_TITLE"],
            @"subtitle": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_TWEETS_SUBTITLE"],
            @"icon": @"quill",
            @"action": @"showTweetsSettings"
        },
        @{
            @"title": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_MEDIA_TITLE"],
            @"subtitle": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_MEDIA_SUBTITLE"],
            @"icon": @"media_tab_stroke",
            @"action": @"showDownloadsSettings"
        },
        @{
            @"title": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_PROFILES_TITLE"],
            @"subtitle": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_PROFILES_SUBTITLE"],
            @"icon": @"account",
            @"action": @"showProfilesSettings"
        },
        @{
            @"title": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_CHAT_TITLE"],
            @"subtitle": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_CHAT_SUBTITLE"],
            @"icon": @"messages_stroke",
            @"action": @"showChatSettings"
        },
        @{
            @"title": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_SEARCH_TITLE"],
            @"subtitle": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_SEARCH_SUBTITLE"],
            @"icon": @"search_stroke",
            @"action": @"showSearchSettings"
        },
        @{
            @"title": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_WEB_TITLE"],
            @"subtitle": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_WEB_SUBTITLE"],
            @"icon": @"globe_stroke",
            @"action": @"showWebSettings"
        },
        @{
            @"title": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_BRANDING_TITLE"],
            @"subtitle": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_BRANDING_SUBTITLE"],
            @"icon": @"hash_stroke",
            @"action": @"showBrandingSettings"
        },
        @{
            @"title": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_PRESETS_TITLE"],
            @"subtitle": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_PRESETS_SUBTITLE"],
            @"icon": @"receipt_checkmark_stroke",
            @"action": @"showPresetsSettings"
        },
        @{
            @"title": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_EXPERIMENTAL_TITLE"],
            @"subtitle": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_EXPERIMENTAL_SUBTITLE"],
            @"icon": @"flask",
            @"action": @"showExperimentalSettings"
        },
        @{
            @"title": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_DEBUG_TITLE"],
            @"subtitle": [[BHTBundle sharedBundle]
                localizedStringForKey:@"MODERN_SETTINGS_DEBUG_SUBTITLE"],
            @"icon": @"code",
            @"action": @"showDebugSettings"
        }
    ];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavigationBar];
    [self setupTableView];
    [self setupLayout];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(contentSizeCategoryDidChange:)
               name:UIContentSizeCategoryDidChangeNotification
             object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contentSizeCategoryDidChange:(NSNotification*)notification {
    [self.tableView reloadData];
}

- (void)setupNavigationBar {

    self.view.backgroundColor = [Palette currentBackgroundColor];

    if (self.account) {
        self.navigationItem.titleView =
            [objc_getClass("TFNTitleView")
                titleViewWithTitle:[[BHTBundle sharedBundle]
                    localizedStringForKey:@"NFB_SETTINGS_TITLE"]
                subtitle:self.account.displayUsername];
    } else {
        self.title = [[BHTBundle sharedBundle]
            localizedStringForKey:@"NFB_SETTINGS_TITLE"];
    }
}

- (void)setupTableView {

    self.tableView =
        [[UITableView alloc] initWithFrame:CGRectZero
                                     style:UITableViewStyleGrouped];

    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [Palette currentBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = 50;
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;

    [self.tableView registerClass:[ModernSettingsTableViewCell class]
           forCellReuseIdentifier:@"SettingsCell"];

    [self.view addSubview:self.tableView];
}

- (void)setupLayout {

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor
            constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor
            constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor
            constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor
            constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section {

    return section == 0 ? self.sections.count : 0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {

    ModernSettingsTableViewCell* cell =
        [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"
                                        forIndexPath:indexPath];

    NSDictionary* sectionData = self.sections[indexPath.row];

    [cell configureWithTitle:sectionData[@"title"]
                    subtitle:sectionData[@"subtitle"]
                    iconName:sectionData[@"icon"]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView
 didSelectRowAtIndexPath:(NSIndexPath*)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary* sectionData = self.sections[indexPath.row];
    NSString* action = sectionData[@"action"];
    SEL selector = NSSelectorFromString(action);

    if ([self respondsToSelector:selector]) {
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL) = (void*)imp;
        func(self, selector);
    }
}

#pragma mark - Navigation to Settings Pages

- (void)showLayoutSettings {

    ModernSettingsPageViewController* vc =
        [[ModernSettingsPageViewController alloc]
            initWithAccount:self.account
                    pageKey:@"general"];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showAppearanceSettings {

    AppearanceSettingsViewController* vc =
        [[AppearanceSettingsViewController alloc]
            initWithAccount:self.account];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showTimelinesSettings {

    TimelinesSettingsViewController* vc =
        [[TimelinesSettingsViewController alloc]
            initWithAccount:self.account];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showGrokSettings {

    ModernSettingsPageViewController* vc =
        [[ModernSettingsPageViewController alloc]
            initWithAccount:self.account
                    pageKey:@"grok"];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showDownloadsSettings {

    ModernSettingsPageViewController* vc =
        [[ModernSettingsPageViewController alloc]
            initWithAccount:self.account
                    pageKey:@"media_downloads"];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showProfilesSettings {

    ProfilesSettingsViewController* vc =
        [[ProfilesSettingsViewController alloc]
            initWithAccount:self.account];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showTweetsSettings {

    TweetsSettingsViewController* vc =
        [[TweetsSettingsViewController alloc]
            initWithAccount:self.account];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showBrandingSettings {

    ModernSettingsPageViewController* vc =
        [[ModernSettingsPageViewController alloc]
            initWithAccount:self.account
                    pageKey:@"branding"];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showExperimentalSettings {

    ModernSettingsPageViewController* vc =
        [[ModernSettingsPageViewController alloc]
            initWithAccount:self.account
                    pageKey:@"experimental"];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showDebugSettings {

    DebugSettingsViewController* vc =
        [[DebugSettingsViewController alloc]
            initWithAccount:self.account];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showSearchSettings {

    ModernSettingsPageViewController* vc =
        [[ModernSettingsPageViewController alloc]
            initWithAccount:self.account
                    pageKey:@"search"];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showWebSettings {

    WebSettingsViewController* vc =
        [[WebSettingsViewController alloc]
            initWithAccount:self.account];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showPresetsSettings {

    PresetsSettingsViewController* vc =
        [[PresetsSettingsViewController alloc]
            initWithAccount:self.account];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showChatSettings {

    ChatSettingsViewController* vc =
        [[ChatSettingsViewController alloc]
            initWithAccount:self.account];

    [self.navigationController pushViewController:vc animated:YES];
}

@end
