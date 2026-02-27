//! URL and session helpers for Qsirch API.

use std::collections::BTreeMap;

/// Build full URL from domain, path and optional query params.
pub fn assemble_url(path: &str, domain: &str, params: Option<&BTreeMap<String, String>>) -> Option<String> {
    let base = domain.trim_end_matches('/');
    let path = path.trim_start_matches('/');
    let mut url = format!("{}/{}", base, path);
    if let Some(params) = params {
        if !params.is_empty() {
            let query: Vec<String> = params
                .iter()
                .map(|(k, v)| format!("{}={}", urlencoding::encode(k), urlencoding::encode(v)))
                .collect();
            url.push('?');
            url.push_str(&query.join("&"));
        }
    }
    Some(url)
}

/// Session file path under Alfred workflow data (or current dir).
pub fn session_file_path() -> std::path::PathBuf {
    let dir = std::env::var("alfred_workflow_data").unwrap_or_else(|_| ".".to_string());
    std::path::PathBuf::from(dir).join("qsirch_session.txt")
}

pub fn read_session() -> Option<String> {
    let path = session_file_path();
    std::fs::read_to_string(&path).ok().map(|s| s.trim().to_string()).filter(|s| !s.is_empty())
}

pub fn write_session(sid: &str) -> std::io::Result<()> {
    let path = session_file_path();
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent)?;
    }
    std::fs::write(&path, sid)
}
