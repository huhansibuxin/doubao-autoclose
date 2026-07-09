static NSString *const kDoubaoBundleID = @"com.bytedance.ios.doubaoime";
static NSString *const kDoubaoKBBundleID = @"com.bytedance.ios.doubaoime.keyboard";

%hook SBMainWorkspace

- (void)_handleOpenApplicationRequest:(id)request
                              options:(id)options
                  activationSettings:(id)settings
                              origin:(id)origin
                          withResult:(id)result {

    NSString *sourceBundleID = nil;
    @try {
        id app = [request sourceApplication];
        if (app) {
            sourceBundleID = [app bundleIdentifier];
        }
    } @catch (NSException *e) {}

    if ([sourceBundleID isEqualToString:kDoubaoBundleID]
     || [sourceBundleID isEqualToString:kDoubaoKBBundleID]) {
        return; // 拦截豆包输入法的跳转请求，不让弹窗出现
    }

    %orig;
}

%end
