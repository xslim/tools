//
//  UINavigationBar+backgroundImage.m
//  
//
//  Created by Kalapun Taras on 11/27/09.
//

#import "UINavigationBar+backgroundImage.h"
#include <objc/runtime.h>  
#include <objc/message.h>

@implementation UINavigationBar (CustomImage)


+ (void)inspectView:(UIView *)aView level:(NSString *)level {
	NSLog(@"Level:%@", level);
	NSLog(@"View:%@", aView);
    
	NSArray *arr = [aView subviews];
	for (int i=0;i<[arr count];i++) {
		[UINavigationBar inspectView:[arr objectAtIndex:i]
                    level:[NSString stringWithFormat:@"%@/%d", level, i]];
	}
}


static IMP UINavigationItemView_original_drawTextInRect; 
static void UINavigationItemView_drawTextInRect(id self, SEL _cmd, NSString *string, CGRect rect)  
{  
    
    CGPoint  point = rect.origin;  
    UIFont  *font  = [self performSelector:NSSelectorFromString(@"_defaultFont")];  
    
    // Draw shadow of string 
    point.y += 2;  
    //[[UIColor whiteColor] set];  
    [[UIColor colorWithRed:241/255.0f green:191/255.0f blue:149/255.0f alpha:1.0f] set];
    [string drawAtPoint:point forWidth:rect.size.width withFont:font lineBreakMode:UILineBreakModeTailTruncation];  
    
    // Draw string 
    point.y -= 1;  
    //[[UIColor blackColor] set];  
    [[UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.0f] set];
    [string drawAtPoint:point forWidth:rect.size.width withFont:font lineBreakMode:UILineBreakModeTailTruncation];  
}  
 

static UIColor *UIButtonLabel_textColor(id self, SEL _cmd)  
{  
    if ([[self superview] isKindOfClass:NSClassFromString(@"UINavigationButton")] &&
        [[[self superview] superview] isKindOfClass:NSClassFromString(@"UINavigationBar")] &&
        ([(UINavigationBar *)[[self superview] superview] barStyle] == UIBarStyleDefault)
        ) 
    {  
        //return [UIColor blackColor];  
        return [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.0f];
    } else {  
        struct objc_super super = { self, [UILabel class] };  
        return objc_msgSendSuper(&super, _cmd);  
    }  
}  


static UIColor *UIButtonLabel_shadowColor(id self, SEL _cmd)  
{  
    if ([[self superview] isKindOfClass:NSClassFromString(@"UINavigationButton")] &&
        [[[self superview] superview] isKindOfClass:NSClassFromString(@"UINavigationBar")] &&
        ([(UINavigationBar *)[[self superview] superview] barStyle] == UIBarStyleDefault)
        ) 
    {   
        //return [UIColor whiteColor];  
        return [UIColor colorWithRed:241/255.0f green:191/255.0f blue:149/255.0f alpha:1.0f];
    } else {  
        struct objc_super super = { self, [UILabel class] };  
        return objc_msgSendSuper(&super, _cmd);  
    }  
}  

static IMP UIButtonLabel_original_setShadowOffset;  
static void UIButtonLabel_setShadowOffset(id self, SEL _cmd, CGSize offset)  
{  
    if ([[self superview] isKindOfClass:NSClassFromString(@"UINavigationButton")]) 
    {  
        struct objc_super super = { self, [UILabel class] };  
        
        objc_msgSendSuper(&super, _cmd, CGSizeMake(0, 1));  
    } else {  
        UIButtonLabel_original_setShadowOffset(self, _cmd, offset);  
    }  
}  

+ (void)load  
{  
    Class  class;  
    Method method;
    
    Method drawRectCustomBackground = class_getInstanceMethod([UINavigationBar class], @selector(drawRectCustomBackground:));
    Method drawRect = class_getInstanceMethod([UINavigationBar class], @selector(drawRect:));
    method_exchangeImplementations(drawRect, drawRectCustomBackground);
    
    class = NSClassFromString(@"UINavigationItemView");
    if (class) {  
        method = class_getInstanceMethod(class, NSSelectorFromString(@"drawText:inRect:"));
        if (method) {
            UINavigationItemView_original_drawTextInRect = method_getImplementation(method);
        }
    }
     
    class = NSClassFromString(@"UIButtonLabel");  
    if (class) {  
        class_addMethod(class, @selector(textColor), (IMP)UIButtonLabel_textColor, "@@:");  
        class_addMethod(class, @selector(shadowColor), (IMP)UIButtonLabel_shadowColor, "@@:");  
        
        method = class_getInstanceMethod(class, NSSelectorFromString(@"setShadowOffset:"));  
        
        if (method) {  
            UIButtonLabel_original_setShadowOffset = method_setImplementation(method, (IMP)UIButtonLabel_setShadowOffset);  
        }  
    }  
     
}  

- (void)drawRectCustomBackground:(CGRect)rect 
{
	//[self inspectView:self level:@""];
    
    Class class;
    Method method;
    
    // Call default implementation
    if (self.barStyle != UIBarStyleDefault) {
        [self drawRectCustomBackground:rect];
        
        class = NSClassFromString(@"UINavigationItemView");
        if (class) {  
            method = class_getInstanceMethod(class, NSSelectorFromString(@"drawText:inRect:"));
            if (method) {
                method_setImplementation(method, (IMP)UINavigationItemView_original_drawTextInRect);
            }
        }
        
        return;
    }
    
    
    class = NSClassFromString(@"UINavigationItemView");
    if (class) {  
        method = class_getInstanceMethod(class, NSSelectorFromString(@"drawText:inRect:"));
        if (method) {
            method_setImplementation(method, (IMP)UINavigationItemView_drawTextInRect);
        }
    }
    
    /*
    for (id subView in self.subviews) {
        
         if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
             [(UIButton *)subView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
             [(UIButton *)subView setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
         }
    }
     */
    
    self.tintColor = [UIColor colorWithRed:251/255.0f green:147/255.0f blue:19/255.0f alpha:1.0f];
    
    NSString *imageName = (self.tag == 10) ? @"TitleBar.png" : @"TitleImg.png";
    
    UIImage *image = [UIImage imageNamed: imageName];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    
}


@end
