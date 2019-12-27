
import UIKit
import Vision

extension VNImageRequestHandler {
    convenience init?(uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage else { return nil }
        let orientation = uiImage.cgImageOrientation
        
        self.init(cgImage: cgImage, orientation: orientation)
    }
}

extension VNRequest {
    func queueFor(image: UIImage, completion: @escaping ([Any]?) -> ()) {
        DispatchQueue.global().async {
            if let handler = VNImageRequestHandler(uiImage: image) {
                try? handler.perform([self])
                completion(self.results)
            } else {
                return completion(nil)
            }
        }
    }
}

extension UIImage {
    func detectRectangles(completion: @escaping ([VNRectangleObservation]) -> ()) {
        let request = VNDetectRectanglesRequest()
        
        request.minimumConfidence = 0.8
        request.minimumAspectRatio = 0.3
        request.maximumObservations = 3
        
        request.queueFor(image: self) { result in
            completion(result as? [VNRectangleObservation] ?? [])
        }
    }
    
    func detectBarcodes(types symbologies: [VNBarcodeSymbology] = [.QR], completion: @escaping ([VNBarcodeObservation]) -> ()) {
        
        let request = VNDetectBarcodesRequest()
        request.symbologies = symbologies
        
        request.queueFor(image: self) { result in
            completion(result as? [VNBarcodeObservation] ?? [])
        }
        
    }
}

let barcodeTestImage = UIImage(named: "test.jpg")!
barcodeTestImage.detectBarcodes { barcodes in
    for barcode in barcodes {
        print("Barcode data: \(barcode.payloadStringValue ?? "None")")
    }
}
