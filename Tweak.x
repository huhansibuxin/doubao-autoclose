static NSString *const kDoubaoBundleID = @"com.bytedance.ios.doubaoime";
static NSString *const kDoubaoKBBundleID = @"com.bytedance.ios.doubaoime.keyboard";

%hook SBMainWorkspace

- (void)_handleOpenApplicationRequest:(id)request
                              options:(id)options
                  activationSettings:(id)settings
                              origin:(id)origin
                          withResult:(id)result {

    NSString *sourceBundleID = nil;
    NSString *targetBundleID = nil;

    @try {
        id srcApp = [request sourceApplication];
        id tgtApp = [request application];
        if (srcApp) sourceBundleID = [srcApp bundleIdentifier];
        if (tgtApp) targetBundleID = [tgtApp bundleIdentifier];
    } @catch (NSException *e) {}

    BOOL isDoubao = [sourceBundleID isEqualToString:kDoubaoBundleID]
                 || [sourceBundleID isEqualToString:kDoubaoKBBundleID];

    // 让弹窗正常出来
    %orig;

    // 延迟 1.5 秒后自动关闭分屏小窗
    if (isDoubao && targetBundleID) {
        NSString *bid = [targetBundleID copy];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            SBMainWorkspace *ws = (SBMainWorkspace *)[NSClassFromString(@"SBMainWorkspace") sharedInstance];

            // 尝试多种关闭 overlay / slide-over 的方式
            SEL selectors[] = {
                NSSelectorFromString(@"_closeApplicationWithBundleID:animate:options:userInfo:result:"),
                NSSelectorFromString(@"dismissOverlay"),
                NSSelectorFromString(@"_closeOverlayApplication"),
            };

            for (int i = 0; i < 3; i++) {
                if ([ws respondsToSelector:selectors[i]]) {
                    NSMethodSignature *sig = [ws methodSignatureForSelector:selectors[i]];
                    if (sig) {
                        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
                        [inv setTarget:ws];
                        [inv setSelector:selectors[i]];
                        if (sig.numberOfArguments > 2) {
                            [inv setArgument:&bid atIndex:2];
                            BOOL animate = NO;
                            if (sig.numberOfArguments > 3) [inv setArgument:&animate atIndex:3];
                        }
                        [inv invoke];
                        return;
                    }
                }
            }
        });
    }
}

%end
