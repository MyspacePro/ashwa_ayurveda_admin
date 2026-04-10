class Validators {
  // =========================
  // EMAIL VALIDATION
  // =========================
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return "Enter a valid email";
    }

    return null;
  }

  // =========================
  // PASSWORD VALIDATION
  // =========================
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }

    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
  }

  // Strong password (for admin/security)
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }

    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }

    final hasUpper = value.contains(RegExp(r'[A-Z]'));
    final hasLower = value.contains(RegExp(r'[a-z]'));
    final hasNumber = value.contains(RegExp(r'[0-9]'));
    final hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUpper || !hasLower || !hasNumber || !hasSpecial) {
      return "Password must include upper, lower, number & special character";
    }

    return null;
  }

  // =========================
  // REQUIRED FIELD
  // =========================
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  // =========================
  // PHONE VALIDATION (INDIA READY)
  // =========================
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }

    final phoneRegex = RegExp(r'^[6-9]\d{9}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return "Enter valid 10-digit Indian number";
    }

    return null;
  }

  // =========================
  // PRICE VALIDATION
  // =========================
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Price is required";
    }

    final number = double.tryParse(value);
    if (number == null) {
      return "Enter valid number";
    }

    if (number <= 0) {
      return "Price must be greater than 0";
    }

    return null;
  }

  // =========================
  // QUANTITY VALIDATION
  // =========================
  static String? quantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Quantity is required";
    }

    final number = int.tryParse(value);
    if (number == null) {
      return "Enter valid quantity";
    }

    if (number < 0) {
      return "Quantity cannot be negative";
    }

    return null;
  }

  // =========================
  // NAME VALIDATION
  // =========================
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }

    if (value.trim().length < 2) {
      return "Name too short";
    }

    final nameRegex = RegExp(r"^[a-zA-Z\s]+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return "Only letters allowed";
    }

    return null;
  }

  // =========================
  // URL VALIDATION
  // =========================
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "URL is required";
    }

    final urlRegex = RegExp(
      r'^(http|https):\/\/([\w\-]+\.)+[\w\-]+(\/[\w\- ./?%&=]*)?$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return "Enter valid URL";
    }

    return null;
  }

  // =========================
  // CONFIRM PASSWORD
  // =========================
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return "Confirm password is required";
    }

    if (value != originalPassword) {
      return "Passwords do not match";
    }

    return null;
  }

  // =========================
  // MIN LENGTH VALIDATION
  // =========================
  static String? minLength(String? value, int min, String fieldName) {
    if (value == null || value.isEmpty) {
      return "$fieldName is required";
    }

    if (value.length < min) {
      return "$fieldName must be at least $min characters";
    }

    return null;
  }

  // =========================
  // MAX LENGTH VALIDATION
  // =========================
  static String? maxLength(String? value, int max, String fieldName) {
    if (value != null && value.length > max) {
      return "$fieldName cannot exceed $max characters";
    }
    return null;
  }
}