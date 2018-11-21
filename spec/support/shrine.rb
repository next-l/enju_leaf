AttachmentUploader.storages = {
  cache: Shrine::Storage::FileSystem.new("private", prefix: "uploads/cache"),
  store: Shrine::Storage::FileSystem.new("private", prefix: "uploads/store")
}

ImageUploader.storages = {
  cache: Shrine::Storage::FileSystem.new("private", prefix: "uploads/cache"),
  store: Shrine::Storage::FileSystem.new("private", prefix: "uploads/store")
}
