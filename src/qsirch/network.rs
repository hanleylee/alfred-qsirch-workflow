//! Qsirch HTTP client with session handling.

use crate::qsirch::error::QsirchError;
use crate::qsirch::model::LoginResult;
use crate::qsirch::tools::{assemble_url, read_session, write_session};
use reqwest::Client;
use serde::de::DeserializeOwned;
use std::collections::BTreeMap;

pub struct QsirchNetwork {
    domain: String,
    username: String,
    password: String,
    client: Client,
}

impl QsirchNetwork {
    pub fn new(domain: impl Into<String>, username: impl Into<String>, password: impl Into<String>) -> Self {
        Self {
            domain: domain.into(),
            username: username.into(),
            password: password.into(),
            client: Client::new(),
        }
    }

    pub async fn login(&self) -> Result<String, QsirchError> {
        let path = "/qsirch/latest/api/login/";
        let url = assemble_url(path, &self.domain, None).ok_or_else(|| QsirchError::InvalidUrl(path.to_string()))?;

        let body = serde_json::json!({
            "account": self.username,
            "password": self.password,
        });

        let resp = self
            .client
            .post(&url)
            .json(&body)
            .send()
            .await?;

        if !resp.status().is_success() {
            let code = resp.status().as_u16();
            let text = resp.text().await.unwrap_or_default();
            return Err(QsirchError::NetworkError {
                message: text,
                code,
            });
        }

        let result: LoginResult = resp.json().await?;
        write_session(&result.qqs_sid).map_err(|e| QsirchError::NetworkError {
            message: e.to_string(),
            code: 0,
        })?;
        Ok(result.qqs_sid)
    }

    pub async fn request<T, B>(
        &self,
        path: &str,
        params: Option<&BTreeMap<String, String>>,
        body: Option<&B>,
        method: &str,
        require_session: bool,
        _retried_login: bool,
    ) -> Result<T, QsirchError>
    where
        T: DeserializeOwned,
        B: serde::Serialize,
    {
        let mut retried = false;
        loop {
            let url = assemble_url(path, &self.domain, params).ok_or_else(|| QsirchError::InvalidUrl(path.to_string()))?;

            let mut session = if require_session { read_session() } else { None };
            if require_session && session.is_none() {
                session = Some(self.login().await?);
            }

            let mut req = match method {
                "POST" => self.client.post(&url),
                _ => self.client.get(&url),
            };
            req = req.header("Content-Type", "application/json");
            if require_session {
                if let Some(ref sid) = session {
                    req = req.header("Cookie", format!("QQS_SID={}", sid));
                }
            }
            if let Some(b) = body {
                req = req.json(b);
            }

            let resp = req.send().await?;
            let status = resp.status();
            let bytes = resp.bytes().await?;

            if status.as_u16() == 401 {
                if let Ok(obj) = serde_json::from_slice::<serde_json::Value>(&bytes) {
                    if let Some(code) = obj.get("error").and_then(|e| e.get("code")).and_then(|c| c.as_i64()) {
                        if code == 101 && !retried && require_session {
                            let _ = self.login().await;
                            retried = true;
                            continue;
                        }
                        if code == 101 {
                            return Err(QsirchError::SessionExpired);
                        }
                    }
                }
                return Err(QsirchError::NetworkError {
                    message: "Unauthorized access".to_string(),
                    code: 401,
                });
            }

            if !status.is_success() {
                return Err(QsirchError::NetworkError {
                    message: format!("HTTP error: {}", status),
                    code: status.as_u16(),
                });
            }

            return serde_json::from_slice(&bytes).map_err(|e| QsirchError::NetworkError {
                message: e.to_string(),
                code: 0,
            });
        }
    }
}
