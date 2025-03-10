import UIKit
import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import CryptoKit

class SignUpViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var termsCheckBox: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var googleSignInImageView: UIImageView!
    @IBOutlet weak var appleSignInImageView: UIImageView!
    @IBOutlet weak var passwordVisibilityButton: UIButton!

    var isTermsAccepted = false
    var isPasswordVisible = false
    fileprivate var currentNonce: String?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createAccountButton.isEnabled = false  // Initially disable button
        setupGestureRecognizers()
    }

    // MARK: - Sign Up Action
    @IBAction func signUpTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let phone = phoneTextField.text, !phone.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Please enter all details")
            return
        }

        if password != confirmPassword {
            showAlert(title: "Error", message: "Passwords do not match")
            return
        }

        // Firebase Sign-Up
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(title: "Signup Failed", message: error.localizedDescription)
                return
            }

            guard let user = authResult?.user else { return }

            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Error updating profile: \(error.localizedDescription)")
                }
            }

            self.showConfirmationPopup()
        }
    }

    // MARK: - Google Sign-In
    @objc func googleSignInTapped() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard let result = signInResult else {
                self.showAlert(title: "Google Sign-In Failed", message: error?.localizedDescription ?? "Unknown error")
                return
            }

            guard let idToken = result.user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showAlert(title: "Firebase Sign-In Failed", message: error.localizedDescription)
                    return
                }
                print("Google Sign-In Successful: \(authResult?.user.email ?? "")")
                self.performSegue(withIdentifier: "goToHome", sender: self)
            }
        }
    }

    // MARK: - Apple Sign-In
    @objc func handleAppleSignIn() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // MARK: - Apple Sign-In Delegate
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }

            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data")
                return
            }

            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)

            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    self.showAlert(title: "Apple Sign-In Failed", message: error.localizedDescription)
                    return
                }
                print("Apple Sign-In Successful: \(authResult?.user.email ?? "")")
                self.performSegue(withIdentifier: "goToHome", sender: self)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        var errorMessage = "Apple Sign-In failed. Please try again."

        // Optionally: You can provide more specific messages for common error types
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                errorMessage = "Sign-in was cancelled. Please try again."
            case .failed:
                errorMessage = "Sign-in failed due to an unknown error."
            case .invalidResponse:
                errorMessage = "Received an invalid response from Apple."
            case .notHandled:
                errorMessage = "Apple Sign-In could not be handled properly."
            case .unknown:
                errorMessage = "An unknown error occurred during Apple Sign-In."
            @unknown default:
                errorMessage = "Something went wrong. Please try again later."
            }
        }

        // Show the alert pop-up
        self.showAlert(title: "Apple Sign-In Error", message: errorMessage)
    }


    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

    // MARK: - Terms & Conditions Checkbox
    @IBAction func termsCheckBoxTapped(_ sender: UIButton) {
        isTermsAccepted.toggle()
        let imageName = isTermsAccepted ? "checkmark.square.fill" : "square"
        termsCheckBox.setImage(UIImage(systemName: imageName), for: .normal)
        createAccountButton.isEnabled = isTermsAccepted
    }

    // MARK: - Password Visibility Toggle
    @IBAction func togglePasswordVisibility(_ sender: UIButton) {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        confirmPasswordTextField.isSecureTextEntry = !isPasswordVisible
        let imageName = isPasswordVisible ? "eye.fill" : "eye.slash.fill"
        passwordVisibilityButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // MARK: - Setup Gesture Recognizers
    func setupGestureRecognizers() {
        let googleTapGesture = UITapGestureRecognizer(target: self, action: #selector(googleSignInTapped))
        googleSignInImageView.isUserInteractionEnabled = true
        googleSignInImageView.addGestureRecognizer(googleTapGesture)

        let appleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAppleSignIn))
        appleSignInImageView.isUserInteractionEnabled = true
        appleSignInImageView.addGestureRecognizer(appleTapGesture)
    }

    // MARK: - Show Confirmation Pop-up
    func showConfirmationPopup() {
        let alert = UIAlertController(title: "Account Created", message: "Your account has been successfully created! Please log in with your credentials.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Show General Alerts
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Nonce Helpers for Apple Sign-In
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
