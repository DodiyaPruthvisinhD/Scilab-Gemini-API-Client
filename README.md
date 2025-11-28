# 🤖 Scilab-Gemini-API-Client

A robust, module-free client for accessing the Google Gemini API directly from Scilab (v6.0+ and 2024/2025).

This project resolves common issues with Scilab's strict parser and missing ATOMS toolboxes by using the host system's **`curl`** utility and custom parsing logic.

## ✨ Key Features

* **No Dependencies:** Requires only Scilab and the system `curl` (standard on Windows 10/11 and Linux).
* **Syntax-Safe:** Uses special character handling (`ascii()`) to eliminate Scilab's "Heterogeneous String" errors.
* **Model Diagnostic (Recommended):** Includes a tool (`list_models.sci`) to automatically find the valid model name for your specific API key.
* **Robust Parsing:** Custom logic to correctly extract code and text from JSON responses, ensuring readable output in the Scilab console.

## 🛠️ Setup Guide (Read Carefully!)

### 1. Download Files

Download **`ask_gemini.sci`** and **`list_models.sci`** to the same directory on your computer (e.g., `C:\Scilab_Tools`).

### 2. Get and Configure Your API Key

1.  Get your Gemini API Key from [Google AI Studio](https://aistudio.google.com/).
2.  Open **both** `ask_gemini.sci` and `list_models.sci`.
3.  Replace the placeholder `"YOUR_GEMINI_API_KEY_HERE"` with your actual key in **both files**.

### 3. Find Your Model Name (Crucial Step!)

Since model names frequently change, we must run a diagnostic to see exactly what models your key has access to (this prevents the `404 NOT_FOUND` error).

1.  Start Scilab.
2.  In the Scilab Console, navigate to the directory where you saved the files.
3.  **Execute the diagnostic script:**
    ```scilab
    exec('list_models.sci', -1);
    ```
4.  **Action:** The console will print a list of valid models (e.g., `gemini-2.5-flash`, `gemini-3.0-pro`).
5.  **Copy the name of the model you want to use.** (E.g., `gemini-2.5-flash` is a good, fast choice).

### 4. Final Configuration

1.  Open **`ask_gemini.sci`** again.
2.  Locate the line starting with `model = ...`.
3.  Update the model variable with the valid name you just copied:
    ```scilab
    // Example fix:
    model = "gemini-2.5-flash"; // <--- PASTE YOUR VALID NAME HERE
    ```
4.  Save `ask_gemini.sci`.

## 🚀 Usage

### Load the Function

Once configured, simply execute the main script:

```scilab
exec('ask_gemini.sci', -1);
