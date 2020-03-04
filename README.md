# scripts
## miscellaneous scripts

---
### cloudflare-api-update.sh

- Dynamically update DNS on cloudflare through their API.
- Uses jq and python (dirty, I know!).
- Set CONFIG values to your needs.
- If the first 3 variables are set, the script tries to get the current IP from your Fritz!Box,
 so it doesn't need a call to ipecho.net to get it.
 For this to work, you'll need this tool: https://github.com/jhubig/FritzBoxShell.
 Please escape the password accordingly and uncomment those lines.
---
