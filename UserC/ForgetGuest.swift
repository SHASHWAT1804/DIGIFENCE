import UIKit
import FirebaseAuth

class GuestForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    
    var isPasswordHidden = true

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func eyeButtonTapped(_ sender: UIButton) {
        isPasswordHidden.toggle()
        newPasswordTextField.isSecureTextEntry = isPasswordHidden
        confirmPasswordTextField.isSecureTextEntry = isPasswordHidden
        let imageName = isPasswordHidden ? "eye.slash" : "eye"
        eyeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @IBAction func resetPasswordTapped(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let newPassword = newPasswordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
            showAlert(message: "Please fill in all fields.")
            return
        }

        guard newPassword == confirmPassword else {
            showAlert(message: "Passwords do not match.")
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
            self.showAlert(message: "Password reset link sent to your email.")
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
}
