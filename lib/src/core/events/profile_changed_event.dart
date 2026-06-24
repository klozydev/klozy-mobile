/// Fired after the current user completes onboarding or edits their profile.
///
/// Listeners (the Profile tab, the Chat repository's cached name/avatar) reload
/// so they reflect the fresh first/last name, avatar and address immediately.
class ProfileChangedEvent {
  const ProfileChangedEvent();
}
