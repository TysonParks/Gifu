import UIKit
/// Represents a single frame in a GIF.
struct AnimatedFrame {

  /// The image to display for this frame. Its value is nil when the frame is removed from the buffer.
  let image: UIImage?
  
  /// The duration that this frame should remain active.
  let duration: TimeInterval

  /// A placeholder frame with no image assigned.
  /// Used to replace frames that are no longer needed in the animation.
  var placeholderFrame: AnimatedFrame {
    return AnimatedFrame(image: nil, duration: duration)
  }

  /// Whether this frame instance contains an image or not.
  var isPlaceholder: Bool {
    return image == nil
  }

  /// Returns a new instance from an optional image.
  ///
  /// - parameter image: An optional `UIImage` instance to be assigned to the new frame.
  /// - returns: An `AnimatedFrame` instance.
  func makeAnimatedFrame(with newImage: UIImage?) -> AnimatedFrame {
    return AnimatedFrame(image: newImage, duration: duration)
  }
}

/// Tyson addition
extension AnimatedFrame {

  /// Returns a new instance with the duration changed by a speed factor and synchronization
  ///
  /// - parameter speed: A speed multiplier where normal speed = 1.0.
  /// - parameter synchronization: Indicates whether frame should be synchronized to a frameRate, and to which frameRate.
  /// - returns: An `AnimatedFrame` instance.
  func newAnimatedFrameWith(speed: PlaybackSpeed, synchronization: SyncFrameRates = .SyncToSixtyFPS) -> AnimatedFrame {
    let syncedDuration = self.duration.synchronized(to: synchronization)
    let spedDuration = syncedDuration / speed
    let syncedSpedDuration = spedDuration.synchronized(to: synchronization)
    return AnimatedFrame(image: self.image, duration: syncedSpedDuration)
  }
  
}
