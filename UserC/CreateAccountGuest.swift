import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn
import AuthenticationServices

class GuestCreateAccountViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var createAccountLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var termsCheckboxButton: UIButton!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var googleSignInImageView: UIImageView!
    @IBOutlet weak var appleSignInImageView: UIImageView!
    
    var isPasswordHidden = true
    var isTermsAgreed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
    }

    func setupGestures() {
        let googleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGoogleSignIn))
        googleSignInImageView.addGestureRecognizer(googleTapGesture)
        googleSignInImageView.isUserInteractionEnabled = true
        
        let appleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAppleSignIn))
        appleSignInImageView.addGestureRecognizer(appleTapGesture)
        appleSignInImageView.isUserInteractionEnabled = true
    }

    @IBAction func eyeButtonTapped(_ sender: UIButton) {
        isPasswordHidden.toggle()
        passwordTextField.isSecureTextEntry = isPasswordHidden
        confirmPasswordTextField.isSecureTextEntry = isPasswordHidden
        let imageName = isPasswordHidden ? "eye.slash" : "eye"
        eyeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @IBAction func termsCheckboxTapped(_ sender: UIButton) {
        isTermsAgreed.toggle()
        let imageName = isTermsAgreed ? "checkmark.square.fill" : "square"
        termsCheckboxButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @IBAction func alreadyHaveAccountTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let phone = phoneNumberTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text,
              isTermsAgreed else {
            showAlert(message: "Please fill all fields and agree to Terms & Conditions.")
            return
        }

        guard password == confirmPassword else {
            showAlert(message: "Passwords do not match.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }

            guard let uid = authResult?.user.uid else { return }
            let db = Firestore.firestore()
            db.collection("users").document(uid).setData([
                "name": name,
                "email": email,
                "phone": phone,
                "role": "guest"
            ]) { error in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                } else {
                    self.navigateToGuestHome()
                }
            }
        }
    }

    @objc func handleGoogleSignIn() {
        // Same as in GuestLoginViewController
    }

    @objc func handleAppleSignIn() {
        // Same as in GuestLoginViewController
    }

    func navigateToGuestHome() {
        // Navigate after successful account creation
        print("Guest account created successfully.")
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
}
