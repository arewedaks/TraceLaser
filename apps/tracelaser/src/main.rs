// No console window in release builds on Windows.
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

//! The TraceLaser program: the whole app is the `tracelaser` library; this
//! is the desktop and browser entry (the Android app loads the library).

#[cfg(not(target_arch = "wasm32"))]
fn main() -> eframe::Result<()> {
    tracelaser::run()
}

#[cfg(target_arch = "wasm32")]
fn main() {
    tracelaser::run();
}
