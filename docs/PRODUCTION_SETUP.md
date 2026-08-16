# Qeon AI production setup

This is the remaining owner-controlled setup for the production Android app and API. Never commit
service-account JSON, OAuth client secrets, refresh tokens, database passwords, or Gemini API keys.

## 1. Firebase Android authentication

1. Open Firebase Console and use the same Google Cloud project as Qeon AI.
2. Add an Android app with package name `com.qeonai.app`.
3. Add the debug SHA-1 while testing:
   `80:52:7A:6A:3F:D1:20:A7:50:1C:7A:BE:20:58:D7:0B:5D:30:3C:EC`.
4. In Firebase Authentication, enable the Google provider and save it.
5. Download the updated `google-services.json`.
6. Put it at `mobile/android/app/google-services.json`.
7. In Firebase Project settings > Service accounts, generate a private key. Keep this file private.
8. In Render, set:
   - `QEON_FIREBASE_PROJECT_ID` to the Firebase project ID.
   - `QEON_FIREBASE_CREDENTIALS_JSON` to the complete service-account JSON as one secret value.

The mobile app exchanges Google sign-in for a Firebase identity. It retrieves a current Firebase ID
token for every API request. The API verifies that token and uses its trusted Firebase UID to isolate
conversations, tasks, memories, Gmail credentials, drafts, and audit activity.

## 2. Managed PostgreSQL

1. Create a managed PostgreSQL database in the same Render region as `qeonai-api`.
2. Copy its internal database URL into the Render secret `QEON_DATABASE_URL`.
3. Redeploy the API. The backend converts a normal `postgresql://` Render URL to SQLAlchemy's
   asynchronous driver automatically.
4. The start command runs `alembic upgrade head` before starting the API.

Do not use the default SQLite database in production because files on a free web-service instance
are not durable.

## 3. Real AI provider

1. Create a server-side Gemini API key in Google AI Studio.
2. Set `QEON_GEMINI_API_KEY` as a Render secret.
3. Keep `QEON_AI_PROVIDER=gemini`.
4. Keep `QEON_GEMINI_MODEL=gemini-3.5-flash-lite` unless intentionally changing models.

The Gemini key belongs only on the backend. Never put it in the APK or a Dart define.

## 4. Gmail OAuth

Keep these Render variables configured:

- `QEON_GOOGLE_CLIENT_ID`
- `QEON_GOOGLE_CLIENT_SECRET`
- `QEON_GOOGLE_OAUTH_REDIRECT_URI=https://api.qeonai.com/api/v1/integrations/gmail/callback`
- `QEON_TOKEN_ENCRYPTION_KEY`

The Google OAuth web client must contain that exact redirect URI. Gmail connection is separate from
Qeon AI sign-in. Sending mail remains disabled until the user reviews a draft, selects the approval
checkbox, and taps **Approve and send**.

## 5. Verify the API

After Render finishes deploying, open:

- `https://api.qeonai.com/api/v1/health` — must return HTTP 200.
- `https://api.qeonai.com/api/v1/ready` — must return HTTP 200 with every check `true`.

An unauthenticated request to `https://api.qeonai.com/api/v1/users/me` must return HTTP 401.

## 6. Build and test Android

From the `mobile` directory:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Install the debug APK on a phone and test this sequence:

1. Sign in with Google.
2. Start a chat, close it, and reopen it from History.
3. Create and delete a task.
4. Connect Gmail and accept the consent screen.
5. Search and summarize mail.
6. Create a draft; confirm it does not send before approval.
7. Approve and send a message to an account you control.
8. Disconnect Gmail and confirm it shows disconnected.
9. Review Security activity and confirm no email body is displayed there.
10. Type `DELETE` in Privacy only when intentionally testing complete data deletion.

Production Play Store signing and the final release APK/AAB should be created only after the above
checks pass and the upload keystore has a secure backup.
