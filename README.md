# mesibo_sample_app

## Problem
we are facing an issue using the `getUnreadMessageCount` function where it always return the unread count as 0 after using `remoteProfile!.createReadSession(this).read(100)`, the steps to reproduce the issue we are facing:
1. user1 logs in.
2. user2 logs in and sends a message to user1 from another device.
3. user1 receives the message and the `getUnreadMessageCount` function is working as expected.
4. user1 reads the messages sent by user2 using `remoteProfile!.createReadSession(this).read(100)` and the unread count gets reset to 0 as expected.
5. now user1 clicks on the back button to go to the homepage of the app and sees the unread count as 0.
6. now user2 sends another message.
7. user1 gets the message but `getUnreadMessageCount` function still returns 0 but it should not return 0 because we haven't read the new message yet by calling `remoteProfile!.createReadSession(this).read(100)`

## NOTE:
1. use 2 different devices for 2 users to reproduce this.