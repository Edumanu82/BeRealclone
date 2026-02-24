//
//  ImageMetadata.swift
//  lab-insta-parse
//
//  Created by Eduardo M. Sanchez-Pereyra on 2/23/26.
//

import Foundation
import ImageIO

struct ImageMetadata {
    let pixelWidth: Int?
    let pixelHeight: Int?
    let make: String?
    let model: String?
    let dateTimeOriginal: String?
}

func extractMetadata(from imageData: Data) -> ImageMetadata {
    guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
          let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else {
        return ImageMetadata(pixelWidth: nil, pixelHeight: nil, make: nil, model: nil, dateTimeOriginal: nil)
    }

    let width = props[kCGImagePropertyPixelWidth] as? Int
    let height = props[kCGImagePropertyPixelHeight] as? Int

    let tiff = props[kCGImagePropertyTIFFDictionary] as? [CFString: Any]
    let make = tiff?[kCGImagePropertyTIFFMake] as? String
    let model = tiff?[kCGImagePropertyTIFFModel] as? String

    let exif = props[kCGImagePropertyExifDictionary] as? [CFString: Any]
    let dateTimeOriginal = exif?[kCGImagePropertyExifDateTimeOriginal] as? String

    return ImageMetadata(
        pixelWidth: width,
        pixelHeight: height,
        make: make,
        model: model,
        dateTimeOriginal: dateTimeOriginal
    )
}
