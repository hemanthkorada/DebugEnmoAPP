//
//  MainViewController.m
//  enmo autolock
//


#import "MainViewController.h"
//@class  AppDelegate;
#import "AppDelegate.h"
//#import "RulesManager.h"
//#import "BeaconsManager.h"
//#import "EnmoSDK/EnmoSDK.h"



#define CLEANUP_HTML       @"<html><head></head><body></body></html>"
#define FAILED_HTML         @"<html><head></head><body>Failed to load URL: %@</body></html>"


MainViewController * mainViewController = nil;
NSString * urlToCallUponLoad = nil;

@interface MainViewController()

@property ( nonatomic, weak ) IBOutlet UIWebView * webView;
@property ( nonatomic, weak ) IBOutlet UIActivityIndicatorView * activityIndicator;
@property ( nonatomic, weak ) IBOutlet UILabel * lblAppVersion;
@property ( nonatomic, weak ) IBOutlet UIButton * btnNavigateBack;

@end


@implementation MainViewController

//==============================================================================
+ ( MainViewController * ) shared
{
	return mainViewController;
}


//==============================================================================
- ( void ) awakeFromNib
{
	[ super awakeFromNib ];

	mainViewController = self;
	
    AppDelegate * appDelegate = ( AppDelegate * ) [ [ UIApplication sharedApplication ] delegate ];
    appDelegate.mainViewController = self;

    /*Implementing the Enmomanager  delegate*/
    
   ((EnmoManager *)[EnmoManager shared]).delegate = (MainViewController *) self;
    
	_arrayHistory = [ [ NSMutableArray alloc ] init ];
}


//==============================================================================
- ( void ) viewDidLoad
{
    [ super viewDidLoad ];

	[ self.activityIndicator setHidden: YES ];
	[ self.activityIndicator stopAnimating ];

	// TODO: polish for Auto-Lock app - it still has nav bar
//	[ self navigationItem ].rightBarButtonItem.image = [ UIImage imageNamed: @"Settings" ];
//
//	UIBarButtonItem * barButton = [ [ UIBarButtonItem alloc ] initWithTitle: @""
//																	  style: UIBarButtonItemStylePlain
//																	 target: self
//																	 action: nil ];
//
//	[ self navigationItem ].leftBarButtonItem = barButton;
//	[ self.navigationController.navigationBar addSubview: self.activityIndicator ];

	self.webView.delegate = self;

	if(urlToCallUponLoad.length)
	{
		[ self loadModifiedRequestFromURLString: urlToCallUponLoad andResetHistory: YES ];
		urlToCallUponLoad = nil;
	}
}


NSString * urlToLoad = nil;

//==============================================================================
- ( void ) viewDidAppear:(BOOL)animated
{
	[ super viewDidAppear: animated ];
	[ self showURLFromString: urlToLoad ];
}

//==============================================================================
- ( IBAction ) onBtnBack: ( id ) sender
{
	NSString * myURL = [ [ NSUserDefaults standardUserDefaults ] objectForKey: @"lastURL" ];

	if( _arrayHistory.count == 0 )
		return;

	NSString * urlString = @"";

	if( _arrayHistory.count == 1 )
		urlString = [ _arrayHistory objectAtIndex: 0 ];
	else if( _arrayHistory.count > 1 )
	{
		urlString = [ _arrayHistory lastObject ];
		[ _arrayHistory removeLastObject ];

		if( [ _lastLoadedRequest isEqualToString: myURL ] && [ urlString isEqualToString: myURL ] )
		{
			urlString = [ _arrayHistory lastObject ];
			[ _arrayHistory removeLastObject ];
		}
	}

	[ self.webView stopLoading ];

//	[ self.webView loadRequest: [ NSURLRequest requestWithURL: [ NSURL URLWithString: urlString ] ] ];
	urlToLoad = urlString;
	[ self showURLFromString: urlToLoad ];
}


//==============================================================================
- ( IBAction ) onBtnUpdateAdvertiserID: ( id ) sender
{
//    [ [ RulesManager shared ] getUsersAdvertiserIDWithCompletionBlock: ^{} ]; //Commented FL
    
    [[EnmoManager shared] getUsersAdvertiserIDWithCompletionBlock:^{}];
}


//==============================================================================
- ( void ) showURLFromString: ( NSString * ) urlString
{
	if( urlString.length != 0 ) {
		NSLog(@"\n\n\n=========================\nWEB VIEW: SHOWING URL:\n%@\n=========================\n\n\n", urlString);
		[ self.webView loadRequest: [ NSURLRequest requestWithURL: [ NSURL URLWithString: urlString ] ] ];
	}
}


//==============================================================================
- ( void ) cleanWebView
{
    [ self.webView loadHTMLString: @"" baseURL: nil ];
}


//==============================================================================
- ( void ) showLoadFailedForURL: ( NSString * ) urlString
{
    [ self.webView loadHTMLString: [ NSString stringWithFormat: FAILED_HTML, urlString ]
                          baseURL: nil ];
}


//==============================================================================
- ( void ) loadModifiedRequestFromURLString: ( NSString * ) urlString
							andResetHistory: ( BOOL ) shouldResetHistory
{
//    [ Logger logToConsole: [ NSString stringWithFormat: @"WEB VIEW loadModifiedRequestFromURLString: %@", urlString ] ]; //Commented FL
    
    [[EnmoManager shared] logToConsoleWithData:[ NSString stringWithFormat: @"WEB VIEW loadModifiedRequestFromURLString: %@", urlString ]];
    

    [ self.webView stopLoading ];

	if( shouldResetHistory )
		[ _arrayHistory removeAllObjects ];


	if( self.isViewLoaded == NO )
	{
		urlToCallUponLoad = urlString;
		return;
	}

    if( urlString.length == 0 )
	{
		NSLog( @"!!!!! WEB VIEW %@ !!!!!\nloading URL: %@", self.webView, CLEANUP_HTML );
        [ self.webView loadHTMLString: CLEANUP_HTML baseURL: nil ];
	}
    else
	{
		NSLog( @"!!!!! WEB VIEW %@ !!!!!\nloading URL: %@", self.webView, urlString );
		urlToLoad = [ urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding ];
		[ self showURLFromString: urlToLoad ];
	}

//    [ RulesManager showTestLocalNotificationWithText: [ NSString stringWithFormat: @"URL: %@", urlString ] ]; //Commented FL
    
    [[EnmoManager shared] showTestLocalNotificationWithText:[ NSString stringWithFormat: @"URL: %@", urlString ]];

	NSUserDefaults * settings = [ NSUserDefaults standardUserDefaults ];
    [ settings setObject: urlString forKey: @"lastURL" ];
	[ settings synchronize ];

	if( _arrayHistory.count )
	{
		NSString * lastURL = [ _arrayHistory lastObject ];
		NSArray * componentsLastURL = [ lastURL componentsSeparatedByString: @"?" ];
		NSArray * componentsNewURL = [ urlString componentsSeparatedByString: @"?" ];

		if(   componentsLastURL.count
		   && componentsNewURL.count
		   && ![ [ componentsNewURL objectAtIndex: 0 ] isEqualToString: [ componentsLastURL objectAtIndex: 0 ] ]
		   )
		{
			[ _arrayHistory addObject: urlString ];
		}
	}
	else
	{
		[ _arrayHistory addObject: urlString ];
	}
}


#pragma mark - RulesManagerDelegate

/* Currently implementing the callbacks from enmo insted of firectly implementing calll backs from the Rules manager*/
- (void)enmoManagerDidDeliverURL:(NSString *)url {
    
#ifdef AUTOLOCK
    
    NSRange rangeAutoLockService = [ url rangeOfString: @"AutoLockService.asmx" ];
    
    if( rangeAutoLockService.location != NSNotFound )
        return;
    
#endif
    
    [ self loadModifiedRequestFromURLString: url andResetHistory: NO ];
}

- (void)enmoManagerDidFailRulesParsing {
    [ self.activityIndicator stopAnimating ];
    [ self.activityIndicator setHidden: YES ];
    //    [ RulesManager showTestLocalNotificationWithText: @"Failed to get Rules." ]; //Commented FL
    [[EnmoManager shared] showTestLocalNotificationWithText:@"Failed to get Rules."];
}

- (void)rulesManagerDidFinishRulesParsing {
    [ self.activityIndicator stopAnimating ];
    [ self.activityIndicator setHidden: YES ];
    [ _arrayHistory removeAllObjects ];
}

- (void)enmoManagerDidStartRulesLoading{
    [ self.activityIndicator setHidden: NO ];
    [ self.activityIndicator startAnimating ];
}

- (void)enmoManagerWillLogout {
    [ self cleanWebView ];
}



/*Commned FL*/
/*
//==============================================================================
- ( void ) rulesManagerDidStartRulesLoading
{
    [ self.activityIndicator setHidden: NO ];
    [ self.activityIndicator startAnimating ];
}


//==============================================================================
- ( void ) rulesManagerDidFailRulesParsing
{
    [ self.activityIndicator stopAnimating ];
    [ self.activityIndicator setHidden: YES ];

//    [ RulesManager showTestLocalNotificationWithText: @"Failed to get Rules." ]; //Commented FL
    
    [[EnmoManager shared] showTestLocalNotificationWithText:@"Failed to get Rules."];
    
}


//==============================================================================
- ( void ) rulesManagerDidFinishRulesParsing
{
    [ self.activityIndicator stopAnimating ];
    [ self.activityIndicator setHidden: YES ];
	[ _arrayHistory removeAllObjects ];
}


//==============================================================================
- ( void ) rulesManagerDidCallURL: ( NSString * ) url
{

#ifdef AUTOLOCK

	NSRange rangeAutoLockService = [ url rangeOfString: @"AutoLockService.asmx" ];

	if( rangeAutoLockService.location != NSNotFound )
		return;
	
#endif

	[ self loadModifiedRequestFromURLString: url andResetHistory: NO ];
}


//==============================================================================
- ( void ) rulesManagerWillLogout
{
	[ self cleanWebView ];
}
 */


#pragma mark - UIWebViewDelegate

//==============================================================================
- ( void ) webViewDidFinishLoad: ( UIWebView * ) webView
{
    [ self.activityIndicator stopAnimating ];
    [ self.activityIndicator setHidden: YES ];
}


//==============================================================================
- ( void ) webView: ( UIWebView * ) webView
didFailLoadWithError: ( NSError * ) error
{
    [ self.activityIndicator stopAnimating ];
    [ self.activityIndicator setHidden: YES ];
}


//==============================================================================
- ( BOOL ) webView: ( UIWebView * ) webView
shouldStartLoadWithRequest: ( NSURLRequest * ) request
    navigationType: ( UIWebViewNavigationType ) navigationType
{
	[ self.activityIndicator startAnimating ];
	[ self.activityIndicator setHidden: NO ];

    __block NSString * urlString = request.URL.absoluteString;

    // check if we need to add params to URL
    NSRange rangePrefixEnmo = [ urlString rangeOfString: @"enmo.cloudapp.net/m/" ];
    NSRange rangePrefixAtmio = [ urlString rangeOfString: @"atmio.com/m/" ];

    // if current redirect string contains needed prefix and this string doesn't have any params in query - substitute URL
    if( rangePrefixEnmo.location != NSNotFound || rangePrefixAtmio.location != NSNotFound )
    {
		NSRange range2 = [ urlString rangeOfString: @"DID=" ];

		if( range2.location == NSNotFound )
        {
//            [ Logger logToConsole: [ NSString stringWithFormat: @"In WEB VIEW %@", urlString ] ]; //Commented FL
            
            [[EnmoManager shared] logToConsoleWithData:[ NSString stringWithFormat: @"In WEB VIEW %@", urlString ]];
            

//            urlString = [ [ RulesManager shared ] addExtraFieldsToURL: urlString
//                                                             withRule: nil
//                                                   andTriggeredRegion: nil ]; //Commented FL
            
          urlString =  [[EnmoManager shared] addExtraFieldsToURL:urlString withRule:nil andTriggeredRegion:nil];
            
            

            [ self loadModifiedRequestFromURLString: [ urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding ]
									andResetHistory: NO ];

			[ self.activityIndicator stopAnimating ];
			[ self.activityIndicator setHidden: YES ];
			
            return NO;
        }
	}

	_lastLoadedRequest = urlString;

	return YES;
}

@end
