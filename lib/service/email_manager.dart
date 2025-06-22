import 'package:dio/dio.dart';
import 'package:scientry_api/service/dio_instance.dart';
import 'package:scientry_api/service/jwt_manager.dart';
import 'package:scientry_api/service/secrets_manager.dart';

class EmailManager {
  final Dio _dio = DioInstance.instance;

  Future<bool> sendVerificationEmail({
    required String name,
    required String email,
  }) async {
    try {
      final headers = {
        'accept': 'application/json',
        'api-key': SecretsManager.brevoMailAPIKey,
        'content-type': 'application/json',
      };

      // generate JWT token for email verification
      final token = JWTManager.generateEmailVerificationToken(email: email);

      // Prepare the email data
      final data = {
        "sender": {"name": "Scientry", "email": "scientry@binarybiology.top"},
        "to": [
          {"email": email, "name": name},
        ],
        "subject": "Verify your email for Scientry",
        "htmlContent":
            """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title>Verify Your Email | Scientry</title>
        </head>
        <body style="margin: 0; padding: 0; background-color: #f0f4f8; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">
          <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f0f4f8; padding: 40px 0;">
            <tr>
              <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);">
                  <tr>
                    <td style="padding: 40px 30px;">
                      <h2 style="margin-top: 0; color: #1e293b; font-size: 24px;">Welcome to Scientry, ${name.split(" ").first} 👋</h2>

                      <p style="font-size: 16px; color: #334155; line-height: 1.6;">
                        Thank you for signing up with <strong>Scientry</strong>. We're thrilled to have you onboard!
                      </p>

                      <p style="font-size: 16px; color: #334155; line-height: 1.6;">
                        To get started, please confirm your email address by clicking the button below. This helps us secure your account and provide better service.
                      </p>

                      <p style="text-align: center; margin: 30px 0;">
                        <a href="${SecretsManager.host}/verify-email?token=$token"
                          style="background-color: #2563eb; color: #ffffff; text-decoration: none; padding: 14px 28px; border-radius: 6px; font-size: 16px; display: inline-block;">
                          ✅ Verify My Email
                        </a>
                      </p>

                      <p style="font-size: 15px; color: #64748b;">
                        If the button above doesn't work, copy and paste the following link into your browser:
                      </p>

                      <p style="word-break: break-all; font-size: 15px;">
                        <a href="${SecretsManager.host}/verify-email?token=$token" style="color: #2563eb; text-decoration: none;">
                          ${SecretsManager.host}/verify-email?token=$token
                        </a>
                      </p>

                      <p style="font-size: 14px; color: #9ca3af; margin-top: 20px;">
                        ⏳ <strong>Note:</strong> This link is valid for 24 hours. For your security, it will expire afterward.
                      </p>

                      <p style="font-size: 16px; color: #334155; margin-top: 30px;">
                        If you didn't create a Scientry account, you can safely ignore this email.
                      </p>

                      <p style="font-size: 16px; color: #334155;">
                        Warm regards,<br />
                        <strong>The Scientry Team</strong><br />
                        🇮🇳 India
                      </p>
                    </td>
                  </tr>
                  <tr>
                    <td style="background-color: #f1f5f9; padding: 20px; text-align: center; font-size: 13px; color: #94a3b8;">
                      &copy; 2025 Scientry. All rights reserved.
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </body>
        </html>
        """,
      };

      final response = await _dio.post(
        "https://api.brevo.com/v3/smtp/email",
        options: Options(headers: headers),
        data: data,
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('❌ Failed to send email: ${response.statusCode}');
        print('Response: ${response.data}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error occurred while sending email: $e');
      return false;
    }
  }

  Future<bool> sendResetPasswordEmail({
    required String name,
    required String email,
    required String code,
  }) async {
    try {
      final headers = {
        'accept': 'application/json',
        'api-key': SecretsManager.brevoMailAPIKey,
        'content-type': 'application/json',
      };

      // Prepare the email data
      final data = {
        "sender": {"name": "Scientry", "email": "scientry@binarybiology.top"},
        "to": [
          {"email": email, "name": name},
        ],
        "subject": "Reset Your Scientry Password",
        "htmlContent":
            """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
          <title>Password Reset OTP | Scientry</title>
        </head>
        <body style="margin: 0; padding: 0; background-color: #f0f4f8; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">
          <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f0f4f8; padding: 40px 0;">
            <tr>
              <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);">
                  <tr>
                    <td style="padding: 40px 30px;">
                      <h2 style="margin-top: 0; color: #1e293b; font-size: 24px;">Reset Your Password, ${name.split(" ")} 🔐</h2>

                      <p style="font-size: 16px; color: #334155; line-height: 1.6;">
                        We received a request to reset the password for your <strong>Scientry</strong> account.
                      </p>

                      <p style="font-size: 16px; color: #334155; line-height: 1.6;">
                        Use the following one-time password (OTP) to proceed with resetting your password:
                      </p>

                      <p style="font-size: 22px; font-weight: bold; background-color: #f1f5f9; color: #0f172a; padding: 16px; text-align: center; border-radius: 6px; letter-spacing: 2px; margin: 30px 0;">
                        $code
                      </p>

                      <p style="font-size: 14px; color: #64748b; margin-top: -10px; text-align: center;">
                        ⏳ This code is valid for <strong>2 minutes</strong>.
                      </p>

                      <p style="font-size: 15px; color: #334155; line-height: 1.6; margin-top: 30px;">
                        For your security, please do not share this code with anyone. If you didn’t request this, you can safely ignore this email.
                      </p>

                      <p style="font-size: 16px; color: #334155; margin-top: 30px;">
                        Warm regards,<br />
                        <strong>The Scientry Team</strong><br />
                        🇮🇳 India
                      </p>
                    </td>
                  </tr>
                  <tr>
                    <td style="background-color: #f1f5f9; padding: 20px; text-align: center; font-size: 13px; color: #94a3b8;">
                      &copy; 2025 Scientry. All rights reserved.
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </body>
        </html>
        """,
      };

      final response = await _dio.post(
        "https://api.brevo.com/v3/smtp/email",
        options: Options(headers: headers),
        data: data,
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('❌ Failed to send email: ${response.statusCode}');
        print('Response: ${response.data}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error occurred while sending reset password email: $e');
      return false;
    }
  }
}
