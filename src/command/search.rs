//! Search command: query Qsirch and output Alfred script filter JSON.

use alfred::script_filter::{Icon, IconType, Item, Mod, ScriptFilter, Variable};
use alfred::updater::{version_compare, Updater};
use std::collections::BTreeMap;
use std::process::Command;
use std::time::Duration;

use crate::common::{aligned_subtitle, format_bytes, GITHUB_REPO, WORKFLOW_ASSET_NAME};
use crate::qsirch::{Qsirch, QsirchError};
use crate::qsirch::tools::assemble_url;

pub async fn run(
    domain: String,
    username: String,
    password: String,
    limit: u32,
    query: String,
) {
    ScriptFilter::reset();
    if domain.is_empty() || username.is_empty() || password.is_empty() {
        ScriptFilter::item(
            Item::new("Configure workflow")
                .subtitle("Set domain, username and password in workflow environment variables"),
        );
        alfred::core::AlfredUtils::output(ScriptFilter::output());
        return;
    }
    let qsirch = Qsirch::new(&domain, &username, &password);

    match qsirch.search(&query, limit).await {
        Ok(Some(result)) => {
            add_results_to_alfred(&result, &domain);
            let updater = Updater::new(
                GITHUB_REPO,
                WORKFLOW_ASSET_NAME,
                Duration::from_secs(60 * 60 * 24),
            );
            let current = alfred::core::AlfredConst::shared().workflow_version.as_deref();
            if let Ok(Some(cached)) = updater.read_cached_release().await {
                if let Some(cur) = current {
                    if version_compare(cur, &cached.tag_name).is_lt() {
                        ScriptFilter::item(
                            Item::new("New version available on GitHub, type [Enter] to update")
                                .subtitle(format!(
                                    "current version: {}, remote version: {}",
                                    cur, cached.tag_name
                                ))
                                .arg("update")
                                .variable(Variable::new(
                                    Some("HAS_UPDATE".to_string()),
                                    Some("1".to_string()),
                                )),
                        );
                    }
                }
            }
            alfred::core::AlfredUtils::output(ScriptFilter::output());

            if let Ok(Some(cached)) = updater.read_cached_release().await {
                if !updater.cache_valid(&cached) {
                    alfred::core::AlfredUtils::log("cache invalid");
                    spawn_background_update_check();
                }
            }
        }
        Ok(None) => {}
        Err(QsirchError::SessionExpired) => {
            alfred::core::AlfredUtils::log("Session expired. Please re-login.");
        }
        Err(QsirchError::NetworkError { message, code }) => {
            alfred::core::AlfredUtils::log(format!("Network error: {}, code: {}", message, code));
        }
        Err(e) => {
            alfred::core::AlfredUtils::log(format!("Unexpected error: {}", e));
        }
    }
}

fn add_results_to_alfred(result: &crate::qsirch::SearchResult, domain: &str) {
    if result.items.is_empty() {
        ScriptFilter::item(
            Item::new("No matched")
                .subtitle(format!("There is no matched file in your QNAP: {}", domain))
                .arg("empty"),
        );
        return;
    }
    for item in &result.items {
        let path_in_mac = match item.preview_path() {
            Some(p) => format!("/Volumes/{}", p),
            None => continue,
        };
        let size_str = format_bytes(item.size, 2, 1000.0);
        let subtitle = aligned_subtitle(&path_in_mac, &size_str);
        let icon = Icon::new(path_in_mac.clone(), Some(IconType::Fileicon));
        let mut fs_params = BTreeMap::new();
        fs_params.insert("path".to_string(), item.path.clone());
        let fname = item
            .extension
            .as_ref()
            .map_or(item.name.clone(), |ext| format!("{}.{}", item.name, ext));
        fs_params.insert("file".to_string(), fname);
        let file_station_url = assemble_url("/filestation/", domain, Some(&fs_params));
        let download_url = assemble_url(&item.actions.download, domain, None);

        let alfred_item = Item::new(item.title.clone())
            .subtitle(subtitle)
            .arg(path_in_mac.clone())
            .icon(icon)
            .quicklookurl(path_in_mac.clone())
            .cmd(Mod::new().subtitle("Reveal file in Finder").arg(path_in_mac.clone()))
            .alt(Mod::new().subtitle("Download file").arg(download_url.unwrap_or_default()))
            .ctrl(Mod::new().subtitle("Open file in FileStation").arg(file_station_url.unwrap_or_default()));
        ScriptFilter::item(alfred_item);
    }
}

fn spawn_background_update_check() {
    let exe = std::env::current_exe().ok();
    if let Some(exe) = exe {
        let _ = Command::new("/usr/bin/nohup")
            .arg(exe)
            .arg("update")
            .arg("--action")
            .arg("check")
            .stdout(std::process::Stdio::null())
            .stderr(std::process::Stdio::null())
            .spawn();
        alfred::core::AlfredUtils::log("Update check completed in the background");
    }
}
