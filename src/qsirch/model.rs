//! Qsirch API response models.

use serde::Deserialize;
use serde_json::Value as JsonValue;

#[derive(Debug, Clone, Deserialize)]
#[allow(dead_code)]
pub struct LoginResult {
    pub qqs_sid: String,
    pub user_name: String,
    pub is_admin: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct SearchResult {
    pub total: u64,
    pub items: Vec<SearchResultItem>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct SearchResultItem {
    pub owner: String,
    pub name: String,
    pub id: String,
    pub title: String,
    pub preview: Option<SearchResultPreview>,
    pub hidden: bool,
    pub r#type: String,
    pub size: u64,
    pub actions: SearchResultActions,
    pub path: String,
    #[serde(rename = "extension")]
    pub extension: Option<String>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct SearchResultPreview {
    pub info: Vec<SearchResultInfo>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct SearchResultInfo {
    pub key: String,
    pub display: String,
    pub value: JsonValue,
}

#[derive(Debug, Clone, Deserialize)]
pub struct SearchResultActions {
    pub download: String,
    pub open: String,
    pub share: String,
    pub icon: String,
}

impl SearchResultItem {
    /// Get file path from preview info (value of key "path").
    pub fn preview_path(&self) -> Option<String> {
        let preview = self.preview.as_ref()?;
        let path_info = preview.info.iter().find(|i| i.key == "path")?;
        path_info.value.as_str().map(String::from)
    }
}
