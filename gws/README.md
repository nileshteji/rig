# Google Workspace CLI Credentials

Place an exported Google Workspace CLI credentials file here as:

`gws/credentials.json`

The installer copies it to:

`~/.config/gws/credentials.json`

You can generate that file from a machine where `gws auth login` already works:

```bash
gws auth export --unmasked > gws/credentials.json
```
