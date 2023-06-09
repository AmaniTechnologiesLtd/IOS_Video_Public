//
//  ViewController.swift
//  VideoSample
//
//  Created by Deniz Can on 8.06.2023.
//

import UIKit
import AmaniVideoSDK

class ViewController: UIViewController {
  private var amaniVideo: AmaniVideo!
  private var videoView: UIView!
  
  @IBAction func onStartPress(_ sender: Any) {
    videoView = amaniVideo.start(on: self.view)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    do {
      amaniVideo = try AmaniVideoBuilder()
        .setServerURL(url: URL(string: SERVER_URL)!)
        .setName(name: NAME, surname: SURNAME)
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
        .setBackgroundViewColor(color: .darkGray)
        .setRemoteViewMode(viewMode: .landscape)
        .setDelegate(delegate: self)
        .build()
      
    } catch {
      fatalError(error.localizedDescription)
    }
  }


}

extension ViewController: AmaniVideoDelegate {
  func didChange(torchState: Bool) {
    print("torch is on \(torchState)")
  }
  
  func didChange(cameraPosition: AmaniVideo.CameraPosition) {
    print("camera pos change")
    let alert = UIAlertController(title: "Switch Camera?", message: "Agent wanted to switch camera", preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
      AmaniVideo.sharedInstance.switchCamera()
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
    print(event)
  }
  
  func onRemoteEvent(event: AmaniVideo.RemoteEvent) {
    print(event)
  }
  
}
