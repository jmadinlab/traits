json.array!(@releases) do |release|
  json.extract! release, :id, :user_id, :release_code, :release_date, :release_notes
  json.url release_url(release, format: :json)
end
