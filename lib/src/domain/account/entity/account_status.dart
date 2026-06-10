/// The resolved session integrity of the current user, computed at app start
/// (and re-checked at action gates). Drives routing and action-gating:
///
/// - [guest] — no Firebase user (`AuthRepository.currentUserId == null`).
///   Allowed on public/browse routes; gated at actions (wishlist, follow, sell).
/// - [legacy] — a Firebase user exists but the Klozy backend has no usable
///   profile (`GET /v1/me` 404/empty) OR the Firebase user is anonymous.
///   Routing signs out and returns to Welcome (with a "continue as guest" path).
/// - [incompleteOnboarding] — authenticated and a backend profile exists, but
///   `MeProfile.isProfileComplete == false`. Routing resumes onboarding.
/// - [valid] — authenticated with a complete profile. Full access.
enum AccountStatus { guest, legacy, incompleteOnboarding, valid }
