//! R bindings for the `dwg2geo` conversion core (via extendr).
//!
//! The heavy lifting stays in Rust; the boundary is deliberately thin: the
//! full `EmbedResult` is serialized to a JSON string and shaped into tibbles
//! on the R side with jsonlite. Errors travel as an explicit `error` field
//! (not extendr's panic-based unwinding) so no scary Rust panic banner ever
//! reaches the user's console.

use extendr_api::prelude::*;

fn convert_inner(
    data: &[u8],
    polygonize_closed: bool,
    tolerance: Option<f64>,
) -> std::result::Result<String, String> {
    let result = dwg2geo::backend::native::convert_bytes(data, polygonize_closed, tolerance)
        .map_err(|error| format!("{error:#}"))?;
    serde_json::to_string(&result).map_err(|error| error.to_string())
}

/// Convert DWG bytes; returns list(json = <string or NULL>, error = <string or NULL>).
/// @noRd
#[extendr]
fn convert_impl(data: Raw, polygonize_closed: bool, curve_tolerance: Nullable<f64>) -> List {
    let tolerance = match curve_tolerance {
        Nullable::NotNull(value) => Some(value),
        Nullable::Null => None,
    };
    match convert_inner(data.as_slice(), polygonize_closed, tolerance) {
        Ok(json) => list!(json = json, error = NULL),
        Err(message) => list!(json = NULL, error = message),
    }
}

/// Version of the embedded conversion core (tracks the dwg2geo crate).
/// @noRd
#[extendr]
fn core_version_impl() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}

extendr_module! {
    mod dwg2geo;
    fn convert_impl;
    fn core_version_impl;
}
