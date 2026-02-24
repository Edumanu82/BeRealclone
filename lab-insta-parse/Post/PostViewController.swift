//
//  PostViewController.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 11/1/22.
//

import UIKit
import PhotosUI
import ParseSwift
import CoreLocation

class PostViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: Outlets
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var previewImageView: UIImageView!

    private var pickedImage: UIImage?
    private var pickedImageData: Data?
    private var pickedMetadata: ImageMetadata?

    // MARK: Location
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuth()
    }

    private func checkLocationAuth() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            print("❌ denied/restricted")
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuth()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        print("📍", currentLocation?.coordinate.latitude ?? 0,
              currentLocation?.coordinate.longitude ?? 0)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌", error.localizedDescription)
    }

    // MARK: - Photo Library

    @IBAction func onPickedImageTapped(_ sender: UIBarButtonItem) {

        // Reset old data/metadata when picking a new image
        pickedImage = nil
        pickedImageData = nil
        pickedMetadata = nil

        var config = PHPickerConfiguration()
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Share Post

    @IBAction func onShareTapped(_ sender: Any) {

        view.endEditing(true)

        // Best-effort: refresh location right before saving (may still be nil if authorization not granted yet)
        locationManager.requestLocation()

        guard let imageData = pickedImageData
                ?? pickedImage?.jpegData(compressionQuality: 0.9) else {
            return
        }

        let imageFile = ParseFile(name: "image.jpg", data: imageData)

        var post = Post()
        post.imageFile = imageFile
        post.caption = captionTextField.text
        post.user = User.current
        post.username = User.current?.username   // <- ensure username is stored on post

        // Save location into Post (if available)
        if let loc = currentLocation {
            post.latitude = loc.coordinate.latitude
            post.longitude = loc.coordinate.longitude
        }

        // Save image metadata into Post (requires Post.swift fields exist)
        if let md = pickedMetadata {
            post.photoWidth = md.pixelWidth
            post.photoHeight = md.pixelHeight
            post.cameraMake = md.make
            post.cameraModel = md.model
            post.photoTakenAt = md.dateTimeOriginal
            print("🧾 Saving metadata:", md)
        } else {
            print("🧾 No metadata found")
        }

        post.save { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let post):
                    print(" Post Saved! \(post)")

                    // Update user's last posted date
                    if var currentUser = User.current {
                        currentUser.lastPostedDate = Date()
                        currentUser.save { [weak self] result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let user):
                                    print("User Saved! \(user)")

                                    // Notify feed that a new post was created (and user's lastPostedDate updated)
                                    NotificationCenter.default.post(name: Notification.Name("didUploadPost"), object: nil)

                                    // Return to previous screen
                                    self?.navigationController?.popViewController(animated: true)

                                case .failure(let error):
                                    self?.showAlert(description: error.localizedDescription)
                                }
                            }
                        }
                    } else {
                        // If no current user for some reason, still notify & pop
                        NotificationCenter.default.post(name: Notification.Name("didUploadPost"), object: nil)
                        self?.navigationController?.popViewController(animated: true)
                    }

                case .failure(let error):
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Camera

    @IBAction func onTakePhotoTapped(_ sender: Any) {

        // Reset old data/metadata when taking a new photo
        pickedImage = nil
        pickedImageData = nil
        pickedMetadata = nil

        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("❌📷 Camera not available")
            return
        }

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self

        present(imagePicker, animated: true)
    }

    @IBAction func onViewTapped(_ sender: Any) {
        view.endEditing(true)
    }
}

// MARK: - PHPicker Delegate

extension PostViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider else { return }

        //  Load original image DATA (preserves metadata)
        if provider.hasItemConformingToTypeIdentifier("public.image") {
            provider.loadDataRepresentation(forTypeIdentifier: "public.image") { [weak self] data, error in
                guard let self = self else { return }

                if let error = error {
                    DispatchQueue.main.async {
                        self.showAlert(description: error.localizedDescription)
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        self.showAlert(description: "No image data returned.")
                    }
                    return
                }

                self.pickedImageData = data
                self.pickedMetadata = extractMetadata(from: data)

                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self.previewImageView.image = image
                    self.pickedImage = image
                    print("🧾 Metadata:", self.pickedMetadata as Any)
                }
            }
        }
    }
}

// MARK: - UIImagePickerController Delegate

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: true)

        // Prefer original image (edited can drop metadata)
        let image = (info[.originalImage] as? UIImage) ?? (info[.editedImage] as? UIImage)

        guard let image = image else {
            print("❌📷 Unable to get image")
            return
        }

        previewImageView.image = image
        pickedImage = image

        //  Save data + metadata (best effort from camera)
        if let data = image.jpegData(compressionQuality: 1.0) {
            pickedImageData = data
            pickedMetadata = extractMetadata(from: data)
            print("🧾 Metadata:", pickedMetadata as Any)
        }
    }
}
