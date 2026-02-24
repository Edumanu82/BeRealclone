//
//  PostCell.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 11/3/22.
//

import UIKit
import Alamofire
import AlamofireImage
import CoreLocation

class PostCell: UITableViewCell {

    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    // Blur view to blur out "hidden" posts
    @IBOutlet private weak var blurView: UIVisualEffectView!

    @IBOutlet weak var locationLabel: UILabel!

    private var imageDataRequest: DataRequest?

    // ✅ Cache for reverse-geocoded strings so we don’t call CLGeocoder repeatedly
    private static var locationCache: [String: String] = [:]

    func configure(with post: Post) {

        // ✅ Username (prefer saved string on Post, fallback to user pointer)
        if let uname = post.username, !uname.isEmpty {
            usernameLabel.text = uname
        } else if let user = post.user, let u = user.username, !u.isEmpty {
            usernameLabel.text = u
        } else {
            usernameLabel.text = "Unknown"
        }

        // Image
        if let imageFile = post.imageFile,
           let imageUrl = imageFile.url {

            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                switch response.result {
                case .success(let image):
                    self?.postImageView.image = image
                case .failure(let error):
                    print("❌ Error fetching image: \(error.localizedDescription)")
                }
            }
        }

        // Caption
        captionLabel.text = post.caption

        // Date
        if let date = post.createdAt {
            dateLabel.text = date.timeAgoDisplay()
        }

        // ✅ Location (City, State)
        if let lat = post.latitude, let lon = post.longitude {

            // Use a stable cache key (rounded so close points reuse the same city/state)
            let cacheKey = String(format: "%.3f,%.3f", lat, lon)

            if let cached = PostCell.locationCache[cacheKey] {
                locationLabel.text = "📍 \(cached)"
            } else {
                locationLabel.text = "📍 Loading..."

                let location = CLLocation(latitude: lat, longitude: lon)
                CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
                    guard let self = self else { return }

                    var display = "Unknown location"

                    if error == nil, let placemark = placemarks?.first {
                        let city = placemark.locality
                        let state = placemark.administrativeArea

                        if let city = city, let state = state, !city.isEmpty, !state.isEmpty {
                            display = "\(city), \(state)"
                        } else if let city = city, !city.isEmpty {
                            display = city
                        } else if let state = state, !state.isEmpty {
                            display = state
                        }
                    }

                    // Cache the result
                    PostCell.locationCache[cacheKey] = display

                    DispatchQueue.main.async {
                        self.locationLabel.text = "📍 \(display)"
                    }
                }
            }

        } else {
            locationLabel.text = "📍 No location"
        }

        // Blur view show/hide
        if let currentUser = User.current,
           let lastPostedDate = currentUser.lastPostedDate,
           let postCreatedDate = post.createdAt,
           let diffHours = Calendar.current.dateComponents([.hour], from: postCreatedDate, to: lastPostedDate).hour {

            let twentyFourHours: TimeInterval = 24 * 60 * 60
            let lowerBound = lastPostedDate.addingTimeInterval(-twentyFourHours)
            let upperBound = lastPostedDate.addingTimeInterval(twentyFourHours)

            blurView.isHidden = (postCreatedDate >= lowerBound && postCreatedDate <= upperBound)

        } else {
            blurView.isHidden = false
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        postImageView.image = nil
        imageDataRequest?.cancel()

        // reset labels to avoid reuse glitches
        usernameLabel.text = ""
        locationLabel.text = ""
        captionLabel.text = ""
        dateLabel.text = ""
    }
}
