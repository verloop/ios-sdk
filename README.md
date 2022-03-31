NOTE:\
Now, you can install using cocoapod - `pod install VerloopSDKiOS`

Or Download the iOS using this link:

`https://drive.google.com/file/d/1qi3_Kq42eRu487rjGRTD5gX9-2-U2Ia5/view?usp=sharing`

**Version 0.1.3**

`https://drive.google.com/file/d/18UUCTqxLqCSybMiK3aUJhZ87aAkM_pO2/view?usp=sharing`

**Version 0.1.4**

`https://drive.google.com/file/d/172R2OaMygDXjYPMj4zUgIKWurV8NDyaO/view?usp=sharing`
 
**For Swift**\
After importing the Framework like any other framework you do, import the SDK in controller as :-

`swift import VerloopSDK`

In your viewDidLoad, create a config and instantiate the verloop variable like this :-

```
let config = VLConfig(clientId: clientId, userId: userId) config.setStaging(isStaging: true/false) // default false config.setNotificationToken(notificationToken: token) // optional config.addCustomField(key: "key", value: "value", scope: VLConfig.SCOPE.USER)

verloop = VerloopSDK(config: config) 
```

After this, when user wants to open the chat, you can simply ask for the UINavigationController and open that UINavigationController :-
```
self.navigationController?.present(verloop.getNavController(), animated: true)
```
Adding user properties
To set a user's name, email, or phone, you can use the method in config object before initializing the SDK.
```
config.setUserName("User's Name") config.setUserEmail("hello@verloop.io") config.setUserPhone("+919xxxxxxxx")
```
Setting a Recipe\
To set a Recipe :-
```
config.setRecipeId("RECIPE ID")
```

Adding a callback for Button Click\
```
config.setButtonOnClickListener(onButtonClicked:{ (title, type, payload) in
     print(title)
})
```

Notifications
When you get a notification from Verloop, simply create the verloop variable and present it's navigation controller.

The notification from Verloop will have a key _by with value verloop. Something like this -
```
json { "_by": "verloop", "aps": { "alert": { "body": "notification message body" } } }
```
So if a user clicks on a notification with payload like this, open the verloop's nav controller.

If you don't have access to your current controller (in case of frameworks like Ionic), you can call
```
verloop.start();
```
But this is not the preferred method of opening the chat.

If you run into run time errors which say that library is missing, you might have to do this to fix - https://stackoverflow.com/a/26949219 (Build Settings > Always Embed Swift Standard Libraries set to YES)


\
**For Objective C**\
After importing the Framework like any other framework you do, import the SDK in controller as :-

```
import <VerloopSDK/VerloopSDK-Swift.h>
```

In your viewDidLoad, create a config and instantiate the verloop variable like this :-

```
VLConfig *config = [[VLConfig alloc] initWithClientId:@"clientId" userId:@"userId"];

[config setNotificationTokenWithNotificationToken:@"token"]; [config setStagingWithIsStaging:YES]; [config putCustomFieldWithKey:@"key" value:@"value" scope:SCOPEUSER];

VerloopSDK *verloop = [[VerloopSDK alloc] initWithConfig:config]; ```
```
After this, when user want to open the chat, you can simply ask for the UINavigationController and open that UINavigationController.

```
[[self navigationController] presentViewController:obj animated:YES completion:NULL];
```
Adding user properties
To set a user's name, email, or phone, you can use the method in config object before initializing the SDK.
```
[config setUserName:@"Name"]; [config setUserEmail:@"hello@verloop.io"]; [config setUserPhone:@"+919xxxxxxxx"];

```
To open the chat -
```
[verloop start]; 
```

# Build SDK manually

Note: you need this if the compiled sdk provided is not compatible with the swift version / Xcode version

https://github.com/Carthage/Carthage


- Open the VerloopSDK project in the xcode (https://github.com/verloop/ios-sdk)
- Set the swift version from the build settings
- Run the following command to build the archive- make sure that you are in the VerloopSDK folder

`carthage build --archive`

- Once this command is executed successfully, a carthage folder will be created
- You will find the framework in Carthage/build/iOS
