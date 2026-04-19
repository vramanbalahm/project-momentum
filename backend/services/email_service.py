import smtplib
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

GMAIL_USER = os.getenv("GMAIL_USER", "vramanbala@gmail.com")
GMAIL_APP_PASSWORD = os.getenv("GMAIL_APP_PASSWORD", "")


def send_otp_email(to_email: str, otp: str, user_name: str = "") -> bool:
    """
    Send OTP email via Gmail SMTP.
    Returns True on success, False on failure.
    """
    if not GMAIL_APP_PASSWORD:
        print("[email_service] GMAIL_APP_PASSWORD not set — skipping email send")
        return False

    subject = "Your Momentum verification code"
    greeting = f"Hi {user_name}," if user_name else "Hi,"

    body_html = f"""
    <div style="font-family: system-ui, sans-serif; max-width: 480px; margin: 0 auto;">
      <div style="background: #1A3A2E; padding: 24px; border-radius: 16px 16px 0 0; text-align: center;">
        <div style="font-size: 28px;">🌿</div>
        <div style="color: #FDFCF8; font-size: 18px; font-weight: 500; margin-top: 6px;">Momentum</div>
      </div>
      <div style="background: #FFF9F2; padding: 28px 24px; border-radius: 0 0 16px 16px;">
        <p style="color: #2C2C2A; font-size: 15px;">{greeting}</p>
        <p style="color: #2C2C2A; font-size: 14px;">Use the code below to verify your email address.</p>
        <div style="background: #E1F5EE; border-radius: 12px; padding: 20px; text-align: center; margin: 20px 0;">
          <div style="font-size: 36px; font-weight: 700; letter-spacing: 10px; color: #1A3A2E;">{otp}</div>
        </div>
        <p style="color: #888780; font-size: 12px;">This code expires in 5 minutes. Do not share it with anyone.</p>
      </div>
    </div>
    """

    msg = MIMEMultipart("alternative")
    msg["Subject"] = subject
    msg["From"] = f"Momentum <{GMAIL_USER}>"
    msg["To"] = to_email
    msg.attach(MIMEText(body_html, "html"))

    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
            server.login(GMAIL_USER, GMAIL_APP_PASSWORD)
            server.sendmail(GMAIL_USER, to_email, msg.as_string())
        print(f"[email_service] OTP sent to {to_email}")
        return True
    except Exception as e:
        print(f"[email_service] Failed to send email: {e}")
        return False
