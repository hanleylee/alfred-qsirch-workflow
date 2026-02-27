//! Qsirch API errors.

use thiserror::Error;

#[derive(Debug, Error)]
pub enum QsirchError {
    #[error("session expired")]
    SessionExpired,

    #[error("network error: {message}, code: {code}")]
    NetworkError { message: String, code: u16 },

    #[error("request failed: {0}")]
    Request(#[from] reqwest::Error),

    #[error("invalid URL: {0}")]
    InvalidUrl(String),
}
