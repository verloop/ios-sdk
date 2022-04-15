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



## **SDK Usage**

 

### **Swift** 

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


The following are the APIs on `VLConfig`

####**Recepie ID:** To set the recipe before launching the chat. If this api isn't used, then default recipe would be picked up.

``` 
config.setRecipeId(recipeId id: String?)
```

**Notification Token:** To receive notifications, you'll need to pass your device token via this API apart from setting you bundle id, p12 apns cert and its password in the dashboard. 

```
config.setNotificationToken(notificationToken: string)
```


**User Parameters** To set user parameters such as username, email and phone number. 


```
config.setUserName(username name:String)

config.setUserEmail(userEmail email:String)

config.setUserPhone(userPhone phone:String)
```

Or you could pass in one or more of the above details using the api `setUserParam`. Key can be either `name`, `email`, and/or `phone`.

```
config.setUserParam(key:String, value:String)

Ex: 

config.setUserParam(key: "name", value: "Test User")

config.setUserParam(key: "email", value: "user@test.com")
```

**Custom Fields:** Use this api setCustomField to pass any custom parameters. This helps to add your own logic into conversation. This could be fetched via webhooks while running the bot recipe. 

```
config.putCustomField(key: String, value: String, scope: SCOPE)
```

Where key and value are the details saved within the set scope. Scope takes in two values, `user` and `room`.


**Listeners:** You could set two listenrs when an end user taps on a button or url in the recipe. 

```
//Button Click Listener

config.setButtonOnClickListener(onButtonClicked buttonClicked: LiveChatButtonClickListener?)


// URL Click Listener

setUrlClickListener(onUrlClicked urlClicked: LiveChatUrlClickListener?)

```


**2) Initialize SDK**

VerloopSDK class is the SDK class which expects configuration as construction parameter. Once above configuration object prepared, create VerloopSDK instance by passing configuration as shown below.

//config: VLConfig object created on step 1.

let verloop = VerloopSDK(config: config)

**3) getNavController and start chat**

getNavController method create an instance of the SDK controller which has embedded WKWebview. When its time to open Verloop chat, like other present controllers, pass getNavController() object on your current controller like shown below.

let chatController = verloop.getNavController()

\&lt;your controller\&gt;.present(chatController, animated: true)

**4)Listen to the events**

//On verloopSDK object call below method to receive call backs occurred in live chat.

//delegate : is a type of VLEventDelegate

observeLiveChatEventsOn(vlEventDelegate delegate:VLEventDelegate)

//Protocol **VLEventdelegate**

//event: Type of the event occurred in live chat.

//below method called if the client confirms to the VLEventDelegate protocol through VerloopSDK&#39;s observeLiveChatEventsOn methods.

didEventOccurOnLiveChat(\_ event: VLEvent)

**VLEvent**

VLEvent is enum with different types of instances or scenarios occurred during the live chat execution.

onButtonClick: Occurred when user makes button click on the live chat

onURLClick : Occurred when user makes url click on the live chat

onChatMaximized: Occured when chat widget is opened and ready to chat.

onChatMinimized: Occured when chat widget is closed by multiple scenarios such as closeWidge.

onChatStarted: Occured when chatSrated call back posted by Livechat

onchatEnded: Occured when chat session is closed

onWidgetClosed: Occured when user closed the widget by click close icon

setUserIdComplete: Occured when the configuration passed user Id sets successfully.

setUserParamComplete: Occured when configuration passed user params set successfully.

**5) Open chat**

Another way to open the chat is by simply calling openWidget on verloopSDK .

Ex: verloopSDK.openWidget()

**6) Start chat**

To start the chat session call start() method in verloopSDK.

Ex: verloopSDK.start()

**7) Close widget**

To close the chat session and dismiss the chat window, call closeWidget on verloopSDK

Ex: verloopSDK.closeWidget()

**8)To close the existing chat**

To close existing running chat call close() method on verloopSDK.

Ex:verloopSDK.close()

**9)To logout**

//To logout the current user chat session call logout() method on verloopSDK. This clears the local preferences and kill chat session of the user.

Ex:verloopSDK.logout()

**10) Clear configuration**

//To wipe the any existing configurations on the chat view, call clearConfig() method on verloopSDK.

Ex: verloopSDK.clearConfig()
