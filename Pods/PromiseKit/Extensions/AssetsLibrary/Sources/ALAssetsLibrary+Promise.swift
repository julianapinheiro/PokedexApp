import UIKit.UIViewController
import Foundation.NSData
import AssetsLibrary
#if !PMKCocoaPods
import PromiseKit
#endif

/**
 To import this `UIViewController` extension:

    use_frameworks!
    pod "PromiseKit/AssetsLibrary"

 And then in your sources:

    import PromiseKit
*/
extension UIViewController {
    /**
      - Returns: A promise that presents the provided UIImagePickerController and fulfills with the user selected media’s `NSData`.
     */
    public func promise(_ vc: UIImagePickerController, animated: Bool = false, completion: (() -> Void)? = nil) -> Promise<NSData> {
        let proxy = UIImagePickerControllerProxy()
        vc.delegate = proxy

        present(vc, animated: animated, completion: completion)

        return proxy.promise.then(on: nil) { info -> Promise<NSData> in
            let url = info[UIImagePickerControllerReferenceURL] as! URL
            
            return Promise { seal in
                ALAssetsLibrary().asset(for: url, resultBlock: { asset in
                    let N = Int(asset!.defaultRepresentation().size())
                    let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: N)
                    var error: NSError?
                    asset!.defaultRepresentation().getBytes(bytes, fromOffset: 0, length: N, error: &error)

                    if let error = error {
                        seal.reject(error)
                    } else {
                        seal.fulfill(NSData(bytesNoCopy: bytes, length: N))
                    }
                }, failureBlock: { seal.reject($0!) } )
            }
        }.ensure {
            self.dismiss(animated: animated, completion: nil)
        }
    }
}

@objc private class UIImagePickerControllerProxy: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let (promise, seal) = Promise<[String: Any]>.pending()
    var retainCycle: AnyObject?

    required override init() {
        super.init()
        retainCycle = self
    }

    fileprivate func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        seal.fulfill(info)
        retainCycle = nil
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        seal.reject(UIImagePickerController.PMKError.cancelled)
        retainCycle = nil
    }
}


extension UIImagePickerController {
    /// Errors representing PromiseKit UIImagePickerController failures
    public enum PMKError: CancellableError {
        /// The user cancelled the UIImagePickerController.
        case cancelled
        /// - Returns: true
        public var isCancelled: Bool {
            switch self {
            case .cancelled:
                return true
            }
        }
    }
}
