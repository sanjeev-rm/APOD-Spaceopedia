//
//  ViewController.swift
//  APOD
//
//  Created by Sanjeev RM on 10/12/22.
//

import UIKit
import SafariServices

class ViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var copyrightLabel: UILabel!
    
    @IBOutlet weak var videoSafariButton: UIButton!
    
    let photoInfoController = PhotoInfoController()
    
    /// URL of the media in the PhotoInfo.
    var mediaUrl : URL?
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    /// this keeps track if the PhotoInfo is fetched from the internet and displayed or not.
    var isPhotoInfoFetched = false
    {
        didSet
        {
            shareButton.isEnabled = isPhotoInfoFetched
        }
    }
    
    var urlQuery : [String:String]?
    
    /// This is the activity indicator. The indetermenent loading view.
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialViewUpdate()
        
        Task
        {
            do
            {
                guard let urlQuery = urlQuery else { return }
                
                activityIndicatorView.startAnimating()
                let photoInfo = try await photoInfoController.fetchPhotoInfo(query: urlQuery)
                activityIndicatorView.stopAnimating()
                
                updateUI(with: photoInfo)
            }
            catch
            {
                updateUI(with: error)
            }
        }
    }
    
    /// This function is to update the view initially whe the info is being fetched from the internet.
    /// As it's an async function the labels must show something till the info is fetched or else it will show the default values in the storyboard.
    func initialViewUpdate()
    {
        navigationItem.title = "Fetching Photo Info..."
        descriptionTextView.text = ""
        copyrightLabel.text = ""
        isPhotoInfoFetched = false
        videoSafariButton.isHidden = true
    }
    
    /// This function is used to update the view with the instance of PhotoInfo.
    func updateUI(with photoInfo: PhotoInfo)
    {
        // Put the whole thing in the Task itself because UIImageView.image must be initialized in the maqin thread only.
        // I suppose it's something like that I'm not really sure that's what the error said.
        // Handling error here only to make the develooper's life easier.
        Task
        {
            do
            {
                if photoInfo.mediaType == "image"
                {
                    activityIndicatorView.startAnimating()
                    photoImageView.image = try await photoInfoController.fetchPhotoImage(imageUrl: photoInfo.url)
                    activityIndicatorView.stopAnimating()
                }
                else if photoInfo.mediaType == "video"
                {
                    videoSafariButton.isHidden = false
                    
                    // Presenting an AlertVC to let the user know that the media is an video not an image.
                    let alertVC = UIAlertController(title: "It's a Video", message: "Click the play button to check it out.", preferredStyle: .actionSheet)
                    let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                    alertVC.addAction(okayAction)
                    present(alertVC, animated: true, completion: nil)
                }
                
                // Setting the mediaUrl as we need to use it later in the videoSafariButtonTapped function.
                mediaUrl = photoInfo.url
                navigationItem.title = photoInfo.title
                descriptionTextView.text = photoInfo.description
                
                if let copyRight = photoInfo.copyright
                {
                    copyrightLabel.text = "?? \(copyRight)"
                }
                
                isPhotoInfoFetched = true
            }
            catch
            {
                updateUI(with: error)
            }
        }
    }
    
    /// This function is used to update the view if there's an error in fetching the info from the internet.
    func updateUI(with error: Error)
    {
        navigationItem.title = "Error Fetching Photo Info"
        photoImageView.image = UIImage(systemName: "exclamationmark.octagon")
        descriptionTextView.text = "\(error)"
        copyrightLabel.text = ""
        
        isPhotoInfoFetched = false
        activityIndicatorView.stopAnimating()
    }
    
    /// Function that is fired when the button covering the media(UIImageView) is tapped.
    @IBAction func videoSafariButtonTapped(_ sender: UIButton)
    {
        guard let videoUrl = mediaUrl else { return }
        
        // This presents safari. I wrote this. This only presents an tab. Contains an button to go to safari. This is much faster than opening safari itself with this UIApplication.shared.open(url: URL, options: [String : Any], completionHandler: ((Bool) -> Void)?) method.
        let safariVC = SFSafariViewController(url: videoUrl)
        present(safariVC, animated: true, completion: nil)
    }
    
    /// This function is fired when the share button is tapped.
    /// This function will only be firs when the button is enabled.
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem)
    {
        // If mediaUrl is nil then it means there is no media to share so just return. Unwrapping description too.
        guard let mediaUrl = mediaUrl, let description = descriptionTextView.text else { return }

        var activityItems : [Any]
        if let mediaImage = photoImageView.image
        {
            activityItems = [mediaImage, description]
        }
        else
        {
            // This means it's an video, so we'll share the url of the video.
            activityItems = [mediaUrl, description]
        }
        
        if let copyright = copyrightLabel.text
        {
            // This means that copyright is present so we'll append it also to the activityItems. We need to share that too.
            activityItems.append(copyright)
        }
        
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
}
