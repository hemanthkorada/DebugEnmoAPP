//
//  EnmoManager.h
//  EnmoSDK
//
//  Created by APPLE on 14/03/18.
//  Copyright © 2018 APPLE. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_URL_TO_SHOW_UPON_FOREGROUND            @"URLtoShowUponForeground"


@protocol EnmoManagerDelegate <NSObject>

@required

- (void)enmoManagerDidDeliverURL:(NSString *)url;
- (void)enmoManagerDidFailRulesParsing;
- (void)rulesManagerDidFinishRulesParsing;
- (void)enmoManagerDidStartRulesLoading;
- (void)enmoManagerWillLogout;

@end


@protocol EnmoStopThirdPartyRangingDelegate < NSObject >

@required

- ( void ) enmostop3rdPartyRanging;
@end


@interface EnmoManager : NSObject <RulesManagerDelegate,StopThirdPartyRangeingDelegate> {
    
}

@property (strong, nonatomic) void (^fetchCompletionHandler)(UIBackgroundFetchResult);
@property (nonatomic, weak) id <EnmoManagerDelegate> delegate;
@property (nonatomic, weak) id <EnmoStopThirdPartyRangingDelegate> enmoStopThirdPartydelegate;



+ (EnmoManager*) shared;

- (void) start3rdPartyRanging;

- (void) stop3rdPartyRanging;

- (void) loadRulesFromServer: (BOOL) isForced;

- (NSInteger) appIdTimer;

- (BOOL) checkNewRules;

- (void) setAdvertiserId: (int) advID;

- (int) getAdvertiserId;

- (void) prepareForAppTerminate;

/////////

- (void) setRulesManagerDelegate:(id) instanceObject;

- (void) logToConsoleWithData:(NSString *) message;

- (void) showTestLocalNotificationWithText:(NSString *) notificationMessage;

- ( void ) getRulesFromServer: ( BOOL ) isForced;

- ( void ) loadLocalRules;


- ( NSString * ) addExtraFieldsToURL: ( NSString * ) urlString1
                            withRule: ( EnmoRule * ) rule
                  andTriggeredRegion: ( id ) triggeredRegion;

- ( void ) getUsersAdvertiserIDWithCompletionBlock: ( void ( ^ ) ( void ) ) resultBlock;

- ( void ) showOKAlertWithTitle: ( NSString * ) title
                        message: ( NSString * ) message
                 andResultBlock: ( void ( ^ ) ( void ) ) resultBlock;


- (void) setSignalStrength:(NSInteger) signalStrength;

- (NSInteger) getSignalStrength;

- (void)setDwellTimeTimeout:(NSInteger) dwellTimeTimeout;

- (NSInteger) getDwellTimeTimeout;

- (void)setExitSignalStrength:(NSInteger) exitSignalStrength;

- (NSInteger) getExitSignalStrength;

- (void) setStayAwayTimeout:(NSInteger) stayAwatTimeout;

- (NSInteger) getStayAwayTimeout;

- (void) setStayAwayTimeoutBG:(NSUInteger) stayAwayTimeOutBG;

- (NSInteger) getStayAwayTimeoutBG;

- (void) resetFrequencyCaps;

- (void) prepareForLogout;

- (void) sendManualLockMessage;

- ( void ) sendEmailWithViewController: ( UIViewController * ) controller;

- ( void ) cleanup;

- ( void ) addString: ( NSString * ) string;

-(void) setcurrentAppIdTimeStamp:(NSString *)timeStamp;





@end
