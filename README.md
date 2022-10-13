
# ebchat-mobile-flutter-sdk

![Pub](https://img.shields.io/badge/pub-v0.0.1-informational)

Flutter chat screen for EBChat Andorid and IOS projects.

- Uses Intercom Android SDK Version `12.5.1`.
- The minimum Android SDK `minSdkVersion` required is 21.
- Uses Intercom iOS SDK Version `13.0.0`.
- The minimum iOS target version required is 13.

## Usage

Import `package:ebchat/ebchat.dart` and use the methods in `EBChatService` class.

Example:
```dart
import  'package:ebchat/ebchat.dart';
import  'package:ebutler/models/user_model.dart';
import  'package:flutter/material.dart';

class  EbChatScreen  extends  StatefulWidget {
const  EbChatScreen({Key? key}) : super(key: key);
@override
State<EbChatScreen> createState() => _EbChatScreenState();
}

class  _EbChatScreenState  extends  State<EbChatScreen> {
StreamChatClient? client;
User? currentUser;
String  ebchatKey ="EBCHAT_KEY";
String azureMapsApiKey="azureMapsApiKey";
@override
void  initState() {
currentUser = User(
id: "UniqueUserId",
name: "userName",
extraData: {
"phone": "3249241317",
//TODO: THIS FIELD IS REQUIRED
"email": "exemple@email.com"});
super.initState();}

@override
Widget  build(BuildContext  context) {
return  Scaffold(
resizeToAvoidBottomInset: true,
appBar: AppBar(backgroundColor: const  Color(0xff214496)),
body: FutureBuilder<String>(
future: EBChatService.getCompanyStreamAcess(
ebchatKey),
builder: (context, snapshot) {
switch (snapshot.connectionState) {
case  ConnectionState.waiting:
return  const  Text('Loading....');
default:
if (snapshot.hasError) {
return  Text('Error: ${snapshot.error}');
} else {
client = StreamChatClient(snapshot.data!);
return  EBChatScreen(
key: Key("UniqueUserId"),
ebchatToken: ebchatKey,
client: client,
currentUser: currentUser!,
azureMapsApiKey:azureMapsApiKey);
					}
				}
			}),
		);
	}
}
```


