/// Stages of the capture-and-certify pipeline.
///
/// Used to provide step-by-step progress feedback to the user
/// during photo processing via a callback.
enum PipelineStage {
  processingPhoto,
  certifying,
}
