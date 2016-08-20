//
//  CCSSampleGroupChartDemoViewController.m
//  CocoaChartsSample
//
//  Created by zhourr_ on 16/3/28.
//  Copyright © 2016年 limc. All rights reserved.
//

#import "CCSSampleGroupChartDemoViewController.h"

#import "CCSChartsSettingViewController.h"

#import "CCSSamplGroupChartDetailTableViewCell.h"

#import "CCSAppDelegate.h"

#define AXIS_CALC_PARM  1000

#import "CCSAreaChart.h"
#import "CCSLineData.h"
#import "CCSTitledLine.h"

#import "NSArray+CCSTACompute.h"
#import "CCSStringUtils.h"
#import "NSString+UserDefault.h"
#import "NSString+UIColor.h"

#define MIN_CHART_LEFT_RIGHT_SCALE                  3.0f

#define VIEW_SIZE                                   self.view.bounds.size

/** 精选 Cell */
static NSString *DetailCellIdentifier             = @"CCSSamplGroupChartDetailTableViewCell";

typedef enum {
    Chart1minData = 0,
    Chart15minData = 1,
    ChartTimesData = 2
} ChartDataType;

@interface CCSSampleGroupChartDemoViewController (){
    CCSGroupChartData                               *_dayData;
    
    NSMutableDictionary                             *_dicTickLineDatas;
    NSMutableDictionary                             *_dicTickAvgLineDatas;
    NSMutableDictionary                             *_dicTickVolStickDatas;
}

- (void)loadJSONData: (ChartDataType) chartDataType;

- (void)loadKLineData: (ChartDataType) chartDataType;

- (void)loadTickData;

@end

@implementation CCSSampleGroupChartDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    [self initAreaChart];
    
    // 延迟操作执行的代码
    [self loadJSONData:Chart15minData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)segTopChartTypeTypeValueChaged:(UISegmentedControl *)segmentedControl {
    
    if (segmentedControl.selectedSegmentIndex == 0) {
        [self.areachart setHidden:NO];
        [self.groupChart setHidden:YES];
        
        [self loadTickData];
    }else if (segmentedControl.selectedSegmentIndex == 1) {
        [self.areachart setHidden:YES];
        [self.groupChart setHidden:NO];
        
        if (!_dayData) {
            [self loadJSONData:Chart15minData];
        }else{
            [self.groupChart setGroupChartData:_dayData];
        }
    }else{
    }
}

/*******************************************************************************
 * Implements Of CCSChartDelegate
 *******************************************************************************/

- (void)CCSChartBeTouchedOn:(id)chart point:(CGPoint)point indexAt:(CCUInt)index{
    [_groupChart CCSChartBeTouchedOn:chart point:point indexAt:index];
}

- (void)CCSChartDisplayChangedFrom:(id)chart from:(CCUInt)from number:(CCUInt)number{
    [_groupChart CCSChartDisplayChangedFrom:chart from:from number:number];
}

- (void)initView{
    [self.segTopChartType addTarget:self action:@selector(segTopChartTypeTypeValueChaged:) forControlEvents:UIControlEventValueChanged];
    [self.segTopChartType setSelectedSegmentIndex:1];
    
    // 设置颜色
    self.segTopChartType.tintColor = [UIColor whiteColor];
    [self.segTopChartType setBackgroundColor:[UIColor whiteColor]];
    NSDictionary* selectedTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:11.0f],
                                             NSForegroundColorAttributeName: [@"#323232" str2Color]};
    // 设置文字属性
    [self.segTopChartType setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];
    NSDictionary* unselectedTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:11.0f],
                                               NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    [self.segTopChartType setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateNormal];
    
    [_groupChart setChartDelegate:self];
    [_groupChart setChartsBackgroundColor:[@"F5F5F5" str2Color]];
    [_groupChart setSetting:^{
        CCSChartsSettingViewController *ctrlSetting = [[CCSChartsSettingViewController alloc] init];
        ctrlSetting.ctrlChart = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:ctrlSetting];
        [self presentViewController:navigationController animated:YES completion:^{
        }];
    }];
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"MM月dd日 HH:mm:ss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    [self.lblTime setText:currentDateStr];
}

- (void)initAreaChart{
    [self.areachart setBackgroundColor:[@"F5F5F5" str2Color]];
    
    self.areachart.lineWidth = 0.8f;
    self.areachart.longitudeNum = 3;
    self.areachart.latitudeNum = 3;
    self.areachart.areaAlpha = 0.2;
    self.areachart.noneDisplayValues = [NSMutableArray arrayWithArray:@[@"0"]];
    
    self.areachart.axisCalc = AXIS_CALC_PARM;
    
    self.areachart.balanceRange = YES;
    self.areachart.lastClose = 0.0f;
    
    self.areachart.displayFrom = 0;
    
    self.areachart.enableSlip = NO;
    self.areachart.enableZoom = NO;
    
    self.areachart.longitudeFontColor = [UIColor lightGrayColor];
    self.areachart.latitudeFontColor = [UIColor lightGrayColor];
    
    self.areachart.borderColor = BORDER_COLOR;
    self.areachart.longitudeColor = GRID_LINE_COLOR;
    self.areachart.latitudeColor = GRID_LINE_COLOR;
    
    _dicTickLineDatas = [[NSMutableDictionary alloc] init];
    _dicTickAvgLineDatas = [[NSMutableDictionary alloc] init];
    _dicTickVolStickDatas = [[NSMutableDictionary alloc] init];
    
    [self initTickLineDataWithDates:@[@""] tickChart:self.areachart dicLineDatas:_dicTickLineDatas dicAvgLineDatas:_dicTickAvgLineDatas volChart:nil dicTickVolStickDatas:_dicTickVolStickDatas];
}

- (void)initTickLineDataWithDates: (NSArray *) dates tickChart:(CCSSlipAreaChart *) tickChart dicLineDatas:(NSMutableDictionary *)dicLineDatas dicAvgLineDatas:(NSMutableDictionary *) dicAvgLineDatas volChart:(CCSMAColoredStickChart *) volChart dicTickVolStickDatas:(NSMutableDictionary *) dicTickVolStickDatas{
    DO_IN_BACKGROUND((^{
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setPositiveFormat:@"00"];
        
        NSMutableArray *arrMinsLineData = [[NSMutableArray alloc] init];
        NSMutableArray *arrMinsAvgLineData = [[NSMutableArray alloc] init];
        
        for (NSString *date in dates) {
            for (int j=9.5*60; j<=60*11.5; j++) {
                int hour = j/60;
                int min = j - hour*60;
                
                NSString *time = [NSString stringWithFormat:@"%@:%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:hour]], [numberFormatter stringFromNumber:[NSNumber numberWithInt:min]]];
                
                if (date && ![date isEqualToString:@""]) {
                    time = [[date append: @" "] append: time];
                }
                
                CCSLineData *priceLineData = [[CCSLineData alloc] initWithValue:0.0 date: time];
                [arrMinsLineData addObject: priceLineData];
                [dicLineDatas setObject:priceLineData forKey: time];
                
                CCSLineData *avgPriceLineData = [[CCSLineData alloc] initWithValue:0.0 date: time];
                [arrMinsAvgLineData addObject: avgPriceLineData];
                [dicAvgLineDatas setObject:avgPriceLineData forKey: time];
            }
            for (int j=13*60+1; j<=60*15; j++) {
                int hour = j/60;
                int min = j - hour*60;
                
                NSString *time = [NSString stringWithFormat:@"%@:%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:hour]], [numberFormatter stringFromNumber:[NSNumber numberWithInt:min]]];
                
                if (date && ![date isEqualToString:@""]) {
                    time = [[date append: @" "] append: time];
                }
                
                CCSLineData *priceLineData = [[CCSLineData alloc] initWithValue:0.0 date: time];
                [arrMinsLineData addObject: priceLineData];
                [dicLineDatas setObject:priceLineData forKey: time];
                
                CCSLineData *avgPriceLineData = [[CCSLineData alloc] initWithValue:0.0 date: time];
                [arrMinsAvgLineData addObject: avgPriceLineData];
                [dicAvgLineDatas setObject:avgPriceLineData forKey: time];
            }
        }
        
        NSMutableArray *linedata = [[NSMutableArray alloc] init];
        
        CCSTitledLine *priceLine = [[CCSTitledLine alloc] init];
        priceLine.data = arrMinsLineData;
        priceLine.color = [UIColor clearColor];
        priceLine.title = @"chartLine";
        
        [linedata addObject:priceLine];
        
        CCSTitledLine *avgLine = [[CCSTitledLine alloc] init];
        avgLine.data = arrMinsAvgLineData;
        avgLine.color = [UIColor clearColor];
        avgLine.title = @"chartLine";
        
        [linedata addObject:avgLine];
        
        tickChart.displayNumber = arrMinsLineData.count;
        tickChart.maxDisplayNumber = arrMinsLineData.count;
        tickChart.minDisplayNumber = arrMinsLineData.count;
        
        tickChart.linesData = linedata;
    }));
}

- (void)loadJSONData: (ChartDataType) chartDataType{
    DO_IN_BACKGROUND(^{
        [self loadKLineData:chartDataType];
    });
}

- (void)loadKLineData: (ChartDataType) chartDataType{
    // 读取JSON
    NSString *jsonString = [@"KLineData" findJSONStringWithType:@"txt"];
    // 解析
    NSDictionary *dicKLineData = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options:kNilOptions
                                                                   error:nil];
    
    NSArray *arrNativeData = dicKLineData[@"kLine"];
    
    arrNativeData = [[arrNativeData reverseObjectEnumerator] allObjects];
    
    NSMutableArray *ohlcdDatas = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in arrNativeData) {
        if (dict != nil) {
            CCSOHLCVDData *data = [[CCSOHLCVDData alloc] init];
            
            data.open = [[dict objectForKey:@"open"] doubleValue] * AXIS_CALC_PARM;
            data.high = [[dict objectForKey:@"high"] doubleValue] * AXIS_CALC_PARM;
            data.low = [[dict objectForKey:@"low"] doubleValue] * AXIS_CALC_PARM;
            data.close = [[dict objectForKey:@"close"] doubleValue]* AXIS_CALC_PARM;
            data.vol = [[dict objectForKey:@"volume"] doubleValue];
            data.date = [dict[@"day"] dateWithFormat:@"yyyy-MM-dd HH:mm:ss" target:@"yyyyMMddHHmmss"];
            data.current = [[dict objectForKey:@"close"] doubleValue];
            data.preclose = 0;
            data.change = 0;
            [ohlcdDatas addObject:data];
        }
    }
    
    DO_IN_MAIN_QUEUE(^{
        [self setDayData:ohlcdDatas];
    });
}

- (void)loadTickData{
    DO_IN_BACKGROUND(^{
        // 读取JSON
        NSString *jsonString = [@"Tick" findJSONStringWithType:@"txt"];
        // 解析
        NSDictionary *dicTickData = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options:kNilOptions
                                                                      error:nil];
        
        NSArray *arrNativeData = dicTickData[@"tick"];
        
        arrNativeData = [[arrNativeData reverseObjectEnumerator] allObjects];
        
        [self tickDataProcess:arrNativeData dates:@[@""] chart:self.areachart dicLineDatas:_dicTickLineDatas dicAvgLineDatas:_dicTickAvgLineDatas volChart:nil dicVolStickDatas:_dicTickVolStickDatas];
    });
}

- (void)tickDataProcess:(NSArray *)arrData dates:(NSArray *)dates chart:(CCSSlipAreaChart *) chart dicLineDatas:(NSMutableDictionary *)dicLineDatas dicAvgLineDatas:(NSMutableDictionary *) dicAvgLineDatas volChart:(CCSMAColoredStickChart *) volChart dicVolStickDatas:(NSMutableDictionary *) dicTickVolStickDatas{
    // 循环设置价格
    for (NSString *date in dates) {
        __block CGFloat sumValue = 0.0f;
        __block CGFloat sumVolume = 0.0f;
        [arrData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
            NSDictionary *dic = obj;
            
            NSString *time = [dic[@"qt"] dateWithFormat:@"yyyy-MM-ddHH: mm: ss" target:@"HH:mm"];
            if (date && ![date isEqualToString:@""]) {
                time = [[date append: @" "] append: time];
            }
            
            CCSLineData *lineData = dicLineDatas[time];
            [lineData setValue: [dic[@"c"] doubleValue] * AXIS_CALC_PARM];
            
            sumValue += [dic[@"v"] doubleValue] * [dic[@"c"] doubleValue];
            sumVolume += [dic[@"v"] doubleValue];
            
            CCSLineData *avgLineData = dicAvgLineDatas[time];
            [avgLineData setValue: sumValue/sumVolume * AXIS_CALC_PARM];
            
            // 当前交易截止时间
            if (index == arrData.count - 1) {
                chart.closingDate = time;
            }
        }];
    }
    
    ((CCSTitledLine*)chart.linesData[0]).color = LINE_COLORS[2];
    ((CCSTitledLine*)chart.linesData[1]).color = LINE_COLORS[1];
    
    DO_IN_MAIN_QUEUE(^{
        [chart setNeedsDisplay];
        [volChart setNeedsDisplay];
    });
}

- (void)updateChartsWithIndicatorType:(IndicatorType) indicatorType{
    if (indicatorType == IndicatorMACD) {
        [_dayData updateMACDStickData:self.macdS l:self.macdL m:self.macdM];
        
        [self.groupChart updateMACDChart];
    }else if (indicatorType == IndicatorMA){
        [_dayData updateCandleStickLinesData:self.ma1 ma2:self.ma2 ma3:self.ma3];
        
        [self.groupChart updateCandleStickChart];
    }else if (indicatorType == IndicatorKDJ){
        [_dayData updateKDJData:self.kdjN];
        
        [self.groupChart updateKDJChart];
    }else if (indicatorType == IndicatorRSI){
        [_dayData updateRSIData:self.rsiN1 n2:self.rsiN2];
        
        [self.groupChart updateRSIChart];
    }else if (indicatorType == IndicatorWR){
        [_dayData updateWRData:self.wrN];
        
        [self.groupChart updateWRChart];
    }else if (indicatorType == IndicatorCCI){
        [_dayData updateCCIData:self.cciN];
        
        [self.groupChart updateCCIChart];
    }else if (indicatorType == IndicatorBOLL){
        [_dayData updateBOLLData:self.bollN];
        [_dayData updateCandleStickBollingerBandData:self.bollN];
        
        [self.groupChart updateCandleStickChart];
        [self.groupChart updateBOLLChart];
    }
}

/*******************************************************************************
 * setter
 *******************************************************************************/

/**
 * 设置日数据
 */
- (void)setDayData:(NSArray *) ohlcvDatas{
    _dayData = [[CCSGroupChartData alloc] initWithCCSOHLCVDDatas:ohlcvDatas displayChartType:GroupChartViewTypeVOL sourceDateFormat:@"yyyyMMddHHmmss" targetDateFormat:@"MM-dd HH:mm"];
    
    [self.groupChart setGroupChartData:_dayData];
}

/**
 * 设置周数据
 */
- (void)setWeekData:(NSArray *) ohlcvDatas{
    _dayData = [[CCSGroupChartData alloc] initWithCCSOHLCVDDatas:ohlcvDatas displayChartType:GroupChartViewTypeVOL sourceDateFormat:@"yyyyMMddHHmmss" targetDateFormat:@"MM-dd HH:mm"];
    
    [self.groupChart setGroupChartData:_dayData];
}

@end
