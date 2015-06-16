json.array!(@snapshots) do |snapshot|
  json.extract! snapshot, :id, :user_id, :snapshot_code, :snapshot_date, :snapshot_notes
  json.url snapshot_url(snapshot, format: :json)
end
