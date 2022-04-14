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
config.setUserId(&quot;12345&quot;)
```



**Recepie ID:**

// recipeId : id of the recipe to be added to configuration object.

//Void method

setRecipeId(recipeId id: String?)

Ex:config.setRecipeId(&quot;RecepieID&quot;)

**Department**

//dept : department name to be added to configuration object.

//Void method

setDepartment( **\_** dept:String)

Ex: config.setDepartment(&quot;DepartmentName&quot;)

**ClearDepartment**

//No inputs needed.

//Void method

clearDepartment()

Ex:config.clearDepartment()

**Notification Token:**

//notificationToken: Token for the push notifications

setNotificationToken(notificationToken: token)

Ex **:** config.setNotificationToken(notificationToken: token)

**User-Name**

//name: Name of the user to be added to configuration object

//Void method

setUserName(username name:String)

Ex: config.setUserName(&quot;User&#39;s Name&quot;)

**User-Email**

//email: Email address of the user to be added to configuration object

//Void method

setUserEmail(userEmail email:String)

Ex: config.setUserEmail(&quot;hello@verloop.io&quot;)

**User-Phone number**

//phone: Phone number of the user to be added to configuration object

//Void method

setUserPhone(userPhone phone:String)

Ex:config.setUserPhone(&quot;+919xxxxxxxx&quot;)

**UserParameters:**

//setUserParam is a another handy method exposed to set any 3 the above values such as : name, email,phone

//key: name of the parameter [&quot;name&quot;,&quot;email&quot;,&quot;phone&quot;]

//value: value of the respective key

//Void method

setUserParam(key:String, value:String)

config.setUserParam(key: &quot;name&quot;, value: &quot;Jack&quot;)

config.setUserParam(key: &quot;email&quot;, value: &quot;jack.albert@gmail.com&quot;)

config.setUserParam(key: &quot;phone&quot;, value: &quot;+91434432&quot;)

**Button Click Listener:**

//Confirm to below method to receive call back while a button click happens on the live script

//onButtonClicked : closure available on the VLConfig

setButtonOnClickListener(onButtonClicked buttonClicked: LiveChatButtonClickListener?)

**URL Click Listener:**

//Confirm to below method to receive call back while a URL click happens on the live script

//onUrlClicked : closure available on the VLConfig

setUrlClickListener(onUrlClicked urlClicked: LiveChatUrlClickListener?)

**CustomField:**

//putCustomField is used to set any custom key values on the config object.

//key: name of the key

//value: value of the respective key

//scope: [&quot;User&quot;,&quot;Room&quot;]. Pass either of the scope to be added on configuration.

putCustomField(key: String, value: String, scope: SCOPE)

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
