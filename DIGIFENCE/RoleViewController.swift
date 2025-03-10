import UIKit

class RoleViewController: UIViewController {
    @IBOutlet weak var hostButton: UIButton!
    @IBOutlet weak var guestButton: UIButton!
    
    var hostGradientLayer = CAGradientLayer()
    var guestGradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Safety check
        guard hostButton != nil && guestButton != nil else {
            print("⚠️ hostButton or guestButton is not connected in storyboard!")
            return
        }
        
        configureButton(button: hostButton, gradientLayer: &hostGradientLayer)
        configureButton(button: guestButton, gradientLayer: &guestGradientLayer)
    }
    
    private func configureButton(button: UIButton, gradientLayer: inout CAGradientLayer) {
        gradientLayer.frame = button.bounds
        gradientLayer.colors = [
            UIColor(red: 0.0, green: 25.0/255.0, blue: 54.0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 0.2, green: 50.0/255.0, blue: 90.0/255.0, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius = button.layer.cornerRadius
        
        button.layer.insertSublayer(gradientLayer, at: 0)
        button.layer.cornerRadius = button.bounds.height / 2
        button.clipsToBounds = true
    }

    @IBAction func hostButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToHostLogin", sender: self)
    }

    @IBAction func guestButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToGuestLogin", sender: self)
    }
    
}
