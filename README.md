# Amani Video SDK IOS

This README file guides you for implementing our iOS Native Video SDK.

## Requirements

- iOS 13.0 or later

## Installation

### Via cocoapods
Add these source lines on top of your Podfile

```rb
source "https://github.com/AmaniTechnologiesLtd/Mobile_SDK_Repo"
source "https://github.com/CocoaPods/Specs"
```

Add this line on your target:

```rb
pod "AmaniVideoSDK"
```

## SDK Usage

### Use the AmaniVideoBuilder class

You can use the AmaniVideoBuilder class to setup the sdk.

```swift
// on your view controller. preferably viewDidLoad method.
amaniVideo = try AmaniVideoBuilder()
        .setServerURL(url: URL(string: "https://videocall.example")!)
        .setName(name: "John", surname: "Doe")
        .setToken(token: "customer token")
        .setRemoteViewMode(viewMode: .portrait)
        .setRTCConfig(
          stunServerURL: "stun:example.stun.server:3478",
          turnServerURL: "turn:example.turn.server:3478",
          turnUsername: "turn_user", turnPassword: "turn_password")
        .setButtonColors(colors: [
          .endCallButtonBackground: .white,
          .endCallButton: .black
        ])
        .setButtonIcons(icons: [
          .endCall: UIImage(systemName: "phone.down")!,
        ])
        .setBackgroundViewColor(color: .darkGray)
        .setDelegate(delegate: self)
        .build()
```

Let's break it down a litte because some of them are required functions to call.

### Required methods on the AmaniBuilder

#### Set the server url (required)

Call the `setServerURL` with a valid URL object. The url string is supplied by Amani to customers.

```swift
  guard let url = URL(string: "https://videocall.server.example") else {
    print("wrong or malformed url string")
    return
  }
  // Returns the AmaniVideoBuilder instance
  let amaniVideoBuilder = AmaniVideoBuilder().setServerURL(url: url)
  // rest is continued in other blocks
```

#### Set the name and surname of the customer (required)

Setting the name and surname of the is required because it's gonna be the name of the user shows up on the studio.

```swift
amaniVideoBuilder.setName(name: "John", surname: "Doe")
```

#### Set the token (required)

On your back-end, you must fetch a customer token from Amani API and send it to your application and give the customer token to the SDK
via the `setToken(token: "customer_token from amani api")`.

```swift
amaniVideoBuilder.setToken(token: "customer_token")
```

#### Set the RTC configuration (required)

Parameters used in here is supplied by Amani to it's customers.

```swift
amaniVideoBuilder.setRTCConfig(
          stunServerURL: "stun:example.stun.server:3478",
          turnServerURL: "turn:example.turn.server:3478",
          turnUsername: "turn_user", turnPassword: "turn_password")
```

#### Set the Delegate (required)

The delegate has methods for stuff like UI Events (such as user pressing the button)
and connection states and a place for handling errors can be occured in runtime such as connection errors.

```swift
extension VideoViewController: AmaniVideoDelegate {

  // NOTE: This function is only called when the camera
  // position that is currently used is on the back camera.
  func didChange(torchState: Bool) {
    print("torch is on \(torchState)")
  }
  
  func didChange(cameraPosition: AmaniVideo.CameraPosition) {
    // Show an alert when the agent wants to switch the camera
    let alert = UIAlertController(title: "Switch Camera?", message: "Agent wanted to switch camera", preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
      // This method is for switching the camera. More on the documentation.
      AmaniVideo.sharedInstance.switchCamera()
    }))
    alert.addAction(UIAlertAction(title: "no", style: .default, handler: nil))
    self.present(alert, animated: true)
  }
  
  func connectionStateDidChange(newState: AmaniVideo.ConnectionState) {
    // You can actually show another view on top of the video view for informing
    // the customer about the call is disconnected. But for the sake of simplycity
    // of documentation we just keep it short as it removes the videoView.
    if newState == .disconnected {
      DispatchQueue.main.async {
        self.videoView.removeFromSuperview()
      }
    }
    // If you want to show a loader while the call is connecting, you can
    // take a look at the AmaniVideo.ConnectionState enum for the other states.
  }
  
  func onError(error: String) {
    // You can handle the errors in here.
    // Since this delegate method is called on the critical issues affecting the call
    // You can remove the view directly.
    DispatchQueue.main.async {
      self.videoView.removeFromSuperview()
    }
  }
  
  func onUIEvent(event: AmaniVideo.UIEvent) 
    // Whenever a button is pressed this delegate methods triggers
    // You can keep a record of the button presses if you want.
    print(event)
  
  func onRemoteEvent(event: AmaniVideo.RemoteEvent) {
    // This function is called when the agent presses
    // sends an event.
    print(event)
  }
}
```

To add the delegate call the `setDelegate`

```swift
amaniVideoBuilder.setDelegate(delegate: self)
```

#### Get AmaniVideo class from the AmaniVideoBuilder

Now you've completed the setup with required parameters. From the point you can either customize stuff like
setting the button colors, change the icons and change the remote video view to show up in either
landscape or in portrait mode.

If you don't want to customize you can get the AmaniVideo by calling the method below.

**Note** Build() method should always be called last as it returns an instance of `AmaniVideo` class unlike the other methods
returns an `AmaniVideoBuilder` instance.

```swift
do {
  self.amaniVideo = amaniVideoBuilder.Build()
} catch {
  print(error.localizedDescription)
}
```

#### Start a call with agent

To start the call just call `AmaniVideo.start(on: UIView)` method. This call will return a referance to the AmaniVideoView that shows
the call.

```swift
  // on your button press action
  self.videoView = self.amaniVideo.start(on: self.view)
```

### Optional customizations

After you've successfully supplied the neccesary information for the SDK, you can customize some aspetcs of the SDK.

**Note** Build() method should always be called last as it returns an instance of `AmaniVideo` class unlike the other methods
returns an `AmaniVideoBuilder` instance.

#### Customizing the button icons

You can give a dictionary of `[AmaniVideo.ButtonIcons: UIImage]` to `setButtonIcons` change the icons on the SDK. These steps are optional as we have icons in the SDK.

```swift
  amaniVideoBuilder.setButtonIcons([
    .switchCamera: UIImage(named: "switch_camera_icon")!,
    .endCall: UIImage(named: "end_call_icon")!,
    .microphone: UIImage(named: "microhpone")!,
    .microphoneOff: UIImage(named: "microphone_off")!,
    .camera: UIImage(named: "camera")!,
    .cameraOff: UIImage(named: "camera_off")!
  ])
```

#### Customizing the button and icon colors

You can give a dictionary of `[AmaniVideo.ButtonColors: UIColor]` to `setButtonColors` function to change the button and icon colors.

```swift
  amaniVideoBuilder.setbuttonColors([
    .switchCameraButton: .white,
    .switchCameraButtonBackground: .black,
    .closeCameraButton: .white,
    .closeCameraButtonBackground: .black,
    .muteButton: .white,
    .muteButtonBackground: .black,
    .endCallButton: .white,
    .endCallButtonBackground: .red,
  ])
```

#### Setting the portrait or landscape mode for remote video

To make the remote view show up in landscape mode you must set a view mode with `setRemoteViewMode`.

```swift
amaniVideoBuilder.setRemoteViewMode(viewMode: .landscape) // or .portrait for defaut
```

#### Setting the background view color

The set background color determines the color behind the local video preview as well as the background color when the remote view is in landscape mode. To set this color you can use `setBackgroundViewColor` method.

```swift
amaniVideoBuilder.setBackgroundViewColor(color: .black) // color is UIColor
```

Please don't forget calling `AmaniVideoBuilder.Build()` after the customization.

