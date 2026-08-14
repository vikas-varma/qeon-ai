# Email Agent

## User value

The Email Agent helps a user understand and respond to Gmail without surrendering control of
their mailbox.

It can:

- summarize unread, important, or selected messages;
- create a daily inbox briefing and highlight messages that need attention;
- search mail and answer questions using the user's messages;
- identify deadlines, requests, follow-ups, and possible tasks;
- prepare replies and follow-up drafts in the user's preferred tone;
- create Gmail drafts after the user asks it to do so.

## Approval policy

Reading, searching, summarizing, and preparing a response in Qeon AI do not require a separate
approval after the user connects Gmail. Sending a message always requires explicit user approval.
Deleting mail, changing security settings, forwarding sensitive content, and bulk mailbox changes
are not automated.

## Connection and data handling

Qeon AI uses Google OAuth and never asks for the user's Gmail password. The backend stores only an
encrypted refresh token and the connected email address. Disconnect revokes the Google token and
removes the stored credential. Production deployments must use HTTPS, authenticated Qeon AI user
accounts, managed secret storage, audit logs, and Google's required OAuth verification.
