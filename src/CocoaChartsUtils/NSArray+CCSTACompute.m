//
//  NSArray+CCSTACompute.m
//  CocoaChartsUtils
//
//  Created by zhourr on 12/27/13.
//
//  Copyright (C) 2013 ShangHai Okasan-Huada computer system CO.,LTD. All Rights Reserved.
//  See LICENSE.txt for this file’s licensing information
//

#import "NSArray+CCSTACompute.h"

#import "CCSColoredStickChartData.h"
#import "CCSCandleStickChartData.h"
#import "CCSLineData.h"
#import "CCSMACDData.h"

#import "CCSOHLCVDData.h"

#import "ta_libc.h"
#import "CCSTALibUtils.h"
#import "CCSStringUtils.h"
#import "NSString+UserDefault.h"
#import "NSString+UIColor.h"

#define WR_NONE_DISPLAY 1

#define AXIS_CALC_PARM  1000

#define SOURCE_DATE_FORMAT                              @"yyyyMMddHHmmss"
#define TO_DATE_FORMAT                                  @"yy-MM-dd"

@implementation NSArray (CCSTACompute)

/******************************************************************************
 *   Method of Chart Compute By TALib
 ******************************************************************************/

- (CCSTitledLine *)computeMAData:(NSInteger)period{
//    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    double *inCls = malloc(sizeof(double) * self.count);
    
    for (NSUInteger index = 0; index < self.count; index++) {
        CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
//        [arrCls addObject:item.close];
        inCls[index] = [item close];
    }
    
//    NSArrayToCArray(arrCls, inCls);
    
    int outBegIdx = 0, outNBElement = 0;
    double *outReal = malloc(sizeof(double) * self.count);
    
    TA_RetCode ta_retCode = TA_MA(0,
                                  (int) (self.count - 1),
                                  inCls,
                                  (int)period,
                                  TA_MAType_SMA,
                                  &outBegIdx,
                                  &outNBElement,
                                  outReal);
    
    NSMutableArray *maData = [[NSMutableArray alloc] init];
    
    if (TA_SUCCESS == ta_retCode) {
        NSArray *arr = CArrayToNSArray(outReal, (int) self.count, outBegIdx, outNBElement);
        
        for (NSInteger index = 0; index < self.count; index++) {
            CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
            [maData addObject:[[CCSLineData alloc] initWithValue:[[arr objectAtIndex:index] doubleValue] date:[item.date dateWithFormat:SOURCE_DATE_FORMAT target:TO_DATE_FORMAT]]];
        }
    }
    
    freeAndSetNULL(inCls);
    freeAndSetNULL(outReal);
    
    CCSTitledLine *maline = [[CCSTitledLine alloc] init];
    
    if (5 == period) {
        maline.title = @"MA5";
    } else if (25 == period) {
        maline.title = @"MA25";
    }
    
    if (5 == period) {
        maline.color = [UIColor cyanColor];
    } else if (25 == period) {
        maline.color = [UIColor magentaColor];
    }
    
    maline.data = maData;
    
    return maline;
}

- (CCSTitledLine *)computeVOLMAData:(NSInteger)period{
//    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    double *inCls = malloc(sizeof(double) * self.count);
    
    for (NSUInteger index = 0; index < self.count; index++) {
        CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
//        [arrCls addObject:item.vol];
                inCls[index] = [item vol];
    }
    
//    NSArrayToCArray(arrCls, inCls);
    
    int outBegIdx = 0, outNBElement = 0;
    double *outReal = malloc(sizeof(double) * self.count);
    
    TA_RetCode ta_retCode = TA_MA(0,
                                  (int) (self.count - 1),
                                  inCls,
                                  (int)period,
                                  TA_MAType_SMA,
                                  &outBegIdx,
                                  &outNBElement,
                                  outReal);
    
    NSMutableArray *maData = [[NSMutableArray alloc] init];
    
    if (TA_SUCCESS == ta_retCode) {
        NSArray *arr = CArrayToNSArray(outReal, (int) self.count, outBegIdx, outNBElement);
        
        for (NSInteger index = 0; index < self.count; index++) {
            CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
            [maData addObject:[[CCSLineData alloc] initWithValue:[[arr objectAtIndex:index] doubleValue] date:[item.date dateWithFormat:SOURCE_DATE_FORMAT target:TO_DATE_FORMAT]]];
        }
    }
    
    freeAndSetNULL(inCls);
    freeAndSetNULL(outReal);
    
    CCSTitledLine *maline = [[CCSTitledLine alloc] init];
    
    
    
//    if (5 == period) {
//        maline.title = @"MA5";
//    } else if (25 == period) {
//        maline.title = @"MA25";
//    }
//    
//    if (5 == period) {
//        maline.color = [UIColor cyanColor];
//    } else if (25 == period) {
//        maline.color = [UIColor magentaColor];
//    }
    
    maline.data = maData;
    
    return maline;
}

- (NSMutableArray *)computeMACDData: (NSInteger)optInFastPeriod optInSlowPeriod:(NSInteger)optInSlowPeriod optInSignalPeriod:(NSInteger)optInSignalPeriod{
//    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    double *inCls = malloc(sizeof(double) * self.count);
    for (NSUInteger index = 0; index < self.count; index++) {
        CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
//        [arrCls addObject:item.close];
        inCls[index] = [item close];
    }
    
//    NSArrayToCArray(arrCls, inCls);
    
    int outBegIdx = 0, outNBElement = 0;
    double *outMACD = malloc(sizeof(double) * self.count);
    double *outMACDSignal = malloc(sizeof(double) * self.count);
    double *outMACDHist = malloc(sizeof(double) * self.count);
    
    TA_RetCode ta_retCode = TA_MACD(0,
                                    (int) (self.count - 1),
                                    inCls,
                                    (int)optInFastPeriod,
                                    (int)optInSlowPeriod,
                                    (int)optInSignalPeriod,
                                    &outBegIdx,
                                    &outNBElement,
                                    outMACD,
                                    outMACDSignal,
                                    outMACDHist);
    
    NSMutableArray *MACDData = [[NSMutableArray alloc] init];
    
    if (TA_SUCCESS == ta_retCode) {
        NSArray *arrMACDSignal = CArrayToNSArray(outMACDSignal, (int) self.count, outBegIdx, outNBElement);
        NSArray *arrMACD = CArrayToNSArray(outMACD, (int) self.count, outBegIdx, outNBElement);
        NSArray *arrMACDHist = CArrayToNSArray(outMACDHist, (int) self.count, outBegIdx, outNBElement);
        
        for (NSInteger index = 0; index < self.count; index++) {
            //两倍表示MACD
            CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
            [MACDData addObject:[[CCSMACDData alloc] initWithDea:[(NSString *) [arrMACDSignal objectAtIndex:index] doubleValue]
                                                            diff:[(NSString *) [arrMACD objectAtIndex:index] doubleValue]
                                                            macd:[(NSString *) [arrMACDHist objectAtIndex:index] doubleValue] * 2
                                                            date:[item.date dateWithFormat:SOURCE_DATE_FORMAT target:TO_DATE_FORMAT]]];
        }
    }
    
    freeAndSetNULL(inCls);
    freeAndSetNULL(outMACD);
    freeAndSetNULL(outMACDSignal);
    freeAndSetNULL(outMACDHist);
    
    return MACDData;
}

- (NSMutableArray *)computeKDJData:(NSInteger)optInFastK_Period optInSlowK_Period:(NSInteger)optInSlowK_Period optInSlowD_Period:(NSInteger)optInSlowD_Period{
//    NSMutableArray *arrHigval = [[NSMutableArray alloc] init];
    double *inHigval = malloc(sizeof(double) * self.count);
    for (NSUInteger index = 0; index < self.count; index++) {
        CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
//        [arrHigval addObject:item.high];
        inHigval[index] = [item high];
    }
    
//    NSArrayToCArray(arrHigval, inHigval);
    
//    NSMutableArray *arrLowval = [[NSMutableArray alloc] init];
    double *inLowval = malloc(sizeof(double) * self.count);
    for (NSUInteger index = 0; index < self.count; index++) {
        CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
//        [arrLowval addObject:item.low];
        inLowval[index] = item.low;
    }
    
//    NSArrayToCArray(arrLowval, inLowval);
    
//    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    double *inCls = malloc(sizeof(double) * self.count);
    for (NSUInteger index = 0; index < self.count; index++) {
        CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
//        [arrCls addObject:item.close];
        inCls[index] = item.close;
    }
    
//    NSArrayToCArray(arrCls, inCls);
    
    int outBegIdx = 0, outNBElement = 0;
    double *outSlowK = malloc(sizeof(double) * self.count);
    double *outSlowD = malloc(sizeof(double) * self.count);
    
    TA_RetCode ta_retCode = TA_STOCH(0,
                                     (int) (self.count - 1),
                                     inHigval,
                                     inLowval,
                                     inCls,
                                     (int)optInFastK_Period,
                                     (int)optInSlowK_Period,
                                     TA_MAType_EMA,
                                     (int)optInSlowD_Period,
                                     TA_MAType_EMA,
                                     &outBegIdx,
                                     &outNBElement,
                                     outSlowK,
                                     outSlowD);
    
    NSMutableArray *slowKLineData = [[NSMutableArray alloc] init];
    NSMutableArray *slowDLineData = [[NSMutableArray alloc] init];
    NSMutableArray *slow3K2DLineData = [[NSMutableArray alloc] init];
    
    if (TA_SUCCESS == ta_retCode) {
        NSArray *arrSlowK = CArrayToNSArray(outSlowK, (int) self.count, outBegIdx, outNBElement);
        NSArray *arrSlowD = CArrayToNSArray(outSlowD, (int) self.count, outBegIdx, outNBElement);
        
        for (NSInteger index = 0; index < self.count; index++) {
            CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
            [slowKLineData addObject:[[CCSLineData alloc] initWithValue:[[arrSlowK objectAtIndex:index] doubleValue] date:[item.date dateWithFormat:SOURCE_DATE_FORMAT target:TO_DATE_FORMAT]]];
            [slowDLineData addObject:[[CCSLineData alloc] initWithValue:[[arrSlowD objectAtIndex:index] doubleValue] date:[item.date dateWithFormat:SOURCE_DATE_FORMAT target:TO_DATE_FORMAT]]];
            
            double slowKLine3k2d = 3 * [[arrSlowK objectAtIndex:index] doubleValue] - 2 * [[arrSlowD objectAtIndex:index] doubleValue];
            [slow3K2DLineData addObject:[[CCSLineData alloc] initWithValue:slowKLine3k2d date:[item.date dateWithFormat:SOURCE_DATE_FORMAT target:TO_DATE_FORMAT]]];
        }
    }
    
    freeAndSetNULL(inHigval);
    freeAndSetNULL(inLowval);
    freeAndSetNULL(inCls);
    freeAndSetNULL(outSlowK);
    freeAndSetNULL(outSlowD);
    
    CCSTitledLine *slowKLine = [[CCSTitledLine alloc] init];
    slowKLine.data = slowKLineData;
    slowKLine.color = LINE_COLORS[0];
    slowKLine.title = @"K";
    
    CCSTitledLine *slowDLine = [[CCSTitledLine alloc] init];
    slowDLine.data = slowDLineData;
    slowDLine.color = LINE_COLORS[1];
    slowDLine.title = @"D";
    
    CCSTitledLine *slow3K2DLine = [[CCSTitledLine alloc] init];
    slow3K2DLine.data = slow3K2DLineData;
    slow3K2DLine.color = LINE_COLORS[2];
    slow3K2DLine.title = @"J";
    
    NSMutableArray *kdjData = [[NSMutableArray alloc] init];
    [kdjData addObject:slowKLine];
    [kdjData addObject:slowDLine];
    [kdjData addObject:slow3K2DLine];
    
    return kdjData;
}

- (CCSTitledLine *)computeRSIData:(NSInteger)period{
//    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    double *inCls = malloc(sizeof(double) * self.count);
    for (NSUInteger index = 0; index < self.count; index++) {
        CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
//        [arrCls addObject:item.close];
        inCls[index] = [item close];
    }
    
//    NSArrayToCArray(arrCls, inCls);
    
    int outBegIdx = 0, outNBElement = 0;
    double *outReal = malloc(sizeof(double) * self.count);
    
    TA_RetCode ta_retCode = TA_RSI(0,
                                   (int) (self.count - 1),
                                   inCls,
                                   (int)period,
                                   &outBegIdx,
                                   &outNBElement,
                                   outReal);
    
    NSMutableArray *rsiLineData = [[NSMutableArray alloc] init];
    
    if (TA_SUCCESS == ta_retCode) {
        NSArray *arr = CArrayToNSArray(outReal, (int) self.count, outBegIdx, outNBElement);
        
        for (NSInteger index = 0; index < self.count; index++) {
            CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
            [rsiLineData addObject:[[CCSLineData alloc] initWithValue:[[arr objectAtIndex:index] doubleValue] date:[item.date dateWithFormat:SOURCE_DATE_FORMAT target:TO_DATE_FORMAT]]];
        }
    }
    
    freeAndSetNULL(inCls);
    freeAndSetNULL(outReal);
    
    CCSTitledLine *rsiLine = [[CCSTitledLine alloc] init];
    rsiLine.title = [NSString stringWithFormat:@"RSI%ld", (long)period];
    
    rsiLine.data = rsiLineData;
    
    if (6 == period) {
        rsiLine.color = [UIColor redColor];
    } else if (12 == period) {
        rsiLine.color = [UIColor greenColor];
    } else if (24 == period) {
        rsiLine.color = [UIColor blueColor];
    }
    
    return rsiLine;
}

- (NSMutableArray *)computeWRData:(NSInteger)period{
//    NSMutableArray *arrHigval = [[NSMutableArray alloc] init];
    double *inHigval = malloc(sizeof(double) * self.count);
    for (NSUInteger index = 0; index < self.count; index++) {
        CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
//        [arrHigval addObject:item.high];
        inHigval[index] = [item high];
    }
    
//    NSArrayToCArray(arrHigval, inHigval);
    
//    NSMutableArray *arrLowval = [[NSMutableArray alloc] init];
    double *inLowval = malloc(sizeof(double) * self.count);
    for (NSUInteger index = 0; index < self.count; index++) {
        CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
//        [arrLowval addObject:item.low];
        inLowval[index] = [item low];
    }
    
//    NSArrayToCArray(arrLowval, inLowval);
    
//    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    double *inCls = malloc(sizeof(double) * self.count);
    for (NSUInteger index = 0; index < self.count; index++) {
        CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
//        [arrCls addObject:item.close];
        inCls[index] = [item close];
    }
    
//    NSArrayToCArray(arrCls, inCls);
    
    int outBegIdx = 0, outNBElement = 0;
    double *outReal = malloc(sizeof(double) * self.count);
    
    TA_RetCode ta_retCode = TA_WILLR(0,
                                     (int) (self.count - 1),
                                     inHigval,
                                     inLowval,
                                     inCls,
                                     (int)period,
                                     &outBegIdx,
                                     &outNBElement,
                                     outReal);
    
    NSMutableArray *wrLineData = [[NSMutableArray alloc] init];
    
    if (TA_SUCCESS == ta_retCode) {
        NSArray *arrWR = CArrayToNSArrayWithParameter(outReal, (int) self.count, outBegIdx, outNBElement, WR_NONE_DISPLAY);
        
        for (NSInteger index = 0; index < self.count; index++) {
            CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
            [wrLineData addObject:[[CCSLineData alloc] initWithValue:([[arrWR objectAtIndex:index] doubleValue]) date:[item.date dateWithFormat:SOURCE_DATE_FORMAT target:TO_DATE_FORMAT]]];
        }
    }
    
    
    freeAndSetNULL(inHigval);
    freeAndSetNULL(inLowval);
    freeAndSetNULL(inCls);
    freeAndSetNULL(outReal);
    
    CCSTitledLine *wrLine = [[CCSTitledLine alloc] init];
    wrLine.data = wrLineData;
    wrLine.color = LINE_COLORS[0];
    wrLine.title = @"WR";
    
    NSMutableArray *wrData = [[NSMutableArray alloc] init];
    [wrData addObject:wrLine];
    
    return wrData;
}

- (NSMutableArray *)computeCCIData:(NSInteger)period{
//    NSMutableArray *arrHigval = [[NSMutableArray alloc] init];
    double *inHigval = malloc(sizeof(double) * self.count);
    for (NSUInteger index = 0; index < self.count; index++) {
        CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
//        [arrHigval addObject:item.high];
        inHigval[index] = [item high];
    }
    
//    NSArrayToCArray(arrHigval, inHigval);
    
//    NSMutableArray *arrLowval = [[NSMutableArray alloc] init];
    double *inLowval = malloc(sizeof(double) * self.count);
    for (NSUInteger index = 0; index < self.count; index++) {
        CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
//        [arrLowval addObject:item.low];
        inLowval[index] = [item low];
    }
    
//    NSArrayToCArray(arrLowval, inLowval);
    
//    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    double *inCls = malloc(sizeof(double) * self.count);
    for (NSUInteger index = 0; index < self.count; index++) {
        CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
//        [arrCls addObject:item.close];
        inCls[index] = [item close];
    }
    
//    NSArrayToCArray(arrCls, inCls);
    
    int outBegIdx = 0, outNBElement = 0;
    double *outReal = malloc(sizeof(double) * self.count);
    
    TA_RetCode ta_retCode = TA_CCI(0,
                                   (int) (self.count - 1),
                                   inHigval,
                                   inLowval,
                                   inCls,
                                   (int)period,
                                   &outBegIdx,
                                   &outNBElement,
                                   outReal);
    
    NSMutableArray *cciLineData = [[NSMutableArray alloc] init];
    
    if (TA_SUCCESS == ta_retCode) {
        NSArray *arrCCI = CArrayToNSArray(outReal, (int) self.count, outBegIdx, outNBElement);
        
        for (NSInteger index = 0; index < self.count; index++) {
            CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
            [cciLineData addObject:[[CCSLineData alloc] initWithValue:[[arrCCI objectAtIndex:index] doubleValue] date:[item.date dateWithFormat:SOURCE_DATE_FORMAT target:TO_DATE_FORMAT]]];
        }
    }
    
    freeAndSetNULL(inHigval);
    freeAndSetNULL(inLowval);
    freeAndSetNULL(inCls);
    freeAndSetNULL(outReal);
    
    CCSTitledLine *cciLine = [[CCSTitledLine alloc] init];
    cciLine.data = cciLineData;
    cciLine.color = LINE_COLORS[0];
    cciLine.title = @"CCI";
    
    NSMutableArray *wrData = [[NSMutableArray alloc] init];
    [wrData addObject:cciLine];
    
    return wrData;
}

- (NSMutableArray *)computeBOLLData:(NSInteger)optInTimePeriod optInNbDevUp:(NSInteger)optInNbDevUp optInNbDevDn:(NSInteger)optInNbDevDn{
//    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    double *inCls = malloc(sizeof(double) * self.count);
    for (NSUInteger index = 0; index < self.count; index++) {
        CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
//        [arrCls addObject:item.close];
        inCls[index] = [item close];
    }
    
//    NSArrayToCArray(arrCls, inCls);
    
    int outBegIdx = 0, outNBElement = 0;
    double *outRealUpperBand = malloc(sizeof(double) * self.count);
    double *outRealBollBand = malloc(sizeof(double) * self.count);
    double *outRealLowerBand = malloc(sizeof(double) * self.count);
    
    TA_RetCode ta_retCode = TA_BBANDS(0,
                                      (int) (self.count - 1),
                                      inCls,
                                      (int)optInTimePeriod,
                                      (int)optInNbDevUp,
                                      (int)optInNbDevDn,
                                      TA_MAType_SMA,
                                      &outBegIdx,
                                      &outNBElement,
                                      outRealUpperBand,
                                      outRealBollBand,
                                      outRealLowerBand);
    
    NSMutableArray *bollLinedataUPPER = [[NSMutableArray alloc] init];
    NSMutableArray *bollLinedataLOWER = [[NSMutableArray alloc] init];
    NSMutableArray *bollLinedataBOLL = [[NSMutableArray alloc] init];
    
    if (TA_SUCCESS == ta_retCode) {
        NSArray *arrUPPER = CArrayToNSArray(outRealUpperBand, (int) self.count, outBegIdx, outNBElement);
        NSArray *arrBOLL = CArrayToNSArray(outRealBollBand, (int) self.count, outBegIdx, outNBElement);
        NSArray *arrLOWER = CArrayToNSArray(outRealLowerBand, (int) self.count, outBegIdx, outNBElement);
        
        for (NSInteger index = 0; index < self.count; index++) {
            CCSOHLCVDData *item = [self objectAtIndex:self.count - 1 - index];
            [bollLinedataUPPER addObject:[[CCSLineData alloc] initWithValue:[[arrUPPER objectAtIndex:index] doubleValue] date:[item.date dateWithFormat:SOURCE_DATE_FORMAT target:TO_DATE_FORMAT]]];
            [bollLinedataLOWER addObject:[[CCSLineData alloc] initWithValue:[[arrLOWER objectAtIndex:index] doubleValue] date:[item.date dateWithFormat:SOURCE_DATE_FORMAT target:TO_DATE_FORMAT]]];
            [bollLinedataBOLL addObject:[[CCSLineData alloc] initWithValue:[[arrBOLL objectAtIndex:index] doubleValue] date:[item.date dateWithFormat:SOURCE_DATE_FORMAT target:TO_DATE_FORMAT]]];
        }
    }
    
    freeAndSetNULL(inCls);
    freeAndSetNULL(outRealUpperBand);
    freeAndSetNULL(outRealBollBand);
    freeAndSetNULL(outRealLowerBand);
    
    CCSTitledLine *bollLineUPPER = [[CCSTitledLine alloc] init];
    bollLineUPPER.data = bollLinedataUPPER;
    bollLineUPPER.color = LINE_COLORS[0];
    bollLineUPPER.title = @"UPPER";
    
    CCSTitledLine *bollLineLOWER = [[CCSTitledLine alloc] init];
    bollLineLOWER.data = bollLinedataLOWER;
    bollLineLOWER.color = LINE_COLORS[1];
    bollLineLOWER.title = @"LOWER";
    
    CCSTitledLine *bollLineBOLL = [[CCSTitledLine alloc] init];
    bollLineBOLL.data = bollLinedataBOLL;
    bollLineBOLL.color = LINE_COLORS[2];
    bollLineBOLL.title = @"BOLL";
    
    NSMutableArray *bollBanddata = [[NSMutableArray alloc] init];
    
    [bollBanddata addObject:bollLineUPPER];
    [bollBanddata addObject:bollLineLOWER];
    [bollBanddata addObject:bollLineBOLL];
    
    return bollBanddata;
}

- (NSArray *)convertCandleStickData{
    NSMutableArray *stickDatas = [[NSMutableArray alloc] initWithCapacity:[self count]];
    
    for (NSInteger i = [self count] - 1; i >= 0; i--) {
        CCSOHLCVDData *item = [self objectAtIndex:i];
        CCSCandleStickChartData *stickData = [[CCSCandleStickChartData alloc] init];
//        stickData.open = [item.open doubleValue];
//        stickData.high = [item.high doubleValue];
//        stickData.low = [item.low doubleValue];
//        stickData.close = [item.close doubleValue];
        stickData.open = item.open;
        stickData.high = item.high;
        stickData.low = item.low;
        stickData.close = item.close;
        stickData.change = 0;
        stickData.date = [item.date dateWithFormat:SOURCE_DATE_FORMAT target:TO_DATE_FORMAT];
        // 增加数据
        [stickDatas addObject:stickData];
    }
    
    return stickDatas;
}

- (NSArray *)convertCandleStickLinesData{
    NSString *strMA1 = [MA1 getUserDefaultString];
    if (strMA1 == nil) {
        strMA1 = @"5";
        [MA1 setUserDefaultWithString:strMA1];
    }
    
    NSString *strMA2 = [MA2 getUserDefaultString];
    if (strMA2 == nil) {
        strMA2 = @"10";
        [MA2 setUserDefaultWithString:strMA2];
    }
    
    NSString *strMA3= [MA3 getUserDefaultString];
    if (strMA3 == nil) {
        strMA3 = @"20";
        [MA3 setUserDefaultWithString:strMA3];
    }
    
    NSMutableArray *maLines = [[NSMutableArray alloc] init];
    [maLines addObject: [self computeMAData:[strMA1 integerValue]]];
    [maLines addObject: [self computeMAData:[strMA2 integerValue]]];
    [maLines addObject: [self computeMAData:[strMA3 integerValue]]];
    
    [maLines enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [maLines[idx] setColor:LINE_COLORS[idx]];
    }];
    
    return maLines;
}

- (NSArray *)convertCandleStickBollingerBandData{
    NSString *strBOLLN = [BOLL_N getUserDefaultString];
    if (strBOLLN == nil) {
        strBOLLN = @"20";
        [BOLL_N setUserDefaultWithString:strBOLLN];
    }
    
    return [self computeBOLLData:[strBOLLN integerValue] optInNbDevUp:2 optInNbDevDn:2];
}

- (NSArray *)convertStickData{
    NSMutableArray *stickDatas = [[NSMutableArray alloc] initWithCapacity:[self count]];
    
    for (NSInteger i = [self count] - 1; i >= 0; i--) {
        CCSOHLCVDData *item = [self objectAtIndex:i];
        CCSColoredStickChartData *stickData = [[CCSColoredStickChartData alloc] init];
//        stickData.high = [item.vol doubleValue];
        stickData.high = item.vol;
        stickData.low = 0;
        stickData.date = [item.date dateWithFormat:SOURCE_DATE_FORMAT target:TO_DATE_FORMAT];
        
        if (item.close > item.open) {
            stickData.fillColor = LINE_COLORS[0];
            stickData.borderColor = [UIColor clearColor];
        } else if (item.close < item.open) {
            stickData.fillColor = LINE_COLORS[1];
            stickData.borderColor = [UIColor clearColor];
        } else {
            stickData.fillColor = [UIColor lightGrayColor];
            stickData.borderColor = [UIColor clearColor];
        }
        //增加数据
        [stickDatas addObject:stickData];
    }
    
    return stickDatas;
}

- (NSArray *)convertStickMAData{
    NSString *strMA1 = [VMA1 getUserDefaultString];
    if (strMA1 == nil) {
        strMA1 = @"5";
        [VMA1 setUserDefaultWithString:strMA1];
    }
    
    NSString *strMA2 = [VMA2 getUserDefaultString];
    if (strMA2 == nil) {
        strMA2 = @"10";
        [VMA2 setUserDefaultWithString:strMA2];
    }
    
    NSString *strMA3= [VMA3 getUserDefaultString];
    if (strMA3 == nil) {
        strMA3 = @"20";
        [VMA3 setUserDefaultWithString:strMA3];
    }
    
    NSMutableArray *maLines = [[NSMutableArray alloc] init];
    [maLines addObject: [self computeVOLMAData:[strMA1 integerValue]]];
    [maLines addObject: [self computeVOLMAData:[strMA2 integerValue]]];
    [maLines addObject: [self computeVOLMAData:[strMA3 integerValue]]];
    
    [maLines enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [maLines[idx] setColor:LINE_COLORS[idx]];
    }];
    
    return maLines;
}

- (NSArray *)convertMacdStickData{
    NSString *strMACDL = [MACD_L getUserDefaultString];
    if (strMACDL == nil) {
        strMACDL = @"12";
        [MACD_L setUserDefaultWithString:strMACDL];
    }
    
    NSString *strMACDM = [MACD_M getUserDefaultString];
    if (strMACDM == nil) {
        strMACDM = @"26";
        [MACD_M setUserDefaultWithString:strMACDM];
    }
    
    NSString *strMACDS = [MACD_S getUserDefaultString];
    if (strMACDS == nil) {
        strMACDS = @"9";
        [MACD_S setUserDefaultWithString:strMACDS];
    }
    
    return [self computeMACDData:[strMACDL integerValue] optInSlowPeriod:[strMACDM integerValue] optInSignalPeriod:[strMACDS integerValue]];
}

- (NSArray *)convertKDJLinesData{
    NSString *strKDJN = [KDJ_N getUserDefaultString];
    if (strKDJN == nil) {
        strKDJN = @"9";
        [KDJ_N setUserDefaultWithString:strKDJN];
    }
    
    return [self computeKDJData:[strKDJN integerValue] optInSlowK_Period:3 optInSlowD_Period:3];
}

- (NSArray *)convertRSILinesData{
    NSString *strRSIN1 = [RSI_N1 getUserDefaultString];
    if (strRSIN1 == nil) {
        strRSIN1 = @"6";
        [RSI_N1 setUserDefaultWithString:strRSIN1];
    }
    
    NSString *strRSIN2 = [RSI_N2 getUserDefaultString];
    if (strRSIN2 == nil) {
        strRSIN2 = @"12";
        [RSI_N2 setUserDefaultWithString:strRSIN2];
    }
    
    NSMutableArray *linesData = [[NSMutableArray alloc] init];
    [linesData addObject:[self computeRSIData:[strRSIN1 integerValue]]];
    [linesData addObject:[self computeRSIData:[strRSIN2 integerValue]]];
    [linesData addObject:[self computeRSIData:24]];
    
    [linesData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [linesData[idx] setColor:LINE_COLORS[idx]];
    }];
    
    return linesData;
}

- (NSArray *)convertWRLinesData{
    NSString *strWRN = [WR_N getUserDefaultString];
    if (strWRN == nil) {
        strWRN = @"10";
        [WR_N setUserDefaultWithString:strWRN];
    }
    
    return [self computeWRData:[strWRN integerValue]];
}

- (NSArray *)convertCCILinesData{
    NSString *strCCIN = [CCI_N getUserDefaultString];
    if (strCCIN == nil) {
        strCCIN = @"14";
        [CCI_N setUserDefaultWithString:strCCIN];
    }
    
    return [self computeCCIData:[strCCIN integerValue]];
}

- (NSArray *)convertBOLLLinesData{
    NSString *strBOLLN = [BOLL_N getUserDefaultString];
    if (strBOLLN == nil) {
        strBOLLN = @"20";
        [BOLL_N setUserDefaultWithString:strBOLLN];
    }
    
    return [self computeBOLLData:[strBOLLN integerValue] optInNbDevUp:2 optInNbDevDn:2];
}

@end
