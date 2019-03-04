import Foundation
import UIKit

/// The protocol that view classes need to conform to to enable animated GIF support.
public protocol GIFAnimatable: class {
  /// Responsible for managing the animation frames.
  var animator: Animator? { get set }

  /// Notifies the instance that it needs display.
  var layer: CALayer { get }

  /// View frame used for resizing the frames.
  var frame: CGRect { get set }

  /// Content mode used for resizing the frames.
  var contentMode: UIView.ContentMode { get set }
}


/// A single-property protocol that animatable classes can optionally conform to.
public protocol ImageContainer {
  /// Used for displaying the animation frames.
  var image: UIImage? { get set }
}

extension GIFAnimatable where Self: ImageContainer {
  /// Returns the intrinsic content size based on the size of the image.
  public var intrinsicContentSize: CGSize {
    return image?.size ?? CGSize.zero
  }
}

extension GIFAnimatable {
  /// Total duration of one animation loop
  public var gifLoopDuration: TimeInterval {
    return animator?.loopDuration ?? 0
  }

  /// Returns the active frame if available.
  public var activeFrame: UIImage? {
    return animator?.activeFrame()
  }

  /// Total frame count of the GIF.
  public var frameCount: Int {
    return animator?.frameCount ?? 0
  }

  /// Introspect whether the instance is animating.
  public var isAnimatingGIF: Bool {
    return animator?.isAnimating ?? false
  }

  /// Prepare for animation and start animating immediately.
  ///
  /// - parameter imageName: The file name of the GIF in the main bundle.
  /// - parameter loopCount: Desired number of loops, <= 0 for infinite loop.
  /// - parameter completionHandler: Completion callback function
  public func animate(withGIFNamed imageName: String, loopCount: Int = 0, completionHandler: (() -> Void)? = nil) {
    animator?.animate(withGIFNamed: imageName,
                      size: frame.size,
                      contentMode: contentMode,
                      loopCount: loopCount,
                      completionHandler: completionHandler)
  }

  /// Prepare for animation and start animating immediately.
  ///
  /// - parameter imageData: GIF image data.
  /// - parameter loopCount: Desired number of loops, <= 0 for infinite loop.
  /// - parameter completionHandler: Completion callback function
  public func animate(withGIFData imageData: Data, loopCount: Int = 0, completionHandler: (() -> Void)? = nil) {
    animator?.animate(withGIFData: imageData,
                      size: frame.size,
                      contentMode: contentMode,
                      loopCount: loopCount,
                      completionHandler: completionHandler)
  }

  /// Prepare for animation and start animating immediately.
  ///
  /// - parameter imageURL: GIF image url.
  /// - parameter loopCount: Desired number of loops, <= 0 for infinite loop.
  /// - parameter completionHandler: Completion callback function
  public func animate(withGIFURL imageURL: URL, loopCount: Int = 0, completionHandler: (() -> Void)? = nil) {
    let session = URLSession.shared

    let task = session.dataTask(with: imageURL) { (data, response, error) in
      switch (data, response, error) {
      case (.none, _, let error?):
        print("Error downloading gif:", error.localizedDescription, "at url:", imageURL.absoluteString)
      case (let data?, _, _):
        DispatchQueue.main.async {
          self.animate(withGIFData: data, loopCount: loopCount, completionHandler: completionHandler)
        }
      default: ()
      }
    }

    task.resume()
  }

  /// Prepares the animator instance for animation.
  ///
  /// - parameter imageName: The file name of the GIF in the main bundle.
  /// - parameter loopCount: Desired number of loops, <= 0 for infinite loop.
  public func prepareForAnimation(withGIFNamed imageName: String,
                                  loopCount: Int = 0,
                                  completionHandler: (() -> Void)? = nil) {
    animator?.prepareForAnimation(withGIFNamed: imageName,
                                  size: frame.size,
                                  contentMode: contentMode,
                                  loopCount: loopCount,
                                  completionHandler: completionHandler)
  }

  /// Prepare for animation and start animating immediately.
  ///
  /// - parameter imageData: GIF image data.
  /// - parameter loopCount: Desired number of loops, <= 0 for infinite loop.
  public func prepareForAnimation(withGIFData imageData: Data,
                                  loopCount: Int = 0,
                                  completionHandler: (() -> Void)? = nil) {
    if var imageContainer = self as? ImageContainer {
      imageContainer.image = UIImage(data: imageData)
    }

    animator?.prepareForAnimation(withGIFData: imageData,
                                  size: frame.size,
                                  contentMode: contentMode,
                                  loopCount: loopCount,
                                  completionHandler: completionHandler)
  }

  /// Prepare for animation and start animating immediately.
  ///
  /// - parameter imageURL: GIF image url.
  /// - parameter loopCount: Desired number of loops, <= 0 for infinite loop.
  public func prepareForAnimation(withGIFURL imageURL: URL,
                                  loopCount: Int = 0,
                                  completionHandler: (() -> Void)? = nil) {
    let session = URLSession.shared
    let task = session.dataTask(with: imageURL) { (data, response, error) in
      switch (data, response, error) {
      case (.none, _, let error?):
        print("Error downloading gif:", error.localizedDescription, "at url:", imageURL.absoluteString)
      case (let data?, _, _):
        DispatchQueue.main.async {
          self.prepareForAnimation(withGIFData: data,
                                   loopCount: loopCount,
                                   completionHandler: completionHandler)
        }
      default: ()
      }
    }

    task.resume()
  }

  /// Stop animating and free up GIF data from memory.
  public func prepareForReuse() {
    animator?.prepareForReuse()
  }

  /// Start animating GIF.
  public func startAnimatingGIF() {
    animator?.startAnimating()
  }

  /// Stop animating GIF.
  public func stopAnimatingGIF() {
    animator?.stopAnimating()
  }

  /// Whether the frame images should be resized or not. The default is `false`, which means that the frame images retain their original size.
  ///
  /// - parameter resize: Boolean value indicating whether individual frames should be resized.
  public func setShouldResizeFrames(_ resize: Bool) {
    animator?.shouldResizeFrames = resize
  }

  /// Sets the number of frames that should be buffered. Default is 50. A high number will result in more memory usage and less CPU load, and vice versa.
  ///
  /// - parameter frames: The number of frames to buffer.
  public func setFrameBufferCount(_ frames: Int) {
    animator?.frameBufferCount = frames
  }

  /// Updates the image with a new frame if necessary.
  public func updateImageIfNeeded() {
    if var imageContainer = self as? ImageContainer {
      let container = imageContainer
      imageContainer.image = activeFrame ?? container.image
    } else {
      layer.contents = activeFrame?.cgImage
    }
  }
}

extension GIFAnimatable {
  /// Calls setNeedsDisplay on the layer whenever the animator has a new frame. Should *not* be called directly.
  func animatorHasNewFrame() {
    layer.setNeedsDisplay()
  }
}


// FIXME: (?)Extra files/ code location
// (?)Ideally GIFControllable is moved into it's own file. I didn't do that here (yet) as I wasn't sure if that's appropriate for a PR and wanted to get feedback/ code review first.
// (?)The associated SyncFrameRates enum should probably live with GIFControllable.
// (?)The TimeInterval extension could go into it's own extension file or go somewhere else if its deemed ideal instead to create a Duration typealias and extend with the sync methods.

// MARK: - GIFControllable

// FIXME: (?)Protocol Requirements
// (?)I opted not to make property or protocol method requirements here in order to respect GIFAnimatable's style/useage of optional methods and computed properties, as well as trying to make my contributions minimally intrusive.
// (?)However it might be worth considering having required speed, synchronization, (and/or frameLimiter?) properties in the protocol?
protocol GIFControllable: GIFAnimatable {}

extension GIFControllable {
  /// Change playback speed of animation based upon a speed multiplier.
  ///
  /// - parameter speed: A speed multiplier where normal speed = 1.0.
  /// - parameter synchronization: Indicates whether frame should be synchronized to a frameRate, and to which frameRate. Default is syncToMaximumFPS.
  public func setAnimationSpeed(to speed: PlaybackSpeed, synchronization: SyncFrameRates = .syncToMaximumFPS) {
    self.animator?.changeAnimationSpeed(to: speed, synchronization: synchronization)
  }
  
  /// Change playback speed of animation based upon a new duration.
  ///
  /// - parameter duration: New target duration (gifLoopDuration) for the animation.
  /// - parameter synchronization: Indicates whether frame should be synchronized to a frameRate, and to which frameRate. Default is syncToMaximumFPS.
  public func setAnimationDuration(to duration: TimeInterval, synchronization: SyncFrameRates = .syncToMaximumFPS) {
    let currentDuration = self.gifLoopDuration
    let newSpeed = currentDuration / duration
    self.setAnimationSpeed(to: newSpeed, synchronization: synchronization)
  }
  
//  public func getAnimationSpeed() -> PlaybackSpeed {
//    return self.animator?.
//  }
  
  /// Set the synchronization parameter for the animator. Default is syncToMaximumFPS.
  ///
  /// - parameter synchronization: Indicates whether frame should be synchronized to a frameRate, and to which frameRate.
  public func setSynchronization(to synchronization: SyncFrameRates) {
    let maxFPS = SyncFrameRates.syncToMaximumFPS.intValue
    let sync: SyncFrameRates
    
    if synchronization.intValue > maxFPS {
      sync = .syncToMaximumFPS
    } else {
      sync = synchronization
    }
    
    self.animator?.synchronization = sync
  }
}

/// Typealias for playback speed of animation.
public typealias PlaybackSpeed = Double

/// An enum defining available frame rates for synchronization.
/// Using synchronization rates below maxFPS may slow down an animation. Historically most web browsers have rate limited GIF frame durations of 5ms or less (20fps), pushing any frame durations below 5ms or 6ms up to 10ms, effectively slowing the animation speed to 10fps. (For better or worse, Gifu natively mirrors this behavior as well.) Because of this the vast majority of gifs are created with frame rates less than 20fps.
/// http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser
/// Thus the use of synchronization below this threshold then becomes a rate limiter that may be useful for synchronizing multiple gifs to the same frame rate and/or improving performance(?)
public enum SyncFrameRates: Int {
  /// Basic synchronization frame rates
  case syncToMaximumFPS = -1
  case notSynchronized = 0
  case syncToSixtyFPS = 60
  case syncToOneTwentyFPS = 120
  
  /// Rate limiting frame rates.
  // FIXME: (?)FrameLimiter implementation possibilities
  // (?)Although personally useful, perhaps these extra rate limiting frame rate options may be too beyond the scope of most developers to include in Gifu?
  // (?)Alternatively these could even be pushed to their own LimiterFrameRates(?) enum and I could create a separate setFrameLimiter() method to clarify usage.
  // (?)Under the hood it would still operate the same by setting the animator's synchronization value; the setFrameLimiter() method would simply override a value set by the setSynchronization() method .
  /// 60FPS sub-frame rates (factors of 60).
  case syncToOneFPS = 1
  case syncToTwoFPS = 2
  case synceToThreeFPS = 3
  case syncToFourFPS = 4
  case syncToFiveFPS = 5
  case syncToSixFPS = 6
  case syncToTenFPS = 10
  case syncToTwelveFPS = 12
  case syncToFifteenFPS = 15
  case syncToTwentyFPS = 20
  case syncToThirtyFPS = 30
  
  /// 120FPS additional sub-frame rates (factors of 120).
  case syncToEightFPS = 8
  case syncToTwentyFourFPS = 24
  case syncToFortyFPS = 40
  
  /// Maximum refresh rate of the device screen.
  var maxFPS: Int {
    let maxFPS: Int
    if #available(iOS 10.3, *) {
      maxFPS = UIScreen.main.maximumFramesPerSecond
    } else {
      maxFPS = 60
    }
    
    return maxFPS
  }
  
  public var intValue: Int {
    switch self {
    case .syncToMaximumFPS:
      return self.maxFPS
      
    case .syncToEightFPS:
      if maxFPS == 120 {
        return self.rawValue
      } else {
        return 10
      }
    case .syncToTwentyFourFPS:
      if maxFPS == 120 {
        return self.rawValue
      } else {
        return 30
      }
    case .syncToFortyFPS:
      if maxFPS == 120 {
        return self.rawValue
      } else {
        return 60
      }
      
    default:
      return self.rawValue
    }
  }
}

/// Extension on TimeInterval to synchronize durations
// FIXME: (?)Extra files/ code location and possible creation of Duration typealias
// (?)Another possibility would be to create a 'typealias: Duration = TimeInterval' and extend Duration instead?
// (?)The usage of a Duration type for durations would need to cascade throughout the Gifu classes.
// (?)But perhaps this could be useful in the longrun as it would provide type-safe delineation between PlaybackSpeeds, Durations, and the more generic uses of TimeInterval (all Double typealiases)?
extension TimeInterval {
  
  /// Returns a synchronized copy of the TimeInterval.
  ///
  /// - parameter synchronization: Indicates whether frame should be synchronized to a frameRate, and to which frameRate. Default is syncToMaximumFPS.
  /// - returns: A TimeInterval.
  func synchronized(to synchronization: SyncFrameRates = .syncToMaximumFPS) -> TimeInterval {
    return self._synchronize(self, to: synchronization)
  }
  
  /// Returns a synchronized copy of a frame duration / TimeInterval.
  ///
  /// - parameter duration: Duration of a frame represented by a TimeInterval.
  /// - parameter synchronization: Indicates whether frame should be synchronized to a frameRate, and to which frameRate. Default is syncToMaximumFPS.
  /// - returns: A TimeInterval.
  // FIXME: (?)Potential timing conflicts between my synchronization implementation and Gifu's native timing optimizations
  // (?)How will assigning these sync durations to timeSinceLastFrameChange in FrameSotre will behave as thresholds?
  // (?)Perhaps I need to subtract ulpOfOne at the end of the calculation to ensure the timeSinceLastFrameChange time elapses far enough before the shouldChangeFrame() method is called?
  // (?)I don't know what the accuracy of Date() and it's .timeIntervalSince(_ date: Date) calculation is compared to a duration set by a Double...
  // (?)Thus there's a chance of time rounding errors that will cause unexpected frameDrops/delays if
  // (?)Additionally, I haven't fully wrapped my head around Gifu's timing implementation, especially the resetTimeSinceLastFrameChange() method and how it will affect my synchronization implementation?
  // (?)It seems that resetTimeSinceLastFrameChange() makes up the timing difference between CADisplayLink refreshes (called at 60fps) and GIF frame durations (set in ms)???
  // (?)It seems like Gifu's timing implementation (if I understand resetTimeSinceLastFrameChange() correctly) aims to respect the native timing of a GIF above all else, with frames refreshing
  // (?)While I respect this as it mirrors historical browser performance, the GIF format's native timing resolution is incompatable with screen refresh rates and so frame drift always occurs (and can be annoying) in a GIF despite most people's intention to make perfectly behaving animations.
  // (?)As a longtime GIF creator myself and in speaking with many other creators as well,the GIF format's limitation of ms resolution delay timing has always been frustrating as one can only create GIFs that will reliably synchronize to a (30hz/60hz/120hz)display (in all browsers) at 10fps, 5fps, 4fps, 2fps, and 1fps... all of which are painfully slow framerates that keep the GIF format looking dated IMHO.
  // (?)The intention with my synchronization implementation is to fix the timing of GIFs to match the timing that was likely INTENDED by the person who made it.
  // (?)For example, in the past I have made all of my gifs with a frame interval duration set to 7ms to get as close to 15fps (6.666...ms duration) performance but I've always known that framedrift will occur.
  // (?)After having dug in to Gifu's implementation I now understand that I probably should have set my frame durations to 6ms instead and in browsers my GIFs would have likely magically shifted to perfect 15fps, as was intended.
  // (?)I suppose my 7ms GIFs must all playback at 12fps on most browsers on 60hz screens and drift between 12-15fps in Gifu?
  // (?)
  private func _synchronize(_ duration: TimeInterval, to synchronization: SyncFrameRates = .syncToMaximumFPS) -> TimeInterval {
    guard duration > 0, synchronization != .notSynchronized else { return duration }
    
    let fpsValue = TimeInterval(synchronization.rawValue)
    let syncedDuration: TimeInterval

    
    let frameRateMultipliedDuration = duration * fpsValue
    let closestWholeDividend = frameRateMultipliedDuration.rounded(.toNearestOrAwayFromZero)
    if closestWholeDividend == 0 {
      syncedDuration = 1 / fpsValue
    } else {
      syncedDuration = closestWholeDividend / fpsValue
    }
    
    // potential implementation change
//    let ulpedDuration = syncedDuration - Double.ulpOfOne
//    return ulpedDuration
    
    return syncedDuration
  }
}
