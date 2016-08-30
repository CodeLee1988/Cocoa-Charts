//
//  CCSAreaChart.m
//  Cocoa-Charts
//
//  Created by limc on 13-10-27.
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

#import "CCSSlipAreaChart.h"
#import "CCSTitledLine.h"
#import "CCSLineData.h"

@implementation CCSSlipAreaChart
@synthesize areaAlpha = _areaAlpha;
@synthesize lastClose = _lastClose;
@synthesize enableZoom = _enableZoom;
@synthesize enableSlip = _enableSlip;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initProperty {
    //初始化父类的熟悉
    [super initProperty];
    //去除轴对称属性
    self.areaAlpha = 0.2;
    self.lastClose = 0;
    
    self.enableSlip = YES;
    self.enableZoom = YES;
}

- (void)calcValueRange {
    if (self.linesData != NULL && [self.linesData count] > 0) {
        [self calcDataValueRange];
        [self calcValueRangePaddingZero];
    } else {
        self.maxValue = 0;
        self.minValue = 0;
    }
    
    //    [self calcValueRangeFormatForAxis];
    
    if (self.balanceRange) {
        [self calcBalanceRange];
    }
}

- (void) calcBalanceRange{
    if(self.lastClose > 0 && self.maxValue > 0 && self.minValue > 0){
        CCFloat gap = MAX(fabs(self.maxValue - self.lastClose),fabs(self.minValue - self.lastClose));
        self.maxValue = self.lastClose + gap;
        self.minValue = self.lastClose - gap;
        
        if (self.minValue < 0) {
            self.minValue = 0;
        }
    }
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    [self drawLastCloseLine:rect];
}

- (void)drawData:(CGRect)rect {
    // 起始位置
    CCFloat startX;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetAllowsAntialiasing(context, YES);
    
    if (self.linesData != NULL) {
        //逐条输出MA线
        for (CCUInt i = 0; i < [self.linesData count]; i++) {
            CCSTitledLine *line = [self.linesData objectAtIndex:i];
            
            if (line != NULL) {
                //设置线条颜色
                CGContextSetStrokeColorWithColor(context, line.color.CGColor);
                //获取线条数据
                NSArray *lineDatas = line.data;
                //判断Y轴的位置设置从左往右还是从右往左绘制
                if (self.axisYPosition == CCSGridChartYAxisPositionLeft) {
                    // 点线距离
                    CCFloat lineLength = ((rect.size.width - self.axisMarginLeft - self.axisMarginRight) / ([line.data count] - 1));
                    //起始点
                    startX = super.axisMarginLeft;
                    //遍历并绘制线条
                    for (CCUInt j = 0; j < [lineDatas count]; j++) {
                        CCSLineData *lineData = [lineDatas objectAtIndex:j];
                        
                        // 绘制结束
                        if (self.closingDate && [self.closingDate isEqualToString:lineData.date]) {
                            break;
                        }
                        
                        CCFloat offsetY = lineData.value - self.minValue;
                        
                        // 价格超过显示范围
                        if (offsetY < 0) {
                            offsetY = 0;
                        }
                        
                        //获取终点Y坐标
                        CCFloat valueY = ((1 - offsetY / (self.maxValue - self.minValue)) * (rect.size.height - 2 * self.axisMarginTop - self.axisMarginBottom) + self.axisMarginTop);
                        
                        if (isnan(valueY)) {
                            valueY = rect.size.height - self.axisMarginBottom;
                        }
                        
                        //绘制线条路径
                        if (j == 0) {
                            CGContextMoveToPoint(context, startX, valueY);
                        } else {
                            CGContextAddLineToPoint(context, startX, valueY);
                        }
                        //X位移
                        startX = startX + lineLength;
                    }
                } else {
                    
                    // 点线距离
                    CCFloat lineLength = ((rect.size.width - 2 * self.axisMarginLeft - self.axisMarginRight) / ([line.data count] - 1));
                    //起始点
                    startX = rect.size.width - self.axisMarginRight - self.axisMarginLeft;
                    
                    //判断点的多少
                    if ([lineDatas count] == 0) {
                        //0根则返回
                        return;
                    } else if ([lineDatas count] == 1) {
                        //1根则绘制一条直线
                        CCSLineData *lineData = [lineDatas objectAtIndex:0];
                        //获取终点Y坐标
                        CCFloat valueY = ((1 - (lineData.value - self.minValue) / (self.maxValue - self.minValue)) * (rect.size.height - 2 * self.axisMarginTop - self.axisMarginBottom) + self.axisMarginTop);
                        
                        CGContextMoveToPoint(context, startX, valueY);
                        CGContextAddLineToPoint(context, self.axisMarginLeft, valueY);
                        
                    } else {
                        //遍历并绘制线条
                        for (CCInt j = [lineDatas count] - 1; j >= 0; j--) {
                            CCSLineData *lineData = [lineDatas objectAtIndex:j];
                            
                            // 绘制结束
                            if (self.closingDate && [self.closingDate isEqualToString:lineData.date]) {
                                break;
                            }
                            
                            //获取终点Y坐标
                            CCFloat valueY = ((1 - (lineData.value - self.minValue) / (self.maxValue - self.minValue)) * (rect.size.height - 2 * self.axisMarginTop - self.axisMarginBottom) + self.axisMarginTop);
                            //绘制线条路径
                            if (j == [lineDatas count] - 1) {
                                CGContextMoveToPoint(context, startX, valueY);
                            } else if (j == 0) {
                                CGContextAddLineToPoint(context, self.axisMarginLeft, valueY);
                            } else {
                                CGContextAddLineToPoint(context, startX, valueY);
                            }
                            //X位移
                            startX = startX - lineLength;
                        }
                    }
                }
                
                //备份路径
                CGPathRef path = CGContextCopyPath(context);
                
                //绘制路径
                CGContextStrokePath(context);
                
                if (i == 0) {
                    CGContextAddPath(context, path);
                    CGContextAddLineToPoint(context, startX, rect.size.height - self.axisMarginBottom - self.axisMarginTop);
                    CGContextAddLineToPoint(context, self.axisMarginLeft, rect.size.height - self.axisMarginBottom - self.axisMarginTop);
                    
                    CGContextClosePath(context);
                    CGContextSetAlpha(context, self.areaAlpha);
                    CGContextSetFillColorWithColor(context, line.color.CGColor);
                    CGContextFillPath(context);
                }
                
                //还原半透明
                CGContextSetAlpha(context, 1);
                CGPathRelease(path);
                
                path = nil;
            }
        }
    }
}

- (void)drawLastCloseLine:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.8f);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
    
    if ([self.longitudeTitles count] <= 0) {
        return;
    }
    //设置线条为点线
    CGFloat lengths[] = {3.0, 3.0};
    CGContextSetLineDash(context, 0.0, lengths, 2);
    
    CGContextMoveToPoint(context, self.axisMarginLeft, (rect.size.height-self.axisMarginBottom - self.axisMarginTop)/2.0f);
    CGContextAddLineToPoint(context, rect.size.width-self.axisMarginRight, (rect.size.height-self.axisMarginBottom - self.axisMarginTop)/2.0f);
    CGContextStrokePath(context);
    
    CGContextSetLineDash(context, 0, nil, 0);
}

- (void)drawXAxisTitles:(CGRect)rect {
    if (self.autoCalcLongitudeTitle) {
        [super drawXAxisTitles: rect];
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5f);
    CGContextSetStrokeColorWithColor(context, self.longitudeColor.CGColor);
    CGContextSetFillColorWithColor(context, self.longitudeFontColor.CGColor);
    
    if (self.displayLongitude == NO) {
        return;
    }
    
    if (self.displayLongitudeTitle == NO) {
        return;
    }
    
    if (self.longitudeTitles == nil) {
        return;
    }
    
    if ([self.longitudeTitles count] <= 0) {
        return;
    }
    
    CCFloat offset;
    
    CCFloat lineLength = rect.size.width - self.axisMarginLeft - self.axisMarginRight;
    offset = lineLength/([self.longitudeTitles count]-1);
    
    UIFont *textFont= self.longitudeFont; //设置字体
    textFont = [UIFont systemFontOfSize:8.0f];
    
    for(CCUInt i=0;i < [self.longitudeTitles count];i++){
        NSString *str = (NSString *) [self.longitudeTitles objectAtIndex:i];
        
        CCFloat titleLength = [str boundingRectWithSize:CGSizeMake(100, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : textFont} context:nil].size.width;
        
        CGRect textRect;
        CCFloat titleX= (offset*i+self.axisMarginLeft) - titleLength/2.0f;
        // 处理最后一条轴线越线问题
        if (i == [self.longitudeTitles count]-1) {
            titleX= rect.size.width - self.axisMarginRight - titleLength - 3.0f;
        }else if (i == 0){
            titleX = self.axisMarginLeft + 3.0f;
        }else{
        }
        textRect= CGRectMake(titleX, rect.size.height - self.axisMarginBottom + 3.0f, titleLength, self.longitudeFontSize);
        
        NSMutableParagraphStyle *textStyle=[[NSMutableParagraphStyle alloc]init];//段落样式
        textStyle.alignment=NSTextAlignmentLeft;
        textStyle.lineBreakMode = NSLineBreakByWordWrapping;
        //绘制字体
        [str drawInRect:textRect withAttributes:@{NSFontAttributeName:textFont,
                                                  NSParagraphStyleAttributeName:textStyle,
                                                  NSForegroundColorAttributeName:self.longitudeFontColor}];
    }
}

-(void) bindSelectedIndex
{
    CCFloat stickWidth = [self getDataStickWidth];
    CCFloat pointX = self.axisMarginLeft +(self.selectedIndex - self.displayFrom + 0.5) * stickWidth;
    CCFloat pointY = self.singleTouchPoint.y;
    
    // is FloatMode
    if (self.touchMode == CCSLineChartTouchModeFloatHorizontal
        || self.touchMode == CCSLineChartTouchModeFloatBoth){
        //noop
    }else{
        
        if (self.linesData != nil && [self.linesData count] > 0 ){
            CCSTitledLine *line = [self.linesData objectAtIndex:0];
            if (line != nil) {
                if (line.data != nil && [line.data count] > self.selectedIndex) {
                    CCSLineData *lineData = [line.data objectAtIndex:self.selectedIndex];
                    if ([self isNoneDisplayValue:lineData.value] == NO) {
                        pointY = [self computeValueY:lineData.value inRect:self.frame];
                    }
                }
            }
        }
    }
    
    _singleTouchPoint = CGPointMake(pointX,pointY);
}

- (void)zoomOut {
    if (self.enableZoom) {
        [super zoomOut];
    }
}

- (void)zoomIn {
    if (self.enableZoom) {
        [super zoomIn];
    }
}

- (void)moveLeft {
    if (self.enableSlip) {
        [super moveLeft];
    }
}

- (void)moveRight {
    if (self.enableSlip) {
        [super moveRight];
    }
}

@end
