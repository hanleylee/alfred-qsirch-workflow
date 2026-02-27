//! Alfred Qsirch Workflow — search QNAP via Qsirch API.
//!
//! Subcommands: search, update.

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "alfred-qsirch")]
#[command(about = "Tool used for connecting alfred with Qsirch")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Perform a search query on QNAP
    Search {
        #[arg(long, env = "ALFRED_QNAP_DOMAIN", default_value = "")]
        domain: String,

        #[arg(long, env = "ALFRED_QNAP_USERNAME", default_value = "")]
        username: String,

        #[arg(long, env = "ALFRED_QNAP_PASSWORD", default_value = "")]
        password: String,

        #[arg(long, default_value = "50", help = "Max count of results")]
        limit: u32,

        #[arg(default_value = "example", help = "Query content")]
        name: String,
    },

    /// Update workflow
    Update {
        #[arg(long, value_enum, default_value = "check")]
        action: alfred_qsirch::command::UpdateAction,
    },
}

#[tokio::main]
async fn main() {
    let cli = Cli::parse();
    match cli.command {
        Commands::Search {
            domain,
            username,
            password,
            limit,
            name,
        } => {
            alfred_qsirch::command::run_search(domain, username, password, limit, name).await;
        }
        Commands::Update { action } => {
            if let Err(e) = alfred_qsirch::command::run_update(action).await {
                eprintln!("update error: {}", e);
                std::process::exit(1);
            }
        }
    }
}
