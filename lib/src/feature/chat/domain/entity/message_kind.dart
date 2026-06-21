/// The render kind of a chat message, derived in the mapper from the raw
/// Firestore `messageType` plus (for `media`) the attached media's type.
///
/// Firestore stores a smaller set of raw strings (`text`, `media`, `audio`,
/// `event`, `offer`, `purchase`, `deleted-message`); the UI needs a finer
/// split (image vs video vs file) that comes from the media payload.
enum ChatMessageKind {
  text,
  image,
  video,
  file,
  audio,
  offer,
  purchase,
  event,
  deleted,
}
