//! Update command: check, open, download, or update workflow.

use alfred::script_filter::{Item, ScriptFilter};
use alfred::updater::{Updater, UpdaterError};
use std::time::Duration;

use crate::common::{GITHUB_REPO, WORKFLOW_ASSET_NAME};

#[derive(Debug, Clone, Copy, clap::ValueEnum)]
pub enum UpdateAction {
    Check,
    Open,
    Download,
    Update,
}

pub async fn run(action: UpdateAction) -> Result<(), UpdaterError> {
    let updater = Updater::new(GITHUB_REPO, WORKFLOW_ASSET_NAME, Duration::from_secs(0));

    match action {
        UpdateAction::Check => {
            if let Some(release) = updater.check(None).await? {
                let current = alfred::core::AlfredConst::shared()
                    .workflow_version
                    .as_deref()
                    .unwrap_or("None");
                ScriptFilter::reset();
                ScriptFilter::item(
                    Item::new(format!("Latest version: {}", release.tag_name))
                        .subtitle(format!("Current version is {}", current)),
                );
                alfred::core::AlfredUtils::output(ScriptFilter::output());
            }
        }
        UpdateAction::Open => {
            updater.open_latest_release_page().await?;
        }
        UpdateAction::Download => {
            updater.download_latest_release(None, false).await?;
        }
        UpdateAction::Update => {
            updater.update_to_latest().await?;
        }
    }
    Ok(())
}
