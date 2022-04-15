# VerloopSDK for iOS

This framework helps you configure and launch Verloop's chat. Inorder to integrate, one needs to initiase our `VerloopSDK` instance by passing a configuration `VLConfig` object and present it's navigation controller. This will present Verloop's chat modally. The APIs on `VerloopSDK` and `VLConfig` are described in detail below. 


## **Requirements**

- XCode 13.1+
- Min IOS version support IOS10

## **Installation**

Two ways to install

- Now, you can install using cocoapod 
  ```
  pod 'VerloopSDKiOS'
  ```
  
- Manually build the repo and generate the VerloopSDK framework and embed the framework in Linked Binaries in your project as shown below. 
<p align="center">
<img width="700" alt="Screenshot 2022-03-15 at 3 08 56 PM" src="https://user-images.githubusercontent.com/98142458/158394191-f40ef1b5-89eb-41cb-8110-dfcd54b700be.png">
</p>



## **SDK Usage - Swift** 

 
Import the library with the following command: 

```
import VerloopSDK
```

Initialise the configuration object `VLConfig`. You could pass an identifier to uniquely indentify a user  - `userId`. Will be useful to manage logged in user sessions. 

```
let config = VLConfig(clientId: String)

let config = VLConfig(clientId: String, userId: String?)    //clientId is required parameter while userId.
```
You could otherwise update the userId using the method `setUserId` on an instance of `VLConfig`.  

```
let config = VLConfig(clientId: String)

config.setUserId(userId: String)
```


### APIs on `VLConfig`

You could configure your chat's instance with the following APIs on VLConfig:

- **Recepie ID:** To set the recipe before launching the chat. If this api isn't used, then default recipe would be picked up.

``` 
config.setRecipeId(recipeId id: String?)
```

- Notification Token: To receive notifications, you'll need to pass your device token via this API apart from setting you bundle id, p12 apns cert and its password in the dashboard. 

```
config.setNotificationToken(notificationToken: string)
```


- UserName, UserEmail and UserPhone: To set user parameters such as username, email and phone number. 


```
config.setUserName(username name:String)

config.setUserEmail(userEmail email:String)

config.setUserPhone(userPhone phone:String)
```

- User Parameters: You could pass in one or more of the above details using the api `setUserParam`. Key can be either `name`, `email`, and/or `phone`.

```
config.setUserParam(key:String, value:String)

Example: 

config.setUserParam(key: "name", value: "Test User")

config.setUserParam(key: "email", value: "user@test.com")
```

- Custom Fields: Use this api setCustomField to pass any custom parameters. This helps to add your own logic into conversation. This could be fetched via webhooks while running the bot recipe. `key` and `value` are the details saved within the set scope. Scope takes in two values, `user` and `room`.

```
config.putCustomField(key: String, value: String, scope: SCOPE)

Example:
                        
config?.putCustomField(key: "custom_key", value: "custom_value", scope: .USER)

```


- Listeners: You could set two listenrs when an end user taps on a button or url in the recipe. 

```
//Button Click Listener

config.setButtonOnClickListener(onButtonClicked buttonClicked: LiveChatButtonClickListener?)


// URL Click Listener

setUrlClickListener(onUrlClicked urlClicked: LiveChatUrlClickListener?)

```


### APIs on `VerloopSDK`

VerloopSDK class is the SDK class which expects a `VLConfig` instance as an initialisation parameter. An instance of VerloopSDK is used to present or close the chat. You could manage user session with the login and logout APIs on this class. Here we'll walk you through the APIs with the scenarios.  

- To initialise the SDK
```
let verloop = VerloopSDK(config: config)     
```

- To prsent the chat, you'll need to get the root view controller of the chat and present it modally from your controller. This will launch the converstation too. Use `getNavController` method of the `VerloopSDK` to create an instance of the SDK's root view controller. 

```
let chatController = verloop.getNavController()

yourViewController.present(chatController, animated: true)
```

- To manage user session, use the login and logout methods. You could login with a user identifier. 

```
let verloop = VerloopSDK(config: config)    

verloop.login(userId: string)

verloop.logout()
```

### For Apple Push Notifications 

To recieve notifications, add the BundleID, APNS Certificate file(.p12) and it's corresponding password on the dashboard's setting page. Homepage > Settings > Chat (under product settings) > iOS SDK / Android SDK

Note: Set the device token on the configuration object, before initialising the SDK. The notification payload from Verloop will have a key `_by` with value `verloop`. 

```
json { "_by": "verloop", "aps": { "alert": { "body": "notification message body" } } }
```


## **SDK Usage - Objective C** 


After importing the Framework, add the following line in your controller:

```
import <VerloopSDK/VerloopSDK-Swift.h>
```

Create the `VLConfig` object. Configure the object. Then initialise `VerloopSDK` with the configuration object. Few of the APIs are listed below. 

```
VLConfig *config = [[VLConfig alloc] initWithClientId:@"clientId" userId:@"userId"];

[config setUserName:@"Name"]; [config setUserEmail:@"hello@verloop.io"]; [config setUserPhone:@"+919xxxxxxxx"];
[config setNotificationTokenWithNotificationToken:@"token"]; 
[config setStagingWithIsStaging:YES]; 
[config putCustomFieldWithKey:@"key" value:@"value" scope:SCOPEUSER];

VerloopSDK *verloop = [[VerloopSDK alloc] initWithConfig:config]; 
```

After this, when user want to open the chat, you can simply ask for the UINavigationController and present it on your viewcontroller. 

```
[[self navigationController] presentViewController:[verloop getNavController] animated:YES completion:NULL];
```

Note: Kindly go through the swift's documentation for further APIs and appropriately call corresponding methods. 
