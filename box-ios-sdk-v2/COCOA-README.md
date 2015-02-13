BoxCocoaSDK: Box API V2 OSX SDK
==========================

[![Build Status](https://travis-ci.org/box/box-ios-sdk-v2.png?branch=master)](https://travis-ci.org/box/box-ios-sdk-v2)
[![Version](https://cocoapod-badges.herokuapp.com/v/box-ios-sdk-v2/badge.png)](http://cocoadocs.org/docsets/box-ios-sdk-v2)
[![Platform](https://cocoapod-badges.herokuapp.com/p/box-ios-sdk-v2/badge.png)](http://cocoadocs.org/docsets/box-ios-sdk-v2)

This SDK provides access to the [Box V2 API](https://developers.box.com/docs/).
It currently supports file, folder, user, comment, and search operations.

Sample applications are forthcoming.

## Add to your project

### CocoaPods

The easiest way to add this Box SDK to your project is with [CocoaPods](http://cocoapods.org).

Add the following to your Podfile:

```
pod 'box-ios-sdk-v2', '~> 1.2'
```

### Dependent XCode Project + Framework

An alternative way to add the Box Cocoa SDK to your project is as a dependent XCode
project. The BoxCocoaSDK framework is intended to be included in your application,
rather than separately installed on a user's machine.

1. Clone this repository into your project's directory. You can use git submodules
   if you want.
2. Open your project in XCode.
3. Drag BoxSDK.xcodeproj into the root of your project explorer.<br />![Dependent project](http://box.github.io/box-ios-sdk-v2/readme-images/dependent-project.png)

4. Add the BoxCocoaSDK target as a target dependency.<br />![Target dependency](http://box.github.io/box-ios-sdk-v2/readme-images/cocoa-target-dependency.png)

5. Link with BoxCocoaSDK.framework<br />![Link with binary](http://box.github.io/box-ios-sdk-v2/readme-images/cocoa-link-with-binary.png)

6. Create a build phase to copy the compiled framework into a 'Frameworks' directory in your application bundle.<br />![Copy to bundle](http://box.github.io/box-ios-sdk-v2/readme-images/cocoa-copy-to-bundle.png)

**Note**: steps 2-6 are covered in [Apple's documentation on using frameworks](https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPFrameworks/Tasks/CreatingFrameworks.html#//apple_ref/doc/uid/20002258-SW1).

7. Add the `-ObjC` linker flag. This is needed to load categories defined in the SDK.<br />![Add linker flag](http://box.github.io/box-ios-sdk-v2/readme-images/linker-flag.png)

8. `#import <BoxCocoaSDK/BoxCocoaSDK.h>`


## Quickstart

### Configure

Set your client ID and client secret on the SDK client:

```objc
[BoxCocoaSDK sharedSDK].OAuth2Session.clientID = @"YOUR_CLIENT_ID";
[BoxCocoaSDK sharedSDK].OAuth2Session.clientSecret = @"YOUR_CLIENT_SECRET";
```

One way to complete the OAuth2 flow is to have your app to register a
custom URL scheme in order to receive an OAuth2 authorization code.
In your `Info.plist`, register the following URL scheme:

```
boxsdk-YOUR_CLIENT_ID
```

**Note**: When setting up your service on Box, leave the OAuth2 redirect URI blank.
The SDK will provide a custom redirect URI when issuing OAuth2 calls; doing so requires
that no redirect URI be set in your service settings.

### Authenticate
To authenticate your app with Box, you need to use OAuth2. It's easiest to use the user's default
browser to execute the OAuth2 authentication and authorization. To get started, you simply ask the system
to open the authentication URL:

```objc
NSURL *authURL = [[BoxCocoaSDK sharedSDK].OAuth2Session authorizeURL];
NSArray *urls = [NSArray arrayWithObject:authURL];
[[NSWorkspace sharedWorkspace] openURLs:urls
				withAppBundleIdentifier:nil //@"com.apple.Safari" if you want to specify Safari rather than the user's default browser
								options:NSWorkspaceLaunchWithoutAddingToRecents
		 additionalEventParamDescriptor:nil
					  launchIdentifiers:NULL];
```

On successful authentication, your app will receive an "open in" request using
the custom URL scheme you registered earlier. In your app delegate:

```objc
- (void)handleURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSString *receivedUrlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    [[BoxCocoaSDK sharedSDK].OAuth2Session performAuthorizationCodeGrantWithReceivedURL:[NSURL URLWithString:receivedUrlString]];
}
```

You can listen to notifications on `[BoxCocoaSDK sharedSDK].OAuth2Session` to be notified
when a user becomes successfully authenticated.

**Note**: The SDK does not store tokens. We recommend storing the refresh token in
the keychain and listening to notifications sent by the OAuth2Session. For more
information, see
[the documetation for BoxOAuth2Session](http://box.github.io/box-ios-sdk-v2/Classes/BoxOAuth2Session.html).

### Making API calls

All SDK API calls are asynchronous. They are scheduled by the SDK on an `NSOperationQueue`.
To be notified of API responses and errors, pass blocks to the SDK API call methods. These
blocks are triggered once the API response has been received by the SDK.

**Note**: callbacks are not triggered on the main thread. Wrap updates to your app's
UI in a `dispatch_sync` block on the main thread.

#### Get a folder's children

```objc
BoxCollectionBlock success = ^(BoxCollection *collection)
{
  // grab items from the collection, use the collection as a data source
  // for a table view, etc.
};

BoxAPIJSONFailureBlock failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
{
  // handle errors
};

[[BoxCocoaSDK sharedSDK].foldersManager folderItemsWithID:folderID requestBuilder:nil success:success failure:failure];
```

#### Get a file's information

```objc
BoxFileBlock success = ^(BoxFile *file)
{
  // manipulate the BoxFile.
};

BoxAPIJSONFailureBlock failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
{
  // handle errors
};

[[BoxCocoaSDK sharedSDK].filesManager fileInfoWithID:folderID requestBuilder:nil success:success failure:failure];
```

#### Edit an item's information

To send data via the API, use a request builder. If we wish to move a file and change its
name:

```objc
BoxFileBlock success = ^(BoxFile *file)
{
  // manipulate the BoxFile.
};

BoxAPIJSONFailureBlock failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
{
  // handle errors
};

BoxFilesRequestBuilder *builder = [BoxFilesRequestBuilder alloc] init];
builder.name = @"My awesome file.txt"
builder.parentID = BoxAPIFolderIDRoot;

[[BoxCocoaSDK sharedSDK].filesManager editFileWithID:folderID requestBuilder:builder success:success failure:failure];
```

#### Upload a new file

```objc
BoxFileBlock fileBlock = ^(BoxFile *file)
{
  // manipulate resulting BoxFile
};

BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
{
  // handle failed upload
};

BoxAPIMultipartProgressBlock progressBlock = ^(unsigned long long totalBytes, unsigned long long bytesSent)
{
  // indicate progress of upload
};

BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
builder.name = @"Logo_Box_Blue_Whitebg_480x480.jpg";
builder.parentID = folderID;

NSString *path = [[NSBundle mainBundle] pathForResource:@"Logo_Box_Blue_Whitebg_480x480.jpg" ofType:nil];
NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:path];
NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
long long contentLength = [[fileAttributes objectForKey:NSFileSize] longLongValue];

[[BoxCocoaSDK sharedSDK].filesManager uploadFileWithInputStream:inputStream contentLength:contentLength MIMEType:nil requestBuilder:builder success:fileBlock failure:failureBlock progress:progressBlock];
```

#### Download a file

```objc
NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];

BoxDownloadSuccessBlock successBlock = ^(NSString *downloadedFileID, long long expectedContentLength)
{
  // handle download, preview download, etc.
};

BoxDownloadFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
{
  // handle download failure
};

BoxAPIDataProgressBlock progressBlock = ^(long long expectedTotalBytes, unsigned long long bytesReceived)
{
  // display progress
};

[[BoxCocoaSDK sharedSDK].filesManager downloadFileWithID:fileID outputStream:outputStream requestBuilder:nil success:successBlock failure:failureBlock progress:progressBlock];
```

## Build Settings

The BoxCocoaSDK framework MUST be built with the OSX 10.8 SDK. It targets the 10.7 OS, and is not currently compatible with OSX 10.6 or earlier.

## Tests

This SDK contains unit tests that are runnable with `./bin/test.sh` or alternatively `rake spec`.

To run tests specifically for the OS X platform, run tests with `./bin/test.sh 10.8`. This will compile
BoxCocoaSDK and tests with the OS X 10.8 SDK.

Pull requests will not be accepted unless they include test coverage.

## Documentation

Documentation for this SDK is generated using [appledoc](http://gentlebytes.com/appledoc/).
Documentation can be generated by running `./bin/generate-documentation.sh`. This script
depends on the `appledoc` binary which can be downloaded using homebrew (`brew install appledoc`).

[Documentation is hosted on this repo's github page](http://box.github.io/box-ios-sdk-v2/).

Pull requests will not be accepted unless they include documentation.

## Known issues

* There is no support for manipulating files in the trash.
* Missing support for the following endpoints:
  * Collaborations
  * Events
  * Groups
  * Tasks

