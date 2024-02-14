## [Unreleased]

## [0.2.0] - 2024-02-14

- **BREAKING**: Changes `MemoPad::Memo#call` to `MemoPad::Memo#fetch` to more closely match interfaces like `ActiveSupport::Cache`.
- Add `#read` and `#write` methods to allow for lower-level manipulation of the cached values, similarly inspired by the interface of `ActiveSupport::Cache`.

## [0.1.0] - 2024-01-22

- Initial release
