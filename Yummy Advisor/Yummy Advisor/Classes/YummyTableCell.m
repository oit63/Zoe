#import "YummyTableCell.h"
#import "ASIHTTPRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>

@implementation YummyTableCell
@synthesize yummyItem;
@synthesize imageView;

+ (id)cell
{
	YummyTableCell *cell = [[[YummyTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YummyTableCell"] autorelease];
    [[cell textLabel] setFont:[UIFont systemFontOfSize:13]];
	[[cell textLabel] setLineBreakMode:UILineBreakModeWordWrap];
	[[cell textLabel] setNumberOfLines:0];
    
//	if ([[UIScreen mainScreen] bounds].size.width > 480) 
//    { // iPad
//		UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(10,10,144,144)] autorelease];
//		[imageView setImage:[UIImage imageNamed:@"Icon72x2.png"]];
//		[[cell contentView] addSubview:imageView];
//	}
	return cell;	
}

//- (void)layoutSubviews
//{
//	[super layoutSubviews];
//	int tablePadding = 20;
//	int tableWidth = [[self superview] frame].size.width;
//	if (tableWidth > 480) { // iPad
//		tablePadding = 110;
//		[[self textLabel] setFrame:CGRectMake(70,10,tableWidth-tablePadding-70,[[self class] neededHeightForDescription:[[self textLabel] text] withTableWidth:tableWidth])];	
//	} else {
//		[[self textLabel] setFrame:CGRectMake(10,10,tableWidth-tablePadding,[[self class] neededHeightForDescription:[[self textLabel] text] withTableWidth:tableWidth])];	
//	}
//
//}
//
//+ (NSUInteger)neededHeightForDescription:(NSString *)description withTableWidth:(NSUInteger)tableWidth
//{
//	int tablePadding = 40;
//	int offset = 0;
//	int textSize = 13;
//	if (tableWidth > 480) 
//    { // iPad
//		tablePadding = 110;
//		offset = 70;
//		textSize = 14;
//	}
//	CGSize labelSize = [description sizeWithFont:[UIFont systemFontOfSize:textSize] constrainedToSize:CGSizeMake(tableWidth-tablePadding-offset,1000) lineBreakMode:UILineBreakModeWordWrap];
//	if (labelSize.height < 48) 
//    {
//		return 58;
//	}
//	return labelSize.height;
//}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [[self contentView]addSubview:[[UIImageView alloc] initWithFrame: CGRectZero]];
    return self;
}

- (UIImage *) image
{
    return imageView.image;
}

- (void) setImage: (UIImage *) anImage
{
    imageView.image = anImage;
    [self setNeedsLayout];
}

-(UIColor*) getBgColor
{
    if(self.yummyItem!=nil)
    {
        NSString *bgColorString=self.yummyItem.bgColorString;
        if([bgColorString length]>=7)
        {
            NSString *s=[bgColorString substringWithRange:NSMakeRange(1,2)];
            unsigned long l=strtoul([s UTF8String], 0, 16);
            float redf=l/255.0;
            
            s=[bgColorString substringWithRange:NSMakeRange(3,2)];
            l=strtoul([s UTF8String], 0, 16);
            float greenf=l/255.0;
            
            s=[bgColorString substringWithRange:NSMakeRange(5,2)];
            l=strtoul([s UTF8String], 0, 16);
            float bluef=l/255.0;
            
            float alphaf=1;
            if([bgColorString length]>=9)
            {
                s=[bgColorString substringWithRange:NSMakeRange(7,2)];
                l=strtoul([s UTF8String], 0, 16);
                alphaf=l/255.0;
            }
            
            return  [UIColor colorWithRed:redf green:greenf blue:bluef alpha:alphaf];
        }
    }
    return [UIColor orangeColor];
}

- (NSString *) md5:(NSString*) str
{
    NSLog(@"%@",str);//XXX
    if(str)
    {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
    }
    return nil;
}

- (void)startIconDownload:(YummyTableCell *)cell
{
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:self.yummyItem.imageURLString]];
    [request setDelegate:self];
    [request startAsynchronous];
}

-(void) checkImage
{
    if (!imageView.image)
    {
        NSString* docPath = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents"];
        NSString* imagePath =[NSString stringWithFormat: @"%@/%@.png", docPath, [self md5:self.yummyItem.imageURLString]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) 
        {  
            //NSArray *array = [[NSArray alloc] initWithContentsOfFile:imagePath];  
            NSData *data = [[NSMutableData alloc] initWithContentsOfFile: imagePath];
            UIImage *image = [[UIImage alloc] initWithData:data];
            [self setImage:image];
        }
        else
        {
            [self startIconDownload:self];
            // if a download is deferred or in progress, return a placeholder image
            //imageView.image = [UIImage imageNamed:@"Placeholder.png"];
            imageView.image = [UIImage imageNamed:@"alien.png"];
        }
    }
}

-(void) layoutIcon:(CGRect)contentBounds
{
    CGSize contentSize=contentBounds.size;
    
    [self checkImage];
    
    // scale it down to fit
    CGRect frame=imageView.frame;
    CGSize imageSize=imageView.image.size;
    CGFloat hRatio = contentSize.width / imageSize.width;
    CGFloat vRatio = contentSize.height / imageSize.height;
    CGFloat ratio = MIN(hRatio, vRatio);
    
    frame.size.width =floorf(imageSize.width * ratio);
    frame.size.height = floorf(imageSize.height * ratio);
    frame.origin.x =floorf((contentSize.width - frame.size.width) * 0.5);
    frame.origin.y =floorf((contentSize.height - frame.size.height) * 0.5);
    //NSLog(@"icon new Frame(%f,%f,%f,%f)",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
    imageView.frame = frame;
}


//-(void) layoutLabels:(CGRect)contentBounds
//{
//    [_indexLabel setText:[NSString stringWithFormat:@"%d",_displayIndex]];
//    _indexLabel.font = [UIFont boldSystemFontOfSize: 24.0];
//    CGRect frame00=CGRectMake(210, 0, 40, 40);
//    _indexLabel.frame=frame00;
//    _indexLabel.textAlignment=UITextAlignmentRight;
//    NSLog(@"layoutLabels,Title:%@",self.yummyItem.title);//XXX
//    
//    
//    _titleLabel.textColor = [UIColor whiteColor];
//    _titleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4]; 
//    _titleLabel.font = [UIFont boldSystemFontOfSize: 24.0];
//    _titleLabel.adjustsFontSizeToFitWidth = YES;
//    //_titleLabel.minimumFontSize = 16.0;
//    
//    
//    CGRect bounds = CGRectMake(0, 210, 250, 40);//FIXME
//    //NSLog(@"Label Bounds(%f,%f,%f,%f)",bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);//XXX
//    
//    [_titleLabel setText:self.yummyItem.title];
//    
//    CGRect frame = _titleLabel.frame;
//    frame.size.width = MIN(frame.size.width, bounds.size.width);
//    frame.origin.y = CGRectGetMaxY(bounds) - frame.size.height;
//    frame.origin.x = floorf((bounds.size.width - frame.size.width) * 0.5);
//    _titleLabel.frame = frame;
//    _titleLabel.frame = bounds;
//    //[_titleLabel sizeToFit];
//}

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect contentBounds = [[self superview] frame];
    [self contentView].backgroundColor = [self getBgColor];  
    //_contentView.frame=contentBounds;
    //[self layoutLabels:contentBounds];
    [self layoutIcon:contentBounds];
}


- (NSString *) findUniqueSavePath
{
	NSString *path; 
    NSString *name=[self md5:self.yummyItem.imageURLString];
	path = [NSString stringWithFormat:@"%@/Documents/%@.png", NSHomeDirectory(), name];
	return path;
}

//****************************************************************************************************

- (void)requestStarted:(ASIHTTPRequest *)request
{
	
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
	
}

- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL
{
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSMutableData *raw=request.rawResponseData;
    UIImage *image = [[UIImage alloc] initWithData:raw];
    
    // Write to file
	// [UIImageJPEGRepresentation(image, 1.0f) writeToFile:[self findUniqueSavePath] atomically:YES];
    //NSLog(@"Write file{%@} to Documents",[self findUniqueSavePath]);
	[UIImagePNGRepresentation(image) writeToFile:[self findUniqueSavePath] atomically:YES];
    
    [self setImage:image];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    
}


- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
	
}
@end