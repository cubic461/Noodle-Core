use tauri::{plugin::TauriPlugin, Manager, Runtime};
use std::process::Command;
use std::io::Write;
use std::fs::{self, File};
use std::path::PathBuf;

#[tauri::command]
async fn store_secure_value(key: String, value: String) -> Result<(), String> {
    let mut store = tauri_plugin_store::StoreBuilder::new("secure.store")
        .build()
        .map_err(|e| e.to_string())?;

    store.insert(key.clone(), value)
        .save()
        .await
        .map_err(|e| e.to_string())?;

    Ok(())
}

#[tauri::command]
async fn get_secure_value(key: String) -> Result<Option<String>, String> {
    let store = tauri_plugin_store::StoreBuilder::new("secure.store")
        .build()
        .map_err(|e| e.to_string())?;

    Ok(store.get(key).cloned())
}

#[tauri::command]
async fn execute_noodle(code: String) -> Result<String, String> {
    // Create a temporary file for the Noodle code
    let temp_dir = std::env::temp_dir();
    let temp_file = temp_dir.join("temp_noodle_script.nl");
    let temp_path = temp_file.to_str().ok_or("Invalid temp path")?.to_string();

    // Write the code to the temp file
    let mut file = File::create(&temp_file).map_err(|e| e.to_string())?;
    file.write_all(code.as_bytes()).map_err(|e| e.to_string())?;

    // Run the Noodle Core entry point
    // Assuming noodle-dev is in the parent directory; adjust path as needed
    let output = Command::new("python")
        .current_dir("../noodle-dev")  // Change to noodle-dev directory
        .args(&["-m", "noodle_dev.core_entry_point", &temp_path])
        .output()
        .map_err(|e| format!("Failed to execute command: {}", e))?;

    // Clean up temp file
    let _ = fs::remove_file(&temp_file);

    if output.status.success() {
        Ok(String::from_utf8_lossy(&output.stdout).to_string())
    } else {
        let stderr = String::from_utf8_lossy(&output.stderr).to_string();
        Err(format!("Execution failed: {}", stderr))
    }
}

#[tauri::command]
async fn execute_python_file(file_path: String) -> Result<String, String> {
    // Check if file exists
    if !std::path::Path::new(&file_path).exists() {
        return Err(format!("File not found: {}", file_path));
    }

    // Execute the Python file
    let output = Command::new("python")
        .arg(&file_path)
        .output()
        .map_err(|e| format!("Failed to execute Python file: {}", e))?;

    if output.status.success() {
        Ok(String::from_utf8_lossy(&output.stdout).to_string())
    } else {
        let stderr = String::from_utf8_lossy(&output.stderr).to_string();
        Err(format!("Python execution failed: {}", stderr))
    }
}

#[tauri::command]
async fn execute_noodle_file(file_path: String) -> Result<String, String> {
    // Check if file exists
    if !std::path::Path::new(&file_path).exists() {
        return Err(format!("File not found: {}", file_path));
    }

    // Create a temporary file for the Noodle code
    let temp_dir = std::env::temp_dir();
    let temp_file = temp_dir.join("temp_noodle_script.nl");
    let temp_path = temp_file.to_str().ok_or("Invalid temp path")?.to_string();

    // Read the Noodle file content
    let code = std::fs::read_to_string(&file_path)
        .map_err(|e| format!("Failed to read Noodle file: {}", e))?;

    // Write the code to the temp file
    let mut file = File::create(&temp_file).map_err(|e| e.to_string())?;
    file.write_all(code.as_bytes()).map_err(|e| e.to_string())?;

    // Run the Noodle Core entry point
    let output = Command::new("python")
        .current_dir("../noodle-dev")  // Change to noodle-dev directory
        .args(&["-m", "noodle_dev.core_entry_point", &temp_path])
        .output()
        .map_err(|e| format!("Failed to execute Noodle file: {}", e))?;

    // Clean up temp file
    let _ = fs::remove_file(&temp_file);

    if output.status.success() {
        Ok(String::from_utf8_lossy(&output.stdout).to_string())
    } else {
        let stderr = String::from_utf8_lossy(&output.stderr).to_string();
        Err(format!("Noodle execution failed: {}", stderr))
    }
}

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    tauri_plugin! {
        name: "secure_store",
        commands: [
            store_secure_value,
            get_secure_value,
            execute_noodle,
            execute_python_file,
            execute_noodle_file
        ]
    }
}
