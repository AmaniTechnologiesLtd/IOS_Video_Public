//
//  ViewController.swift
//  VideoSample
//
//  Created by Deniz Can on 8.06.2023.
//

import UIKit
import AmaniVideoSDK

class ViewController: UIViewController {
  private var amaniVideo: AmaniVideo?
  private var videoView: UIView!
  
  @IBAction func onStartPress(_ sender: Any) {
      // Do any additional setup after loading the view.
      do {
        amaniVideo = try AmaniVideoBuilder()
          .setServerURL(url: URL(string: SERVER_URL)!)
          .setName(name: "name", surname: "surname")
          .setToken(token: TOKEN)
          .setRemoteViewMode(viewMode: .portrait)
          .setRTCConfig(
            stunServerURL: STUN_URL,
            turnServerURL: TURN_URL,
            turnUsername: TURN_USERNAME, turnPassword: TURN_PASSWORD)
          .setButtonColors(colors: [
            .endCallButtonBackground: .red,
            .endCallButton: .white
          ])
          //        .setButtonIcons(icons: [
          ////          .endCall: UIImage(systemName: "phone.down")!,
          //        ])
          .setBackgroundViewColor(color: .darkGray)
          .setDelegate(delegate: self)
          .build()
      
    } catch {
      
      print(error.localizedDescription)
    }
    videoView = amaniVideo?.start(on: self.view)
  }
  override func viewDidLoad() {
    super.viewDidLoad()

  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    DispatchQueue.main.async {
      self.videoView?.removeFromSuperview()
      self.videoView = nil
    }
    amaniVideo?.closeSDK()
    amaniVideo = nil
    
  }
  
}

extension ViewController: AmaniVideoDelegate {
  func onConnectionState(newState: AmaniVideoSDK.AmaniVideo.ConnectionState) {
    print("onConnectionState :",newState)
    switch newState {
      case .connecting:
        break
      case .connected:
        break
      case .disconnected:
        break
      case .failed:
        DispatchQueue.main.async {
          self.videoView?.removeFromSuperview()
          self.amaniVideo?.closeSDK()
          self.amaniVideo = nil
        }
    }
  }
  
  func onException(error: [String]) {
    print("onException :",error)
    DispatchQueue.main.async {
      self.videoView?.removeFromSuperview()
    }
  }
  
  func didChange(torchState: Bool) {
    print("torch is on \(torchState)")
  }
  
  func didChange(cameraPosition: AmaniVideo.CameraPosition) {
    print("camera pos change")
    let alert = UIAlertController(title: "Switch Camera?", message: "Agent wanted to switch camera", preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
      self.amaniVideo!.switchCamera()
    }))
    alert.addAction(UIAlertAction(title: "no", style: .default, handler: nil))
    self.present(alert, animated: true)
  }
  
  func connectionStateDidChange(newState: AmaniVideo.ConnectionState) {
    if newState == .disconnected {
      DispatchQueue.main.async {
        self.videoView.removeFromSuperview()
      }
    }
    
  }
  
  func onError(error: String) {
    print(error)
    DispatchQueue.main.async {
      self.videoView.removeFromSuperview()
    }
  }
  
  func onUIEvent(event: AmaniVideo.UIEvent) {
    print("UIEvent :", event)
    
    switch event {
    case .cameraSwitch:
      break
    case .cameraClose:
      break
    case .callEnd:
      let alert = UIAlertController(title: "End Call?", message: "Are you sure to end call?", preferredStyle: .actionSheet)
      alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
        self?.endCall()
      }))
      alert.addAction(UIAlertAction(title: "no", style: .default, handler: nil))
      self.present(alert, animated: true)
      
      break
    case .mute:
      break
    case .torch:
      break
    }
  }
  func endCall() {
    DispatchQueue.main.async {
      self.videoView?.removeFromSuperview()
      self.videoView = nil
    }
    self.amaniVideo?.closeSDK()
    self.amaniVideo = nil
  }
  func onRemoteEvent(event: AmaniVideo.RemoteEvent) {
    print("RemoteEvent :",event)
    switch event {
    case .cameraSwitch:
      let alert = UIAlertController(title: "Switch Camera?", message: "Agent wanted to switch camera", preferredStyle: .actionSheet)
      alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
        self?.amaniVideo?.switchCamera()
      }))
      alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
      self.present(alert, animated: true)
      break
    case .callEnd:
      DispatchQueue.main.async {
        self.videoView?.removeFromSuperview()
      }
      break
    case .escalated:
      DispatchQueue.main.async {
        self.videoView?.removeFromSuperview()
          //add escalated parameter to pass socket "join room" event
          //            socket.value.emit('join room', {
          //                    roomID: roomID.value,
          //                    userID: customer.id,
          //                    userType: 'customer',
          //                    name: customer.name,
          //                    status: startEscalatedCall.value ? 'Escalated' : 'Waiting',
          //            });
          // reinit amani video
        self.videoView = self.amaniVideo?.start(on: self.view,status:.escalated )
      }
      
    case .torch:
      let alert = UIAlertController(title: "Toggle torch?", message: "Agent wanted to toggle torch", preferredStyle: .actionSheet)
      alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {[weak self] _ in
        self?.amaniVideo?.toggleTorch()
      }))
      alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
      self.present(alert, animated: true)

    }
  }
}
