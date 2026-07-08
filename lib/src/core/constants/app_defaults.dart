/// App-wide default values that are *stored data*, not display labels.
///
/// [kDefaultCountry] is the country value persisted on an address / profile when
/// none is provided. It is a raw data value sent to the backend — do NOT
/// localize it. (The uppercase display label used in the auth country picker is
/// a separate l10n key: `auth_country_uae`.)
const String kDefaultCountry = 'United Arab Emirates';
