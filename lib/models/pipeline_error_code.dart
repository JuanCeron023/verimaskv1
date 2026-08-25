/// Error codes returned by the pipeline when processing fails.
///
/// Screens map these codes to localized user-facing strings via l10n,
/// keeping the pipeline layer decoupled from the presentation layer.
enum PipelineErrorCode {
  captureError,
  processingError,
  certificationError,
  genericError,
}
