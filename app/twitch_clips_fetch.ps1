$clientId = "DEINE_CLIENT_ID"
$clientSecret = "DEIN_CLIENT_SECRET"
$channelName = "bimbelbumbel123"

# === Token holen ===
$body = @{
    client_id     = $clientId
    client_secret = $clientSecret
    grant_type    = "client_credentials"
}
$tokenResponse = Invoke-WebRequest -Uri "https://id.twitch.tv/oauth2/token" `
    -Method Post `
    -Body $body `
    -ContentType "application/x-www-form-urlencoded"

$accessToken = ($tokenResponse.Content | ConvertFrom-Json).access_token

# === User-ID holen ===
$userRes = Invoke-WebRequest -Uri "https://api.twitch.tv/helix/users?login=$channelName" `
    -Headers @{
        "Client-ID" = $clientId
        "Authorization" = "Bearer $accessToken"
    }

$userId = ($userRes.Content | ConvertFrom-Json).data[0].id

# === Clips holen ===
$clipsRes = Invoke-WebRequest -Uri "https://api.twitch.tv/helix/clips?broadcaster_id=$userId&first=10" `
    -Headers @{
        "Client-ID" = $clientId
        "Authorization" = "Bearer $accessToken"
    }

$clips = ($clipsRes.Content | ConvertFrom-Json).data |
    Select-Object id, title

# === Speichern als JSON ===
$clips | ConvertTo-Json -Depth 3 | Out-File -Encoding UTF8 clips.json

Write-Host "`n✅ Fertig! Clips wurden in 'clips.json' gespeichert."
