#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "YummyItem.h"

@interface YummyTableCell : UITableViewCell<ASIHTTPRequestDelegate> 
{
    YummyItem *yummyItem;
    UIImageView *imageView;
}

//@property (retain,nonatomic) NSString* title;
@property (nonatomic, retain) YummyItem * yummyItem;
@property (nonatomic, retain) UIImage * image;

+ (id)cell;
@end