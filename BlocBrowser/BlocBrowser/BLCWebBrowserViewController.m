//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by Trevor Vieweg on 5/17/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "BLCWebBrowserViewController.h"
#import "BLCAwesomeFloatingToolbar.h"

#define kBLCWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kBLCWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kBLCWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kBLCWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

@interface BLCWebBrowserViewController() <UIWebViewDelegate, UITextFieldDelegate, BLCAwesomeFloatingToolbarDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) BLCAwesomeFloatingToolbar *awesomeToolbar;

@property (nonatomic, assign) NSUInteger frameCount;

@end

@implementation BLCWebBrowserViewController

#pragma mark - UIViewController ************************************************************************

- (void)loadView {
    
    //create main view
    UIView *mainView = [UIView new];
    
    //create webview
    self.webview = [[UIWebView alloc] init];
    self.webview.delegate = self;
    
    //create text field for URL bar
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Search or enter website name", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0 alpha:1];
    self.textField.delegate = self;
    
    //generate toolbar
    self.awesomeToolbar = [[BLCAwesomeFloatingToolbar alloc] initWithFourTitles:@[kBLCWebBrowserBackString, kBLCWebBrowserForwardString, kBLCWebBrowserStopString, kBLCWebBrowserRefreshString]];
    self.awesomeToolbar.delegate = self;
    
    //add to the main view, and add main view to the viewcontroller
    for (UIView *viewToAdd in @[self.webview, self.textField, self.awesomeToolbar]) {
        [mainView addSubview:viewToAdd];
    }
    self.view = mainView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //activity indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width,browserHeight);
    
    self.awesomeToolbar.frame = CGRectMake(20, 100, 280, 60);
}

#pragma mark - UITextFieldDelegate ************************************************************************

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *URLString = textField.text;
    
    //if user either included spaces or did not add a ".com" or similar address
    if ([URLString containsString:@" "] || ![URLString containsString:@"."]) {
        URLString = [URLString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *googleSearch = @"http://www.google.com/search?q=";
        URLString = [googleSearch stringByAppendingString:URLString];
    }
    NSURL *URL = [NSURL URLWithString: URLString];
    
    if(!URL.scheme) {
        //The user didn't type http: or https:
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
    }
    
    if (URL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webview loadRequest:request];
    }
    
    return NO;
}

#pragma mark - UIWebViewDelegate ************************************************************************

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.frameCount++;
    [self updateButtonsAndTitle];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.frameCount--;
    [self updateButtonsAndTitle];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if (error.code != -999) {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"Error")
                                                        message:[error localizedDescription]
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                              otherButtonTitles: nil];
        
        [alert show];
    }
    
    [self updateButtonsAndTitle];
    self.frameCount--;
}

#pragma mark - BLCAwesomeFloatingToolbarDelegate

- (void) floatingToolbar:(BLCAwesomeFloatingToolbar *)awesome didSelectButtonWithTitle:(NSString *)title {
    if ([title isEqual:kBLCWebBrowserBackString]) {
        [self.webview goBack];
    } else if ([title isEqual:kBLCWebBrowserForwardString]) {
        [self.webview goForward];
    } else if ([title isEqual: kBLCWebBrowserStopString]) {
        [self.webview stopLoading];
    } else if ([title isEqual:kBLCWebBrowserRefreshString]) {
        [self.webview reload];
    }
}

#pragma mark - Miscellaneous ************************************************************************

- (void) updateButtonsAndTitle {
    NSString *webpageTitle = [self.webview stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (webpageTitle) {
        self.title = webpageTitle;
    } else {
        self.title = self.webview.request.URL.absoluteString;
    }
    
    if (self.frameCount > 0) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
    
    [self.awesomeToolbar setEnabled:[self.webview canGoBack] forButtonWithTitle:kBLCWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webview canGoForward] forButtonWithTitle:kBLCWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:self.frameCount > 0 forButtonWithTitle:kBLCWebBrowserStopString];
    [self.awesomeToolbar setEnabled:self.webview.request.URL && self.frameCount == 0 forButtonWithTitle:kBLCWebBrowserRefreshString];
    
}

- (void) resetWebView {
    [self.webview removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc] init];
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webview = newWebView;
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
}

@end
