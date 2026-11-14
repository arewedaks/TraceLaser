//! The app's own source, compiled alone (see Cargo.toml).
#[cfg(windows)]
#[path = "../../../../apps/tracelaser/src/spell_windows.rs"]
#[allow(dead_code)]
mod spell_windows;

/// Open drawings keep their files (#2130): a held file cannot be deleted
/// or renamed and is still saved, on a real Windows.
#[path = "../../../../apps/tracelaser/src/file_hold.rs"]
#[allow(dead_code)]
mod file_hold;
