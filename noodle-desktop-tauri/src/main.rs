#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

mod lib;

fn main() {
    tauri::Builder::default()
        .plugin(lib::init()) // Register secure store plugin
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
