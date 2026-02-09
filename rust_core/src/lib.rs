#![allow(unexpected_cfgs)]

pub mod api;
pub mod core;
mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */

pub use api::*;
pub use core::{Dose, MarEntry, MedicationOrder};

#[cfg(test)]
mod tests {
    use super::core;

    #[test]
    fn normalizes_name() {
        assert_eq!(
            core::normalize_medication_name("Acetaminophen 500 MG".to_string()),
            "acetaminophen-500-mg"
        );
    }
}
