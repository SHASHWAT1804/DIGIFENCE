import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var updatePasswordButton: UIButton!
    @IBOutlet weak var passwordVisibilityButton: UIButton!

    var isPasswordVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePasswordButton.isEnabled = false  // Initially disabled
    }

    // MARK: - Send Password Reset Email
    @IBAction func resetPasswordTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty else {
            print("Enter your email")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Error sending password reset email: \(error.localizedDescription)")
                return
            }
            print("Password reset email sent successfully!")
        }
    }

    // MARK: - Update Password in Firebase
    @IBAction func updatePasswordTapped(_ sender: UIButton) {
        guard let newPassword = newPasswordTextField.text, !newPassword.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            print("Please enter new password and confirm password")
            return
        }
        
        if newPassword != confirmPassword {
            print("Passwords do not match")
            return
        }

        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }

        user.updatePassword(to: newPassword) { error in
            if let error = error {
                print("Error updating password: \(error.localizedDescription)")
                return
            }
            print("Password updated successfully!")
        }
    }

    // MARK: - Password Visibility Toggle
    @IBAction func togglePasswordVisibility(_ sender: UIButton) {
        isPasswordVisible.toggle()
        newPasswordTextField.isSecureTextEntry = !isPasswordVisible
        confirmPasswordTextField.isSecureTextEntry = !isPasswordVisible
        let imageName = isPasswordVisible ? "eye.fill" : "eye.slash.fill"
        passwordVisibilityButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}
