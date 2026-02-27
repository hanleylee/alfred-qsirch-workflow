//! Shared constants and helpers.

/// Format byte size to human-readable string (B, KB, MB, GB, ...).
pub fn format_bytes(bytes: u64, decimals: usize, kilo: f64) -> String {
    if bytes == 0 {
        return "0 B".to_string();
    }
    let units = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    let bytes_f: f64 = bytes as f64;
    let unit_index = (bytes_f.ln() / kilo.ln()) as usize;
    let unit_index = unit_index.min(units.len() - 1);
    let value = bytes_f / kilo.powi(unit_index as i32);
    let s = format!("{:.prec$} {}", value, units[unit_index], prec = decimals);
    s.replace(".00 ", " ")
}

/// Subtitle with left and right aligned text (left ... right).
pub fn aligned_subtitle(left: &str, right: &str) -> String {
    const WIDTH: usize = 80;
    let left_len = left.chars().count();
    let right_len = right.chars().count();
    if left_len + 1 + right_len <= WIDTH {
        let pad = WIDTH - left_len - right_len;
        format!("{}{}{}", left, " ".repeat(pad), right)
    } else {
        format!("{}  {}", left, right)
    }
}

pub const GITHUB_REPO: &str = "hanleylee/alfred-qsirch-workflow";
pub const WORKFLOW_ASSET_NAME: &str = "Qsirch.alfredworkflow";
