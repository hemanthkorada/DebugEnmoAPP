//
//  EnmoManager.m
//  EnmoSDK
//
//  Created by APPLE on 14/03/18.
//  Copyright © 2018 APPLE. All rights reserved.
//

#import "EnmoManager.h"
#import "GimbalsManager.h"
#import "EddystoneManager.h"


EnmoManager *enmoManager = nil;

@implementation EnmoManager

+ (EnmoManager *) shared {
    {
        if( enmoManager == nil )
            enmoManager = [ [ EnmoManager alloc ] init ];
        
        if ([RulesManager shared].delegate != nil){
            [RulesManager shared].delegate = (EnmoManager *) self;
            [RulesManager shared].stopRangingDelegate = (EnmoManager *) self;
        }
        return enmoManager;
    }
}

- (BOOL) checkNewRules {
    return  [ [ RulesManager shared ] checkForNewRules ];
}

- ( void ) start3rdPartyRanging
{
    [ [ GimbalsManager shared ] startMonitoring ];
    [ [ EddystoneManager shared ] startScanning ];
}

- ( void ) stop3rdPartyRanging
{
    [ [ GimbalsManager shared ] stopMonitoring ];
    [ [ EddystoneManager shared ] stopScanning ];
}

- ( void ) loadRulesFromServer: (BOOL) isForced
{
    [ [ RulesManager shared ] getRulesFromServer: NO ];
}

- ( NSInteger ) appIdTimer{
    return  [ RulesManager shared ].currentAppId.timer;
}

-(void) setcurrentAppIdTimeStamp:(NSString *)timeStamp {
    [ RulesManager shared ].currentAppId.timestamp  = timeStamp;
}

- ( void ) setAdvertiserId: (int) advID {
    [ RulesManager shared ].advertiserId = advID;

}
- ( int ) getAdvertiserId {
    return (int)[ RulesManager shared ].advertiserId;
}

- (void)prepareForAppTerminate {
    [ [ RulesManager shared ] saveMonitoredRegions ];
}

- (void) setRulesManagerDelegate:(id) instanceObject {
    
    [ RulesManager shared ].delegate = instanceObject;
}

-(void) logToConsoleWithData:(NSString *)message {
    [ Logger logToConsole: message ];
}

- ( void ) getRulesFromServer: ( BOOL ) isForced {
    [ [ RulesManager shared ] getRulesFromServer: NO ];
}

- ( void ) loadLocalRules{
    
    [ [ RulesManager shared ] loadLocalRules ];
}

- (void) showTestLocalNotificationWithText:(NSString *) notificationMessage {
    
    [ RulesManager showTestLocalNotificationWithText: notificationMessage];
}


//==============================================================================
- ( NSString * ) addExtraFieldsToURL: ( NSString * ) urlString1
                            withRule: ( EnmoRule * ) rule
                  andTriggeredRegion: ( id ) triggeredRegion
{
  return  [ [ RulesManager shared ] addExtraFieldsToURL: urlString1
                                         withRule: rule
                               andTriggeredRegion: triggeredRegion ];
}
- ( void ) getUsersAdvertiserIDWithCompletionBlock: ( void ( ^ ) ( void ) ) resultBlock
{
    [ [ RulesManager shared ] getUsersAdvertiserIDWithCompletionBlock: resultBlock ];
}

- ( void ) showOKAlertWithTitle: ( NSString * ) title
                        message: ( NSString * ) message
                 andResultBlock: ( void ( ^ ) ( void ) ) resultBlock{
    
    [ UIAlerter showOKAlertWithTitle: title
                             message: message
                      andResultBlock: resultBlock
     ];
}

// ******************** //Settings Screen    *************

- (void) setSignalStrength:(NSInteger) signalStrength {
    [ GimbalsManager shared ].enterSignalStrength = signalStrength;
}

- (NSInteger) getSignalStrength;
{
    return [ GimbalsManager shared ].enterSignalStrength;
}

- (void)setDwellTimeTimeout:(NSInteger) dwellTimeTimeout {
    [ GimbalsManager shared ].dwellTimeTimeout  = dwellTimeTimeout;
}

- (NSInteger) getDwellTimeTimeout {
    return[ GimbalsManager shared ].dwellTimeTimeout;
}

- (void)setExitSignalStrength:(NSInteger) exitSignalStrength {
    [ GimbalsManager shared ].exitSignalStrength = exitSignalStrength;
}

- (NSInteger) getExitSignalStrength{
    return [ GimbalsManager shared ].exitSignalStrength;
}

- (void) setStayAwayTimeout:(NSInteger) stayAwatTimeout{
    [ GimbalsManager shared ].stayAwayTimeout = stayAwatTimeout;
}

- (NSInteger) getStayAwayTimeout{
    return  [ GimbalsManager shared ].stayAwayTimeout;
}

- (void) setStayAwayTimeoutBG:(NSUInteger) stayAwayTimeOutBG {
    [ GimbalsManager shared ].stayAwayTimeoutBG = stayAwayTimeOutBG;
}

- (NSInteger) getStayAwayTimeoutBG {
    return [ GimbalsManager shared ].stayAwayTimeoutBG;
}

-(void) resetFrequencyCaps {
    [ [ RulesManager shared ] resetFrequencyCaps ];
}

-(void) prepareForLogout {
    [ [ RulesManager shared ] prepareForLogout ];
}

-(void) sendManualLockMessage{
    [ [ RulesManager shared ] sendManualLockMessage ];
}

- ( void ) sendEmailWithViewController: ( UIViewController * ) controller {
    [ [ EmailManager shared ] sendEmailWithViewController: controller ];
}

- ( void ) cleanup {
    [ [ EmailManager shared ] cleanup ];
}

- ( void ) addString: ( NSString * ) string {
    [ [ EmailManager shared ] addString: string ];
}

//Call backs fo Rules manager

- (void)rulesManagerDidCallURL:(NSString *)url {
    [self.delegate enmoManagerDidDeliverURL:url];
}

- (void)rulesManagerDidFailRulesParsing {
    [self.delegate enmoManagerDidFailRulesParsing];
}

- (void)rulesManagerDidFinishRulesParsing {
    [self.delegate enmoManagerDidFailRulesParsing];
}

- (void)rulesManagerDidStartRulesLoading {
    [self.delegate enmoManagerDidStartRulesLoading];
}

- (void)rulesManagerWillLogout {
    [self.delegate enmoManagerWillLogout];
}

//-(void) stopThirdPartyRangeingDelegate
//{
//}

- (void)rulesManagerDidStop3rdPartyRanging {
    [self.enmoStopThirdPartydelegate  enmostop3rdPartyRanging];

}

@end
