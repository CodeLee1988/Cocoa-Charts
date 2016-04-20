//
//  CCSCandleStickChart.m
//  Cocoa-Charts
//
//  Created by limc on 11-10-24.
//  Copyright 2011 limc.cn All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
#import "CCSSlipCandleStickChart.h"
#import "CCSCandleStickChartData.h"


@implementation CCSSlipCandleStickChart

@synthesize positiveStickBorderColor = _positiveStickBorderColor;
@synthesize positiveStickFillColor = _positiveStickFillColor;
@synthesize negativeStickBorderColor = _negativeStickBorderColor;
@synthesize negativeStickFillColor = _negativeStickFillColor;
@synthesize crossStarColor = _crossStarColor;
@synthesize candleStickStyle = _candleStickStyle;


- (void)initProperty {

    [super initProperty];
    //初始化颜色
    self.positiveStickBorderColor = [UIColor redColor];
    self.positiveStickFillColor = [UIColor clearColor];
    self.negativeStickBorderColor = [UIColor greenColor];
    self.negativeStickFillColor = [UIColor greenColor];
    self.crossStarColor = [UIColor lightGrayColor];

    self.candleStickStyle = CCSCandleStickStyleStandard;

}

- (void)calcDataValueRange {
    if (self.displayNumber <= 0) {
        return;
    }
    
    CCFloat maxValue = 0;
    CCFloat minValue = CCIntMax;
//
//    CCSCandleStickChartData *first = [self.stickData objectAtIndex:self.displayFrom];
//
//    //第一个stick为停盘的情况
//    if (first.high == 0 && first.low == 0) {
//
//    } else {
//        //max取最小，min取最大
//        maxValue = first.high;
//        minValue = first.low;
//    }

    //判断显示为方柱或显示为线条
//    if (self.axisYPosition == CCSGridChartYAxisPositionLeft) {
        for (CCUInt i = self.displayFrom; i < [self getDisplayTo] - 1; i++) {
            CCSCandleStickChartData *stick = [self.stickData objectAtIndex:i];
            if (stick.open == 0 && stick.high == 0 && stick.low == 0) {
                //停盘期间计算收盘价
                if (stick.close > 0) {
                    if (stick.close < minValue) {
                        minValue = stick.close;
                    }

                    if (stick.close > maxValue) {
                        maxValue = stick.close;
                    }
                }
            } else {
                if (stick.low < minValue) {
                    minValue = stick.low;
                }

                if (stick.high > maxValue) {
                    maxValue = stick.high;
                }
            }
        }
//    } else {
//        for (CCUInt i = 0; i < self.displayNumber; i++) {
//            CCUInt index = [self getDisplayTo] - 1 - i;
//            CCSCandleStickChartData *stick = [self.stickData objectAtIndex:index];
//            if (stick.open == 0 && stick.high == 0 && stick.low == 0) {
//                //停盘期间计算收盘价
//                if (stick.close > 0) {
//                    if (stick.close < minValue) {
//                        minValue = stick.close;
//                    }
//
//                    if (stick.close > maxValue) {
//                        maxValue = stick.close;
//                    }
//                }
//            } else {
//                if (stick.low < minValue) {
//                    minValue = stick.low;
//                }
//
//                if (stick.high > maxValue) {
//                    maxValue = stick.high;
//                }
//            }
//        }
//    }

    self.maxValue = maxValue;
    self.minValue = minValue;

}

- (void)calcValueRangeFormatForAxis {
    
//    return;

    CCInt rate = self.axisCalc;

//    if (self.maxValue < 3000) {
//        rate = 1;
//    } else if (self.maxValue >= 3000 && self.maxValue < 5000) {
//        rate = 5;
//    } else if (self.maxValue >= 5000 && self.maxValue < 30000) {
//        rate = 10;
//    } else if (self.maxValue >= 30000 && self.maxValue < 50000) {
//        rate = 50;
//    } else if (self.maxValue >= 50000 && self.maxValue < 300000) {
//        rate = 100;
//    } else if (self.maxValue >= 300000 && self.maxValue < 500000) {
//        rate = 500;
//    } else if (self.maxValue >= 500000 && self.maxValue < 3000000) {
//        rate = 1000;
//    } else if (self.maxValue >= 3000000 && self.maxValue < 5000000) {
//        rate = 5000;
//    } else if (self.maxValue >= 5000000 && self.maxValue < 30000000) {
//        rate = 10000;
//    } else if (self.maxValue >= 30000000 && self.maxValue < 50000000) {
//        rate = 50000;
//    } else {
//        rate = 100000;
//    }

    //等分轴修正
    if (self.latitudeNum > 0 && rate > 1 && (CCInt) (self.minValue) % rate != 0) {
        //最大值加上轴差
        self.minValue = (CCInt) self.minValue - ((CCInt) (self.minValue) % rate);
    }
    //等分轴修正
    if (self.latitudeNum > 0 && (CCInt) (self.maxValue - self.minValue) % (self.latitudeNum * rate) != 0) {
        //最大值加上轴差
        self.maxValue = (CCInt) self.maxValue + (self.latitudeNum * rate) - ((CCInt) (self.maxValue - self.minValue) % (self.latitudeNum * rate));
    }
}

- (void)initAxisX {
    //计算取值范围
    [self calcValueRange];

    NSMutableArray *TitleX = [[NSMutableArray alloc] init];
    if (self.stickData != NULL && [self.stickData count] > 0 && self.displayNumber > 0) {
        CCFloat average = 1.0 * self.displayNumber / self.longitudeNum;
        if (self.axisYPosition == CCSGridChartYAxisPositionLeft) {
            CCSCandleStickChartData *chartdata = nil;
            //处理刻度
            for (CCUInt i = 0; i < self.longitudeNum; i++) {
                CCUInt index = self.displayFrom + (CCUInt) floor(i * average);
                if (index > [self getDisplayTo] - 1) {
                    index = [self getDisplayTo] - 1;
                }
                chartdata = [self.stickData objectAtIndex:index];
                //追加标题
                [TitleX addObject:[NSString stringWithFormat:@"%@", chartdata.date]];
            }
            chartdata = [self.stickData objectAtIndex:[self getDisplayTo] - 1];
            //追加标题
            [TitleX addObject:[NSString stringWithFormat:@"%@", chartdata.date]];
        } else {
            CCSCandleStickChartData *chartdata = nil;
            //处理刻度
            for (CCUInt i = 0; i < self.longitudeNum; i++) {
                CCUInt index = self.displayFrom + (CCUInt) floor(i * average);
                if (index > [self getDisplayTo] - 1) {
                    index = [self getDisplayTo] - 1;
                }
                chartdata = [self.stickData objectAtIndex:index];
                //追加标题
                [TitleX addObject:[NSString stringWithFormat:@"%@", chartdata.date]];
            }
            chartdata = [self.stickData objectAtIndex:[self getDisplayTo] - 1];
            //追加标题
            [TitleX addObject:[NSString stringWithFormat:@"%@", chartdata.date]];
        }

    }
    self.longitudeTitles = TitleX;
}


- (void)initAxisY {
    //调用父类的initAxisY方法
    [super initAxisY];
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

-(void) drawData:(CGRect)rect{
    if (self.displayNumber > self.maxDisplayNumberToLine) {
        [self drawDataAsLine:rect];
    }else{
        //绘制数据
        [self drawSticks:rect];
    }
}

- (void)drawSticks:(CGRect)rect {
    // 蜡烛棒宽度
    CCFloat stickWidth = [self getDataStickWidth] - 0.5f;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5f);

    if (self.stickData != NULL && [self.stickData count] > 0) {
        //判断Y轴的位置设置从左往右还是从右往左绘制
        if (self.axisYPosition == CCSGridChartYAxisPositionLeft) {
            // 蜡烛棒起始绘制位置
            CCFloat stickX = self.axisMarginLeft + 1;
            for (CCUInt i = self.displayFrom; i < [self getDisplayTo]; i++) {
                CCSCandleStickChartData *data = [self.stickData objectAtIndex:i];
                CCFloat openY = [self computeValueY:data.open inRect:rect];
                CCFloat highY = [self computeValueY:data.high inRect:rect];
                CCFloat lowY = [self computeValueY:data.low inRect:rect];
                CCFloat closeY = [self computeValueY:data.close inRect:rect];

                // 处理和生产K线中的阴线和阳线
                if (data.open == 0 && data.high == 0 && data.low == 0) {
                    //停盘的情况，什么都不绘制
                } else if (data.open < data.close) {
                    //阳线
                    //根据宽度判断是否绘制立柱
                    CGContextSetStrokeColorWithColor(context, self.positiveStickBorderColor.CGColor);
                    CGContextSetFillColorWithColor(context, self.positiveStickFillColor.CGColor);

                    if (self.candleStickStyle == CCSCandleStickStyleStandard) {
                        
                        //绘制上下影线
                        CGContextMoveToPoint(context, stickX + stickWidth / 2, highY);
                        CGContextAddLineToPoint(context, stickX + stickWidth / 2, closeY);

                        CGContextStrokePath(context);
                        
                        CGContextMoveToPoint(context, stickX + stickWidth / 2, openY);
                        CGContextAddLineToPoint(context, stickX + stickWidth / 2, lowY);
                        
                        CGContextStrokePath(context);
                        
                        if (stickWidth >= 1) {
                            CGContextAddRect(context, CGRectMake(stickX, closeY, stickWidth, openY - closeY));
                            CGContextFillPath(context);
                            CGContextAddRect(context, CGRectMake(stickX, closeY, stickWidth, openY - closeY));
                            CGContextStrokePath(context);
                        }

                    } else if (self.candleStickStyle == CCSCandleStickStyleBar) {
                        //绘制上下影线
                        CGContextMoveToPoint(context, stickX + stickWidth / 2, highY);
                        CGContextAddLineToPoint(context, stickX + stickWidth / 2, lowY);

                        CGContextMoveToPoint(context, stickX + stickWidth / 2, openY);
                        CGContextAddLineToPoint(context, stickX, openY);

                        CGContextMoveToPoint(context, stickX + stickWidth / 2, closeY);
                        CGContextAddLineToPoint(context, stickX + stickWidth, closeY);

                        CGContextStrokePath(context);
                    } else if (self.candleStickStyle == CCSCandleStickStyleLine) {

                    }

                } else if (data.open > data.close) {
                    //阴线
                    //根据宽度判断是否绘制立柱
                   
                    CGContextSetStrokeColorWithColor(context, self.negativeStickBorderColor.CGColor);
                    CGContextSetFillColorWithColor(context, self.negativeStickFillColor.CGColor);

                    if (self.candleStickStyle == CCSCandleStickStyleStandard) {
                        
                        //绘制上下影线
                        CGContextMoveToPoint(context, stickX + stickWidth / 2, highY);
                        CGContextAddLineToPoint(context, stickX + stickWidth / 2, openY);

                        CGContextStrokePath(context);
                        
                        
                        CGContextMoveToPoint(context, stickX + stickWidth / 2, closeY);
                        CGContextAddLineToPoint(context, stickX + stickWidth / 2, lowY);
                        
                        CGContextStrokePath(context);
                        
                        
                        if (stickWidth >= 1) {
                            CGContextAddRect(context, CGRectMake(stickX, openY, stickWidth, closeY - openY));
                            CGContextFillPath(context);
                            
                            CGContextAddRect(context, CGRectMake(stickX, closeY, stickWidth, openY - closeY));
                            CGContextStrokePath(context);
                        }

                    } else if (self.candleStickStyle == CCSCandleStickStyleBar) {
                        //绘制上下影线
                        CGContextMoveToPoint(context, stickX + stickWidth / 2, highY);
                        CGContextAddLineToPoint(context, stickX + stickWidth / 2, lowY);

                        CGContextMoveToPoint(context, stickX + stickWidth / 2, openY);
                        CGContextAddLineToPoint(context, stickX, openY);

                        CGContextMoveToPoint(context, stickX + stickWidth / 2, closeY);
                        CGContextAddLineToPoint(context, stickX + stickWidth, closeY);

                        CGContextStrokePath(context);
                    } else if (self.candleStickStyle == CCSCandleStickStyleLine) {

                    }
                } else {
                    //十字线
                    //根据宽度判断是否绘制横线
                    CGContextSetStrokeColorWithColor(context, self.crossStarColor.CGColor);
                    CGContextSetFillColorWithColor(context, self.crossStarColor.CGColor);
                    if (stickWidth >= 1) {
                        CGContextMoveToPoint(context, stickX, closeY);
                        CGContextAddLineToPoint(context, stickX + stickWidth, openY);
                    }
                    //绘制上下影线
                    CGContextMoveToPoint(context, stickX + stickWidth / 2, highY);
                    CGContextAddLineToPoint(context, stickX + stickWidth / 2, lowY);

                    CGContextStrokePath(context);
                }

                //X位移
                stickX = stickX + 0.5f + stickWidth;
            }
        } else {
            // 蜡烛棒起始绘制位置
            CCFloat stickX = rect.size.width - self.axisMarginRight - 1 - stickWidth;
            for (CCUInt i = 0; i < self.displayNumber; i++) {
                //获取index
                CCUInt index = [self getDisplayTo] - 1 - i;

                CCSCandleStickChartData *data = [self.stickData objectAtIndex:index];
                CCFloat openY = [self computeValueY:data.open inRect:rect];
                CCFloat highY = [self computeValueY:data.high inRect:rect];
                CCFloat lowY = [self computeValueY:data.low inRect:rect];
                CCFloat closeY = [self computeValueY:data.close inRect:rect];

                // 处理和生产K线中的阴线和阳线
                if (data.open == 0 && data.high == 0 && data.low == 0) {
                    //停盘的情况，什么都不绘制
                } else if (data.open < data.close) {
                    
                    if (self.candleStickStyle == CCSCandleStickStyleStandard) {
                        //阳线
                        //根据宽度判断是否绘制立柱
                        CGContextSetStrokeColorWithColor(context, self.positiveStickBorderColor.CGColor);
                        CGContextSetFillColorWithColor(context, self.positiveStickFillColor.CGColor);
                        
                        
                        //绘制上下影线
                        CGContextMoveToPoint(context, stickX + stickWidth / 2, openY);
                        CGContextAddLineToPoint(context, stickX + stickWidth / 2, lowY);
                        CGContextStrokePath(context);
                        
                        
                        CGContextMoveToPoint(context, stickX + stickWidth / 2, highY);
                        CGContextAddLineToPoint(context, stickX + stickWidth / 2, closeY);
                        CGContextStrokePath(context);
                        
                        
                        if (stickWidth >= 1) {
                            CGContextAddRect(context, CGRectMake(stickX, closeY, stickWidth, openY - closeY));
                            CGContextFillPath(context);
                            
                            CGContextAddRect(context, CGRectMake(stickX, closeY, stickWidth, openY - closeY));
                            CGContextStrokePath(context);
                        }
                    } else if (self.candleStickStyle == CCSCandleStickStyleBar) {
                        //绘制上下影线
                        CGContextMoveToPoint(context, stickX + stickWidth / 2, highY);
                        CGContextAddLineToPoint(context, stickX + stickWidth / 2, lowY);
                        
                        CGContextMoveToPoint(context, stickX + stickWidth / 2, openY);
                        CGContextAddLineToPoint(context, stickX, openY);
                        
                        CGContextMoveToPoint(context, stickX + stickWidth / 2, closeY);
                        CGContextAddLineToPoint(context, stickX + stickWidth, closeY);
                        
                        CGContextStrokePath(context);
                    } else if (self.candleStickStyle == CCSCandleStickStyleLine) {
                        
                    }
                   

                } else if (data.open > data.close) {
                    
                    if (self.candleStickStyle == CCSCandleStickStyleStandard) {
                        //阴线
                        //根据宽度判断是否绘制立柱
                        
                        CGContextSetStrokeColorWithColor(context, self.negativeStickBorderColor.CGColor);
                        CGContextSetFillColorWithColor(context, self.negativeStickFillColor.CGColor);
                        //绘制上下影线
                        CGContextMoveToPoint(context, stickX + stickWidth / 2, highY);
                        CGContextAddLineToPoint(context, stickX + stickWidth / 2, openY);

                        CGContextStrokePath(context);
                        
                        CGContextMoveToPoint(context, stickX + stickWidth / 2, closeY);
                        CGContextAddLineToPoint(context, stickX + stickWidth / 2, lowY);
                        
                        CGContextStrokePath(context);

                        
                        if (stickWidth >= 1) {
                            CGContextAddRect(context, CGRectMake(stickX, openY, stickWidth, closeY - openY));
                            CGContextFillPath(context);
                            CGContextAddRect(context, CGRectMake(stickX, closeY, stickWidth, openY - closeY));
                            CGContextStrokePath(context);
                        }
                    
                    }else if (self.candleStickStyle == CCSCandleStickStyleBar) {
                        //绘制上下影线
                        CGContextMoveToPoint(context, stickX + stickWidth / 2, highY);
                        CGContextAddLineToPoint(context, stickX + stickWidth / 2, lowY);
                        
                        CGContextMoveToPoint(context, stickX + stickWidth / 2, openY);
                        CGContextAddLineToPoint(context, stickX, openY);
                        
                        CGContextMoveToPoint(context, stickX + stickWidth / 2, closeY);
                        CGContextAddLineToPoint(context, stickX + stickWidth, closeY);
                        
                        CGContextStrokePath(context);
                    } else if (self.candleStickStyle == CCSCandleStickStyleLine) {
                        
                    }
                } else {
                    //十字线
                    //根据宽度判断是否绘制横线
                    CGContextSetStrokeColorWithColor(context, self.crossStarColor.CGColor);
                    CGContextSetFillColorWithColor(context, self.crossStarColor.CGColor);
                    if (stickWidth >= 1) {
                        CGContextMoveToPoint(context, stickX, closeY);
                        CGContextAddLineToPoint(context, stickX + stickWidth, openY);
                    }
                    //绘制上下影线
                    CGContextMoveToPoint(context, stickX + stickWidth / 2, highY);
                    CGContextAddLineToPoint(context, stickX + stickWidth / 2, lowY);

                    CGContextStrokePath(context);
                }

                //X位移
                stickX = stickX - 0.5f - stickWidth;
            }
        }
    }
}

- (void)drawDataAsLine:(CGRect)rect {
    if (self.stickData != NULL && [self.stickData count] > 0) {
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 1.0f);
        CGContextSetAllowsAntialiasing(context, YES);
        CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor] );
        // 点线距离
        CCFloat lineLength = [self getDataStickWidth];
        //起始点
        CCFloat startX = super.axisMarginLeft + lineLength / 2;
        
        //遍历并绘制线条
        for (CCUInt j = self.displayFrom; j < [self getDisplayTo]; j++) {
            CCSCandleStickChartData *data = [self.stickData objectAtIndex:j];
            
            CCFloat closeY = [self computeValueY:data.close inRect:rect];
            
            //绘制线条路径
            if (j == self.displayFrom) {
                CGContextMoveToPoint(context, startX, closeY);
            } else {
                
                CCSCandleStickChartData *dataPre = [self.stickData objectAtIndex:j-1];
                if (dataPre.close != 0) {
                    CGContextAddLineToPoint(context, startX, closeY);
                } else {
                    CGContextMoveToPoint(context, startX - lineLength / 2, closeY);
                    CGContextAddLineToPoint(context, startX, closeY);
                }
            }
            //X位移
            startX = startX + lineLength;
        }
        
        //绘制路径
        CGContextStrokePath(context);
    }
}


@end
