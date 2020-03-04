# scripts
## miscellaneous scripts
---
> cloudflare-api-update.sh

- Dynamically update DNS on cloudflare through their API.
- Uses jq and python (dirty, I know!).
- Set CONFIG values to your needs.
- Add a cronjob like this: `*/5 * * * * /usr/local/bin/cloudflare-api-update.sh`
- If the first 3 variables are set, the script tries to get the current IP from your Fritz!Box, so it doesn't need a call to ipecho.net to get it. For this to work, you'll need this tool: https://github.com/jhubig/FritzBoxShell. Please escape the password accordingly and uncomment those lines. 

This was written quick and dirty, so if you have any suggestions, please feel free to pull and modify it.
---

### License

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

- **[MIT license](http://opensource.org/licenses/mit-license.php)**
- Copyright 2020 © netphantm.
