/*
 Copyright 2015 OpenMarket Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MXKReceiptAvartarsContainer.h"

#import "MXSession.h"
#import "MXKImageView.h"


#define MAX_NBR_USERS 3

@interface MXKReceiptAvartarsContainer ()
{
    NSMutableArray* avatarViews;
    UIView* moreView;
    
}
@end

@implementation MXKReceiptAvartarsContainer

- (void)setUserIds:(NSArray*)userIds roomState:(MXRoomState*)roomState session:(MXSession*)session placeholder:(UIImage*)placeHolder withAlignment:(ReadReceiptsAlignment)alignment
{
    CGRect globalFrame = self.frame;
    CGFloat side = globalFrame.size.height;
    unsigned long count;
    unsigned long maxDisplayableItems = ((int)globalFrame.size.width / side) - 1;
    
    maxDisplayableItems = MIN(maxDisplayableItems, MAX_NBR_USERS);
    count = MIN(userIds.count, maxDisplayableItems);
    
    int index;
    
    MXRestClient* restclient = session.matrixRestClient;
    
    CGFloat xOff = 0;
    
    if (alignment == ReadReceiptAlignmentRight)
    {
        xOff = globalFrame.size.width - (side + 2);
    }
    
    for(index = 0; index < count; index++)
    {
        NSString* userId = [userIds objectAtIndex:index];
        
        // Compute the member avatar URL
        MXRoomMember *roomMember = [roomState memberWithUserId:userId];
        NSString *avatarUrl = NULL;
        
        if (roomMember)
        {
            avatarUrl = [restclient urlOfContentThumbnail:roomMember.avatarUrl toFitViewSize:CGSizeMake(side, side) withMethod:MXThumbnailingMethodCrop];
        }
        
        MXKImageView *imageView = [[MXKImageView alloc] initWithFrame:CGRectMake(xOff, 0, side, side)];
        
        if (alignment == ReadReceiptAlignmentRight)
        {
            xOff -= side + 2;
        }
        else
        {
            xOff += side + 2;
        }
        
        [self addSubview:imageView];
        [avatarViews addObject:imageView];
        imageView.enableInMemoryCache = YES;
        [imageView setImageURL:avatarUrl withType:nil andImageOrientation:UIImageOrientationUp previewImage:placeHolder];
        [imageView.layer setCornerRadius:imageView.frame.size.width / 2];
        imageView.clipsToBounds = YES;
        
    }
    
    // more than expected read receipts
    if (userIds.count > maxDisplayableItems)
    {
        // add a more indicator

        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(xOff, 0, side, side)];
        label.text = [NSString stringWithFormat:(alignment == ReadReceiptAlignmentRight) ? @"%tu+" : @"+%tu", userIds.count - MAX_NBR_USERS];
        label.font = [UIFont systemFontOfSize:11];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.6;
        
        label.textColor = [UIColor blackColor];
        moreView = label;
        [self addSubview:label];
    }
}

- (void)dealloc
{
    if (avatarViews)
    {
        for(UIView* view in avatarViews)
        {
            [view removeFromSuperview];
        }
        
        avatarViews = NULL;
    }
    
    if (moreView)
    {
        [moreView removeFromSuperview];
        moreView = nil;
    }
}

@end