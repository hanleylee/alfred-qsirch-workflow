//! Qsirch API client for QNAP search.

mod error;
mod model;
mod network;
pub mod tools;

pub use error::QsirchError;
pub use model::{SearchResult, SearchResultItem};
pub use network::QsirchNetwork;
pub use tools::{assemble_url, session_file_path};

use std::collections::BTreeMap;

#[allow(dead_code)]
pub struct Qsirch {
    domain: String,
    username: String,
    password: String,
    network: QsirchNetwork,
}

impl Qsirch {
    pub fn new(domain: impl Into<String>, username: impl Into<String>, password: impl Into<String>) -> Self {
        let domain = domain.into();
        let username = username.into();
        let password = password.into();
        let network = QsirchNetwork::new(&domain, &username, &password);
        Self {
            domain,
            username,
            password,
            network,
        }
    }

    pub async fn search(&self, query: &str, limit: u32) -> Result<Option<SearchResult>, QsirchError> {
        let path = "/qsirch/latest/api/search";
        let mut params = BTreeMap::new();
        params.insert("limit".to_string(), limit.to_string());
        params.insert("q".to_string(), query.to_string());

        let result: model::SearchResult = self
            .network
            .request(path, Some(&params), None::<&()>, "GET", true, false)
            .await?;
        Ok(Some(result))
    }
}
