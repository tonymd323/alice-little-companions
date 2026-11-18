import AVFAudio
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var verandaFoley: VerandaFoley?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let soundRegistry = engineBridge.pluginRegistry.registrar(forPlugin: "VerandaFoley") {
      let sound = VerandaFoley(registrar: soundRegistry)
      verandaFoley = sound
      let channel = FlutterMethodChannel(
        name: "alice/wind-sound", binaryMessenger: soundRegistry.messenger())
      channel.setMethodCallHandler { [weak sound] call, result in
        guard let sound else { result(nil); return }
        do {
          switch call.method {
          case "prepare": try sound.prepare()
          case "play": try sound.play(call.arguments as? String)
          case "stop": sound.stop()
          case "setMuted": sound.setMuted(call.arguments as? Bool ?? false)
          case "isMuted": result(sound.muted); return
          default: result(FlutterMethodNotImplemented); return
          }
          result(nil)
        } catch {
          result(FlutterError(code: "foley_asset", message: error.localizedDescription, details: nil))
        }
      }
    }
    guard let registry = engineBridge.pluginRegistry.registrar(forPlugin: "AliceStorage") else {
      return
    }
    let storage = FlutterMethodChannel(name: "alice/storage", binaryMessenger: registry.messenger())
    storage.setMethodCallHandler { call, result in
      guard call.method == "excludeFromBackup" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let path = call.arguments as? String else {
        result(FlutterError(code: "storage", message: "Invalid storage location", details: nil))
        return
      }
      do {
        var directory = URL(fileURLWithPath: path, isDirectory: true)
        var settings = URLResourceValues()
        settings.isExcludedFromBackup = true
        try directory.setResourceValues(settings)
        result(nil)
      } catch {
        result(FlutterError(code: "storage", message: "Could not protect app storage", details: nil))
      }
    }

  }
}

private final class VerandaFoley {
  private let registrar: FlutterPluginRegistrar
  private let cues = ["wind", "scarf", "basket", "takeLeaf", "seatLeaf", "windowLight", "footsteps"]
  private let muteKey = "alice.veranda.audioMuted"
  private var players = [String: AVAudioPlayer]()
  private var observations = [NSObjectProtocol]()
  private var interrupted = false

  var muted: Bool { UserDefaults.standard.bool(forKey: muteKey) }

  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
    let center = NotificationCenter.default
    for event in [UIApplication.willResignActiveNotification, UIScene.willDeactivateNotification] {
      observations.append(center.addObserver(forName: event, object: nil, queue: .main) { [weak self] _ in
        self?.stop()
      })
    }
    observations.append(center.addObserver(
      forName: AVAudioSession.interruptionNotification,
      object: AVAudioSession.sharedInstance(), queue: .main
    ) { [weak self] note in
      guard let raw = (note.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let type = AVAudioSession.InterruptionType(rawValue: raw)
      else { return }
      self?.interrupted = type == .began
      if type == .began { self?.stop() }
    })
  }

  deinit {
    for token in observations { NotificationCenter.default.removeObserver(token) }
    stop()
  }

  private func load(_ cue: String) throws -> AVAudioPlayer {
    if let player = players[cue] { return player }
    let key = registrar.lookupKey(forAsset: "assets/wind/audio/\(cue).wav")
    guard let url = Bundle.main.url(forResource: key, withExtension: nil) else {
      throw CocoaError(.fileNoSuchFile)
    }
    let player = try AVAudioPlayer(contentsOf: url)
    players[cue] = player
    return player
  }

  private func mixWithOtherAudio() throws {
    let session = AVAudioSession.sharedInstance()
    // Ambient mixes with other apps and honours the iPhone silent switch.
    if session.category != .ambient {
      try session.setCategory(.ambient, mode: .default)
    }
  }

  func prepare() throws {
    guard !muted && !interrupted else { return }
    try mixWithOtherAudio()
    for cue in cues { _ = try load(cue).prepareToPlay() }
  }

  func play(_ name: String?) throws {
    guard !muted, !interrupted, UIApplication.shared.applicationState == .active,
          let cue = name, cues.contains(cue) else { return }
    try mixWithOtherAudio()
    let player = try load(cue)
    player.currentTime = 0
    player.play()
  }

  func setMuted(_ value: Bool) {
    if value { stop() }
    UserDefaults.standard.set(value, forKey: muteKey)
  }

  func stop() {
    for player in players.values {
      player.stop()
      player.currentTime = 0
    }
  }
}
