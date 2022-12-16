#import "WebSharePlugin.h"
#import <Cordova/CDV.h>

@implementation WebSharePlugin

- (void)share:(CDVInvokedUrlCommand*)command {
    NSDictionary* options = [command argumentAtIndex:0 withDefault:@{} andClass:[NSDictionary class]];
    NSMutableArray* activityItems = [[NSMutableArray alloc] init];

    if (options[@"text"]) {
        [activityItems addObject:options[@"text"]];
    }
    if (options[@"url"]) {
        NSString* url =options[@"url"];
        if([self checkUrlWithString:url] == NO) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        [activityItems addObject:[NSURL URLWithString:url]];
    }

    if ([activityItems count] == 0) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        UIActivityViewController* dlg = [[UIActivityViewController alloc]
                                              initWithActivityItems:activityItems
                                              applicationActivities:NULL];

        dlg.excludedActivityTypes = options[@"iosExcludedActivities"];
        if (options[@"title"]) {
            [dlg setValue:options[@"title"] forKey:@"subject"];
        }

        UIPopoverPresentationController *popover = dlg.popoverPresentationController;
        if (popover) {
            popover.permittedArrowDirections = 0;
            popover.sourceView = self.webView.superview;
            popover.sourceRect = CGRectMake(CGRectGetMidX(self.webView.bounds), CGRectGetMidY(self.webView.bounds), 0, 0);
        }

        dlg.completionWithItemsHandler = ^(NSString *activityType,
                                          BOOL completed,
                                          NSArray *returnedItems,
                                          NSError *error){
            CDVPluginResult* pluginResult = NULL;
            if (error) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
            } else {
                NSMutableArray *packageNames = [[NSMutableArray alloc] init];
                if (completed) {
                    [packageNames addObject:activityType];
                }
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:packageNames];
            }

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        };

        [self.getTopPresentedViewController presentViewController:dlg animated:YES completion:NULL];
    }
}

-(UIViewController *)getTopPresentedViewController {
    UIViewController *presentingViewController = self.viewController;
    while(presentingViewController.presentedViewController != nil && ![presentingViewController.presentedViewController isBeingDismissed])
    {
        presentingViewController = presentingViewController.presentedViewController;
    }
    return presentingViewController;
}

- (BOOL)checkUrlWithString:(NSString *)url {
    if(url.length < 1)
        return NO;
    if (url.length>4 && [[url substringToIndex:4] isEqualToString:@"www."]) {
        url = [NSString stringWithFormat:@"http://%@",url];
    } else {
        url = url;
    }
    NSString *urlRegex = @"(https|http|ftp|rtsp|igmp|file|rtspt|rtspu)://((((25[0-5]|2[0-4]\\d|1?\\d?\\d)\\.){3}(25[0-5]|2[0-4]\\d|1?\\d?\\d))|([0-9a-z_!~*'()-]*\\.?))([0-9a-z][0-9a-z-]{0,61})?[0-9a-z]\\.([a-z]{2,6})(:[0-9]{1,4})?([a-zA-Z/?_=]*)\\.\\w{1,5}";
 
    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
 
    return [urlTest evaluateWithObject:url];
}

@end
