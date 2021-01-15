class UserService {
  bool confirmPasswordIfEqual(password, confirm) {
    return (password == confirm) ? true : false;
  }
}
